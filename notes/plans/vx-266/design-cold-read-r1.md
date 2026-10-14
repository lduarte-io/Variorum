# Cold read of the finished design and plans — round 1 (VX-266)

**Reviewer:** a fresh Opus reviewer at max effort, zero framing (her pick after the Fable reviewer stopped on Fable's
usage limit before reporting). **Target:** `notes/plans/vx-266-castle-backups-prelaunch.md`,
`notes/plans/vx-305-castle-core.md`, `notes/plans/vx-266/castle-target-key-map.html` and its generator, at commit
`219777d8`. **Her ask, verbatim:** *"run another cold review on the finished design + plans to make sure that the design
has no gaps and that the plans reflect the design."*

The report follows, committed unedited. The dispositions are at the end.

---

## Findings, most severe first

**[MAJOR] 1 · Design §3.6 seals (lines 302–315), §3.10, §4.1 promise 10; phase-1 plan §3 U1 (line 152), §6 alphabet · Seals prove what a value says, but not that it is current. A replayed plan or memory value passes.**
- **What's wrong.** The seal is an HMAC under HKDF(L, libraryID, purpose) that names the sealing key. Nothing ties a plan or a memory value to the library's present state: no sequence number, no epoch check, no "this is the plan in flight" id. Plan seals also verify "through the history when the plan's own act has since re-keyed". So a genuine value captured earlier and written back later still verifies.
- **Evidence, memory arm.** This stays inside §4.1's own adversary ("edit a sealed setting"); it rests on Apple fact 2 (Keychain Access can edit what it lists, medium confidence). The plan-file arm below needs no such fact.
  1. She is in Castle with Touch ID. Someone with the login password reads the memory item.
  2. She switches to Always ask. That door doesn't re-key, so the new value is sealed under the same L.
  3. The attacker enrolls a finger (the login password is enough) and writes the old value back.
  4. At her next passphrase unlock, the seal verifies and the gate reads Touch ID.
  5. The Castle custody target ("touchid", §3.2 line 134) then creates a Touch ID item under the current biometry set, and the attacker's finger opens the library.
  - The re-arm question doesn't step in: it fires only when an existing item's read fails (line 431), and Always ask had no item.
  - This is the exact attack VX-313 exists to stop (second opinion §2.3).
  - The same road replays a scheduled Markdown export set to "on", which writes plaintext of a Castle library.
- **Evidence, plan arm.**
  1. The attacker copies `variorum-plan.json` partway through a Use Castle (sealed under L0; a re-keying act).
  2. Later she leaves Castle: no re-key, so the current key is L1, with a silent item and a fresh Apple key a1.
  3. The attacker plants the old plan. It verifies, because L0 is in the history and the plan's own act re-keyed.
  4. Resuming it sets the record to Castle, deletes the current key's silent item ("every silent item … go") and deletes and retires a1. No act she chose did any of this (promise 10).
- **Why the proof misses it.** The world's adversary only plants and edits; it never replays. U1 tests only "a tampered sealed field fails verification".
- **Proposed fix.**
  - Bind every seal to freshness the attacker can't roll back without L. For example: the record carries an act sequence and the id of the plan in flight; plan and memory seals cover them; the executor resumes only the plan the record names.
  - Separately, a Touch ID item is only ever created at a press (Use Castle, the gate door, a "yes" to the re-arm question), never by a repair.
  - Add "replay an earlier sealed plan, memory value or key file" to the alphabet, with a mutation pin.

**[MAJOR] 2 · Design §3.3 line 183, §3.5 lines 216–222, §3.7 line 351; §4.1 fixed scenario line 636; plan §6 line 290 · One library on two Macs has no consistent key rule. Whichever way it's read, rule 2 or rule 3 breaks.**
- **(a) Sent after this change.**
  - Send Library carries the live key file (LibraryHandOff.swift:5–23). It lands as "a different library [that] keeps its own key and mode". Its key file names the sender's own Apple key a1, which the receiving Mac can read (same Apple ID).
  - Nothing gives the receiver a key of its own: the one-minter list (lines 206–209) is sync setup, Use Standard, a new local library and the migration.
  - When the sender enters Castle, a1 is deleted everywhere with no recovery, and recorded as retired, so delete on sight removes it if it ever returns.
  - The receiver's Standard library now has no Apple road and no way to mint one, so it waits forever. Rule 3 is false for it.
  - With no passphrase (Standard's default) it opens only on that Mac. If that Mac is lost, so are its edits since the send — outside promise 5's exceptions and never shown on any sheet.
  - The design's own fixed scenario ("the other's own key is never deleted") assumes a key of its own that no rule mints.
- **(b) Sent before this change.** Each Mac's migration mints its own key, but both Macs still share L.
  - The sender's Castle entry retires only its own key and the old shared key.
  - The receiver's key files — which sit in iCloud Drive when its backups go there — wrap L under its own live Apple key.
  - So the sender's pre-Castle copies, made on the sender, still open through the Apple account. On the sender, the login password reaches them too, through Keychain Access and the shared folder.
  - Rule 2's "any copy Variorum made of it on this Mac" is false. The carve-out at lines 109–110 covers only the receiver's copy.
- **(c) The migration's gifts** (line 232–236; §3.2 line 133, "or unattributed legacy ones").
  - In VX-302's own setup (Pro and Air sharing an iCloud Drive backup folder), the Pro mints a key, a_pro_q, and writes `Backups/<q8>/<pro8>/` wrapping the Air's library Q's keys.
  - When the Air later enters Castle, it retires its own key and the old shared key, but never a_pro_q (delete on sight is "by recorded id only").
  - Q's pre-Castle copies in that folder keep opening through the Apple account. Rule 2 and promise 2 fail on the Air, and the file-swap attack that was withdrawn as redundant (second opinion §2.2) works again on those copies.
  - Every Use Castle "runs the moves again" (line 251), so it mints more of these.
- **Proposed fix (needs her ruling).** One rule for a key held by two Macs. For example: landing a different library re-keys it under a key of the receiving Mac's own, without folding the sender's key into its history; and gifts are made only for copies attributed to this Mac, never for unattributed legacy copies in a shared folder. Alternatively, keep the sharing and state the exception in rule 2 and on the retirement sheet. Pin the post-change send as its own fixed scenario.

**[MAJOR] 3 · Design §3.8 (lines 381–385), §3.9 Use Castle (393–399), §3.5 lines 216–219 · Leaving an account doesn't cut the library loose from that account's keys.**
- **(i) The account master.**
  - Stop syncing here, Move, and deleting the account here change the record but don't re-key the library. The re-key list at lines 192–193 doesn't include them.
  - Every backup pair's frozen key file keeps the current key L wrapped under the account master M_X, and decision 11 says those files are never rewritten.
  - The sequence: a Castle library, then Stop syncing here, then later another device presses Use Standard. "The vault gains M under it" (line 402) — the same M_X, now under a fresh Apple key.
  - The Apple account (plus a session, by resetting the account password through the iCloud email) can then go vault → M_X → any pair → L, and reach the **current** key of a library that says Castle. On this Mac, Keychain Access gets both the Apple key and the session.
- **(ii) The account's Apple key.**
  - A synced library uses the account's key (point 2), so Use Castle deletes that key with no check — only the old shared key gets checks.
  - On This-Mac-Only Castle (her #216 screen), or a Use Castle after Stop syncing here, a Move, or deleting the account here, that key is still a Standard account's vault copy and every other device's Apple road. Deleting it orphans the account. Keeping it leaves this library's pre-Castle copies Apple-openable.
  - Move or join into a Castle account isn't addressed either.
- **Proposed fix (her ruling).**
  - A Castle library that leaves an account re-keys at that act, with both secrets typed.
  - Retirement deletes only Apple keys this library alone uses; the record tracks every Apple key id that has ever wrapped a key in its history.
  - State the residue for pre-Castle copies under a still-Standard account.
  - Add fixed scenarios for both sequences.

**[MAJOR] 4 · Design §3.5 point 1 (line 227) and point 2 (239–242), §3.12 decision 30 (474), §4.1 promise 3 (599), key-map checklist rows S-4 and S-5 · For accounts from before this change, still on the old shared key, the rules contradict each other for every act that must land a new Apple wrap.**
- The four rules in conflict:
  - "never writes under it";
  - "stays on the old key until Castle or re-link";
  - decision 30 (a Standard Replace All Keys stays under the account's Apple key) — today's code re-wraps the new master under the key it reads, which for these accounts is the old shared one (PostureSwitch.swift:1386–1410);
  - promise 3 (the Apple wrap exists whenever the account's key is readable).
- **Replace All Keys** on such an account must either write under the old shared key (breaking point 1 and S-5) or drop the account's Apple copy (breaking decision 30, S-4 and rule 3).
- **Its follow** on every other device can't wrap the re-keyed key under the account key.
- **A new device joining:**
  - if enrolling through the old shared key counts as a read, the device can't land its own wrap, and promise 3 is false from day one;
  - if it doesn't count, the target map's "a new device … nothing typed" is false.
- **Proposed fix.** Pick one rule. For example: any act that would write a new Apple wrap for such an account re-links it first, with Re-link's consent and caveat; or devices wrap their own key file under a key of their own (corner 34's road) while the vault stays on the old shared key, and promise 3 is restated. Add all three sequences as scenarios.

**[MINOR] 5 · §3.5a residue (298–300), promise 5's exceptions (603–605) · The stated residue is narrower than the mechanism.**
- Use Castle and Replace All Keys can regenerate the words in the same act that replaces the master (decision 33; key map entering step 1 and Replace All Keys step 1).
- A device that joined without typing a secret and hasn't followed yet holds the old master under the old words. That copy refreshes only "while that master is current", so it can't refresh before the follow, online or not.
- If its Keychain is lost first, the new words open nothing in its file.
- The residue says "while offline", so the generator will report this as a violation. Restate the residue.

**[MINOR] 6 · §3.13 step 6, §3.3, plan starting states (246–261) · The 13p escrow item isn't named as a fold source, a repair target or a starting state.**
- Today's migration leaves the escrow item — a raw library key in iCloud Keychain, synchronizable, named by store id — when it holds "another key's" (ProtectionMigration.swift:198–206; StoreKeyGuard.swift:431–458).
- The fold's listed sources don't include it, so a key reachable only through it never reaches the history, the item stays, and promise 2 fails outside the stated exception.
- Name it as a fold source, remove it in the Castle repair, and add it to the starting states.

**[MINOR] 7 · §3.13 step 2, §3.3 guard (line 175) · The guard for unconfirmed and ambiguous modes blocks only Apple-reachable writes.**
- Corner 45's ambiguous case "records Castle", and the Castle repair then deletes the silent item before the one-time notice is answered. A Standard-waiting user's library suddenly needs a passphrase they may not remember, and the floor was never "said at the door".
- The value an unconfirmed synced library records isn't stated. If it were Standard, the Standard repair would move a Castle library's custody to a silent item, which the guard allows.
- Fix: no custody repair in either direction until the mode is confirmed; the interim value is today's custody shape; the notice carries the floor sentence and Export.

**[MINOR] 8 · §3.9 Use Castle order (393–399), promise 6 · The record is written after the commit, so a copy can carry the new key with the old record.**
- A scheduled backup, a lock-time copy or a Send Library taken between the swap and the record write carries L′ with the record still saying Standard. On another Mac it lands as a different library in Standard.
- The merge dropped the proposal's "backups pause while the file is swapped".
- The lock-time copy is still named from `locate()` (StoreBackup.swift:648–662). With one format-3 key file, during the prepare window it names L′ while the bytes are under L.
- Fix: write the record into the staged file before the swap, and say which steps pause copies.

**[MINOR] 9 · §3.5 point 4 (250–259) and point 6 (280) · The retirement check and the door use the wrong or mismatched conditions.**
- "A vault … that still names the old key stops the retirement", checked "before the sheet", blocks the account that this very act is moving into Castle. It needs "except the account this act rotates", plus a fresh vault read at the last step.
- The door shows only while catalog copies open through the old shared key, but the exception text shows "until it's retired". With only Time Machine or hand-moved copies left, the exception shows forever and no door exists. Use one condition for both.

**[MINOR] 10 · §3.10, §3.2 memory row · VX-310 relies on a stored biometry hash that has no home in the design.**
- "stateHash changed" — compared with what? No stored hash is listed in what this Mac remembers, and it would need sealing.
- "Has a Touch ID item" is ambiguous: an invalidated item still exists.
- "Re-arms only on yes" doesn't say what "no" records. It should record Always ask at her press.

**[MINOR] 11 · §3.5 lines 206–213 vs 216–217; plan §5; checklist S-3 · Corner 34's key of a device's own is allowed, but nothing says when it's minted.**
- It isn't in the one-minter list, and a device can't tell "not yet arrived" from "another Apple ID".
- The plan and S-3 say only "followers wait", yet retirement deletes "every device-own key made for it".
- Specify the trigger.

**[MINOR] 12 · §3.5 lines 216–222, §8; plan §6 fakes · Retirement depends on iCloud Keychain state no device can see.**
- **(a)** Retiring on a Mac whose iCloud Keychain is off deletes only locally (Apple fact 6, medium confidence). The key lives on in iCloud while the record says retired and the surfaces drop the exception. No residue states this.
- **(b)** A retired account key coming back from a device whose sync was off is deleted on sight only by devices whose record lists it. A follower records only "its own" keys.
  - Followers should record every Apple key id their key file names, the account's and the old shared key included.
- **(c)** The fake iCloud Keychain has no same-name conflict rule (one survivor). The older build's mints under the shared name need it.

**[MINOR] 13 · §3.7 lines 342–348 vs key map "Other copies" and T-5 · The raise rule lost "from another Mac".**
- As written, a Castle-era copy from this Mac's own line, restored after she left Castle, both "takes the library's mode" and "raises" it. The second also contradicts rule 4.
- The proposal and the map scope the raise to a copy whose key isn't in the history. Restore that qualifier.

**[MINOR] 14 · §3.1 rule 5, §3.9 · The rule 5 sentence ("Leaving Castle gives your Apple account a key to your library and every copy Variorum kept of it, including copies made while you were in Castle") appears only on the leave screen.** Every road into Standard exposes the history the same way: joining or moving to a Standard account, and the follow into Standard, which "asks nothing" (the second opinion's own list in §2.1). Put the sentence on each of them.

**[MINOR] 15 · §4.1 promises 3, 4, 7, 8, 11 · Some promises would fail a per-step check by design.**
- Promise 8 is unqualified: the passphrase and words from before open everything after, and a device that hasn't followed keeps writing under its old key. It needs decision 28's "credentials the old posture could reach", scoped to devices that have followed.
- Promise 11 contradicts the offer, which lets her delete other libraries' older libraries.
- Promise 4 needs to exempt the migration's corner 45 recording.
- Promises 3 and 7 are properties of a settled state ("ends in", "whenever readable") and can't hold after every action.

**[MINOR] 16 · §5 table vs §6 · Phase membership disagrees.** §6 places VX-313 in phase 1, VX-235 in phases 2 and 3, and VX-263 and VX-301 in phase 5. §5's members column omits all of these.

**[MINOR] 17 · §7 canon deltas · These changes are missing from the list:**
- decision 7 (leaving Castle now always mints a fresh key, not "read, minted if absent");
- decision 3, §3.3, the device-identity row and decision 13's identity clause (the identity moves to what this Mac remembers; sync keys become per account, not per store);
- §3.4's credential-audit tables ("STAYS in iCloud", "minted if absent");
- §6's "for as long as it exists";
- the identity and per-store sentence in SyncSpec §3's pre-13x paragraph;
- AppSpec §12's 13x line "so a Mac new to a library enrolls".

**[MINOR] 18 · Phase-1 plan lines 135, 111–113, 184–185 · The plan understates the design in three places.**
- U1's key file has "Apple key with its id" in the singular. The design carries several Apple wraps: the old shared key's beside the library's own, and a device's own.
- The act list omits deleting the account (an account-changing act, §3.8) and creating a library (a minter).
- U2's retirement-list oracle ("nothing else is") omits the accounts that can't be checked and the case where a readable vault blocks the retirement.

**[MINOR] 19 · §3.3 lobby roads (166–169) vs design-proposal §3.4 · The merge dropped two rules that the marker and mirror exist for.**
- "A missing library is missing in both modes" survives only as a §7 canon delta.
- The proposal's "a missing key file is not fatal" (fall back to the newest key file in the catalog — cold read 1, finding m5) is gone.
- Failure case: a local-only Castle library with both its key file and its memory item deleted (both within §4.1's adversary). No road names the Touch ID item's fingerprint or holds a passphrase wrap, though the newest backup pair would open it.
- Make the lobby's roads for the slot the route finder's roads.

**[MINOR] 20 · Second opinion §2.4 and §2.5 → design · Items the merge dropped with no ticket, phase or stated reason.**
- §2.5's condition for moving the device identity: re-mint it when the hardware changes (Apple fact 10, Quick Start).
- Three of §2.4's hazards, each marked "needs a red-on-old pin":
  - the lock-time copy's naming;
  - Resume Sync clearing the banner when removing the marker failed — still present at RestoreHoldModel.swift:85–89;
  - adoption landing the store before its key file.

**[MINOR] 21 · §5 lines 698–699 · The refresh after every phase puts old and new code together on her daily store.**
- Phase 2 makes the format-3 key file, per-key items and the record live, and migrates her real stores.
- The acts that write keys (PostureSwitch's runner) are only rebuilt in phase 3. They still write per-library-id items and format-2 key files, which the new lobby leaves "unread".
- A Replace All Keys pressed between phases 2 and 3 leaves the file under a key that memory and the format-3 file don't name. The open rule then flags it as "made on another Mac, or not by you" and wants to re-encrypt it.
- Fix: phase 2 disables, or routes through the executor, every act phase 3 rebuilds — or the real-store refresh waits for phase 3.

**[NIT]**
1. Line 210, "the other device deletes the key it minted, unused": by §3.9's order the key file's wrap was already written. Say "deletes it and drops its wrap".
2. Line 381's list of account-changing acts omits set up sync and enroll.
3. Format 3 has no stated home for what `vaultKDF`, `vaultCorpusKeyID` and `vaultRecoveryWrapDigest` carry today (derive-once, VX-113's detection, the words notice).
4. The catalog list doesn't name `Backups/safety-copies/variorum-adopt-safety-*`.
5. `<mac8>` has no stated source or stability rule (reinstall, Migration Assistant).
6. Key map:
   - "Opening an older backup" step 1's "Touch ID or the passphrase comes first either way" is Castle-only;
   - the Standard map's passphrase and words chips (gen.py:279–280) aren't marked "if set";
   - the checklist has no row for a plaintext export landing or for Standard's history.
7. Line 163, "every delete comes after the replacement has verified": retirements are deletes with no replacement. Say so.
8. §3.7 "takes the library's mode and account" should read "takes the current record", including its retired ids, so a restored copy can't weaken delete on sight.

## Clean bill
- `castle-target-key-map.html` and `castle-key-map.html` are byte-identical to fresh generator output. Its maps, every step list (entering and leaving Castle, Replace All Keys, the follow, the migration, the old shared key), the lobby table and the accounts table match §3.5, §3.8–§3.10 and §3.13 in order. The checklist covers every element except NIT 6.
- The code premises the design leans on check out:
  - the old shared key is one item per scope holding a random-id value (AppleKeyCustody.swift:36–68, 135), so an older build re-mints it under a fresh id, as point 5 says;
  - an older build's Re-link re-lands the vault under whatever it reads there (AppleRelinkModel.swift:132–181), as point 3 says;
  - decision 30 and decision 7 are what the code does (PostureSwitch.swift:1386–1410 and 1441–1463);
  - older builds can't see `variorum-library-keys.json` (StoreKeyEnvelope.swift:420–474) or the new backup subfolders (`existingBackups` is non-recursive);
  - the KDF floor relaxes for test runs (PassphraseKDF.swift:104–128);
  - `refuseIfRekeyIncomplete`, `KeychainTestTripwire` and `VX209WayBackRoundTripTests` exist;
  - the device identity lives in the sync custody record today (EncryptionKeychain.swift:61–66), so §3.13 step 3's carry is the right leg.
- The key history works as claimed: it runs backwards only, entering Castle is unaffected, and prepare-then-commit leaves a road at every crash point, Always ask included (passphrase → L′ → history → L).
- §3.5a adds no brute-force target: the words already open L directly.
- The VX-310 reading matches her ruling.
- All 23 tickets are placed (the project's 17 plus VX-301, 302, 310, 313, 314 and 113).
- No server or lockstep change is needed beyond what the design says.
- The phase-1 plan matches the design's phase-1 scope, hard limits, go/no-go and mutation-pin rule, and its fixed scenarios include all of the design's.
- This round reviewed documents only; no custody, keychain or `Sync/` code changed. The code phases remain Fable's under §5's cast.

---

## Dispositions

Every mechanism was traced before a fix: the four MAJORs against the design's own text and against the code they
cite. LibraryHandOff.swift copies the live key file byte for byte. PostureSwitch.swift's Standard Replace All Keys
reads the one Apple key it can and wraps M′ under it. Leaving Castle doesn't rotate the master. The 13p escrow item
is left when it holds another key's. `RestoreHoldModel.resume()` clears the banner without checking the marker's
removal. No finding is disputed.

| # | finding | disposition | where |
|---|---|---|---|
| M1 | Seals carry no freshness: a replayed plan or memory value passes | **Fixed.** Nothing that decides lives where a replay of one item reaches it alone. **(1)** The settings that could weaken protection move into the protection record, per device — inside the encrypted library. That is VX-313's ruling built stronger. **(2)** Plans are named by the record's act in flight and resume only when named. A missing or unmatched plan never blocks: it rolls back before the commit point and finishes from the record after it, so VX-235's class stays closed. **(3)** No repair makes a Touch ID item; a missing working item while the record says Touch ID gets the re-arm question, and a no records Always ask. **(4)** A whole-state rollback is the stated limit: it never opens the library to the one who did it. The reviewer's sequence-in-the-seal alone wasn't enough: rolling back the library file (same key) replays the sequence too. Removing the target from the memory closes that | design §3.2, §3.3, §3.6, §3.10, §4.1 (promise 10, the adversary's replay, pins), §8; plan §3, §5 |
| M2 | One library on two Macs has no consistent key rule | **(a) Fixed, PROVISIONAL:** a different library lands under a key of this Mac's own, re-encrypted with an empty history, so no key is ever held by two Macs; in Castle the landing asks for both secrets. **(c) Fixed:** gifts only for copies the catalog attributes to this Mac, made once per library per Mac. **(b) Stated:** a library sent before this change shares its key with the other Mac until one of them changes it — rule 2's third exception — and the retirement sheet names the other Mac's key file whenever it can see it. Fixed scenarios added for each | design §3.1, §3.4, §3.5, §3.7, §4.1, §9 |
| M3 | Leaving an account doesn't cut the library loose from its keys | **Fixed, PROVISIONAL.** A Castle library leaving an account re-keys at that act, with both secrets typed. Use Castle retires only the keys this library alone uses; the account's key goes with the account's own rotation, never when one library leaves (no orphaned vault copy). The record lists every Apple key id that ever wrapped its keys. The account-era copies are rule 2's second exception, said at the act and in Data Safety. Joining or moving into Castle is entering Castle; into Standard is leaving it, with rule 5's sentence | design §3.1, §3.2, §3.4, §3.5, §3.8, §3.9, §4.1, §9; map A-3, C-4 |
| M4 | Accounts on the old shared key: the rules contradict | **Fixed, one rule:** nothing is ever written under the old shared key. Enrolling reads; a device that must land a new wrap (in practice, one joining) uses a key of its own — corner 34's road with its trigger; Replace All Keys on such an account re-links it first with Re-link's consent, so decision 30 holds under the account's own key. Promise 3 restated for a settled world, counting a device's own wrap | design §3.3, §3.5 (one minter, point 7), §3.9, §3.12, §4.1; map S-3, S-5 |
| m5 | The residue is narrower than its mechanism | **Fixed:** restated for the words changing alone or with the master; the old words still open the file | design §3.5a, §8, promise 5 |
| m6 | The escrow item isn't a fold source, repair target or starting state | **Fixed:** all three, and Use Castle removes it once the history holds its key | design §3.3, §3.9, §3.13; plan §6 |
| m7 | The unconfirmed-mode guard blocks only Apple-reachable writes | **Fixed:** no custody repair either way until confirmed; the notice carries the floor sentence and Export | design §3.3, §3.13, promise 4 |
| m8 | A copy can carry the new key with the old record | **Fixed:** the record goes into the staged file before the swap; copies pause from the prepare to the swap and are named from the file's own key | design §3.7, §3.9; plan §5; map T-1 |
| m9 | The retirement check and door use mismatched conditions | **Fixed:** the act's own account is excepted and re-read fresh at the last step; the door and the exception share one condition from the record | design §3.5 point 4 |
| m10 | The biometry hash has no home | **Fixed:** what this Mac remembers holds it; "working item" defined; a no records Always ask | design §3.2, §3.10; map lobby |
| m11 | Corner 34's key has no trigger | **Fixed:** a device joining an account still on the old shared key; kept until Castle or the library's last copy | design §3.5 |
| m12 | Retirement depends on unseen iCloud Keychain state | **(a) Stated** (delete on sight finishes it when sync returns); **(b) Fixed:** followers record every Apple key id their key file names; **(c) Fixed:** the fakes' same-name rule | design §3.5, §4.1, §8 |
| m13 | The raise rule lost "from another Mac" | **Fixed:** restored; an own-line Castle copy takes the current mode (rule 4) | design §3.7 |
| m14 | Rule 5's sentence only on the leave screen | **Fixed:** on every road into Standard, and as a notice after a follow | design §3.1, §3.8, §3.9; map follow |
| m15 | Promises that fail a per-step check | **Fixed:** 8 per decision 28, scoped to followed devices; 11 at her press; 4 exempts corner 45's recording; 3 and 7 checked once the world settles | design §4.1 |
| m16 | §5 and §6 disagree on membership | **Fixed:** reconciled | design §5, §6 |
| m17 | Canon deltas missing | **Fixed:** decision 7, decision 3 / identity / decision 13, §3.4's audit tables, §6's sentence, SyncSpec §3's identity sentence, AppSpec §12's enroll line, the dials row | design §7 |
| m18 | The phase-1 plan understates the design | **Fixed:** plural Apple wraps; CreateLibrary and DeleteAccountHere; the retirement-list oracle completed | plan §2, §3, §4 |
| m19 | Two lobby rules were dropped in the merge | **Fixed:** the lobby enumerates this scope's custody items and takes the route finder's roads; a missing library is missing in both modes; a missing key file or memory item isn't fatal | design §3.3; map R-4 |
| m20 | Second-opinion items with no home | **Fixed:** VX-317 minted (Resume Sync's banner); the device identity's move (phase 2) — memory is device-only, so a new Mac starts its own; the lock-time copy's naming and adoption order (phase 5), each with a pin | design §3.2, §5, §6 |
| m21 | Old acts and new storage together on her real store | **Fixed, hers to confirm:** the real-store refresh waits for phase 3's close | design §5, §9 |
| N1–N8 | the nits | **Fixed:** N1 §3.5; N2 §3.8; N3 and N5 §3.2's memory row; N4 §3.7's catalog; N6 the map (the older-backup step, Standard's "if set", rows T-8 and S-6); N7 §3.3; N8 §3.7 | as named |

**Why none of this brings back what the design solved:**
- **The record carries only the act's identity** (sequence and keys). The plan stays beside the library, and a missing plan never blocks, so the in-file marker's trap (VX-235) doesn't return.
- **No new key is ever written under a shared name**, and no key is held by two Macs after this change.
- **No vault moves automatically** (round 3).
- **The account's key dies only with the account's own rotation**, so no vault copy is orphaned.
- **Every new mint is per id**, at a deliberate act or the migration.

**The ladder:** the MAJORs earn round 2, a fresh reviewer re-reading the fixes. Fable reviews it once the usage limit
clears, as she was told when she picked Opus for round 1. Three calls are hers (design §9): M2's landing re-key, M3's
leaving rules, and m21's refresh timing.

### After round 1: her rulings on the PROVISIONAL calls (2026-10-13)

- **M2 (a) revised at her ruling.** Her words: *"i think you should be able to land a Castle library with just the
  passphrase OR the words - that's what we guarantee for being able to access it."* A fresh key at landing can carry
  both secrets' roads only if both are typed, so with one secret the other would stop opening the library from then
  on, which breaks that guarantee. So a landed library now **keeps the key it came with**:
  - its passphrase alone, or its words alone, open it;
  - in Standard it also gains an Apple key of the receiving Mac's own, so the sender entering Castle never strands it.
    That keeps (a)'s fix.

  The two copies share that key. This is rule 2's third exception, widened from "before this change" to every
  hand-off. It is said at Send Library, where the sharing starts, and on Use Castle's sheet and the leave screen. The
  record now notes every hand-off made or received, so those surfaces always know. (c) stands unchanged.
- **M3 ruled as drawn:** *"so basically backups from when it was in standard still open to the standard account that
  remains? i imagine that's fine"* (the nuance said back to her: every copy made while it synced, if the account
  returns to Standard).
- **The old shared key's shape confirmed** (no keep-for-now).
- **m21's refresh timing:** asked; her answer pending.
