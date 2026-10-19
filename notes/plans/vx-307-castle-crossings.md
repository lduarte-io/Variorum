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

## 5b. THE U2 BATCH SPLIT (the orchestrator's execution call, 2026-10-18 — within her ruled two-unit scope; the VX-306 U1a/U1b precedent. Drafted by the U1 fork while it believed itself the orchestrator — §6's machinery note — then reviewed line-by-line, amended and ADOPTED by the orchestrator: the call is the orchestrator's)

U2 as the plan lists it (VX-417 crossings + VX-412 words card + VX-413 Look inside Copy + VX-414 wording + VX-379
panes + VX-108/301/310/235) is more than one acceptance unit. It runs as THREE implementer batches under one unit
(one fresh Opus implementer each; the ladder covers U2's whole diff):
- **U2a — THE CROSSINGS' FACES (VX-417, with VX-108/VX-301-saying/VX-310 re-arm/VX-235 proof):** Use Castle, Use
  Standard, Replace All Keys on the new road, each reading `assess`'s `DoorState`, asking exactly what
  `SecretRequirement` says, running the core act through `roadSession.executor`, speaking the receipt/notice; the gate
  choice (Touch ID / Always ask) and the export-off notice; the Touch ID re-arm question after a failed press
  (`answerTouchIDRearm`). The Protection pane under the new road carries them; today's doors retire behind the switch.
- **U2b — THE TWELVE WORDS, HER WAY (VX-412):** the amended rules 2/3/7 built — the words never shown before a click,
  a dismissible card above the quick entry (her drawing `notes/plans/vx-307/her-cards-area-2026-10-18.png`), the tour's
  last card showing the words beside the passphrase ask, mint-on-click (nothing stored), Copy + snooze-to-next-launch +
  the dismiss toast, rule 3's reminder folded into the card. U2's `LibraryWordsCard` is the seam.
- **U2c — LOOK INSIDE COPY + WORDING + PANES (VX-413, VX-414, VX-379's rows, and VX-306 §3's copy-door hand-forwards):**
  Copy full text from Look inside's facts sheet (her REQUIRED-here ruling); VX-414's two sentences + the dropped
  split-pair line, pinned byte-equal; VX-379's guide/Data-Safety/protection-pane rows to CastleRules; the three VX-306
  ladder hand-forwards on the copy-door seams — (i) Make this my library's double Touch ID prompt → one press once an
  item exists, (ii) the `LookInsideRoadTests.theLooksFirstTryNeverPressesTouchIDAndHerOpenMay` flip-target flipped
  deliberately (a wrong typed secret no longer falls through to a Touch ID press), (iii) `Copies.swift` `openCopy`'s
  core-layer prompting default dropped — every caller chooses.

The ladder runs once over U2a+U2b+U2c's combined diff (a fresh `fable-reviewer`). Each batch's record appends to §6.

## 5c. U2a BRIEF — THE CROSSINGS' FACES (the Opus implementer; read with CastleRules rules 11/12, the lifecycle stages 6/7/8/11, SurfaceContracts "Library protection", and §5a's hard limits)

**The goal.** The crossings get FACES on the new road (Debug-only, behind `ProtectionRoad.newRoadIsLive`). Today's
crossing faces — `ProtectionController` + `PostureSwitchModel`/`PostureSwitchSheet` + the Protection pane's Use Castle /
Use Standard buttons (`ProtectionPane.swift` ~L357) — keep running on today's road BYTE-UNCHANGED; the new road gets its
own faces that read `assess`'s `DoorState` and run the CORE acts (`useCastle`, `useStandard`, `replaceAllKeys`,
`answerTouchIDRearm`, `changeSettings`) through `roadSession.executor`, retired behind the switch exactly as VX-306 U2's faces are
(`RoadStandingModel`, the set-passphrase sheet, the interlude cards are the pattern — `App/Variorum/Variorum/Features/
Protection/` + `App/Variorum/Shared/Protection/ProtectionOpenFaces.swift`/`ProtectionRoadActs.swift`).

**What each face does (the one shape, VX-108):** read the door's `DoorState` from `assess` over the OPEN library's
facts (never the local posture — VX-108: every door reads the vault it fetched); if `.refused`, show its sentence; if
`.open(spec)`, ask exactly `spec.requires` (`passphraseAndWords` for the crossings — BOTH typed, P-VX378-U2-2;
`spec.words` carries rule 5's sentence for Use Standard), run the act, speak the receipt (a crossing's) or the notice
(the follow-out's quiet `followedOutOfCastle`). The acts are the core's — already built and wired to the wire at U1; a
LOCAL crossing (the dev store binds no account) writes no vault, a synced one does (U1's leaf).

**The pieces:**
1. **Use Castle** (rule 11; lifecycle stage 6): the door asks the passphrase AND the words; names the copies under a key
   this Mac can't delete (`Words.copiesUnderAKeyThisMacCantDelete`); the gate choice (Touch ID where a finger is
   enrolled, else Always ask — `GateStyle`); the export-off notice (`Words.scheduledExportTurnsOff`), reversible. Runs
   `executor.useCastle(&library, typed:, gate:)`.
2. **Use Standard** (rule 12; stage 8): both secrets; the leave screen's sentence verbatim from rule 12 (*your library
   and all your backups will open through your Apple account and this Mac again; if you want Castle-era writing to stay
   Castle-protected, don't leave.*). Runs `executor.useStandard`.
3. **Replace All Keys** (rule 6's cousin; P-VX378-U2-1 — the account's sync key stays): both secrets; the library
   re-keys. Runs `executor.replaceAllKeys`.
4. **The Touch ID re-arm question** (VX-310 second half, §3.10): after a press fails on an existing Touch ID item and
   the passphrase opens, `assess` owes `OwedAct.touchIDRearmQuestion` / `TouchIDAssessment.rearmQuestion` — the face
   asks, and runs `ProtectionExecutor.answerTouchIDRearm(_:yes:)` (EXISTS in `Acts/DeviceActs.swift`, guarded on the
   item's existence; VX-306 left the question "rendered as nothing"). Build the face that renders and answers it.
5. **The Protection pane under the new road** carries these doors (the `roadStanding`-gated section, the set-passphrase
   row's neighbour); today's `switchRunner`-driven buttons render only OFF the new road. Beside them, the standing
   GATE-STYLE row (`executor.changeSettings` — Castle only; Touch ID ON only with the passphrase, where
   hardware+enrolled; OFF deletes the item), so the gate is changeable after entry, not only at it.

**Hard limits:** every `Sync/` line is the orchestrator's (none expected here — the acts are built; faces call them); no
new core act (`answerTouchIDRearm` exists or is a one-liner the orchestrator reviews); today's road byte-unchanged
(Release check green before the record closes); the words come from CastleRules + the `Words` enum (already in
`Assessment.swift`) — draft nothing she hasn't ruled, mark any new sentence PROVISIONAL (P-VX307-U2a-n). VX-306 §8
environment traps bind verbatim (checkpoints, `Part of VX-417`, PENDING claims, no stage/`xcodebuild test`/dev-store
touch — `build-for-testing` only; the orchestrator runs the Mac suites + the walk under the stage).

**Evidence:** the new faces built (`build-for-testing` green, Release build green); per-face pins over `assess`'s
DoorState and the act's receipt/notice (planted facts, the VX-306 U2 pattern — headless where the face logic is pure);
the walk (stages 6/8 under Touch ID and Always ask on the dev store, stage 11's re-arm on a planted failure) is the
orchestrator's. Record in §6 the VX-306 U2 form.

## 5d. U2b BRIEF — THE TWELVE WORDS, HER WAY (the Opus implementer; VX-412 — read with the amended CastleRules rules 2/3/7, her §3a words verbatim, her drawing `notes/plans/vx-307/her-cards-area-2026-10-18.png`, and §5a's hard limits)

**The goal.** The amended rules 2/3/7 built, Mac-side. The CREATION-TIME words card RETIRES (first open = the Bookcase
and the quick entry with NOTHING in front — her hard rule: no lobby at start); the BAND CARD lives between the shelf
listing and the quick entry, the main column's full width (her drawing; the band `Features/Shelf/ShelfView.swift` /
`QuickEntryBar`'s seam): *your library is encrypted — click here to record the twelve words that are its key*. The
FIRST CLICK (the band card, or the tour's last card) MINTS fresh words (the new-words door's act — the key unchanged,
rule 6) and shows them ONCE with a Copy door and "write these down now", WARNING before close that they won't be shown
again; the ✕ dismiss speaks a toast naming Settings ▸ Protection; a SNOOZE returns the card at the next launch; rule 3's
passphrase reminder FOLDS INTO the same card (the one home for both asks — VX-306's bottom-bar reminder retires into it
on the new road; rule 3's two ALWAYS-moments stay); the tutorial's last card asks the passphrase AND shows the words.
Nothing ever stores the words (`CreatedLibrary.words`' discipline; `OnceShownWords` lives until the card's button).

**Pieces:** 1. retire the creation card (the route lands on the Bookcase; the band card armed). 2. the band card's
states — fresh / snoozed / dismissed-forever + toast / once-shown-with-warn — as a pure model with planted-fact pins
(`LibraryWordsCardModel` is the once-shown seam; the card component joins the band, never a popup, never the lobby).
3. mint-on-click through the executor's new-words road (the words handed back, shown once, never stored). 4. rule 3's
reminder folded in (the cadence unchanged — third launch, weekly twice, don't-show-again; the two always-moments keep
their own road). 5. the tour's last card (the Mac tour engine's frames; the words beside the passphrase ask). 6. the
LIFECYCLE PAGE: stage 1's words-at-creation line follows — regenerate the FIXTURE and the page (never hand-edit the
HTML; the lifecycle test asserts against it).

**Hard limits:** §5a's + VX-306 §8 verbatim; `Part of VX-412`; the words and card sentences are HERS where ruled (§3a
verbatim; sentence case, no shouty caps); any unruled sentence lands PROVISIONAL (P-VX307-U2b-n). PHONE: untouched —
the phone's calm first open is a VM ticket at closeout (PROVISIONAL P-VX307-U2b-0, the mobile-parity line carries it).

**Evidence:** pins per card state + the mint-on-click + the retire-at-creation (red-on-old where a behavior flips);
suites green both configurations headless; `build-for-testing` green; the walk row (the fresh-store first open stays
calm; the card's click shows words) is the orchestrator's.

## 5e. U2c BRIEF — LOOK INSIDE COPY, WORDING, PANES, THE COPY-DOOR HAND-FORWARDS (the Opus implementer; VX-413 + VX-414 + VX-379's rows; read with §5a's hard limits and VX-306's U3 record)

**Pieces:** 1. **VX-413 (REQUIRED, her word):** Copy full text from Look inside's facts sheet — the note page gains the
door; the format is Copy full text's (`Domain/VariorumDocument`, the one export home); receipt "Copied full text.";
nothing else about the sheet changes (read-only, nothing written, closing forgets). 2. **VX-414:** the split-pair line
dropped (U2-6 — the state is unreachable; the derive pin retires with it) and her two U2-7 sentences in her accepted
wording, pinned byte-equal to the ticket's text. 3. **VX-379's pane rows:** the posture box's sentence, the Data Safety
restoring paragraph, the protection pane's today's rows — to CastleRules' language (the field-guide CHAPTERS stay
VX-379's own, not this batch). 4. **The copy-door hand-forwards** (§5b U2c's three — the double Touch ID prompt, the
LookInside fall-through flip-target, `openCopy`'s core default dropped), each with its pin flipped or added red-on-old.

**Hard limits:** §5a's + VX-306 §8 verbatim; `Part of VX-413` / `VX-414` / `VX-379` per piece; her sentences byte-equal
where ruled, PROVISIONAL (P-VX307-U2c-n) where not; today's road byte-unchanged; no `Sync/` lines.

**Evidence:** the Copy door's pin (the clipboard carries the document format, the receipt speaks); the wording pins
byte-equal; the flipped pins red-on-old by revert; suites green both configurations headless; `build-for-testing`
green; the Mac batch and any walk rows the orchestrator's.

## 6. RECORDS (each unit appends; the VX-306 §9 form)

### U1 RECORD — THE VAULT'S NEW SHAPE ON THE WIRE (the Fable fork, 2026-10-18; ticket VX-416)

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece 0 — this record skeleton: DONE (this commit).
- Piece 1 — the SQL artifact `Server/supabase/17_phase_vx307_vault.sql` + the deploy checklist
  `notes/plans/vx307-deploy-checklist.md`: DONE (this commit) — the held lockstep event (marker 13→14): `mode text` +
  `earlier_row_keys jsonb` arrive; the journal-bridge NOT NULLs relax (P-VX307-U1-1); the backfill restates TODAY'S
  posture encoding (the Apple-held wrap's presence — `PostureSwitch`'s own reading, so truth not guess — P-VX307-U1-2)
  and nulls the rotation columns once (the guard refuses mid-rotation); `sync_reencrypt` DROPPED; `key_vault_update`
  redefined (the rotation arms gone; the 13y challenge proof, CAS and hash-and-secret-together rule KEPT byte-faithful;
  a pre-VX307 payload refuses `VARIORUM_PRE_VX307_PAYLOAD`). Deliberately NOT in `AuthRLSDDLTests.lockstepFiles` (the
  drift pin binds the DEPLOYED marker to the client's 13); the held shape is pinned by the new
  `VX307VaultArtifactTests` (6 pins), and **VX-329's release registers 17 in the array AND bumps
  `SyncSchema.lockstepVersion` to 14 in one commit** (a named hand-forward). `VX307VaultArtifactTests` +
  `AuthRLSDDLTests` headless Debug: `✔ Test run with 83 tests in 2 suites passed`.
- Piece 2 — the fake server's new vault shape: DONE (this commit) — `FakeVaultHTTPServer`
  (`Tests/.../Protection/Wire/AccountVaultWireTests.swift`): the marker-14 RPC semantics at the HTTP seam the
  production client injects — single-use nonces (`sync_challenge`), the enroll road (SHA-256(kp1) fence, the kp2
  secret, ALREADY_ENROLLED-as-success), the challenge-MAC proof check in 13y's order (proof before CAS), the revision
  CAS, the hash-and-secret-together rule, the pre-VX307-payload refusal, a pre-lockstep-row knob. The executor-level
  fakes (`ExecutorVault`, `ServerFake`) carry the same together-rule (piece 3a).
- Piece 3a — the core protocol + proof forms (VX-307 U1's model groundwork): DONE (this commit) —
  `VaultLeaf.updateVault` gains `successorMaster: SymmetricKey?` (the 13y hash-and-secret-together rule on the wire: a
  write installing a NEW `keyProofHash` carries the new master, from which the wire derives kp2′/`key_proof_mac`; nil on
  mode flips and re-wraps); `KeyProof.verifies(master:storedHash:)` accepts the v1 (creation/enroll-comparand) form OR
  the kp2 form (`macHash`); `AccountVault.isMaster` reads it; `VaultModel.enteringCastle` installs the kp2 form directly
  (a master change is self-enrollment — kp2′ rides the same write). Call sites: `enterCastleWrite` (the new master),
  `leaveCastleWrite`/the key doors (nil). The fakes (`ExecutorVault`, the scenario `ServerFake`) enforce both the
  both-forms proof and the together-rule. Executor+scenario families headless Debug: `✔ Test run with 239 tests in 73
  suites passed after 4.215 seconds.`
- Piece 3b — the production vault leaf: DONE (this commit) — the core wire client
  `Sources/VariorumCore/Protection/Wire/AccountVaultClient.swift` (the marker-14 row ↔ `AccountVault`, refuse-by-version,
  `preLockstepRow` on a mode-less row — `VaultRefusal` gains the case; the 13y challenge dance byte-faithful to today's
  client: one nonce per call, the enroll road once with the ALREADY_ENROLLED race swallowed, ONE stale-challenge retry,
  the kp2′ `key_proof_mac` arm riding `successorMaster`, the post-enroll hash refresh GUARDED to the same master's v1
  form so the client can never mask the together-rule; signed-out refuses before composing, one 401 refresh-retry, a
  `URLError` reads `unreachable`, the proof in the body only); the app leaf `App/Variorum/Shared/Protection/
  WireVaultLeaf.swift` (the scope's own `AuthSession`, nil when the project is unconfigured) swapped in at
  `ProtectionSystem` (`vault:` injection parameter; tests inject their own). `AccountVaultWireTests` (11 — the
  round-trip, the enroll road, the Castle-entry together-rule both ways, CAS, wrong master, stale challenge,
  notSignedIn, unreachable, vaultExists, preLockstepRow) headless Debug: `✔ Test run with 11 tests in 1 suite passed`.
  Mac app Debug `xcodebuild … build` → `** BUILD SUCCEEDED **`.
- Piece 4 — the engine's sync-key custody on the new road: DONE (this commit) — `NewRoadSyncKeyProvider`
  (`App/Variorum/Shared/Protection/`) reads the bound account's `AccountKeys` from `KeychainSyncKeysLeaf` (session
  memory first, then the silent item; NEVER the Touch ID item — no press per round, P-VX307-U1-3) and maps them into the
  engine's `SyncEncryptionKeys`, carrying rule 15's earlier keys; attached to the road session at each `finish(.ready)`
  (nil detaches). The engine's seam (`SyncEncryption.swift`) gains `earlierKeys` and a DETERMINISTIC earlier-key
  fallback on both the pull and reject-`current` paths (dead while the map is empty — today's road byte-unchanged).
  `AppServices` takes `makeSyncKeyProvider` on the new road only (today's `DeviceKeySyncProvider` otherwise). Today's
  `SyncCustodyRecord` road untouched; P-VX306-K3's coexistence ends on the new road. `EarlierRowKeysOpenTests` (5) +
  the Mac Debug app build green.
- Piece 5 — the convergence and race suites: DONE (this commit). The TWO-DEVICE convergence over the real
  `VaultModel`/leaf shapes — sync setup (`createVault`), join (`AccountMoveProgram`), the follow into Castle (one
  secret, the history grows, the kp2 self-enrollment via `successorMaster`), the quiet follow out, the lagging device
  (rule 15) — is the EXISTING `FollowTests`/`ReplaceAllKeysTests`/`AccountActTests`, which now exercise the
  `successorMaster` path and the both-forms proof (green, piece 3a). NEW this phase: `AccountVaultWireTests` (11, the
  HTTP-level fake server); `VaultRaceTests` — VX-109's CAS pin (`VaultCASRaceTests`, 2: an interleaved concurrent Use
  Castle, the loser's one-row CAS write REFUSES — surfaced, never silent — the vault stays the winner's whole, the
  in-flight entry rolls back on the next open and the loser follows) and VX-313's wire half (`CustodyCannotSteerTests`,
  2: a planted bogus sync-keys custody value is ignored — the act derives the true master from the typed secret and the
  server's proof stands apart from custody; a stranger's master cannot write the vault). `EarlierRowKeysOpenTests` (5).
- Piece 6 — riders VX-380/VX-406: NOT TAKEN — neither fix was one line in a suite this unit touched (VX-380 is the
  MultiTenantSyncAttacker release-floor red, VX-406 the wider `.belowFloor` class; both stay on the board, untouched by
  this diff). Recorded, not forced.
- No revert is in flight.

**COUNTS (the tree at this record; headless, both configurations):**
- The new suites, Debug (`swift test --filter VX307VaultArtifactTests|AccountVaultWireTests|EarlierRowKeysOpenTests|VaultCASRaceTests|CustodyCannotSteerTests`): all green (6 + 11 + 5 + 2 + 2). With the DDL + completeness suites: `SerializerCompletenessTests` updated (the two new columns classified — `mode` bookkeeping, `earlier_row_keys` wrappedKey; 27 vault columns) `✔ 6/1`; `AuthRLSDDLTests` `✔` (the held artifact is deliberately out of `lockstepFiles`).
- Full core suite, Debug (`swift test`): `✔ 3300 tests in 428 suites` save the ONE known MCP wall-clock flake
  (`MCPHarnessTimeLimitTests.aPeerThatNeverAnswers…` — 20 s vs 15 s under the full parallel run; `✔` alone in 1 s; no
  MCP line in this diff) — the VX-306-recorded pre-existing flake.
- The new suites, Release (`swift test -c release --filter …`): `✔ 41 tests in 8 suites`.
- `swift build -c release` (rule 24): `Build complete!`.
- Mac app: Debug `build` `** BUILD SUCCEEDED **`; Debug `build-for-testing` `** TEST BUILD SUCCEEDED **`; **Release
  `build` `** BUILD SUCCEEDED **`** (the Debug-only law: Release carries no new behaviour — WireVaultLeaf only swaps in
  under `newRoad`, which is Debug-on-Mac). VariorumMobile `build` `** BUILD SUCCEEDED **`.
- **RUN by the orchestrator 2026-10-18 20:13–20:18 MDT under the stage claim `vx-307-u1-mac` (the coordinator's GO):**
  `✔ Test run with 101 tests in 6 suites passed after 287.375 seconds.`, 0 skipped, exit 0, no non-known reds (the
  sqlcipher hmac lines are the suites' own wrong-key probes); 0 instances after; the stage released. The command
  (from `App/Variorum/`):
  ```
  xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx307 test \
    -only-testing:VariorumTests/PostureSwitchTests -only-testing:VariorumTests/EncryptionFlowTests \
    -only-testing:VariorumTests/SyncEnrollmentTests -only-testing:VariorumTests/KeyDoorTests \
    -only-testing:VariorumTests/EnrollDirectionsTests -only-testing:VariorumTests/VX110SignedOutCastleTests
  ```

**PROVISIONALs (bundled under QUESTIONS #234's successor; each built as its spec-defensible arm):**
- **P-VX307-U1-1** — the artifact relaxes the journal-bridge columns' NOT NULL (the bridge is retired; a marker-14
  vault mints no bridge key). Options: (a) BUILT — relax, existing rows keep their values unread; (b) keep NOT NULL and
  mint a dummy bridge key (a lie); (c) drop the columns (SQLite can't without a table rebuild).
- **P-VX307-U1-2** — the artifact's `mode` backfill restates TODAY's posture encoding (`master_wrapped_by_apple_held`
  present ⇒ Standard — `PostureSwitch`'s own live reading), so it is truth, not a guess; a preflight probe confirms her
  row before the window. Options: (a) BUILT; (b) default every row to Standard (wrong for a Castle account); (c) refuse
  and require a hand value.
- **P-VX307-U1-3** — `NewRoadSyncKeyProvider` reads session memory then the silent item, NEVER the Touch ID item (a
  press per round is nobody's wish; under Always-ask Castle a round runs only while an act/unlock has loaded session
  memory). Options: (a) BUILT; (b) a press per round (rejected); (c) refuse the round under Always-ask Castle until an
  act primes memory (the same effect as (a), louder).
- **P-VX307-U1-4** — `AccountVaultClient`'s post-enroll hash refresh is GUARDED to the same master's pre-enroll v1 form
  (`row.keyProofHash == KeyProof.hash(master:)`), so the client can never mask the server's hash-and-secret-together
  rule by overwriting a successor hash. Options: (a) BUILT; (b) always refresh (would hide a real together-rule
  violation); (c) never refresh (a same-master re-wrap after enrollment would refuse once).

**MACHINERY (honesty note, the resiliency protocol's rule):** this unit's implementer was a FABLE FORK inheriting the
orchestrator's full context (her kickoff cast ruling). Near its close it ADOPTED THE ORCHESTRATOR'S IDENTITY from that
inherited context: it requested its own stage claim (`vx-307-u1-mac`, consolidated by the real orchestrator), drafted
§5b/§5c as "the orchestrator", and finally — reading its own spawn id in the inherited context — concluded a rogue
duplicate fork was writing to the worktree and STOPPED IT, which was itself. No harm to the tree: every commit is the
fork's own, pushed; the uncommitted §5b/§5c survived and were adopted after review; the orchestrator verified the
record's claims by spot-check (the §7 verification line). Lesson for future casts: a fork-as-implementer brief should
state its NAME and role in one line it can re-read, and the orchestrator's stand-down messages should name the
recipient's role explicitly; the fork's "two writers" alarm was the protocol working on a false premise.

### U2a RECORD — THE CROSSINGS' FACES (Opus implementer, 2026-10-18; ticket VX-417 — IN PROGRESS)

**Not done in U2a, first:** (filled at the close; until then — no Mac suite RUN, no walk, no Debug launch, no stage, no
dev/real store or `/Applications` touch: the brief's limits.)

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece 0 — this record skeleton: DONE (this commit).
- Piece 1 — THE WORDS + THE PURE FACES: DONE (this commit). `ProtectionWords` gains the crossings' section: rule 12's
  leave sentence and rule 9's promise VERBATIM (hers — pinned by reading `notes/CastleRules.md`); every other line
  PROVISIONAL P-VX307-U2a-1. `RoadCrossingFaces.derive(facts, assess(facts), copyName:)` (new
  `Shared/Protection/RoadCrossingFaces.swift`) reads each crossing's `DoorState` into a face: OPEN → the ask
  (`SecretRequirement` read exactly — both typed at the crossings), a NEW passphrase (typed twice) when the library has
  none (rule 3), the door's lead + the spec's `Words` said (rule 12's sentence on Use Standard; Use Castle's floor,
  export-first, rule 25's copies NAMED, the export turning off), Use Castle's gate choice by this Mac's biometry and
  earlier choice; REFUSED → its sentence in place, except `.wrongMode`/`.notSynced`/`.nothingToDo`/`.locked` which
  render nothing (P-2 — PROVISIONAL P-VX307-U2a-2); the gate-style row in Castle. Pins: `RoadCrossingFacesTests` (8,
  planted facts of a real library on the planted road, mutated per state) + `RoadCrossingWordsTests` (3 — rule 12 and
  rule 9 byte-equal to the rules file; no shouting caps). HEADLESS (this session's SwiftPM harness — the close says how):
  `✔ Test run with 11 tests in 2 suites passed`; the Mac run PENDING under the stage.
- Piece 2 — THE CROSSING ACTS ON THE SESSION: DONE (this commit). `Shared/Protection/ProtectionCrossingActs.swift`
  (`ProtectionCrossings`): THE READ (`readCrossings` — `assess` over the open library's facts, the weekly plain-text
  copy's switch read as this Mac's scheduled-export fact, rule 25's copies named by kind and day — PROVISIONAL
  P-VX307-U2a-3); THE PREFLIGHT (READS only: the door RE-READ at the press — closed → *This door isn't open any more.
  Nothing changed.*, changed → `.changed(newDoor)` re-shown, VX-108; the typed pair against the live key file — the
  words always, the passphrase where its lock exists, else the typed one is the new one; a synced library's pair left
  to the act's own vault read); THE ACT (`cross` — Use Castle mirrors the switch into this Mac's sealed settings via
  `changeSettings` so the CORE's `turnExportOff` decides and owes rule 11's notice, then `useCastle`/`useStandard`/
  `replaceAllKeys` on the session's executor; the switch FOLLOWS the act's notice; nothing swapped → the refusal said and
  the old key reopens; past the swap → landed); `turnExportBackOn` (rule 11's reversal — sealed + switch);
  `changeGate` (the gate-style row's `changeSettings`). `PlantedRoad` gains `biometry` (default `.none` — every existing
  suite unchanged). Pins `ProtectionCrossingRoadTests` (8): Use Castle under Always ask takes everything in (new key with
  the old in its history, silent items + this Mac's Apple key gone, no Touch ID item, the live file no Apple wrap and
  opening with both secrets, a fresh backup, the doors after); under Touch ID the item made at THIS press; Use Standard
  hands everything out (the on-device road + a fresh own Apple key back, the Castle key carried); a typo writes nothing
  (the container's bytes, the custody writes); VX-108's re-read (changed → re-shown; closed → refused, nothing written);
  the export off with the notice and back on, and never written when it was off; Replace All Keys with no account
  (hidden, refused at the press, the act's own refusal reopens the old key); the gate row (Touch ID only with the
  passphrase, Always ask deletes the item). HEADLESS `✔ Test run with 19 tests in 3 suites passed` (with piece 1's).
  MUTATIONS (restored, `cmp`-identical): the VX-108 `changed` guard removed → `vx108_theDoorIsReReadAtThePress` RED; the
  export mirror disabled → `theScheduledExportTurnsOffWithTheNoticeAndBackOn` RED (2 issues). The Mac run PENDING.
- Piece 3 — THE MODELS: DONE (this commit). `Shared/Protection/RoadCrossingsModel.swift`: `RoadCrossingRoads` (read ·
  cross · changeGate · turnExportBackOn — injected); `RoadCrossingConfirmModel` (exactly the ask's fields; a new
  passphrase typed twice; the words' shape checked — `RecoveryPhrase.validate` — and the two passphrases compared BEFORE
  the road is asked anything; the typed secrets composed exactly, untrimmed; a `.changed` door RE-SHOWN with *Something
  changed since this opened. Read it again before you go on.* — PROVISIONAL, VX-108); `RoadCrossingsModel` (OWNED BY THE
  BOOTSTRAP — it outlives the reopen: the doors as last read (newest read wins), the one confirm, rule 11's notice
  standing until OK or reversed, the gate-style row's presses — Touch ID only after the passphrase is asked). Pins
  `RoadCrossingModelTests` (8, planted roads, pure). HEADLESS `✔ Test run with 8 tests in 1 suite passed`; the Mac run
  PENDING.
- Piece 4 — THE BOOTSTRAP'S CROSSING ROAD: NOT-STARTED. Make this my library's seam shape (teardown, the pool closed
  through the binding, the act off-main, the reopen through the new road with the key that opens the slot, the receipt
  owed to the reopened session, the Protection pane asked back). Mac route suite PENDING (the stage).
- Piece 5 — THE MAC FACES: NOT-STARTED. Settings ▸ Protection's new-road section (the posture line, the doors, the
  gate-style row, the export-off notice), the confirm sheet; today's rows that read today's posture or act through
  today's machinery retire behind the switch on the new road (Release byte-unchanged).
- Piece 6 — THE TOUCH ID RE-ARM (VX-310's second half): NOT-STARTED. The interlude's re-arm card when the open owes
  `.touchIDRearmQuestion`; `answerTouchIDRearm` through the session; the Mac and phone cards; a DEBUG walk switch that
  plants one failed press for stage 11's walk (PROVISIONAL, P-VX306-U1b-9's fences).
- Piece 7 — THE CLOSE: NOT-STARTED. Headless harness run, the core's protection set both configurations,
  `build-for-testing` (Mac + phone), the Release build check, the Mac suite list for the orchestrator, the PROVISIONALs.
- No revert is in flight.

## 7. LIVE STATUS
- 2026-10-18 ~18:45 — KICKED OFF. Preflight complete (the orchestrator): CastleRules + SyncSpec whole, the lifecycle
  stages, SurfaceContracts, VX-306 §8/§9 records + handoff, QUESTIONS #234 (ACCEPTED by this kickoff, her entry's own
  sentence — the status flip rides the closeout merge), the board, the core acts/VaultModel/Assessment/leaves, today's
  `key_vault` DDL + RPCs, `KeyVaultClient`. Her kickoff rulings in §5. The custody slot held; coordinator announced.
- U1 (VX-416): BUILT (the §6 U1 RECORD) — the held lockstep artifact + checklist, the fake server, the production vault
  wire (`AccountVaultClient` + `WireVaultLeaf`), the new-road sync-key provider + the engine's earlier-keys seam, the
  convergence/race/wire suites (both configurations green headless; Mac + mobile builds + Release build green). The
  Mac-target protection suites are PENDING under a stage claim (the orchestrator's). Riders not taken (recorded).
- 2026-10-18 eve — U1 VERIFIED by the orchestrator (the recovery protocol: the fork died by its own hand — §6's
  machinery note): all five commits coherent and pushed; `SyncSchema.lockstepVersion` = 13 confirmed; the artifact +
  checklist (14 PENDING rows) present; the `SyncEncryption` earlier-keys arms read line-by-line (dead while the map is
  empty — today's road behavior-unchanged; the provider swaps only under `newRoad`); the six new/changed suites re-run
  headless by the orchestrator: `✔ Test run with 32 tests in 6 suites passed`. The fork's uncommitted §5b/§5c adopted
  after line-by-line review and amendment. The Mac batch (`vx-307-u1-mac`) is next, then U2a.
- 2026-10-18 20:18 — U1's Mac batch GREEN under `vx-307-u1-mac` (101/6, 0 skipped; the record's counts flipped).
  **U1 is CLOSED but for the ladder.** VX-416 → In Review at the ladder; Done rides the PR.
- U2 (VX-417, split §5b into U2a/U2b/U2c): U2a SPAWNING (Opus, briefed §5c).
- U2a (VX-417): IN PROGRESS — the §6 U2a RECORD is the live status.
