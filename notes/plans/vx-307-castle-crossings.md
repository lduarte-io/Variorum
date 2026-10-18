# VX-307 — Castle rebuild, phase 3: the crossings' faces and the account's new shape (the `key_vault` lockstep)

**Status: PLANNED — written 2026-10-18 at VX-306's closeout, to `notes/CastleRules.md` (the contract) and the lifecycle page.
Kicks off at the author's word with `/architect-phase vx-307` (the crossings are face- and sitting-heavy, and the lockstep
is hers to deploy).** The VX-307 TICKET'S BODY IS THE OLD DESIGN (the anchor, the rotation, VX-107/VX-109's lines) and is
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

**Closes on USE-shaped evidence:** the dev store walked through stages 6, 7, 8 and 12 (sync setup on the dev account? —
the dev scope's sync is OFF by the A4 fence; the account rows need a real account: HER call at kickoff whether the dev
store signs into a throwaway Supabase account for the walk, or the account arms stand on the two-client fake-server
convergence suites alone), a convergence suite per account act (two clients, the fake server emulating the new RPCs),
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

### U3 — THE ACCOUNT FACES (sync setup, the join, the follow, leave the account; VX-113's sentence)
Evidence: the convergence suites; the walk if her kickoff call allows a throwaway account; the words.

## 3a. HER RULINGS OF 2026-10-18 ON THE VX-306 BUNDLE (verbatim where quoted; they bind this phase)

- **The mirror:** "I think it makes sense to wait to bump the mirror until we're ready to release this so that my client doesn't stop syncing." (recorded in §1 — the deploy and marker 14 wait for the release carrying VX-329.)
- **Look inside** (P-VX306-U3-15): "I think it's fine for Look inside to be a facts sheet." Then: "Can you still copy text out of it? … I think that should be done somewhere in this phase because otherwise look inside isn't that useful." → **VX-413 is a REQUIRED piece of this phase** (a Copy door on the note page; the format — Copy full text (recommended) or plain — her call at kickoff).
- **Make this my library's fresh store identity** (U3-9): "it's fine for make this my library change your settings, I think that's fair." ACCEPTED.
- **The interlude card** (U2-1): "I think 3 is fine, I'll wait and see it when I'm going through the whole tutorial flow on a fresh account to see how it looks." STANDS; her fresh-account walk is the check.
- **The crossover** (U3-5): "I'm not worried about what happens in the crossover before the new system really." ACCEPTED.
- **THE TWELVE WORDS, HER WAY — VX-412 (High, Needs Lillian on one fork):** "I don't want the new library to show those words at creation before the bookcase and before the tour offer. that breaks my idea of opening the app for the first time being a calm moment where the user can just type. i think it should show at the end of the tour and maybe as a separate notice on the same screen the first time a user opens - having two cards on the screen isn't my favorite, but it's fine I think. maybe a card above the 'write note here' line that just says 'your library is encrypted. click here to record the 12 words that are its key' or however you want to say it. but opening the app for the first time can still be calm - and that card can be present until the user clicks the dismissing x button on it. in fact, I feel like that would be better than showing things in the lobby in general. i do think that for the notice or key file offer the lobby is fine because it should be more obvious, but first open should still be calm. … it should also show a toast when dismissed like 'look in settings, protection for this information' or something. I think a snoozed card showing on next launch is fine." Her drawing of the band — between the shelf listing and the quick-entry line, the main column's full width: `notes/plans/vx-307/her-cards-area-2026-10-18.png`. **The fact that shapes the build:** the app never keeps the words (rule 2; `OnceShownWords` lives until the card's button), so a later card MINTS fresh words when she chooses to look (rule 6's act, the Settings new-words door's) — recommended; keeping them until recorded is the alternative. **Her addendum, minutes later:** "ok if the words aren't kept it can warn them before they close the card or that can be handled differently than i suggested. i dont want the lobby at start though." — so the HARD rule is NO LOBBY AT START; the snooze mechanics are the orchestrator's to shape (the once-shown card may warn before it closes — *these words won't be shown again* — and the band card then reads as the door to fresh words), nothing stored. Rules 2 and 3 amend at VX-412's merge (the words shown once — at the tour's end or from the card, no longer before the first screen; the tutorial's last card asks the passphrase AND shows the words). The **tour offer as a card in the same band** is VX-415, PARKED at her word ("that change doesn't have to be in these plans").
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

## 5. LIVE STATUS
- not started.
