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
VX-379's own, not this batch). U2b's F-U2b-1 rides here too: the readme's Start Here words passage (byte-pinned at VX-306) says creation-time words and points at Data Safety — reword to the amended rules 2/3 and re-anchor the pin honestly. U2a's F-6 rides here: Data Safety's Castle warning reads today's posture — reword to the
rules; today's rows render on TODAY's road only (the U2a-4 ruling above: never un-hide them on the new road). 4. **The copy-door hand-forwards** (§5b U2c's three — the double Touch ID prompt, the
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

### U2a RECORD — THE CROSSINGS' FACES (Opus implementer, 2026-10-18; ticket VX-417 — BUILT; the Mac suites and the walk PENDING)

**Not done in U2a, first:**
- **No Mac suite was RUN** (the brief: no `xcodebuild test`, no stage) — only BUILT (`build-for-testing` green on the final
  tree). The list below is the orchestrator's to run under a stage claim. What DID run: the planted and pure suites
  HEADLESS in this session's SwiftPM harness over the real `Shared/Protection/` files (87 / 12, the recipe below), and
  the core's protection set in both configurations (this batch changes no core file).
- **The walk was not done** (the orchestrator's — the recipe below: stages 6 (Touch ID and Always ask), 7's Castle
  backup, 8, 11's re-arm on a planted failure). No Debug app was launched; the dev store, the real store and
  `/Applications` were never touched.
- **Replace All Keys is not walkable this phase**: it needs an account (`.notSynced` on a local library — rendered as
  nothing, P-2), and no new-road library names one until VX-308's account faces. Pinned over planted facts only.
- **The account faces, the follow and the synced arms are VX-308's** (her ruling, §2 U3): the crossings' synced refusal
  sentences are built and pinned on planted facts but unreachable on the new road this phase (the facts gatherer reads no
  vault — P-VX306-K3's `vault: nil`).
- **Not built here (hand-forwards below):** no lock on the new road (Castle's idle lock / Lock Now — `canLock` stays false
  on the new road); the phone's crossing faces (the shared brains are ready; only the re-arm card renders there); the
  canon delta for SurfaceContracts' "Library protection" line (the closeout's).

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
- Piece 4 — THE BOOTSTRAP'S CROSSING ROAD: DONE (this commit). `AppBootstrap.crossOnNewRoad` — Make this my library's
  seam shape: the preflight (all reads) BEFORE anything closes; then `onWillLock`, `.opening`, the pool closed through
  the binding, `ProtectionCrossings.cross` off the main actor; the reopen through the new road with the key that opens
  the slot; the door's receipt owed to the reopened session (`receiptsForNextRoadOpen`); Settings asked back to
  Protection (`ProtectionController.requestProtectionPaneForRoadCrossing` — a new, unconditional twin of the ceremony's
  request, never called on today's road). `crossingRoads()` (each road reads the CURRENT session at its call).
  `roadCrossings` is made at the first ready on the new road and handed to every open library's faces
  (`RoadStandingModel.crossings` — the pane's reach). The scheduled-export switch: production `MarkdownInsurance` over
  `.standard`; the test bootstrap's own suite (`crossingTestExportSuiteName`), which never falls back to the app's
  domain. Mac suite `ProtectionCrossingRouteTests` (2: Use Castle through the bootstrap — the pool closed, the reopen on
  the new road in Castle under a new key, the receipt owed once, Settings asked back, rule 11's notice and its reversal;
  then Use Standard back with its receipt; a wrong word never tears the window down) — BUILT, its RUN PENDING under the
  stage. `xcodebuild … build-for-testing` → `** TEST BUILD SUCCEEDED **`, no warning in a touched file.
- Piece 5 — THE MAC FACES: DONE (this commit). `Features/Protection/RoadCrossingSheet.swift`: `RoadCrossingSheet` (the
  title, the door's sentences — rule 12's in the primary ink — rule 25's copies bulleted under their line, Use Castle's
  gate choice as a radio pair with its rule-9 line, or Always ask alone with *Touch ID isn't set up on this Mac.*;
  exactly the ask's fields; the refusal; *Cancel* · the door's title; not dismissable while the act runs) and
  `RoadCrossingsSection` (Settings ▸ Protection: the posture line, each door as `assess` says it — open = its button,
  refused = its sentence in place, hidden = nothing; rule 11's notice with *Turn it back on* · *OK*; in Castle the
  gate-style row — *Use Always ask* at once, *Use Touch ID…* asking the passphrase first, the quiet line where Touch ID
  can't work here). `ProtectionPane`: the section from `roadStanding?.crossings`, its confirm sheet bound to the
  bootstrap's model (it survives the reopen), the doors re-read at each appearance; TODAY'S ROWS (the current-state
  line, the checklist, the posture cards and today's choose doors, the re-link door, Castle's switches, today's
  passphrase doors, the reminder) render only with NO road model — on the new road they retire behind the switch
  (PROVISIONAL P-VX307-U2a-4); today's road renders them exactly as before (the VX-306 row's source pin still holds).
  Mac suite `RoadCrossingSurfaceTests` (3: the pane hosts the section in both postures; the confirm hosts in each shape;
  the pane's gate source-pinned) — BUILT, RUN PENDING under the stage. `build-for-testing` → `** TEST BUILD SUCCEEDED
  **`, no warning in a touched file.
- Piece 6 — THE TOUCH ID RE-ARM (VX-310's second half): DONE (this commit). `RoadInterlude.Card.rearm` — owed exactly
  when the open's report owes `assess`'s `.touchIDRearmQuestion` (a press failed on an item that exists, then a typed
  secret opened the library), after rule 21's notice and offer, once per open, in the lobby's room before the library
  shows (PROVISIONAL P-VX307-U2a-5); its sentence the design's §3.10 words (*Touch ID can't open Variorum on this Mac any
  more. Set it up again? Every finger enrolled on this Mac will open it.* — the third sentence the Mac's only);
  `RoadInterludeModel.rearm(yes:)` → the bootstrap's `answerRearm` road → `ProtectionCrossings.answerRearm` →
  `answerTouchIDRearm` (the stale item goes either way; yes makes a new one at this press; no records Always ask); an
  answer that could not be written says so and offers *OK* — the open goes on with nothing decided, never a dead end.
  The Mac (`RoadInterludeCard`) and phone (`MobileRoadInterludeCard` — the shared card, reachable only once the phone
  enters Castle) render it. THE WALK SWITCH `VARIORUM_WALK_TOUCHID=fail` (DEBUG; the new road; a writing road; once per
  process — P-VX306-U1b-9's fences; PROVISIONAL P-VX307-U2a-6): the launch's first Touch ID press on an item that EXISTS
  answers `.failedOnExistingItem` with nothing read (`KeychainCustodyLeaf.walkFailNextTouchIDPress`), so stage 11's
  re-arm is walkable on a planted failure. Pins `RoadRearmTests` (4, headless: the card owed only by the question;
  the answers reach the road and an unwritten one never strands her; `answerTouchIDRearm` through a planted Castle
  session — delete + write on yes, gone + Always ask on no, nothing written with no item; the switch's word and fences)
  — MUTATION: the card's line removed → RED (3 issues), restored `cmp`-identical; `ProtectionCrossingRouteTests` gains
  the switch arming the PRODUCTION leaf once per process (Mac, PENDING). HEADLESS (the harness, all symlinked suites)
  `✔ Test run with 86 tests in 12 suites passed`. `build-for-testing` → `** TEST BUILD SUCCEEDED **`; the phone
  `-scheme VariorumMobile -destination 'generic/platform=iOS Simulator' build` → `** BUILD SUCCEEDED **`; no warning in a
  touched file.
- Piece 7 — THE CLOSE: DONE (the close commit) — the counts, the Mac suite list, the walk recipe, the PROVISIONALs and
  the findings below; `TravellingDotsIndicatorTests`' surface list gains `RoadCrossingSheet.swift` (no system spinner on
  the new face); `RoadCrossingWordsTests` gains the doors' names/titles/receipts (4 there now).
- No revert is in flight (every mutation run restored and `cmp`-checked; no scratch worktree was made).

**THE FACES AS BUILT (for the ladder):** the pane on the new road reads `roadStanding.crossings` — the BOOTSTRAP's
`RoadCrossingsModel` (made at the first ready on the new road, kept across every reopen) — whose `read` road runs `assess`
over the open library's facts (`ProtectionCrossings.readCrossings`, with the weekly plain-text copy's switch as this Mac's
scheduled-export fact) and `RoadCrossingFaces.derive` reads each door. A press: the confirm checks the words' shape and
the new passphrase twice (pure), then `AppBootstrap.crossOnNewRoad` — `session.beginAct`, the PREFLIGHT off-main (the door
re-read: closed → refused, changed → re-shown; the typed pair against the live key file), and only then the teardown
(`onWillLock`, `.opening`, the pool closed through the binding), `ProtectionCrossings.cross` off-main (Use Castle mirrors the
switch into the sealed settings via `changeSettings`, then the core's act on its sealed plan; the switch follows the act's
`.scheduledExportTurnedOff`), the reopen through the new road with the key that opens the slot, the receipt owed to the
reopened session, `requestProtectionPaneForRoadCrossing`. The confirm closes on `.made` (rule 11's notice then stands in
the pane until *OK* or *Turn it back on*); a refusal after the reopen re-presents it with its sentence. The gate-style row
and the reversal run `changeSettings` on the open session (no reopen — the pool stays open, as the set-passphrase road's
record write does). The re-arm: `RoadInterlude.cards` appends `.rearm` when the open's report owes
`.touchIDRearmQuestion`; its answers run `answerTouchIDRearm` on the session before the library opens. ZERO `Sources/`,
`Sync/`, `Server/`, schema or dependency lines; no new core act.

**COUNTS (the final tree — the close commit):**
- HEADLESS (this session's SwiftPM harness — not durable; the VX-306 U1b/U2/U3 recipe: a package in the scratchpad,
  swift-tools 6.2, macOS 26, the app's concurrency settings — default `MainActor` isolation,
  `NonisolatedNonsendingByDefault`, `InferIsolatedConformances`, `MemberImportVisibility` — depending on the worktree's core
  by path; its `Variorum` target SYMLINKS every `App/Variorum/Shared/Protection/*.swift` but `ProtectionBackupHook.swift`
  and `WireVaultLeaf.swift`, plus `Shared/LibraryOpenCopy.swift`, plus one stub file of one-line stand-ins (`DeviceName`,
  `BackupDestination`, `KeychainTestTripwire`, `KeychainPartition`, `AppleKeyKeychain`, `AppleKey`, `AuthTokens`/
  `KeychainAuthStorage`, `EncryptionSession.words`, `ProtectionCopy`'s three names, a nil `WireVaultLeaf.live`); its test
  target symlinks `ProtectionTestSupport`, `ProtectionFacesSupport`, `ProtectionOpenRoadPlantedTests`,
  `ProtectionWordsPlanTests`, `ProtectionLobbyModelTests`, `PassphraseReminderTests`, `ProtectionNoticeFaceTests`,
  `ProtectionOfferFaceTests`, `ProtectionWalkSwitchTests` (the baseline: `✔ 55 tests in 7 suites`) and this batch's
  `RoadCrossingFacesTests`, `ProtectionCrossingRoadTests`, `RoadCrossingModelTests`, `RoadRearmTests`, + a one-line
  `RoadWorld.RoadWorldError` stub): **`✔ Test run with 87 tests in 12 suites passed after 0.595 seconds.`**
- MUTATIONS (each restored from a pre-mutation copy and `cmp`-identical): the preflight's VX-108 `changed` guard removed →
  `✘ vx108_theDoorIsReReadAtThePress` (1 issue); Use Castle's export mirror disabled → `✘
  theScheduledExportTurnsOffWithTheNoticeAndBackOn` (2 issues); the interlude's `.rearm` line removed → `✘
  theCardIsOwedOnlyWhenTheOpenOwesTheQuestion` (3 issues) — the last is VX-310's second half red-on-old in effect (before
  this batch the open's interlude had no card for the question: VX-306 rendered it as nothing).
- The core's protection set (the 81 `@Suite` types under `Tests/VariorumCoreTests/Protection`): Debug `✔ Test run with 327
  tests in 81 suites passed after 5.337 seconds.`; Release (`swift test -c release`, the same filter) `✔ Test run with 303
  tests in 77 suites passed after 4.059 seconds.` (no core file changed in this batch).
- `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx307
  build-for-testing` → `** TEST BUILD SUCCEEDED **` (the final tree); the phone `-scheme VariorumMobile -destination
  'generic/platform=iOS Simulator' -configuration Debug -derivedDataPath DerivedData/vx307 build` → `** BUILD SUCCEEDED
  **`; **the Release check `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Release
  -derivedDataPath DerivedData/vx307 build` → `** BUILD SUCCEEDED **`**; no warning in a touched file.
- Release behaviour: unchanged by construction — every new line is a new file, sits behind `roadStanding`/`roadCrossings`
  (nil on today's road), behind `newRoad`, or under `#if DEBUG` (the walk switch); the pane's today's rows render only with
  no road model, which is today's road exactly; the controller's new request method is never called there. The binary is
  not byte-identical (the new types compile in both configurations — rule 24, U1b's precedent).

**THE MAC SUITES THE ORCHESTRATOR RUNS UNDER THE STAGE (from `App/Variorum/`; PENDING):**
```
xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx307 test \
  -only-testing:VariorumTests/RoadCrossingFacesTests \
  -only-testing:VariorumTests/RoadCrossingWordsTests \
  -only-testing:VariorumTests/ProtectionCrossingRoadTests \
  -only-testing:VariorumTests/RoadCrossingModelTests \
  -only-testing:VariorumTests/RoadRearmTests \
  -only-testing:VariorumTests/ProtectionCrossingRouteTests \
  -only-testing:VariorumTests/RoadCrossingSurfaceTests \
  -only-testing:VariorumTests/ProtectionOpenRoadPlantedTests \
  -only-testing:VariorumTests/ProtectionNoticeFaceTests \
  -only-testing:VariorumTests/ProtectionOfferFaceTests \
  -only-testing:VariorumTests/ProtectionPaneRoadRowTests \
  -only-testing:VariorumTests/ProtectionWalkSwitchTests \
  -only-testing:VariorumTests/ProtectionWordsPlanTests \
  -only-testing:VariorumTests/ProtectionLobbyModelTests \
  -only-testing:VariorumTests/PassphraseReminderTests \
  -only-testing:VariorumTests/ProtectionFacesRouteTests \
  -only-testing:VariorumTests/ProtectionRoadRouteTests \
  -only-testing:VariorumTests/MakeMineRouteTests \
  -only-testing:VariorumTests/KeychainLeavesTests \
  -only-testing:VariorumTests/ProtectionKeychainFamilyTests \
  -only-testing:VariorumTests/KeychainTripwireTests \
  -only-testing:VariorumTests/ProtectionSystemCompositionTests \
  -only-testing:VariorumTests/VX310TodayLobbyWitnessTests \
  -only-testing:VariorumTests/StoreLaunchRouteTests \
  -only-testing:VariorumTests/AppBootstrapOffMainTests \
  -only-testing:VariorumTests/SettingsLockCloseTests \
  -only-testing:VariorumTests/VX206ProtectionLandingTests \
  -only-testing:VariorumTests/ProtectionSurfaceRenderTests \
  -only-testing:VariorumTests/ProtectionTierFaceTests \
  -only-testing:VariorumTests/TravellingDotsIndicatorTests \
  -only-testing:VariorumTests/CopyRegisterPinTests \
  -only-testing:VariorumTests/NoLiteralColourTests \
  -only-testing:VariorumTests/StatusSeamVocabularyTests
```
The first seven are U2a's new suites (8 + 4 + 9 + 8 + 4 + 3 + 3 = **39 tests** after the fix commit's twin; `ProtectionCrossingRouteTests` needs the
signed test host — a throwaway keychain scope, the real custody leaf, a test bootstrap whose scheduled-export switch is its
own suite `io.lduarte.Variorum.vx307-crossing-tests`, never the app's domain); then the suites whose files this batch
touched (the planted road's `biometry`, the interlude model's init, the pane, the walk switch, the custody leaf, the
bootstrap's ready, the controller's request) and the source pins over the edited files. `VX310TodayLobbyWitnessTests`
still reports its KNOWN ISSUES (expected — a pass of either is a FAILURE); read the `skipped:` lines.

**THE MAC BATCH — RUN by the orchestrator under the stage (2026-10-18): 164 tests / 33 suites; ONE real red, a TEST-SIDE
read — FIXED (the fix commit, `Part of VX-417`):** `ProtectionCrossingRouteTests.useCastleClosesThePoolCrossesAndReopensOn
TheNewRoadThenUseStandardHandsItBack` at `#expect(back.key != reopened.key)` — BYTE-IDENTICAL keys, while the same run's
protection log showed three distinct keys (created `dbfc3710` → Use Castle `fe325f9b` → Use Standard `66fd95de`; the export
notice owed true, then false). **The traced mechanism:** the second press (`crossOnNewRoad`) runs on `roadSession` — which
IS `reopened` (the session the first crossing's reopen made); `ProtectionCrossings.cross` writes the act's library into
that session (`session.library = library`, after `useStandard`); `ProtectionRoadSession.key` is COMPUTED from the held
library (`library.key`), so the late read `reopened.key` answered the post-Use-Standard key — the very key `back` opened
with (`reopenKey = library.key`). Not a product aliasing: the session is the open library's ONE holder by design (Make this
my library writes it the same way — `ProtectionCopyDoors.makeMine`), and the bootstrap retires it at the reopen (`back` is
a fresh session). **The fix (test-side):** the Castle key captured as a value right after the first crossing (`let
castleKey = reopened.key`), then `back.key != castleKey`, `back.key != created.key`, `back !== reopened`. **The headless
twin:** `ProtectionCrossingRoadTests.aSessionsKeyIsTheOpenLibrarysNow` (two crossings on ONE planted session: the live
`session.key` equals each act's reopen key; the captured values stand — three distinct keys) — the harness `✔ Test run with
88 tests in 12 suites passed`; `build-for-testing` → `** TEST BUILD SUCCEEDED **`. The suite's re-run is the
orchestrator's (the signed host). Everything else in the batch green; the 3 `VX310TodayLobbyWitnessTests` known issues as
expected; the throwaway scopes cleaned up.

**THE WALK RECIPE (the orchestrator's, under a held stage claim; the DEV STORE only; light and dark where a face changed —
Settings' pane and sheet are system chrome, the interlude card speaks the leading voice's fallback):**
0. Zero Debug instances (discriminate by PATH; a `/Applications` instance is NEVER touched). Build: `cd App/Variorum &&
   xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx307
   build`. Launch as the BINARY with stderr captured (`OS_ACTIVITY_DT_MODE=YES [VARIORUM_WALK_TOUCHID=fail] App/Variorum/
   DerivedData/vx307/Build/Products/Debug/Variorum.app/Contents/MacOS/Variorum 2> ~/vx307-walk/run-N.log &`), quit with ⌘Q,
   read the `road:` lines. `source ~/.variorum/dev-castle.env`. **PRECONDITION — the dev library's twelve words in hand:**
   both crossings type the passphrase AND the words (P-VX378-U2-2). If the current dev library's words were never
   recorded (a new-road library's words are shown once at creation), the walker makes a fresh dev library through the
   missing face's *Start a New Library* (the old one aside, never deleted) and records its words — and the dev passphrase,
   set through *Set a passphrase…* — in `dev-castle.env` in the same window (CLAUDE.md: never invent; update the file when
   one must change). Expected start: Standard, the dev passphrase set.
1. **Stage 6 under Always ask.** (Optional — rule 11's export notice: before the launch, `defaults write ~/Library/
   Containers/io.lduarte.Variorum.debug/Data/Library/Preferences/io.lduarte.Variorum.debug.plist
   variorum.backup.markdownInsurance.enabled -bool true` — the weekly copy's switch.) Settings ▸ Protection → *You're in
   Standard.* and *Use Castle…* (no Use Standard, no Replace All Keys — P-2). The confirm: *Use Castle*, rule 9's promise
   (hers), the lead, the floor, the export-first line, (*Your scheduled plain-text export turns off …* when the switch is
   on), *On this Mac* with *Touch ID* / *Always ask* and its line, *Your passphrase*, *Your twelve words*, *Cancel* · *Use
   Castle*. Capture (light, dark). Type a WRONG word first → *Those twelve words don't open this library.*, the window never
   closes. Then the right pair with *Always ask* → the window shows *Opening your library…* → Settings returns ON
   PROTECTION: *You're in Castle.*, *Use Standard…*, (the export notice with *Turn it back on* · *OK* when it was on —
   capture; press *Turn it back on* → `defaults read …markdownInsurance.enabled` → 1) and *On this Mac* — *Always ask: no
   copy of the key stays on this Mac, and you type every time.* · *Use Touch ID…*. The main window's quiet line: *You're in
   Castle now.* Log: `enter_castle: done #N under …`, `road: useCastle — library … now castle under …`. The live key file
   has no `"apple"`; quit → relaunch → THE LOBBY asks a secret at once (no Touch ID button; *Touch ID isn't set up for this
   library.*); the passphrase opens.
2. **The gate-style row.** Settings ▸ Protection ▸ *Use Touch ID…* → a wrong passphrase → *That passphrase doesn't open this
   library.*; the right one → *Touch ID opens your library on this Mac.* (log `road: this Mac's gate is touch_id now`);
   quit → relaunch → the Touch ID prompt (auto-ask) opens it. *Use Always ask* → the row flips; relaunch → typed.
3. **Stage 7's backup in Castle.** Data Safety ▸ Back Up Now → the new pair's `….keys.json` carries no `"apple"` (`grep -c`).
4. **Stage 8 — Use Standard.** *Use Standard…* → the confirm: *Use Standard*, the lead, rule 12's sentence (hers, primary
   ink), *Your passphrase* (once), *Your twelve words*. Capture. Both typed → reopen → *You're in Standard.*, *Use Castle…*,
   no gate row; the quiet line *You're in Standard now.*; the live key file has an `"apple"` wrap again; quit → relaunch →
   opens quietly.
5. **Stage 6 under Touch ID, then STAGE 11's RE-ARM on a planted failure.** *Use Castle…* with *Touch ID* → reopen; quit →
   relaunch → the Touch ID prompt opens it. Quit → launch with `VARIORUM_WALK_TOUCHID=fail` → log `WALK SWITCH
   (VARIORUM_WALK_TOUCHID): the next Touch ID press fails on its item` → the auto-ask answers at once with NO prompt → the
   lobby's line *Touch ID changed since you set it up — unlock with the passphrase*; type the passphrase → THE CARD in the
   lobby's room: *Touch ID can't open Variorum on this Mac any more. Set it up again? Every finger enrolled on this Mac will
   open it.* · *Always ask instead* · *Set it up again*. Capture (light, dark). *Set it up again* → the library opens (log
   `road: the Touch ID re-arm answered yes — a new item at this press`); quit → relaunch (no switch) → the Touch ID prompt
   opens it. Repeat with the switch → *Always ask instead* → opens; relaunch → no Touch ID button, the quiet line; the gate
   row reads Always ask.
6. **Posture after the window:** *Use Standard…* back (rule 12) — the dev store in Standard with the dev passphrase, quiet
   roads re-made; `defaults delete … variorum.backup.markdownInsurance.enabled` if row 1 set it; record the posture for the
   coordinator (the Castle walk restores Standard before release — her standing rule).

**PROVISIONALs (each built as its option (a); for the orchestrator to bundle under QUESTIONS at the closeout — the shared
ledger is the merging session's):**
- **P-VX307-U2a-1 — the crossings' undrafted words** (`ProtectionWords`' VX-307 section): the doors' names (the canon's)
  and titles; the posture line (*You're in Standard.* / *You're in Castle.* — today's current-state line's first
  sentence); Use Castle's lead; the floor (*From now on your passphrase, your twelve words, or Touch ID on this Mac open
  your library. Lose all three and it is gone.* — the design's §3.1 (2)); the export-first line; rule 25's sentence at the
  door and the copy's name (*Backup from August 3*); the export turning off (rule 11's parenthetical) and its notice, *Turn
  it back on* · *OK*; the gate choice's heading and two lines (rule 9 + stage 6); Use Standard's lead; Replace All Keys'
  lead; the fields; *This library has no passphrase yet. Choose one — Castle needs it.*; the refusals (door closed, door
  changed, failed, secrets missing, VX-113's changed-elsewhere sentence after the plan's §1, the five door refusals); the
  three receipts; the gate row's lines and doors; the re-arm's two doors and its failure line (its question is the
  design's §3.10 sentence). HER sentences verbatim (pinned): rule 12's leave sentence; rule 9's promise. (b) blank until
  her sitting; (c) other words.
- **P-VX307-U2a-2 — which refusals render.** (a) BUILT — `.wrongMode`, `.notSynced`, `.nothingToDo` (and `.locked`) render
  NOTHING (P-2: the door is not this posture's, or has no subject here — so Replace All Keys is absent on a library with no
  account); every other refusal says its sentence IN PLACE of the door; (b) every refused door rendered disabled with its
  reason; (c) refused doors never rendered.
- **P-VX307-U2a-3 — the scheduled export's two places.** The app's only scheduled export is the weekly plain-text copy
  (`MarkdownInsurance`, this Mac's defaults); the core's rule-11 step reads this Mac's SEALED `DeviceSettings
  .scheduledExport`, which nothing on the new road set. (a) BUILT — the read takes the switch as this Mac's
  scheduled-export fact (the door says it turns off exactly when it is on); the Use Castle press mirrors the switch into
  the sealed settings (`changeSettings`) so the CORE's step decides and owes the notice; the switch follows the act's
  notice; *Turn it back on* flips both. (b) the Data Safety toggle writes the sealed setting on the new road (a pane
  change — U2c/VX-379's); (c) the core reads the defaults key (a core change).
- **P-VX307-U2a-4 — today's Protection rows on the new road.** (a) BUILT — they retire behind the switch there (the
  current-state line, the checklist, the posture cards with today's checkmark and choose doors, the re-link door, Castle's
  switches, today's passphrase doors, the reminder): each reads today's posture or acts through today's machinery, which
  on the new road would contradict the record (a Castle library shown as Standard) or write today's key file; the
  keystone sentence stays; (b) keep the cards with the new road's checkmark (their words are U2c's/VX-379's to bring to
  the rules); (c) keep everything (VX-306's posture — the contradiction visible).
- **P-VX307-U2a-5 — where the re-arm is asked.** (a) BUILT — a card in the interlude (the lobby's room, after the unlock,
  before the library shows, once per open — P-VX306-U2-1's idiom); an answer that could not be written says so and offers
  *OK* (nothing decided; the question returns after the next failed press); (b) a calm bar on the open library; (c) a
  sheet over the window.
- **P-VX307-U2a-6 — the Touch ID walk switch** `VARIORUM_WALK_TOUCHID=fail` (DEBUG, the new road, a writing road, once per
  process — P-VX306-U1b-9's fences): the launch's first Touch ID press on an item that exists answers
  `.failedOnExistingItem` with nothing read. (a) BUILT; (b) a real enrollment change (her hands); (c) no walk of stage 11.
- **P-VX307-U2a-7 — how a crossing ends.** (a) BUILT — Make this my library's precedent: the confirm closes on success
  and the act's receipt is spoken once on the reopened window's status seam (`receipt_style` governs it); the leave's
  `ActOutcome.done` (`[.ruleFive]`) is read as already said at the door (rule 12: "the leave screen says so"); Settings
  returns on Protection; (b) a Done screen in the sheet (today's ceremony's); (c) both.
- **P-VX307-U2a-8 — a library with no passphrase at Use Castle.** (a) BUILT — the door asks a NEW passphrase typed twice
  and the executor sets it (its existing road — rule 3, the lifecycle's stage 2: "nothing below depends on it except
  entering Castle"); (b) refuse until the set-passphrase sheet ran; (c) one field.

**FINDINGS AND HAND-FORWARDS (routed, not fixed here):**
- **F-1 (the re-arm, a narrower gap — for the ladder):** `ProtectionOpenRoad.pressTouchID`'s arm for an item whose key
  OPENS NOTHING here (`.noneOpens`) returns `.failedOnExistingItem` to the lobby (the changed line shows) but leaves
  `KeychainCustodyLeaf.lastPress` nil (the read succeeded), so the typed open's facts carry no failed press and `assess`
  owes no re-arm. The real biometry-change case (`errSecAuthFailed` / a not-found read on an existing item) sets
  `lastPress` and IS served. Not fixed: no pin can press Touch ID (headless or hosted), and it is not this batch's row.
- **F-2:** an entry that stops past its swap BEFORE its export step finishes at the next open's settle, whose notices the
  new road does not surface — the weekly copy's switch is not followed there (the core's crash harness covers the act).
- **F-3:** no lock on the new road (`canLock` false — VX-306 U1b's "every library it opens is Standard") — Castle's idle
  lock and Lock Now are VX-308/VX-329's now that Castle exists on the new road.
- **F-4:** the restore hold's ceremony gate (13x F1 R1-M1: Use Castle / Replace All Keys refuse while held) is not carried
  onto the new road — unreachable for a SYNCED crossing this phase; VX-308's with the account faces.
- **F-5:** today's store-id envelope beside the library (`variorum-keys-<storeID>.json`) stays under the pre-crossing key
  (`ensureStoreIdentity` never re-mints an existing id; nothing on the new road opens with it; today's backups still copy
  it) — VX-329's retirement of today's road.
- **F-6:** Data Safety's weekly-copy toggle and its Castle warning read today's posture on the new road (the warning won't
  show in a new-road Castle) — U2c/VX-379's rows.
- **F-7 (canon, the closeout's):** SurfaceContracts' "Library protection" line gains the crossings' faces (the doors from
  `assess`, the gate choice and row, rule 11's notice, the re-arm card) in place, one pointer to this plan.
- **F-8 (the phone):** no crossing faces on the phone this batch (the shared brains — `RoadCrossingsModel`,
  `RoadCrossingFaces` — are ready); the re-arm card renders there (the shared interlude). MOBILE PARITY line for the
  closeout.

**Notes:** no machinery deaths; no Sonnet lookup; no scratch worktree; every mutation restored and `cmp`-checked. Commits:
`6db1518a8` (record) · `8203417f8` (1) · `cd5d99009` (2) · `a9dc3bace` (3) · `1e776c19e` (4) · `443a16c5f` (5) ·
`d7dd30979` (6) · the close commit.

**U2a ARBITRATION (the orchestrator, the same evening — each finding's disposition, repo-first before U2b spawns):**
- **F-1** (a press on an item whose key opens nothing shows the changed line but owes no re-arm — `lastPress` stays nil;
  the real biometry-change case works; unpinnable without a finger): RECORDED — a ticket at closeout (Bug, Suspected,
  Castle & sync, Low).
- **F-2** (a crash after the swap, before the export step, leaves the app's weekly-copy switch on while the sealed
  setting turns off at resume): HELD FOR THE LADDER — a traced crash-window corner on U2a-3's mirror; round 1's reviewer
  judges severity; the fix leg takes it if confirmed.
- **F-3** (no lock on the new road — Castle's idle lock and Lock Now unwired; `canLock` false): a NAMED HAND-FORWARD to
  VX-308's plan (a ticket at closeout if VX-308's scope doesn't carry it). Not a walk blocker: the Always-ask lobby is
  reached by relaunch.
- **F-4** (the restore hold's gate on synced crossings): VX-308's by construction (§5a already says the account arms are
  VX-308's).
- **F-5** (today's store-id envelope beside the slot keeps the pre-crossing key — unread on the new road, dead weight at
  VX-329): a ticket at closeout (Debt, Low).
- **F-6** (Data Safety's Castle warning reads today's posture): U2c's — §5e piece 3 amended to name it.
- **F-7** (SurfaceContracts' Library-protection line gains the crossings' faces): the closeout's canon delta list.
- **F-8** (the phone has the re-arm card, no crossing faces): the closeout's MOBILE PARITY row.
- **U2a-4's overlap question, RULED:** no conflict — U2a hides TODAY's rows on the NEW road; U2c rewords those rows as
  they render on TODAY's road (Release); U2c must NOT un-hide them on the new road.
- **The walk precondition is satisfied:** the dev library's words are `VARIORUM_DEV_NEWROAD_WORDS` in
  `~/.variorum/dev-castle.env` (the coordinator's dev-store facts; values never committed). No fresh dev library needed.

### U2b RECORD — THE TWELVE WORDS, HER WAY (Opus implementer, 2026-10-18; ticket VX-412 — BUILT; the Mac suites and the walk PENDING)

**Not done in U2b, first:**
- **A CORE CUSTODY LINE WAS WRITTEN (piece 1, P-VX307-U2b-1 — ARBITRATE FIRST):** the amended rules cannot be built on
  the core as it stood — the new-words act asked a passphrase always, and the card offers the words while no passphrase
  exists. `regenerateWords` now takes `passphrase: String?`; nil is asked nothing ONLY in Standard, unsynced, with no
  passphrase lock (the reset door's Standard plain confirm, twinned). No new act; no `Sync/` line. If the arbitration
  rules the other way, the fallback is option (b) below (a passphrase chosen before the first look — no core line).
- **No Mac suite was RUN** (the brief: no stage, no `xcodebuild test`) — only BUILT (`build-for-testing` green on the
  final tree). The list below is the orchestrator's. What DID run: the core (full Debug suite; the protection set in both
  configurations) and this session's headless harness over the real `Shared/Protection/` files (101 / 14 — the recipe
  below).
- **The walk was not done** (the orchestrator's — the recipe below: the calm first open, the card's click, the toast,
  the snooze, the tour's last card, the Settings door). No Debug app launched; the dev store, the real store and
  `/Applications` untouched.
- **The phone is untouched in behaviour** (P-VX307-U2b-0): its creation card stands; its shared brains compile (the band
  model is built there and rendered nowhere). The phone's calm first open is a VM ticket at closeout (the MOBILE PARITY
  line).
- **Not touched here (hand-forwards below):** the readme's Start Here words passage (byte-pinned to VX-306 §7c (5) — now
  contradicts the amended rule 2), the canon lines (SurfaceContracts' "the once-shown words card at creation";
  CastleRules' status note "Until VX-412 lands…"), the card's ledger across Make this my library.

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece 0 — this record skeleton: DONE (this commit).
- Piece 1 — the core's new-words act on a library with NO passphrase: DONE (`95bde6ea3`). **THE GAP (traced):** the
  amended rules 2–3 show the words only when she asks — from the card, which offers them WHILE NO PASSPHRASE EXISTS
  (rule 3), or at the tour's last card BESIDE the passphrase ask — and a look mints the words through rule 6's act; the
  act as built (`regenerateWords(_:passphrase: String, newWords:)`, design §3.9 "new words (asking the passphrase)")
  verified the passphrase against the live key file always (`verifiedPassphrase` → `.passphraseDoesNotOpen` on a key
  file with no passphrase lock), so the look could not run on the very library the card is for. **BUILT:**
  `regenerateWords(passphrase: String?)` — nil is asked nothing ONLY in Standard, unsynced, with no passphrase lock on
  the live key file (the reset door's Standard plain confirm, twinned: this Mac holds the key, the library is open);
  a library WITH a passphrase is asked it exactly as before; Castle and a synced library refuse nil
  (`secretMissing`). The key is unchanged (rule 6); the vault step is unreached (unsynced only). Every existing call
  site passes a `String` (unchanged). **Pins** `FirstLookWordsTests` (4, core, headless): the look on a fresh Standard
  library (fresh words open the live key file, the creation's no longer do, the key and every other lock and this
  Mac's items unchanged, the mirror follows, the words stored nowhere — the key file's canonical bytes and every memory
  item scanned); a library with a passphrase still asked (nil refuses, a wrong one refuses, the right one mints);
  Castle refuses nil; synced refuses nil. Debug `✔ Test run with 12 tests in 3 suites passed` (with the key-door and
  device-act suites). **MUTATIONS** (each restored by `git checkout --`, `git diff` clean): the nil arm answering the
  old act's `.passphraseDoesNotOpen` → `✘ Test run with 4 tests in 1 suite failed … with 4 issues` (the behaviour flip,
  red-on-old in effect); the narrowing dropped (nil asked nothing anywhere) → `✘ … with 6 issues` (Castle, synced and
  with-a-passphrase all red). PROVISIONAL P-VX307-U2b-1 — THE FIRST ITEM TO ARBITRATE (a core custody line).
- Piece 2 — the creation-time words card retires on the Mac: DONE (`a1a948c73`).
  `ProtectionRoad.wordsCardAtCreation(mac:)` (pure: false on the Mac; TRUE on the phone — P-VX307-U2b-0, its card
  stands this phase) read as `showsWordsAtCreation`; `AppBootstrap.finish(.roadCreated)` on the Mac opens straight on
  (`beginOpening(roadOpened:)` — the creation's words dropped unseen; nothing stores the words; a log line says so).
  The Mac route suites FLIPPED (`ProtectionRoadRouteTests.aFreshSlotCreatesAndOpensWithNothingInFrontThenReopensQuietly`,
  the missing face's two `startANewLibrary…`, `ProtectionFacesRouteTests.rule27sLobbyStartsANewLibraryThroughTheBootstrap`
  — `.newLibraryWords` → `.ready`; red on the pre-VX-412 tree by construction, whose state there was the card; their RUN
  is the orchestrator's under the stage — PENDING). Pin `RoadCreationFaceTests` (1, headless): the Mac never, the
  phone yes, this build its platform's. MUTATION (the rule `true` everywhere) → `✘ … with 2 issues`, restored.
- Piece 3 — the shared brains: DONE (`6a0b5a05a`). `Shared/Protection/WordsBand.swift`: `WordsCardRules` (the offer:
  a writing road, not dismissed, not recorded, not snoozed; the two columns) · `WordsCardLedger` (LOCAL, per library,
  this Mac's defaults beside the reminder's keys — `variorum.calmAsks.words.<libraryID>.{dismissed,recorded}`; never
  the words) · `WordsCardSnoozes` (this process's only — the next launch shows the card again) · `WordsLookModel`
  (closed → asking [only where a passphrase exists — rule 6] → minting → shown [Copy; `copied`] → warning [her "these
  words won't be shown again"; *Go back*] → closed, the words forgotten, `recorded`) · `WordsBandModel` (the words'
  offer; *Later*; the ✕ → dismissed for good + the toast's sentence handed back; recorded at ANY home retires the
  offer; RULE 3's REMINDER FOLDED — `showsReminder`, `visible` = the offer, a look in progress, or the reminder) ·
  `TourEndLibraryModel` (the passphrase ask beside the words; a passphrase chosen there handed to the look, never asked
  twice; the card's doors held while words are on screen). `ProtectionOpenRoad.mintFreshWords` (`ProtectionRoadActs`:
  one act at a time on the session; fresh words from the system's `ids.mintWords`, `regenerateWords` on the session's
  executor, the session's library updated, a log line with the fingerprint only — never the words). `RoadStandingModel`
  gains `band` (built in `make` — its ledger in the reminder ledger's defaults, `copyWords` the platform's clipboard
  rule injected), `makeWordsLook()` (the other homes' looks over the same roads), and `makeSetPassphraseSheet(close:
  onSet:)`. `ProtectionWords` gains the U2b lines (rule 2's card sentence and the warning HERS; the rest PROVISIONAL
  P-VX307-U2b-2). **Pins** `WordsBandTests` (11, headless): rule 2's sentence byte-equal to the rules file (wrapped
  whitespace collapsed) + no shouting caps; the snooze (gone this launch, back at the next); the ✕ (dismissed for good,
  the toast names Settings ▸ Protection); a read-only road offers nothing; the look with no passphrase (minted at the
  click, Copy, the warning, *Go back*, the close forgets and records, a later look says rule 6 and mints FRESH words);
  with a passphrase (asked first; empty asks nothing; wrong says why; right mints; Cancel mints nothing); the reminder
  folded (both asks one card; the reminder alone keeps it); THROUGH THE REAL ROAD on a planted session (fresh words open
  the live key file, the creation's don't, the key unchanged, every other lock stays, and the words stored NOWHERE —
  every file under the temp slot, every memory item, the card's defaults domain scanned); a passphrase asked through
  the real road (wrong writes nothing); the tour's last card both orders (the passphrase first — the look mints with
  it, not asked twice, the doors held; the words first — minted with nothing asked; a second visit asks the
  passphrase). The harness `✔ Test run with 100 tests in 14 suites passed`. MUTATIONS (restored, `git status` clean):
  the warning bypassed → `✘ … with 3 issues`; the snooze persisted as a dismissal → `✘ … with 1 issue`.
- Piece 4 — the Mac faces: DONE (this commit). `Features/Protection/WordsBandCard.swift`: `WordsBandCard` (the card
  above the quick entry — her drawing's band, between the shelf listing and the quick-entry line, the board's own
  28-pt gutter, the main column's full width; never a popup, never the lobby: the words row is rule 2's sentence
  [hers] as the whole door in the accent ink, *Later*, the ✕ [its toast through the status seam's `direct` — always
  shown]; RULE 3's REMINDER folded in, its line and doors and its own set-passphrase sheet), `WordsLookPanel` (the
  look wherever composed: the passphrase asked only where one exists, the words numbered in two columns in the mono
  face, never selectable, privacy-sensitive, *Copy* through the model's road + its caption, "write these down now",
  rule 6's sentence on a later look, *I've written them down* → her warning with *Go back* · *Close*, no Return
  shortcut anywhere), `TourEndLibraryBlock` (piece 5), `WordsLookSection` (Settings ▸ Protection — the door the ✕'s
  toast names; a fresh look per press). `ShelfView` gains `wordsBand: AnyView?` rendered after the listing and before
  `entryBar` (the offer line's road — the Bookcase never holds the model); `RootView` gains `protectionFaces`
  (`bootstrap.roadStanding`, nil on today's road) and builds the card; `VariorumApp` passes it; `AppBootstrap` passes
  the Mac's one clipboard rule as `copyWords` (`WordsClipboard.copy` — 60 s, decision 23). **RULE 3's BOTTOM BAR
  RETIRED on the new road:** `ProtectionRoadBar` keeps rule 27's banner and the split pair's line, and still re-reads
  the reminder's schedule when the app becomes active (for the card). **The Mac's creation card face is DELETED**
  (`LibraryWordsCard.swift`); `VariorumApp`'s `.newLibraryWords` arm — unreachable on the Mac — renders the opening
  face and lets the open go straight on (the words forgotten unseen); `LibraryWordsCardTests` loses its face source
  pin (the model and §7c (1)'s words stay pinned — the phone's card). Settings ▸ Protection on the new road gains the
  words section. **Pins** (Mac suite — BUILT, the RUN PENDING under the stage): `WordsBandSurfaceTests` (8: the card
  hosted in every state — the offer + the reminder, the words, the warning, nothing, the ask; the ✕'s toast through
  the direction door; the tour's last card hosted with and without the two asks and holding its doors while words
  show; the Settings section hosted; BY SOURCE — the listing, then the card, then the quick entry; the reminder gone
  from the bottom bar and carried by the card; the faces name no raw pasteboard, no `.textSelection(.enabled)`, no
  `keyboardShortcut`, no `.popover`/`.alert`/`.confirmationDialog`, the bootstrap's one clipboard rule; the Mac's
  creation face deleted); `TravellingDotsIndicatorTests`' surface list gains `WordsBandCard.swift`.
  `xcodebuild … -configuration Debug -derivedDataPath DerivedData/vx307 build-for-testing` → `** TEST BUILD SUCCEEDED
  **` (no warning in a file this batch touched but three pre-existing `Text +` deprecations in `ShelfView.swift` and a
  pre-existing `try` note in `ProtectionRoadRouteTests.swift:260`); the phone `-scheme VariorumMobile -destination
  'generic/platform=iOS Simulator' build` → `** BUILD SUCCEEDED **`; the headless harness `✔ 100 tests in 14 suites`.
- Piece 5 — the tour's last card: DONE (this commit — the same diff as piece 4: the faces share one file).
  `TourOverlay` takes `endLibrary` (the composition root's factory; nil on today's road) and makes ONE
  `TourEndLibraryModel` when the end card first shows; `TourEndCard` gains `library` — on the new road
  `TourEndLibraryBlock` between the aside and the three doors: the passphrase ask (§7c (7)'s lead and fields, only while
  the library has none; *Passphrase set.* after) and the words door (rule 2's sentence) → the look in place; THE THREE
  DOORS WAIT (`.disabled`) while words are on screen — leaving would put them away without her warning (PROVISIONAL
  P-VX307-U2b-5). Today's road: `library` nil — the end card byte-identical in what it draws. Pins: the headless
  `WordsBandTests` tour pair (piece 3's record) + the hosted `WordsBandSurfaceTests` pair above.
- Piece 6 — the lifecycle page's stages 1–2 from the FIXTURE: DONE (`aadcf2e9c` the fixture + this commit — the page).
  `LifecycleFixture` stage 1: *Nothing is shown: the first open is the Bookcase and the quick entry with nothing in
  front of them, and the card above the quick entry offers the words until you record them or dismiss it.*; its note's
  reminder now *the card above the quick entry reminds you*; its facts — `.wordsShownOnce` RETIRED there for the new
  `.wordsStoredNowhere` (the creation's words, handed back by the door and shown to no one, open the key file and are
  stored nowhere) + a `.notAModelFact` line for the face (the first open's calm is `RoadCreationFaceTests` and the route
  suites'). Stage 2: *The tutorial ends: you set a passphrase and record your twelve words* — *The tutorial's last card
  asks for a passphrase and shows your twelve words beside the ask. Nothing keeps the words, so they are made when you
  look: the key file gains a passphrase lock, and its words lock is re-made under the words you write down. The key
  itself does not change, and nothing else changes [2, 3, 6].*; facts `.keyUnchanged`, the locks, `.lockRelocked(.words)`
  (new), `.wordsShownOnce` (now the LOOK's words — `LStageContext.shownWords`), `.nothingElseChanges(except: [.passphrase,
  .words])` (the case now takes a list). `LifecycleWalk.stage2`: `resetPassphrase(.plainConfirm)`, then
  `regenerateWords(passphrase: <the one just set>, newWords:)` — the tour card's passphrase-first order.
  `LifecycleChecks`: the two words facts share one check (the look's words vs the creation's). `LifecycleProse`: the
  three-roads table's words row reads *shown once when you ask*. All page prose here is PROVISIONAL P-VX307-U2b-3 (the
  page is hers; the rules are amended and the page "follows at that merge"). **The page REGENERATED** (never
  hand-edited): `CASTLE_LIFECYCLE_PAGE_OUT=<scratch> swift test --filter LifecyclePageTests` → `cp` over
  `notes/plans/vx-266/castle-lifecycle.html` — the diff is exactly stages 1–2 and the table row (5 lines). Debug
  `LifecyclePageTests` + `LifecycleScenarioTests` `✔ Test run with 6 tests in 2 suites passed`. **RED-ON-OLD** (the old
  walk — no look at the tour's end, the words "shown" at the creation — against the new fixture, restored by `git
  checkout --`): `✘` on every argument pair, stage 2's *the words lock is the same* · *the old words still open it* · *the
  door handed back no words*.
- Piece 6b — ONE LOOK AT A TIME (found while closing): DONE (`d723b0eda`). Two homes open at once (the card and
  Settings, say) would each mint — the second's words REPLACE the first's, which would stay on screen no longer opening
  the library (she could write down stale words). `WordsBandModel` keeps every look it made (weakly) and a look's mint
  REFUSES while another holds words (*Your twelve words are already on screen — finish with them there first.*,
  PROVISIONAL P-VX307-U2b-6). Pin `WordsBandTests.oneLookHoldsWordsAtATime` — MUTATION (the guard off) → `✘ … with 2
  issues`, restored. `WordsBandModel.refresh()` dropped as dead (`020d6ab8e`).
- Piece 7 — the close: DONE (this commit) — the counts, the Mac suite list, the walk recipe, the PROVISIONALs and the
  findings below.
- No revert is in flight (every mutation restored by `git checkout --`, `git status` clean; no scratch worktree).

**THE FACES AS BUILT (for the ladder):** the bootstrap's `.roadCreated` on the Mac goes straight to the open (the
creation's `OnceShownWords` dropped unseen); at `.ready` `RoadStandingModel.make(session, ledger:, copyWords:)` builds
the faces and, new, the BAND (`WordsBandModel` over the session: its ledger in the reminder ledger's defaults, the snooze
this process's, the mint `ProtectionOpenRoad.mintFreshWords` off the main actor — one act at a time on the session,
`ids.mintWords()`, `regenerateWords` on the session's executor, the session's library updated — and `copyWords` the
Mac's `WordsClipboard.copy`). `VariorumApp` hands `bootstrap.roadStanding` to `RootView` (`protectionFaces`), which
builds `WordsBandCard` for the Bookcase's new `wordsBand` slot (after the listing's `ScrollView`, before `entryBar`) and
a `TourEndLibraryModel` factory for the tour's layer (`TourOverlay` makes ONE when the end card first shows;
`TourEndCard` renders `TourEndLibraryBlock` above its doors and holds the doors while words show). The ✕'s toast is
`session.status.direct` (always shown — a direction, not a receipt `receipt_style` could hide). Settings ▸ Protection
(new road) gains `WordsLookSection` (a fresh look per press over `standing.makeWordsLook()`). `ProtectionRoadBar` keeps
rule 27's banner, the split pair's line and the became-active re-read of the reminder; the reminder's row renders in the
card. Every look records through the band (the ledger's `recorded`), so the card's offer retires wherever she looked.
Today's road: `protectionFaces` nil → no card, the end card exactly as it was, the pane's new section absent; the
`.newLibraryWords` arm unreachable on the Mac. ZERO `Sync/`, `Server/`, schema or dependency lines; ONE core line set
(`KeyDoors.swift` — the nil arm).

**COUNTS (the final tree):**
- Core, Debug, the full suite (`swift test`): VariorumCoreTests `✔ Test run with 3304 tests in 429 suites passed after
  203.589 seconds.`; the third target `✔ Test run with 40 tests in 6 suites passed`; VariorumMCPTests `✘ Test run with 383
  tests in 71 suites failed … with 1 issue` — the ONE known wall-clock flake
  (`MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`, 19.6 s vs 15 s under the full
  parallel run; alone `✔ … passed after 1.055 seconds`; no MCP line in this diff — U1's recorded flake).
- Core, the protection set (every `@Suite` under `Tests/VariorumCoreTests/Protection`, 82 now — +`FirstLookWordsTests`):
  Debug `✔ Test run with 331 tests in 82 suites passed after 6.944 seconds.`; Release (`swift test -c release`, the same
  filter) `✔ Test run with 307 tests in 78 suites passed after 3.902 seconds.`
- HEADLESS HARNESS (this session's — not durable; U2a's recipe exactly: a scratch SwiftPM package, tools 6.2, macOS 26,
  `.defaultIsolation(MainActor.self)` + `NonisolatedNonsendingByDefault` + `InferIsolatedConformances` +
  `MemberImportVisibility`, the worktree's core by path + swift-dependencies; its `Variorum` target SYMLINKS every
  `Shared/Protection/*.swift` but `ProtectionBackupHook.swift` and `WireVaultLeaf.swift` (`WordsBand.swift` among them),
  plus `Shared/LibraryOpenCopy.swift`, plus one stub file (`ProtectionCopy`'s three names, `KeychainTestTripwire`,
  `KeychainPartition`, `AppleKeyKeychain`, `AppleKey`, `DeviceName`, `BackupDestination`, a nil `WireVaultLeaf.live`,
  `AuthTokens`/`KeychainAuthStorage`, `EncryptionSession.words`); its tests symlink `ProtectionTestSupport`,
  `ProtectionFacesSupport`, `ProtectionOpenRoadPlantedTests`, `ProtectionWordsPlanTests`, `ProtectionLobbyModelTests`,
  `PassphraseReminderTests`, `ProtectionNoticeFaceTests`, `ProtectionOfferFaceTests`, `ProtectionWalkSwitchTests`,
  `RoadCrossingFacesTests`, `ProtectionCrossingRoadTests`, `RoadCrossingModelTests`, `RoadRearmTests` (U2a's 88) and this
  batch's `RoadCreationFaceTests` + `WordsBandTests` (+ a one-line `RoadWorld.RoadWorldError` stub; a test reading a repo
  file resolves its symlinked `#filePath`)): **`✔ Test run with 101 tests in 14 suites passed after 0.626 seconds.`**
- MUTATIONS (each restored, `git status` clean): the core's nil arm answering the old `.passphraseDoesNotOpen` → 4 red;
  the narrowing dropped → 6 red; the creation rule `true` everywhere → 2 red; the warning bypassed → 3 red; the snooze
  persisted → 1 red; the one-look guard off → 2 red; the OLD lifecycle walk (no look at the tour's end) against the new
  fixture → red on every argument pair at stage 2.
- `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx307
  build-for-testing` → `** TEST BUILD SUCCEEDED **` (no new warning; the three `Text +` deprecations in `ShelfView.swift`
  and the `try` note at `ProtectionRoadRouteTests.swift:260` pre-exist); the phone `-scheme VariorumMobile -destination
  'generic/platform=iOS Simulator' -configuration Debug … build` → `** BUILD SUCCEEDED **`; **the Release check
  `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Release -derivedDataPath DerivedData/vx307
  build` → `** BUILD SUCCEEDED **`.**
- Release behaviour: unchanged by construction — every new face sits behind `protectionFaces`/`roadStanding` (nil on
  today's road) or `ProtectionRoad.showsWordsAtCreation` on a state only the new road reaches; the core's act with a
  `String` passphrase behaves exactly as before, and nothing on today's road calls it. The binary is not byte-identical
  (the new types compile in both configurations — rule 24, U1b's precedent).

**THE MAC SUITES THE ORCHESTRATOR RUNS UNDER THE STAGE (from `App/Variorum/`; PENDING):**
```
xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx307 test \
  -only-testing:VariorumTests/WordsBandTests \
  -only-testing:VariorumTests/WordsBandSurfaceTests \
  -only-testing:VariorumTests/RoadCreationFaceTests \
  -only-testing:VariorumTests/ProtectionRoadRouteTests \
  -only-testing:VariorumTests/ProtectionFacesRouteTests \
  -only-testing:VariorumTests/LibraryWordsCardTests \
  -only-testing:VariorumTests/PassphraseReminderTests \
  -only-testing:VariorumTests/ProtectionReminderRoadTests \
  -only-testing:VariorumTests/ProtectionRestoreReceiptTests \
  -only-testing:VariorumTests/ProtectionPaneRoadRowTests \
  -only-testing:VariorumTests/RoadCrossingSurfaceTests \
  -only-testing:VariorumTests/ProtectionOpenRoadPlantedTests \
  -only-testing:VariorumTests/ProtectionNoticeFaceTests \
  -only-testing:VariorumTests/ProtectionOfferFaceTests \
  -only-testing:VariorumTests/ProtectionCrossingRoadTests \
  -only-testing:VariorumTests/ProtectionCrossingRouteTests \
  -only-testing:VariorumTests/MakeMineRouteTests \
  -only-testing:VariorumTests/ProtectionRule27FaceTests \
  -only-testing:VariorumTests/ProtectionSurfaceRenderTests \
  -only-testing:VariorumTests/TravellingDotsIndicatorTests \
  -only-testing:VariorumTests/CopyRegisterPinTests \
  -only-testing:VariorumTests/NoLiteralColourTests \
  -only-testing:VariorumTests/StatusSeamVocabularyTests \
  -only-testing:VariorumTests/WordsCopyDoorTests \
  -only-testing:VariorumTests/TourScriptTests \
  -only-testing:VariorumTests/TourSpotlightTests \
  -only-testing:VariorumTests/TourEngineTests \
  -only-testing:VariorumTests/TourPoolTuckTests \
  -only-testing:VariorumTests/TourEntryTests \
  -only-testing:VariorumTests/TourEndCardTests \
  -only-testing:VariorumTests/TourEndCardAsideGateTests \
  -only-testing:VariorumTests/TourOfferLineTests \
  -only-testing:VariorumTests/BookcaseQuickEntryPlacementTests \
  -only-testing:VariorumTests/QuickEntryLaunchFocusTests \
  -only-testing:VariorumTests/StatusToastPlacementRuleTests \
  -only-testing:VariorumTests/StatusToastPlacementShellTests \
  -only-testing:VariorumTests/ShellChromeTests \
  -only-testing:VariorumTests/VX310TodayLobbyWitnessTests
```
The first three are U2b's new suites (12 + 8 + 1 = **21 tests**); `ProtectionRoadRouteTests` and
`ProtectionFacesRouteTests` carry the four FLIPPED route pins (the signed host — a throwaway keychain scope, a temp slot;
red on the pre-VX-412 tree by construction: their state there was `.newLibraryWords` — the orchestrator may confirm by
reverting `a1a948c73`'s `AppBootstrap` arm on a scratch tree, optional); then the suites over every file this batch
touched (the faces model and its factory, the road acts, the pane, `ProtectionRoadBar`, the Bookcase, the shell, the tour
overlay and end card) and the source pins over edited files. `VX310TodayLobbyWitnessTests` still reports its KNOWN ISSUES
(a pass of either is a FAILURE); read the `skipped:` lines.

**THE WALK RECIPE (the orchestrator's, under a held stage claim; the DEV STORE only; light and dark — the card speaks
the Bookcase's voice, the tour's card its own):**
0. Zero Debug instances (by PATH; a `/Applications` instance is NEVER touched). Build and launch as U2a's recipe row 0.
   `source ~/.variorum/dev-castle.env`. **WARNING — the card mints:** the dev library's words are recorded
   (`VARIORUM_DEV_NEWROAD_WORDS`) but this Mac's card ledger has no record of a look, so the card OFFERS the words on the
   dev library; a look there REPLACES its words — update `VARIORUM_DEV_NEWROAD_WORDS` in `dev-castle.env` in the same
   window (CLAUDE.md: when one must change, update the file), or walk the look on a throwaway library only (row 1).
1. **The calm first open + the card (a throwaway library B).** Quit. Library A aside exactly as VX-306's U2 walk row 5
   (`mkdir -p ~/vx307-walk/A && mv DC/variorum.sqlite DC/variorum-library-keys.json DC/variorum-keys-*.json
   ~/vx307-walk/A/`). Launch → the missing face → *Start a New Library* → **B opens straight onto the Bookcase: NO words
   card, no lobby in front** (log `road: created — the first open goes straight on (the words wait for her look)`); the
   card sits between the shelf listing and the quick-entry line, the column's width: *Your library is encrypted — click
   here to record the twelve words that are its key.* · *Later* · ✕ — and, the first backup's always-moment, rule 3's
   reminder row in the same card. Capture (light, dark).
2. **The snooze.** *Later* → the words row goes (the reminder row stays while owed); quit → relaunch → the card offers the
   words again (log `road: the words card snoozed to the next launch`). Capture.
3. **The click.** Click the sentence → (B has no passphrase) the words at once: *Write these down now…*, the twelve words
   in two columns (not selectable), *Copy* → *Copied. Your clipboard clears in 60 seconds.* (paste once to a scratch
   field, then 60 s → the clipboard is empty), *I've written them down* → *These words won't be shown again.* · *Go back*
   · *Close* → *Close* → the words row gone for good (log `rule 2's look closed`). Capture each (light, dark). B's live key
   file: `grep -c` for any of the words → 0. Quit → relaunch → no words row.
4. **The ✕ and the toast.** Make a second throwaway C the same way (or reset the ledger key
   `variorum.calmAsks.words.<B's id>.recorded` with `defaults delete` on the dev domain) → ✕ → the toast *You can record
   your twelve words any time in Settings ▸ Protection.* (always shown, whatever `receipt_style`). Capture. Settings ▸
   Protection → *Your twelve words* · *Record your twelve words…* → the look there (B/C has no passphrase → minted at
   once; with the dev passphrase set, the field first).
5. **The tour's last card.** Help ▸ Take the Tour → walk to the end card → above the three doors: the passphrase ask
   (§7c (7)'s lead, two fields, *Set passphrase*) and the sentence door; set a passphrase → *Passphrase set.*; click the
   sentence → the words at once (not asked again); the three doors are greyed until *Close*. Capture (light, dark).
6. **Posture after the window:** B (and C) aside into `~/vx307-walk/B…`, A back (`mv ~/vx307-walk/A/* DC/`) → A opens with
   the different-library notice once (VX-306's row 5) → OK. The dev library A is as before, its words unchanged (never
   looked at in this recipe). `rm -r ~/vx307-walk` when done; record the posture for the coordinator.

**PROVISIONALs (each built as its option (a); for the orchestrator to bundle under QUESTIONS at the closeout):**
- **P-VX307-U2b-0 — the phone keeps its creation card this phase.** (a) BUILT — `wordsCardAtCreation(mac:)` true on the
  phone; the phone's calm first open (the card in its own band) is a VM ticket — the MOBILE PARITY line; (b) retire it
  on the phone too, with no phone band (the words then never shown on the phone — rule 2 broken there); (c) build the
  phone's band now (out of this batch's surface).
- **P-VX307-U2b-1 — the first look on a library with no passphrase (A CORE LINE).** (a) BUILT — `regenerateWords(passphrase:
  nil)` asks nothing in Standard, unsynced, with no passphrase lock (the reset door's Standard plain confirm twinned —
  this Mac holds the key; rule 3: "the passphrase is a convenience over the words"; rule 2: shown "when the user asks";
  rule 3: the tour's card shows the words "beside the ask"); (b) no core line — the look on a passphraseless library asks
  her to CHOOSE a passphrase first (rule 6's door "asking the passphrase" kept literally; but the words then depend on a
  passphrase she may not want, and "beside the ask" becomes "after it"); (c) the core's new-words door plain-confirm in
  Standard always (asks nothing even where a passphrase exists — a wider change than the rules need).
- **P-VX307-U2b-2 — the undrafted words** (`ProtectionWords`' U2b section): *Later*; *Dismiss*; the toast *You can record
  your twelve words any time in Settings ▸ Protection.*; the ask *Enter your passphrase to see your twelve words.*; *Your
  passphrase*; *Show my twelve words*; *Cancel*; *Making your twelve words…*; the lead *Write these down now. They open
  your library — on this Mac and on any copy of it — for as long as they are its words.*; rule 6's sentence *Your
  library's key doesn't change: every backup opens with these words, and still with the words you had when you made
  it.*; *Copy* and its caption; *I've written them down*; *Go back* · *Close*; *Variorum couldn't make your twelve words
  just now. Nothing changed.*; the Settings section (*Your twelve words*, its line, *Record your twelve words…*); *Passphrase
  set.*; the one-look refusal. HERS verbatim (pinned): rule 2's card sentence; the warning *These words won't be shown
  again.* (b) blank until her sitting; (c) other words.
- **P-VX307-U2b-3 — the lifecycle page's stages 1–2 prose** (the page is hers; drafted from the amended rules): stage 1
  *Nothing is shown: the first open is the Bookcase and the quick entry with nothing in front of them, and the card above
  the quick entry offers the words until you record them or dismiss it.*; stage 2's title and *What happens*; the
  three-roads table's *shown once when you ask*.
- **P-VX307-U2b-4 — where and when the card speaks.** (a) BUILT — the card lives on the Bookcase only (her drawing), so
  rule 3's reminder — now IN the card — is seen on the Bookcase; its showings still count when owed (at the open), not
  when seen; the first launch's card carries both rows (the words' offer and rule 3's first-backup always-moment —
  P-VX306-U2-9's timing kept); (b) the card on the Library too (the shared `QuickEntryBar`'s other host); (c) hold the
  reminder row back while the words row stands at the first launch.
- **P-VX307-U2b-5 — the tour's last card holds its doors while words show** (leaving would put the once-shown words away
  without her warning). (a) BUILT — the three doors disabled until *Close*; (b) a door pressed mid-look warns first; (c)
  the doors free (the words lost unwarned).
- **P-VX307-U2b-6 — one look at a time.** (a) BUILT — a second home's look refuses to mint while another holds words;
  (b) a second look mints and the first is closed with a line saying its words were replaced; (c) nothing (two homes
  could show different words, one set stale).
- **P-VX307-U2b-7 — after a look is recorded the card's words row retires for good** (rule 2: the card stays "until they
  are recorded"; *I've written them down* past the warning is the record); Settings ▸ Protection keeps the door (rule 7's
  new-words door). (b) the card stays until the ✕ even after a look (her "present until the user clicks the dismissing x
  button" read literally); (c) the card returns weekly like the reminder.

**FINDINGS AND HAND-FORWARDS (routed, not fixed here):**
- **F-U2b-1 (the readme's Start Here, a contradiction this batch creates):** the seeded words passage
  (`BirthFurnitureSeeders.startHerePassages[1]`, byte-pinned to VX-306 §7c (5) by `ReadmeStartHerePlanTests`) says *They
  were shown once, when the library was created … you can make new ones in Settings ▸ Data Safety* — on the new road both
  clauses are now false (shown when she asks; the door is Settings ▸ Protection). VX-379's rows (U2c) or the closeout's
  — the plan's §7c (5) text and the passage together.
- **F-U2b-2 (canon, the closeout's):** SurfaceContracts' "Library protection" line names *the once-shown words card at
  creation, rule 3's reminder* — now the card above the quick entry (both asks), the tour's last card and Settings ▸
  Protection's words door; CastleRules' status note *Until VX-412 lands, the Debug build and the lifecycle page's stage 1
  still show the creation-time words card; the page follows at that merge.* retires at the merge (the page has followed).
- **F-U2b-3 (Make this my library and the card's ledger):** the ledger is per library ID; Make this my library makes a
  NEW library (a fresh identity) under the CURRENT pair, so its card offers the words again although she knows them — a
  look would replace a pair she holds (harmless, confusing). Options: carry `recorded`/`dismissed` across the act in the
  bootstrap's `makeThisMyLibrary`; or accept. Not a walk blocker.
- **F-U2b-4 (the phone):** P-VX307-U2b-0's VM ticket — the calm first open, the band, the look and the tour's equivalent
  on the phone (its pasteboard arm is the mobile row's).
- **F-U2b-5 (the dev store, the walk):** the dev library's card offers the words (row 0's warning) — a look there changes
  `VARIORUM_DEV_NEWROAD_WORDS`.

**Notes:** no machinery deaths; no Sonnet lookup; no scratch worktree; every mutation restored and `git status`-checked.
Commits: `edbd86c14` (record) · `95bde6ea3` (1) · `a1a948c73` (2) · `6a0b5a05a` (3) · `e70797315` (record) · `67c32e85b`
(4–5) · `aadcf2e9c` (6 fixture) · `9c833dce5` (6 page) · `d723b0eda` (6b) · `020d6ab8e` (cleanup) · the close commit.

**U2b ARBITRATION (the orchestrator, the same night — repo-first before U2c spawns):**
- **P-VX307-U2b-1 ACCEPTED AS BUILT** (the orchestrator's ruling; the Fable ladder cold-reads the line regardless).
  The diff read line-by-line: 18 lines in `KeyDoors.swift`, zero `Sync/` lines; the nil-passphrase arm is guarded to
  STANDARD + UNSYNCED + the live key file current + NO passphrase lock, else `secretMissing`; every other path
  byte-unchanged. Why it is right, not merely acceptable: the amended rule 2 requires the words to be mintable BEFORE
  any passphrase exists (the card exists exactly for the no-passphrase era, and the tour's last card shows the words
  BESIDE the first passphrase ask — option (b) would contradict her ruled sequence); and the narrowing sits inside the
  posture's own trust model (that same library's reset door is a plain confirm — strictly more powerful — and its key
  opens by this Mac's quiet roads).
- **F-U2b-1** (the readme's Start Here words passage says creation-time words and points at Data Safety — both now
  wrong on the new road): U2c's — §5e amended below; the VX-306 byte-pin re-anchors HONESTLY (new text, the pin reads
  the new ruled source), never deleted to make the change fit.
- **F-U2b-2** (canon at closeout): the SurfaceContracts protection line gains the band card + the crossings' faces
  (with U2a's F-7); CastleRules' header sentence "Until VX-412 lands…" RETIRES at the merge (it lands here).
- **F-U2b-3** (the ledger doesn't carry across Make this my library — the card re-offers words for the pair she
  already knows, and a look would MINT AWAY from that pair): a ticket at closeout (Improvement, Low — carry the
  recorded flag with the pair; her eye in the bundle).
- **F-U2b-4**: the VM ticket at closeout (P-VX307-U2b-0; the MOBILE PARITY row).
- **F-U2b-5** (the walk): the card-state rows walk on a THROWAWAY library only; the dev library's card is verified
  RENDERED but never clicked through the look (a look would replace the dev pair). If any row ever forces a dev-library
  look, `~/.variorum/dev-castle.env` is updated in the same window (the standing rule).

### U2c RECORD — LOOK INSIDE'S COPY, THE WORDING, THE PANES, THE COPY-DOOR HAND-FORWARDS (Opus implementer, 2026-10-18 night; tickets VX-413 · VX-414 · VX-379's pane rows — BUILT; the Mac suites and the walk PENDING)

**Not done in U2c, first:**
- **No Mac suite was RUN** (the brief: no stage, no `xcodebuild test`) — only BUILT (`build-for-testing` green on the
  final tree). The list below is the orchestrator's. What DID run: the core (full Debug suite; the protection set in
  both configurations) and this session's headless harness over the real `Shared/Protection/` files (144 / 23); the
  Mac-only source pins' logic replicated in Python (green new, red old — piece 3).
- **The walk was not done** (the orchestrator's — the rows below). No Debug app launched; the dev store, the real store
  and `/Applications` untouched (the Release build check built into `DerivedData/vx307` only).
- **VX-379 is NOT closed by this batch:** the field guide's Castle/backups chapters stay VX-379's own (the brief); the
  pane rows were brought to the rules only where the words stay true of today's road (piece 3's principle) — the rows
  KEPT are listed in piece 3 and retire with today's road at VX-329; the new road's own "what opens a backup" line
  (rule 5) has no Data Safety face now that today's posture lines retire there (F-U2c-4).
- **Look inside has no Touch ID road of its own** after the flip (P-VX307-U2c-3) — a Touch-ID-only copy opens at the
  look by its secret (her pair opens her own copies — rules 4–5); a *Use Touch ID* door at the look is option (b).
- **The phone has no Look inside** (P-VX306-U3-18 stands) — its road carries no copy door (`copyFullTextRoad` nil there).
- **The canon deltas are the closeout's** (F-U2c-3).

**LIVE STATUS (per piece; PENDING = unverified):**
- Piece 0 — this record skeleton: DONE (this commit).
- Piece 1 — VX-413, Copy full text from Look inside's note page: DONE (this commit). THE CORE READ
  `ProtectionCopyPeek.Reader.fullText(id:)` runs THE export's own projection (`Queries.variorumDocumentText` — the
  format's one home `Domain/VariorumDocument`, consumed, never forked: the title, every live take with its label, the
  tags) over the look's private READ-ONLY connection (the peek's one non-raw-SQL read, said in its header); nil for a
  note that isn't a living post. THE BRAIN `LookInsideModel.copyFullText()` reads it off the main actor (the read in
  flight, so a close waits for it), hands the text to an injected clipboard road (`copyText`, from
  `CopyDoorsRoads.copyFullText` — the bootstrap's `AppBootstrap.copyFullTextRoad`: on the Mac `CopyForAI.put`, the ONE
  clipboard rule a live note's Copy full text now also calls — the general pasteboard, cleared then set, no expiry; nil
  on the phone, which has no look) and says `copyLine` in the sheet under the door: *Copied full text.* (CopyForAI's
  receipt), *Nothing to copy — this note has no text yet.* (CopyForAI's refusal, an untitled empty note), or the one
  added line *Variorum couldn't read this note's full text from the copy just now.* (PROVISIONAL P-VX307-U2c-2); the
  line clears on *Back*, on another note, on close. THE FACE: `LookInsideSheet`'s note page — *Back* · *Copy full text*
  (the live note's door name) only where the model offers it; the text stays read-only, never selectable. Nothing else
  about the sheet changes (read-only, nothing written, closing forgets). **Pins:** core `ProtectionCopyPeekTests
  .aLookHandsANotesFullTextInTheDocumentFormatAndWritesNothing` (the plant gains a labeled take and a tag: the look's
  full text BYTE-EQUAL to `Queries.variorumDocumentText` over the live library, its header `{t:"…"} {#trip}`, the
  Alternates section with `take: "first"`, parsed back whole; a deleted note nil; the catalogued folder byte-identical;
  a closed look refuses) — Debug `✔ Test run with 5 tests in 1 suite passed`; headless app `LookInsideRoadTests
  .theNotePagesCopyFullTextCarriesTheDocumentFormatAndWritesNothing` (the clipboard road handed exactly
  `{t:"A note in the backup"}\n\nOne.\n\nTwo.`, parsed whole; the receipt; the look still open and read-only; the empty
  note's refusal with nothing copied; every keychain write log and container byte unchanged; closing forgets; no road →
  no door) + `CopyDoorsModelTests.theDoorsHandTheLookItsCopyFullTextRoad` — the harness `✔ Test run with 17 tests in 2
  suites passed`; the Mac suite `LookInsideCopyDoorTests` (3: the door's name and sentences ARE the live note's —
  the registry's verb, CopyForAI's receipt and refusal; the Mac's road writes a named board by `CopyForAI.put`; the
  sheet's door by source, the text never selectable, no raw pasteboard in the face) — BUILT, its RUN PENDING under the
  stage. New feature: no red side (the API is new). Mac `build-for-testing` → `** TEST BUILD SUCCEEDED **`, no warning
  in a touched file.
- Piece 2 — VX-414, the split-pair line dropped + her two U2-7 sentences: DONE (`0eba2d245`). **U2-6 (her "sure we can
  drop the sentence"):** `ProtectionWords.offerSplitPair`, `RoadStandingFaces.splitPair`, `ProtectionRoadBar`'s
  `splitPairLine` — gone; the core's `KeyFileSearch.besideOpensItOnlyThroughItsHistory` stays (the model's answer; the
  faces now say nothing for it); its DERIVE PIN RETIRES with the line (`ProtectionOfferFaceTests
  .theSearchsOtherAnswersAreTheStandingFaces` now asserts the split pair says nothing — `.none`, no card) and
  `ProtectionWordsPlanTests` drops the line from §7c (2)'s list (the VX-306 plan keeps the draft as history). **U2-7
  (her "I agree with your suggested wording") — byte-equal to the ticket's text (the words block below):** (1)
  `ProtectionWords.noKeyFileAfterAQuietOpen` — the STANDING BANNER after a quiet open with no key file anywhere: the
  Mac's `ProtectionRoadBar` and the phone's `MobileNoKeyFileSheet` say it (the account-road sentence still follows when
  the library names an account — not ruled to change); both LOBBIES (nothing opened — `StoreLockView`,
  `MobileRoadLockView`) keep §7c (3)'s refusal. (2) `ProtectionWords.offerBesideEmptyFromABackup` + her sentence's
  question (`offerUseItQuestion` = *Use it?*, pinned the suffix of her `KeyFileOffer.backupHoldsOne`) — the interlude's
  offer when the place beside the library is EMPTY and a BACKUP holds the right file: the open's report gains
  `besideIsEmpty` (the library's `keyFile` nil when the search ran — set at the open and after *Use it*'s re-search),
  the card `.offer(offer, besideEmpty:)` (default false — every existing construction unchanged); a stray beside keeps
  her sentence; this Mac's keychain copy over an empty place (unreached — rule 1's quiet restore puts it back first)
  keeps her keychain sentence. The composition is PROVISIONAL P-VX307-U2c-4. **Pins:** `ProtectionWordsVX307Tests` (4,
  headless: her two sentences byte-equal to the plan's words block + the question her own sentence ends with + the
  split pair gone from the words and both faces by source; the banner's words on the Mac bar and the phone sheet with
  both lobbies keeping §7c (3), by source; THROUGH THE ROAD — the beside key file removed and this Mac's memory
  cleared, a backup holding the file: `besideIsEmpty`, the card, the sentence *There is no key file beside your library.
  A backup holds one that opens it. Use it?*, the receipt naming the backup's day, *Use it* putting the file back; a
  stray beside keeps her sentence; the keychain offer keeps hers). MUTATIONS on the committed tree (restored by `git
  checkout --`, `git status` clean): the variant's arm disabled → `✘ … with 1 issue` (the sentence); the report's
  `besideIsEmpty` line removed → `✘ … with 3 issues`. The harness `✔ Test run with 144 tests in 23 suites passed`; Mac
  `build-for-testing` → `** TEST BUILD SUCCEEDED **`; the phone `build` → `** BUILD SUCCEEDED **`.
- Piece 3 — VX-379's pane rows to the rules, today's rows on TODAY's road only (the U2a-4 ruling) + F-U2b-1: DONE (this
  commit). THE PRINCIPLE (recorded so the ladder can judge it): a today's row renders on today's road only, and where it
  renders its words move to the rules' language ONLY where the result stays TRUE OF TODAY'S ROAD (Release runs it until
  VX-329); rows whose today's-road FACTS differ from the rules keep their words (listed below — they retire with today's
  road). **(3a) THE POSTURE BOX (the VX-306 walk's W-1):** `ProtectionStatusRow` reads today's tier, and on the new road
  said *Right now, only this Mac can open your work.* — false under rule 8. `RootView.statusRows` composes it only
  with no new-road faces (`if let protection, protectionFaces == nil`); on today's road its words stay (true there: the
  exposed tier IS no Apple key landed, no passphrase, no words — this Mac's keychain the only holder); on the new road
  the card above the quick entry carries rule 3's ask (U2b). **(3b) DATA SAFETY'S TODAY'S ROWS (F-U3-1 + today's
  posture's backup lines):** the *Restoring a copy* lead — *Restoring is a Finder operation, not a button: …* — was
  false on today's road too since 13x's Restore from Backup door; now `DataSafetyCopy.restoringByTheDoor`, rule 17's
  language and true of today's road (*To restore a copy, use Restore from Backup above, or File ▸ Open Library… for a
  copy kept anywhere else: the copy becomes your library, and your current library steps aside whole into Previous
  Libraries. If Variorum won't open, the step-by-step for restoring by hand is in "RESTORE.md", which sits in every
  backup folder above.*), rendered on today's road only (`roadStanding == nil` — the new road's Restore list says it in
  its own lead); `BackupsPostureLines` (what opens a backup, by TODAY's posture — on the new road a Castle library read
  "Standard" there and was told its backups open through its Apple account, false under rule 11) on today's road only.
  Her mandated deletion sentences (the synced/local warnings, the both-sided truth) stay on both roads. `DataSafetyPane`
  takes `roadStanding` (Settings hands it, as the Protection pane's). **(3c) THE CASTLE WARNING (U2a's F-6):**
  `ProtectionCopy.plaintextExportUnderLockedDown` in rule 11's words — *You're in Castle — and a scheduled plain-text
  copy on disk would undo Castle's promise: every note, readable, on a timer, in the folder you picked. It's your
  call.* (true on both roads); shown by the pure `DataSafetyPane.castleWarningShows(todaysPosture:roadPosture:)` — on
  the new road by the OPEN library's posture (`RoadStandingModel.posture`, new: the record's mode, read when the open's
  faces are made — a crossing reopens and gets faces of its own), on today's road by today's controller as ever.
  **(3d) THE PROTECTION PANE'S TODAY'S ROWS (today's road only since U2a — reworded where they render):** the
  checklist (`ProtectionCopy.checklistRows`, the Mac pane its only renderer) — *Recovery phrase* → *Twelve words* (note
  *the passphrase's twin, on paper*), *iCloud key* → *Your Apple account* (notes *verified this launch — your Apple
  account opens the key file's copy* / *not landing — no copy verifiably opens through your Apple account* / in Castle
  *no road through Apple in Castle* — rule 8's and 9's words), the passphrase's note *opens any copy, and …* → *opens
  this library, and lets a new device into sync* (a copy opens with the passphrase it was made under — rules 4–5, and
  today's runbook §2 says the same); the two posture cards' floors *AND* → *and* (her no-shouty-caps rule), with
  `notes/DataSafetyRunbook.md` re-synced (the runbook's §8 composes the floors; `DataSafetyTests`' byte pin's own
  road). KEPT on today's road (true there, contradicting the new design's facts — they retire with today's road at
  VX-329, VX-379's remainder): the current-state lines (*Your Apple account holds a key.* / *Only you hold the keys.*),
  the keystones, the posture cards' other rows, Castle's switches, *Encryption passphrase* (today's road's one label on
  every field — a pane-only rename would split it), the re-link door (today's Apple-held vault copy — superseded by
  rule 14 on the new road), today's ceremonies and follow notices. All reworded lines PROVISIONAL P-VX307-U2c-7. **(3e)
  F-U2b-1 — THE README'S START HERE PASSAGE:** passage 2 (*They were shown once, when the library was created … in
  Settings ▸ Data Safety*) → the amended rules 2/3/7 (the words block below — PROVISIONAL P-VX307-U2c-5); the byte-pin
  RE-ANCHORED HONESTLY: `ReadmeStartHerePlanTests` now reads THIS plan's U2c words block (all four passages — 1, 3, 4
  byte-identical to VX-306's §7c (5), which keeps its drafts as history), its suite name and header saying so; the
  seeder's passage spelled once, its lead unchanged (the source pin's leads hold). **Pins:** `VX379PaneRowsTests` (4,
  Mac target: the posture box's gate by source; Data Safety's today's rows behind `roadStanding == nil` and Settings
  handing it; the warning's pure rule both ways + its wiring by source; the rows' words — rule 11's clause, rule 17's
  road, the checklist's names and notes, no *AND*) — its SOURCE PINS' logic replicated in Python over the files: green
  on this tree, RED on the pre-piece tree (`git show HEAD:` — all seven checks false); `Phase13pCopySweepTests
  .thePlainTextEscapeWarnsUnderLockedDown` follows the new words (a justified edit: *re-opens the door* → *would undo
  Castle's promise*); `ReadmeStartHerePlanTests` re-anchored — its parse replicated in Python: the four passages
  byte-equal to the seeder (passage 2 would be red against the old seeder). The Mac RUN of these suites PENDING under
  the stage. Mac `build-for-testing` → `** TEST BUILD SUCCEEDED **`; the phone `build` → `** BUILD SUCCEEDED **`; the
  harness `✔ Test run with 144 tests in 23 suites passed`; no new warning in a touched file (the one
  `AppSettingsView.swift:1247` warning pre-exists, a line this batch didn't touch).
- Piece 4 — the three VX-306 copy-door hand-forwards: DONE (`7f521bcbb`; red-on-old by revert below).
  **(i) ONE PRESS at Make this my library (round-2 NIT 1 (i)).** TRACED: the door's preflight
  (`ProtectionCopyDoors.preflight`) runs a look at her press (`lookInside(… .includingTouchID)`) and the act
  (`ProtectionExecutor.makeThisMyLibrary(copySecrets:)`) opened the copy AGAIN through `openCopy(… .includingTouchID)` —
  so a copy whose own secret was mistyped (or that only this Mac's Touch ID item holds) read the Touch ID item twice:
  two prompts for one press. FIX: the core gains `makeThisMyLibrary(_:opened:copy:in:currentPair:)` — the act takes the
  key the look OPENED and re-verifies it against the copy's own file (`copyKeyOpens` — its fingerprint among the copy's,
  and `copyOpens` on the copy's file: a read that never prompts; `openCopy`'s own check, factored out) instead of
  opening it again; a key that no longer opens the copy refuses `copyDoesNotOpen` with nothing written. One private body
  serves both forms (the secrets form stays for the lifecycle walk and the scenario world, which never hand a key).
  `LookedInside` becomes `Sendable`. The app: `Preflight.ready` carries the look (`.ready(copy, catalog, opened)`);
  `ProtectionCopyDoors.makeMine` takes `opened:` (no `copySecrets` any more); `AppBootstrap.makeThisMyLibrary` hands
  the preflight's look to the act. No `Sync/` line; the custody stays the executor's (VX-313: a handed key steers
  nothing — it must open the copy's own file). **(ii) THE FLIP-TARGET FLIPPED (round-2 NIT 1 (ii)).**
  `LookInsideModel.submit` hands `.withoutAPress`: her typed *Open* tries what she typed and the quiet roads that never
  prompt — a wrong secret refuses in words (`copyDoesNotOpen`) and never falls through to a Touch ID press
  (PROVISIONAL P-VX307-U2c-3 — the look then has no Touch ID road of its own). The pinned test RENAMED
  `theLooksFirstTryNeverPressesTouchIDAndHerOpenMay` → `theLookNeverPressesTouchIDAndAWrongSecretRefusesInWords`: the
  wrong secret → `[.withoutAPress, .withoutAPress]` handed, zero Touch ID reads, `.needsSecret` with the refusal; her
  words then open it by its own secrets, still zero reads. **(iii) THE CORE DEFAULT DROPPED (round-2 NIT 2).**
  `ProtectionExecutor.lookInside`'s `quietRoads: CopyQuietRoads = .includingTouchID` → `quietRoads: CopyQuietRoads` (no
  default): every core caller chooses — the app's three already did; the core tests' and the scenario world's/lifecycle
  walk's eleven calls now say `.includingTouchID` explicitly (behaviour byte-identical: the model's own door, rule 17's
  "its own quiet road on this Mac"). The app's twin `ProtectionCopyDoors.lookInside` keeps its non-prompting
  `.withoutAPress` default (the brief). **Pins:** core `U2MakeMineTests.anOpenedCopyIsMadeMineWithOnePressNotTwo`
  (Castle + Touch ID, the copy only the Touch ID item opens, the copy field wrong: the look 1 press, the opened act 0
  more; the secrets form presses again at the act — the bug, documented; a key the copy doesn't open refuses with no
  write) + `U2LookInsideTests.theCoreCopyDoorCarriesNoPromptingDefault` (SOURCE: the declaration names `quietRoads:
  CopyQuietRoads` with no `=`) — core Debug `✔ Test run with 12 tests in 2 suites passed`; app headless
  `MakeMineRoadTests.oneConfirmedPressReadsATouchIDItemOnce` (the planted road: the preflight's one read, the act made
  with none more) + the flipped `LookInsideRoadTests` pin; `MakeMineRoadTests`/`PickedCopyRoadTests` follow the new
  shapes (the refusal-inside-the-act test hands a look opened with `.withoutAPress`). **RED-ON-OLD BY REVERT** (each on
  the committed tree `7f521bcbb`, restored by `git checkout --`, `git status` clean after): R1 `submit` back to
  `.includingTouchID` → `✘ theLookNeverPressesTouchIDAndAWrongSecretRefusesInWords … with 4 issues` (handed, the read,
  the refusal, the open); R2 the core default back → `✘ theCoreCopyDoorCarriesNoPromptingDefault … with 2 issues`; R3
  the opened act re-opening the copy through the quiet roads (the pre-fix second open) → core `✘
  anOpenedCopyIsMadeMineWithOnePressNotTwo … with 3 issues` and app `✘ oneConfirmedPressReadsATouchIDItemOnce … with 1
  issue` (`touchIDReads == before + 1` — it read twice). Green again after: core 12/2, the harness `✔ Test run with 140
  tests in 22 suites passed`. Mac `build-for-testing` → `** TEST BUILD SUCCEEDED **`.
- Piece 5 — the close: DONE (this commit) — the counts, the Mac suite list, the walk rows, the PROVISIONALs and the
  findings below.

**THE WORDS THIS BATCH LANDS (the pins read this block — `ProtectionWordsVX307Tests`; hers verbatim where ruled):**
- **VX-414 — her two U2-7 sentences, VERBATIM from the ticket's body** (VX-414 read from the board 2026-10-18 — her
  ruling "I agree with your suggested wording"): (1) the standing banner after a quiet open with no key file found
  anywhere reads *Variorum opened your library, but found no key file for it anywhere. Make a backup now, so a copy
  exists.* (replacing rule 27's refusal words in that one state); (2) the key-file offer when the place beside the
  library is EMPTY and a backup holds the right file opens *There is no key file beside your library. A backup holds one
  that opens it.* (then her offer sentence's remainder — built as her sentence's question, *Use it?*: P-VX307-U2c-4).
  And U2-6, her "sure we can drop the sentence": the split-pair line *The key file beside your library is an older
  one. …* is gone.
- **F-U2b-1 — the readme's Start Here passages, as amended** (the pin `ReadmeStartHerePlanTests` reads THIS block since
  U2c — re-anchored from VX-306's plan §7c (5), whose drafts stay there as history; passage 2 reworded to the amended
  rules 2, 3 and 7 — the words shown only when she asks, from the card above the quick entry, at the tour's end, or in
  Settings ▸ Protection, each look making new ones, the key unchanged; passages 1, 3 and 4 byte-identical to §7c (5);
  PROVISIONAL P-VX307-U2c-5 — hers at the bundle, the readme being hers):

> **Your work is encrypted.** Every library is locked with its own random key, kept in a small key file beside it.
> Variorum keeps copies of that key file for you — beside the library, inside every backup, and sealed in this Mac's
> keychain — so you never have to think about it.
>
> **Write down your twelve words.** Every library has twelve words from the moment it is made, and they open it for as
> long as they are its words. Variorum never keeps them, so it shows them only when you ask — from the card above the
> quick entry, at the end of the tour, or any time in Settings ▸ Protection — and each look makes new ones for you to
> write down. Your library's key doesn't change.
>
> **Set a passphrase.** A passphrase is a convenience over the words: easier to type, and either one can reset the
> other. Until you set one, Variorum reminds you now and then.
>
> **The Apple road is a convenience.** In Standard, Variorum also keeps quiet roads to your key — through your iCloud
> Keychain and this Mac's login — so most people never type anything, and for most people that simply works forever.
> If it ever stops, your passphrase or your words open the library, and nothing was ever at risk. Castle is the one
> promise that there is no quiet road through Apple, ever; it is a choice you can make in Settings.
- No revert is in flight (piece 4's R1–R3 ran and were restored by `git checkout --`; `git status` clean).


**THE BATCH AS BUILT (for the ladder):** VX-413 — the note page of Look inside's facts sheet carries *Copy full text*:
`ProtectionCopyPeek.Reader.fullText(id:)` (core) runs Copy full text's own projection `Queries.variorumDocumentText` over
the look's private READ-ONLY connection; `LookInsideModel.copyFullText()` reads it off the main actor and hands it to
`CopyDoorsRoads.copyFullText` (the bootstrap's `AppBootstrap.copyFullTextRoad` — on the Mac `CopyForAI.put`, the ONE
clipboard rule the live note's Copy full text now calls too; nil on the phone); the receipt in the sheet. The hand-forwards
— the core's `makeThisMyLibrary(_:opened:copy:in:currentPair:)` (the act takes the preflight's opened key, re-verified
by `copyKeyOpens`, never opening the copy twice), `Preflight.ready` carrying the look, `ProtectionCopyDoors.makeMine(opened:)`;
`LookInsideModel.submit` handing `.withoutAPress`; the core `lookInside` with no `quietRoads` default. VX-414 — the
split pair's face gone; `ProtectionWords.noKeyFileAfterAQuietOpen` on the Mac bar and the phone sheet; the report's
`besideIsEmpty` and the card's `besideEmpty` choosing `offerBesideEmptyFromABackup` + *Use it?* for a backup offer over an
empty place. VX-379's rows — `RootView`'s posture box gated to today's road; `DataSafetyPane(roadStanding:)` gating today's
posture's backup lines and the new `DataSafetyCopy.restoringByTheDoor` lead, the Castle warning by
`castleWarningShows(todaysPosture:roadPosture:)` over `RoadStandingModel.posture` (new); the checklist, the floors, the
warning's words; the runbook doc re-synced; the readme's passage 2 and its re-anchored pin. ONE core file of acts changed
(`Copies.swift` — the opened form + `copyKeyOpens` + the dropped default) and one core read (`ProtectionCopyPeek.swift`);
ZERO `Sync/`, `Server/`, schema or dependency lines.

**COUNTS (the final tree — `824cad782` + this record):**
- Core, Debug, the full suite (`swift test`): VariorumCoreTests `✔ Test run with 3307 tests in 429 suites passed after
  202.121 seconds.`; the third target `✔ Test run with 40 tests in 6 suites passed`; VariorumMCPTests (run alone with
  `--filter VariorumMCPTests`) `✘ Test run with 383 tests in 71 suites failed … with 1 issue` — the ONE known wall-clock
  flake `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded` (18.8 s vs 15 s);
  `MCPHarnessTimeLimitTests` alone `✔ Test run with 3 tests in 1 suite passed after 2.171 seconds.`; no MCP line in this
  diff (U1's and U2b's recorded flake).
- Core, the protection set (every `@Suite` under `Tests/VariorumCoreTests/Protection` — 82 types): Debug `✔ Test run with
  334 tests in 82 suites passed after 5.294 seconds.` (U2b's 331 + the peek's full text, the opened act, the dropped
  default's source pin); Release (`swift test -c release`, the set as two halves — the long filter's release quirk) `✔
  Test run with 139 tests in 39 suites passed` + `✔ Test run with 171 tests in 39 suites passed` = 310 in 78 (U2b's 307 +
  3). `swift build -c release` (rule 24) green in that run.
- HEADLESS HARNESS (this session's — not durable; U2a/U2b's recipe exactly: a scratch SwiftPM package, tools 6.2, macOS
  26, `.defaultIsolation(MainActor.self)` + `NonisolatedNonsendingByDefault` + `InferIsolatedConformances` +
  `MemberImportVisibility`, the worktree's core by path + swift-dependencies; its `Variorum` target SYMLINKS every
  `Shared/Protection/*.swift` but `ProtectionBackupHook.swift` and `WireVaultLeaf.swift`, plus `Shared/LibraryOpenCopy
  .swift`, plus one stub file (`ProtectionCopy`'s names, `DeviceName`, `BackupDestination`, `KeychainTestTripwire`,
  `KeychainPartition`, `AppleKeyKeychain`, `AppleKey`, `AuthTokens` (with `email`)/`KeychainAuthStorage`,
  `EncryptionSession.words`, a nil `WireVaultLeaf.live`); its tests symlink `ProtectionTestSupport`,
  `ProtectionFacesSupport`, `ProtectionOpenRoadPlantedTests`, `ProtectionWordsPlanTests`, `ProtectionLobbyModelTests`,
  `PassphraseReminderTests`, `ProtectionNoticeFaceTests`, `ProtectionOfferFaceTests`, `ProtectionWalkSwitchTests`,
  `RoadCrossingFacesTests`, `ProtectionCrossingRoadTests`, `RoadCrossingModelTests`, `RoadRearmTests`,
  `RoadCreationFaceTests`, `WordsBandTests`, `LookInsideRoadTests`, `CopyDoorsQuietProbeTests`, `MakeMineRoadTests`,
  `CopyDoorsModelTests`, `PickedCopyRoadTests`, `CopyDoorsListRefreshTests`, `CopyDoorsPickRefreshTests`,
  `ProtectionFileLeavesTests` (the baseline before this batch: `✔ Test run with 137 tests in 22 suites passed`) and this
  batch's `ProtectionWordsVX307Tests` (+ a one-line `RoadWorld.RoadWorldError` stub)): **`✔ Test run with 144 tests in 23
  suites passed after 2.072 seconds.`**
- RED-ON-OLD / MUTATIONS (each on a committed tree, restored by `git checkout --`, `git status` clean): piece 4's R1 (4
  issues), R2 (2), R3 (3 core + 1 app) — the record's piece 4; piece 2's variant arm off (1) and `besideIsEmpty` off (3);
  piece 3's source pins' logic in Python — all seven checks red on the pre-piece tree.
- `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx307
  build-for-testing` → `** TEST BUILD SUCCEEDED **` (the final code tree; no new warning in a touched file — the one
  `AppSettingsView.swift:1247` warning pre-exists, a line this batch didn't touch); the phone `-scheme VariorumMobile
  -destination 'generic/platform=iOS Simulator' -configuration Debug -derivedDataPath DerivedData/vx307 build` → `**
  BUILD SUCCEEDED **`; **the Release check `xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration
  Release -derivedDataPath DerivedData/vx307 build` → `** BUILD SUCCEEDED **`.**
- Release behaviour: the new-road surfaces (Look inside's Copy, the one-press act, the flipped look, VX-414's faces) sit
  behind the new road (`copyDoorsRoads()` and the interlude/bar/sheet are new-road only); `RootView`'s gate and Data
  Safety's gates read `protectionFaces`/`roadStanding`, nil on today's road, so today's road renders every row it did.
  TODAY's road's TEXT changes, by the brief ("legal and render in Release — they are text, not behavior"): the
  restoring lead, the Castle warning's words, the checklist's names and notes, the floors' *and* (the RESTORE.md runbook
  written into backup folders carries the floors — re-synced), and nothing else. The core's `lookInside` change is
  compile-time (every caller passes the value it had); the secrets form of `makeThisMyLibrary` is unchanged.

**THE MAC SUITES THE ORCHESTRATOR RUNS UNDER THE STAGE (from `App/Variorum/`; PENDING):**
```
xcodebuild -scheme Variorum -destination 'platform=macOS' -configuration Debug -derivedDataPath DerivedData/vx307 test \
  -only-testing:VariorumTests/LookInsideCopyDoorTests \
  -only-testing:VariorumTests/ProtectionWordsVX307Tests \
  -only-testing:VariorumTests/VX379PaneRowsTests \
  -only-testing:VariorumTests/LookInsideRoadTests \
  -only-testing:VariorumTests/CopyDoorsModelTests \
  -only-testing:VariorumTests/MakeMineRoadTests \
  -only-testing:VariorumTests/MakeMineRouteTests \
  -only-testing:VariorumTests/PickedCopyRoadTests \
  -only-testing:VariorumTests/CopyDoorsQuietProbeTests \
  -only-testing:VariorumTests/CopyDoorsListRefreshTests \
  -only-testing:VariorumTests/CopyDoorsPickRefreshTests \
  -only-testing:VariorumTests/ProtectionOfferFaceTests \
  -only-testing:VariorumTests/ProtectionNoticeFaceTests \
  -only-testing:VariorumTests/ProtectionRule27FaceTests \
  -only-testing:VariorumTests/ProtectionRestoreReceiptTests \
  -only-testing:VariorumTests/ProtectionFacesRouteTests \
  -only-testing:VariorumTests/ProtectionRoadRouteTests \
  -only-testing:VariorumTests/ProtectionOpenRoadPlantedTests \
  -only-testing:VariorumTests/ProtectionWordsPlanTests \
  -only-testing:VariorumTests/ReadmeStartHerePlanTests \
  -only-testing:VariorumTests/LaunchFurnitureTests \
  -only-testing:VariorumTests/TutorialFurnitureFoldTests \
  -only-testing:VariorumTests/RoadRearmTests \
  -only-testing:VariorumTests/PassphraseReminderTests \
  -only-testing:VariorumTests/ProtectionReminderRoadTests \
  -only-testing:VariorumTests/ProtectionPaneRoadRowTests \
  -only-testing:VariorumTests/RoadCrossingSurfaceTests \
  -only-testing:VariorumTests/WordsBandSurfaceTests \
  -only-testing:VariorumTests/ProtectionSurfaceRenderTests \
  -only-testing:VariorumTests/ProtectionTierFaceTests \
  -only-testing:VariorumTests/Phase13pCopySweepTests \
  -only-testing:VariorumTests/DataSafetyRunbookTests \
  -only-testing:VariorumTests/DocumentImportDoorTests \
  -only-testing:VariorumTests/ICloudDriveOfferTests \
  -only-testing:VariorumTests/VX209GuideWarningTests \
  -only-testing:VariorumTests/LibraryPortabilityDoorTests \
  -only-testing:VariorumTests/ShellChromeTests \
  -only-testing:VariorumTests/TravellingDotsIndicatorTests \
  -only-testing:VariorumTests/CopyRegisterPinTests \
  -only-testing:VariorumTests/NoLiteralColourTests \
  -only-testing:VariorumTests/StatusSeamVocabularyTests \
  -only-testing:VariorumTests/CapabilityRegistryTests \
  -only-testing:VariorumTests/DeadVocabularyTests \
  -only-testing:VariorumTests/KeychainTripwireTests \
  -only-testing:VariorumTests/VX310TodayLobbyWitnessTests
```
The first three are U2c's NEW suites (3 + 4 + 4 = **11 tests**; `ProtectionWordsVX307Tests` also runs headless — 4
green); then the suites a piece grew or adapted (`LookInsideRoadTests` +1 and its flipped pin, `CopyDoorsModelTests`
+1, `MakeMineRoadTests` +1 and two adapted, `PickedCopyRoadTests` adapted, `ProtectionOfferFaceTests`' retired derive
pin, `ProtectionWordsPlanTests`' list, `ProtectionFacesRouteTests`' pattern, `ReadmeStartHerePlanTests` re-anchored,
`Phase13pCopySweepTests`' warning words, `DataSafetyRunbookTests` over the re-synced runbook doc, `DocumentImportDoorTests`
over `CopyForAI.put`); then every suite over a file this batch touched (the bootstrap's make-mine road — `MakeMineRouteTests`
needs the signed host; the faces model, the interlude, the bar, the pane, Data Safety, `RootView`, the readme seeder) and
the source pins over edited files. `VX310TodayLobbyWitnessTests` still reports its KNOWN ISSUES (a pass of either is a
FAILURE); read the `skipped:` lines. **The optional red leg** for the posture box (a Mac-only source pin): `RootView`'s gate
back to `if let protection {` → `VX379PaneRowsTests.thePostureBoxRendersOnTodaysRoadOnly` red — one line, restored by `git
checkout`.

**THE WALK ROWS (the orchestrator's, under a held stage claim; the DEV STORE only; light and dark where a face changed):**
0. U2a's recipe row 0 (zero Debug instances by PATH; build; launch the binary with stderr captured; `source
   ~/.variorum/dev-castle.env`).
1. **VX-413.** Settings ▸ Data Safety ▸ the Restore list → a backup row's *Look inside…* (or File ▸ Open Library… on a
   throwaway's folder) → the look → a note → the note page reads *Back* · *Copy full text* → press it → *Copied full
   text.* under the door; paste into a scratch note's quick entry or TextEdit → the document format (`{t:"…"}` header,
   the blocks, any Alternates section); the look still open, read-only; *Close* → the private folder gone (the `road: a
   look inside a copy … read-only, nothing written` log line). Capture (light, dark). Optional: File ▸ Import… the pasted
   text saved as a `.md` → the note comes back whole.
2. **The hand-forwards (on a planted Touch-ID-only copy — optional; the pins carry them):** after U2a's stage 6 under
   Touch ID, a look at a Castle-era backup with a WRONG secret typed → the refusal line, NO Touch ID prompt; Make this
   my library with the copy's field wrong → ONE Touch ID prompt for the press (the act raises none).
3. **VX-379's rows.** The sidebar on the new road: NO posture box (*Standard — Right now, only this Mac…* gone). Settings
   ▸ Data Safety on the new road: no *Restoring is a Finder operation…* lead and no today's backup-posture lines; the
   deletion sentences stand. In a new-road CASTLE library (U2a's stage 6) with the weekly copy switched on: the warning
   *You're in Castle — and a scheduled plain-text copy on disk would undo Castle's promise: …* shows. (Today's road's
   text — the restoring lead, the checklist, the floors — is the Release build's; her eye at the bundle.)
4. **VX-414 (optional — needs the walk switch):** rule 27 after a quiet open and the empty-beside offer are planted-fact
   states (`VARIORUM_WALK_FORGET=memory` + the live key file moved aside, a backup present → the interlude reads *There is
   no key file beside your library. A backup holds one that opens it. Use it?*; *Use it* puts it back). Restore the dev
   store's posture after (her standing rule).

**PROVISIONALs (each built as its option (a); for the orchestrator to bundle under QUESTIONS at the closeout):**
- **P-VX307-U2c-1 — where Look inside's Copy receipt is said.** (a) BUILT — in the sheet, under the door (the sheet is where
  she is; a window's status seam may sit behind it, and with no library open — the missing face, rule 27's lobby — none
  exists); (b) the status seam's receipt (`receipt_style` governing) where one exists; (c) both.
- **P-VX307-U2c-2 — the Copy door's one added line** *Variorum couldn't read this note's full text from the copy just
  now.* (the door's name and its other two sentences are a live note's Copy full text's own). (b) blank until her
  sitting; (c) other words.
- **P-VX307-U2c-3 — Look inside has no Touch ID road after the flip.** (a) BUILT — the typed *Open* hands `.withoutAPress`;
  a copy only this Mac's Touch ID item opens is opened at the look by its own secret (her pair opens her own copies,
  rules 4–5); Touch ID is pressed only at Make this my library's confirmed press, once; (b) a *Use Touch ID* door in the
  look's ask, shown only where this Mac holds a Touch ID item for the copy's key (rule 17's "its own quiet road on this
  Mac" kept whole); (c) the typed *Open* with an EMPTY field presses Touch ID.
- **P-VX307-U2c-4 — U2-7 (2)'s composition.** (a) BUILT — the ticket's two sentences, then her sentence's question: *There is
  no key file beside your library. A backup holds one that opens it. Use it?* (the backup's day said in the receipt
  *Key file restored from the backup from <date>.*); (b) the second sentence carrying the day (*The backup from <date>
  holds one that opens it.*) — rule 21's "saying where"; (c) the ticket's two sentences then her whole backup sentence.
- **P-VX307-U2c-5 — the readme's Start Here passage 2** (the readme is hers): *Write down your twelve words. Every library
  has twelve words from the moment it is made, and they open it for as long as they are its words. Variorum never keeps
  them, so it shows them only when you ask — from the card above the quick entry, at the end of the tour, or any time in
  Settings ▸ Protection — and each look makes new ones for you to write down. Your library's key doesn't change.* (b)
  blank until her sitting; (c) other words.
- **P-VX307-U2c-6 — the Castle warning on the new road reads the OPEN library's posture** (U2a's F-6). (a) BUILT —
  `castleWarningShows`: the new road's record mode there, today's posture on today's road; (b) the warning on today's road
  only (a new-road Castle library unwarned at the weekly copy's switch); (c) (a) plus the switch writing the sealed
  setting on the new road (U2a's P-VX307-U2a-3 (b)).
- **P-VX307-U2c-7 — piece 3's reworded today's-road lines** (each in the rules' words, each true of today's road): the
  restoring lead; the Castle warning; the checklist's *Twelve words* / *Your Apple account* names and their notes, the
  passphrase's *opens this library, …*; the floors' *and*. (b) today's words kept until VX-329 (the VX-306 words pass's
  position); (c) a wider pass (the current-state lines, the cards, *Encryption passphrase* everywhere) — VX-379's.

**FINDINGS AND HAND-FORWARDS (routed, not fixed here):**
- **F-U2c-1 (her U2-7 (1), for her eye — built byte-equal as ruled):** the banner after a quiet open with no key file
  anywhere advises *Make a backup now, so a copy exists.* — in exactly that state the new road's backup PAIR cannot be
  taken (`ProtectionBackupHook.takePair` needs a live key file of the current key → `.noKeyFileOfTheKey`, logged *none
  taken*); today's flat backup still copies the library file, which no key file opens. Options for her: keep (the
  sentence is hers), or a variant once the new road can re-make a key file from the key in hand (rule 1's redundancy — a
  design question, not this batch's).
- **F-U2c-2 (P-VX307-U2c-4's fact):** U2-7 (2)'s sentence no longer names WHICH backup holds the file; the receipt does.
- **F-U2c-3 (canon, the closeout's):** SurfaceContracts' "Library protection" line — Look inside's facts sheet gains
  *Copy full text* on a note's page (the Copy full text format, nothing written); "Doors to the outside"'s Import and
  Copy full text bullet may name Look inside's door too. AppSpec untouched.
- **F-U2c-4 (VX-379's remainder):** on the new road Data Safety has no "what opens a backup" sentence now that today's
  posture lines retire there — rule 5's sentence is the natural one (unruled words; the field-guide pass's).
- **F-U2c-5 (her §7c (3) words, for her eye):** the account-road sentence after the after-open banner (*… to bring your
  writing back.*) reads oddly over a library that just opened too — her words, not ruled to change.
- **F-U2c-6 (the phone):** no Look inside, so no Copy door there (P-VX306-U3-18) — the MOBILE PARITY line.

**Notes:** no machinery deaths; no Sonnet lookup; no subagents; no scratch worktree (`git worktree list`: main, mobile,
this worktree). Every revert and mutation ran on a committed tree and was restored by `git checkout --`. The ticket
VX-414's wording was read from the board (read-only) — its body is quoted in the words block above, the pins' source.
Commits: `4d14e4047` (record) · `2cf931f0e` (1) · `7f521bcbb` (4) · `4df309746` (the reverts named) · `03606cfa8` (4
record) · `0eba2d245` (2) · `d50b4dc72` (2 record) · `824cad782` (3) · the close commit.

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
- 2026-10-18 21:32 — U2a's Mac batch GREEN on the re-run under `vx-307-u2a-mac-rerun`: ✔ 165 tests in 33 suites
  passed (only the 3 expected VX-310 known-issue witnesses), 0 instances, throwaway scope and domain absent. The first
  run's one red was the route test's late key read — traced, fixed test-side (64ac751f5) with a headless twin, the
  record's batch paragraph carries it. **U2a is CLOSED but for the walk and the ladder.**
- U2 (VX-417, split §5b into U2a/U2b/U2c): U2b (VX-412) BUILT 2026-10-18 night (the §6 U2b RECORD; one core custody
  line to arbitrate — P-VX307-U2b-1; its Mac suites and walk PENDING); U2c next. U2a BUILT (the §6 U2a RECORD — 8 commits, headless + builds green; the
  orchestrator's structural verification: zero `Sources/`/`Server/` lines, all pushed; the findings arbitrated — the §6
  U2a ARBITRATION). The U2a Mac batch runs next under the stage (`vx-307-u2a-mac`); U2b spawns after it (tree quiet
  during the xcodebuild run).
- U2a (VX-417): BUILT (the §6 U2a RECORD) — the crossings' faces on the new road (Use Castle / Use Standard / Replace
  All Keys read from `assess`, the gate choice and the gate-style row, rule 11's notice and its reversal, VX-310's re-arm
  card, the Touch ID walk switch); headless 87/12 + the core's protection set both configurations green; Mac
  `build-for-testing`, the phone build and the Release build check green. The Mac suites (38 new tests + the touched
  suites — the record's list) and the walk (stages 6/7/8/11) PENDING — the orchestrator's, under the stage.
- U2b (VX-412): BUILT (the §6 U2b RECORD — the Opus implementer, 2026-10-18 night): the creation-time words card retired
  on the Mac; the card above the quick entry (the words' offer, *Later*, the ✕ and its Settings toast, rule 3's reminder
  folded in); the look (asked only where a passphrase exists, minted at the click through rule 6's act — the key
  unchanged, nothing stored — shown once with Copy, her warning before close); the tour's last card (the passphrase ask
  beside the words); Settings ▸ Protection's words door; the lifecycle page's stages 1–2 regenerated from the fixture.
  ONE CORE CUSTODY LINE (P-VX307-U2b-1: the new-words act asks nothing of a passphraseless Standard library) — arbitrate
  first. Core full Debug + the protection set both configurations green; the harness 101/14; Mac `build-for-testing`,
  the phone build and the Release build check green. The Mac suites (21 new tests + the touched suites — the record's
  list) and the walk PENDING — the orchestrator's, under the stage.
- U2c (VX-413 · VX-414 · VX-379's pane rows · the VX-306 copy-door hand-forwards): BUILT (the §6 U2c RECORD — the Opus
  implementer, 2026-10-18 night): Look inside's note page copies the note's full text (Copy full text's own projection,
  nothing written); Make this my library presses Touch ID once (the act takes the preflight's opened key — a core
  overload); the look's typed Open never falls through to Touch ID (the flip-target flipped); the core `lookInside`
  carries no prompting default; VX-414's split pair dropped and her two U2-7 sentences byte-equal; VX-379's pane rows on
  today's road only, in the rules' words where true there (the posture box, Data Safety's lead and backup lines, the
  Castle warning reading the open library's posture, the checklist and floors); the readme's passage 2 and its pin
  re-anchored. Core full Debug + the protection set both configurations green; the harness 144/23; Mac
  `build-for-testing`, the phone build and the Release build check green. The Mac suites (11 new tests + the touched
  suites — the record's list) and the walk rows PENDING — the orchestrator's, under the stage. PROVISIONALs
  P-VX307-U2c-1..7; findings F-U2c-1..6 (F-U2c-1 for her eye).
