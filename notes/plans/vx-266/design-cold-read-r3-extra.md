# Cold read of the design and plans — round 3, extra and late (VX-266)

**Reviewer:** the session she started as round 3's Fable reviewer (`round3fablecastlereviewer`). Its safeguards paused
it three times; she switched it to Opus, and it finished there. **Her word on it, verbatim:** *"it doesn't count as the
review, but might as well since it read everything"*. **Target:** the design and the phase-1 plan at `3bdbf7bb`, read
whole, with the diff from `fbcf8794` and the round-3 records; the key maps and the explainer left out at her word. It
arrived 2026-10-14, after round 3 had settled and before round 4.

The report follows, committed unedited. The dispositions are in `design-cold-read-r3.md`, under "The extra, late read".

---

Design cold read, round 3 (extra, late)

Reviewer: this session started as the round-3 Fable reviewer (round3fablecastlereviewer), was paused by a safeguard, and finished on Opus after she switched its model. It is an extra read, not a ladder round. Target: the design (notes/plans/vx-266-castle-backups-prelaunch.md) and the phase-1 plan (notes/plans/vx-305-castle-core.md) at HEAD 3bdbf7bb, read whole, plus the round-3 record (design-cold-read-r3-opus.md, design-cold-read-r3.md) and the diff from fbcf8794. Before the pause I had read every round-1 and round-2 record, the generator, the explainer, the replaced pre-13x design and SyncSpec in full. The key maps and the explainer are left out of this pass, at her word. No edits, no commits, no subagents, no web.

Result: 0 BLOCKER · 5 MAJOR · 4 MINOR · 3 NIT. Finding 3 touches the premise of her frozen-anchor ruling, and finding 9 is a consequence of her release-switch ruling she hasn't been told; both want her eye.

======== MAJOR ========

[MAJOR] 1 · design §3.5 (351–356 "Entering Castle retires this Mac's own Apple key", one minter 335–342, replacement Mac 357–360), §3.8 (597–598), §3.9 Use Castle (622–624) and Re-link's library arm (682–685); plan U3's Apple-key rules · Entering Castle retires only ONE of this Mac's own Apple keys for the library, but this Mac can hold several, so pre-Castle copies keep opening through the Apple account.

What's wrong: every rule says "this Mac's own Apple key for the library", singular. But two doors mint a second one for the same library. Leaving an account in Standard is on the library minter list (the accounts paragraph says "a fresh Apple key of this Mac's own"). Re-link's library arm mints a new one when the old can't be read here. Nothing ever retires the older key.

Sequence:
1. A Standard library synced with account X has key L1. Its key file wraps L1 under a1, this Mac's own Apple key. Backups b1…bn carry L1 under a1, frozen.
2. Stop syncing here re-keys to L2, minting a fresh a2. a1 stays in iCloud Keychain: no rule retires it, and §3.3 forbids deletes without a replacement.
3. Later, Use Castle re-keys to L3 and retires "this Mac's own key", meaning a2, the one the live key file names. a1 is never listed as retired, so neither the Castle repair nor delete on sight touches it.
4. b1…bn now open through a1: through the Apple account, and through Keychain Access for anyone with the login password.

Rule 2 says nothing reachable that way opens any copy made on this Mac. Its second exception covers reach "through that account", meaning the Variorum account's master, not a library Apple key. Promise 2's last clause goes red in the generator on this ordinary sequence.

The same happens after Re-link's library arm when the old key was only unreadable here, because iCloud Keychain was off or hadn't yet carried it to a replacement Mac: the old key is alive elsewhere, and a later Use Castle retires only the new one. After a switch of Apple ID, the old key lives in the old Apple account, which this Mac can't delete from, and no stated exception covers those copies once the library enters Castle. The replacement-Mac rule also adopts only "the Apple key ids its live key file's wraps name", which misses a predecessor's older own keys.

Proposed fix:
(a) Entering Castle, by the act or its follow, retires every Apple key this Mac's device section lists as its own for the library and not yet retired, not only the live wrap's.
(b) Drop "leaving an account in Standard" from the library minters. Since round 2 the account's Apple key never touches the library's key file, so the new key can go under this Mac's existing own key, as Standard's Replace All Keys already does. That mint is a leftover of round 2's M9 fix.
(c) A replacement Mac adopts every own id its predecessor's section lists.
(d) State an exception, with an Opens-with line, for copies under a key left in a former Apple ID.
(e) Fixed scenarios: Standard synced, then leave the account, back up, and Use Castle, after which no pre-leave backup opens through anything Apple-reachable; and Re-link's arm followed by Use Castle.

[MAJOR] 2 · design §3.9 Use Standard, synced (632–641), the follow's rotation-in-progress hold (652–654), §3.5 (364–366), §3.12 "the vault protocol … kept exactly as today" (751–752); plan U3, §6 · The leave's "one completing write" and the lost-actor finish need to know that a rotation in progress is a leave, and nothing tells them.

What's wrong: during the rotation, a leave and a Castle Replace All Keys write the same vault: a new master under P and W, the previous corpus key, and no Apple copy. The intent lives only in the actor's plan, beside its library on its own Mac.

(a) Who completes the rotation. Today any device holding the new master completes it ("the device that pulls to head and sees none left clears that copy" — pre-13x decision 6 and §4 step 3), and §3.12 keeps that. Followers still re-encrypt; §3.9 holds back only their library re-key. Suppose a follower reaches head first:
1. The follower clears the previous key with no Apple copy, because it doesn't hold the actor's fresh account key.
2. The account now reads Castle, with no rotation pending.
3. The followers that held their re-key "until that one write settles the account's mode" re-key into Castle.
4. When the actor adds its Apple copy in a separate write, they follow again into Standard, typing again.
That is round 3's m8 double follow, reopened, and the race favours the followers whenever the actor is slower or offline.

(b) The lost actor. The design says "another device of the account finishes it at a press, minting the account's key if this one's never arrived". The finisher can't tell a lost leave from a lost Castle Replace All Keys, and Replace All Keys is pressed exactly when a device may be in someone's hands, so a lost actor is the expected case there. If the finisher adds an Apple copy to a Castle account, a press that never said so lowers the account's mode, breaking promise 4, rule 2 and "in Castle = safe". If it doesn't, her leave silently never happened, which is what m8 meant to stop. "If this one's never arrived" also presumes the finisher knows the actor minted a key, and nothing records that.

Proposed fix (needs a stated rule; no server change): the leave's rotation-start write records the fresh account Apple key's id in the vault's existing apple_key_id column, with the Apple wrap still empty. The vault format keeps the id and the wrap as separate fields (KeyVaultFormat.swift:57–58), and today's posture reads only the wrap (ProtectionController.swift:2135), so the id marks "a leave in progress" without changing the vault's mode. Then:
- only a device that can read that key makes the completing write; other devices re-encrypt but leave the completion to it;
- a rotation with no id is a Castle Replace All Keys, and anyone completes it;
- a lost actor's finish, at a press, reads the id and says "Finish leaving Castle, started on [device] on [day]", minting a new key only if that one never arrives.
SPECULATIVE: how today's builds (the older-build actor) treat an id with no wrap. Today's reconcile compares the vault's id with the key file's (ProtectionController.swift:1663–1667), so phase 1's world should model it.
Fixed scenarios: a follower reaching head first during a leave; a lost actor during a leave, and during a Castle Replace All Keys.

[MAJOR] 3 · design §3.4's follower anchor (299–305), §1 her round-3 ruling (63–66), §3.1 rule 5 (189–193), promise 5 (924–928), §8 (1249–1251); plan U1 (the key file and its tests) and §6's scenario "copies from before the leave still opening with the leave day's passphrase or words everywhere" · A follower's anchor carries whatever locks that device last held, not the leave day's secrets, which falsifies the premise of her frozen-anchor ruling on every follower.

What's wrong: a follower's anchor goes under its outgoing key, with "that key's own locks from the device's key file copied beside it". Her ruling rests on "copies before you left castle open with the passphrase you had when you left", and rule 5 tells her "the passphrase or the twelve words you had on the day you left". On a follower that is often false.

Sequence:
1. Pro, Air and phone are in Castle and synced. Each device's key file holds its library key under P1.
2. On the Pro, she changes the passphrase from P1 to P2. Under pre-13x §3.6, the Air and phone keep their P1 lock until P2 is typed there. They open by Touch ID or Face ID every day, so the lock stays P1.
3. The Pro presses Use Standard with P2 and W1, so the Pro's anchor is under P2 and W1.
4. The Air follows, typing P2 through the vault to reach the new master. Its anchor goes under its outgoing key with the key file's locks copied: P1, the Castle-era master, and that master's words copy. Nothing in §3.4 or §3.9 re-locks the outgoing key under the P2 just typed before sealing.
5. The Air's copies from before the leave now open with P1 or the words, not with P2, the passphrase she had when she left. The same holds on the phone.

A follower that typed the words at its follow into Castle never held a passphrase lock at all (§3.9: "the passphrase directly when it was the one typed"), so its anchor never opens with any passphrase.

The words road is that device's words copy, which is refreshed only while its master is current (§3.5a). If the words were regenerated during Castle while the Air was offline, the Air comes back online to a rotated vault and can no longer refresh. Its anchor then opens with neither of the leave day's secrets. That state is outside promise 5's exceptions, so the generator goes red. The §8 residue that covered it at round 2 ("a follower's anchor whose words road is as fresh as that device's words copy") was dropped at round 3.

Proposed fix:
(a) At a follow out of Castle, before sealing, re-lock the outgoing key under the secret just typed. That secret opened the vault, so it is the current one. Every follower's anchor then opens with at least the secret it took at its follow, and promise 5, which is defined by the anchor's own day, holds.
(b) Say the truth to her and in rule 5: on the device you left from, either secret of that day opens these copies; on a device that followed, the words do, and the passphrase only where it was typed at the follow. The Opens-with line names which.
(c) Restore the follower residue in §8.
(d) Fixed scenarios: the passphrase changed on another device before the leave, then a restore on a follower; and a follower that typed the words.
Because this changes a sentence her ruling rests on, tell her.

[MAJOR] 4 · design §3.15 "When" (831–833) and its list (835–841, 845) against §3.13 steps 1, 2 and 6 (773–802) and §3.7's copy with no record (552–554) · Round 3 moved every deletion into the switch change itself, but the migration runs after that change ships, and it calls code the same change deletes.

What's wrong: the migration runs "at their next unlock" after the switch ships, and it depends on:
- Step 1, "finish anything in flight with today's runner", and the VX-235 stuck-marker check. Both read the in-file RotationMarker and run today's runner, which are deleted.
- Step 2, "work out the mode once with today's rules", including corner 45's ambiguous case. Posture.derive and corner 45 are deleted, and "after migration" now contradicts "in the same change".
- Step 6, which folds keys from "custody" (today's per-library-ID items) and from "the 13p escrow items". Reading custody named by library ID and "the 13p legacy read-through" are deleted.
- §3.7, which works out a no-record copy's mode "with today's rules" forever, because backups made before the change exist forever.

Consequence: built as written, the switch build can't migrate a tester's store that had a crashed act on the last old build, or a corner-45 store. That is VX-235's class, at the riskiest moment §5 names.

Proposed fix: split §3.15 into two lists.
- What dies at the switch: the deciding and writing roles.
- What survives as read-only legacy readers in the core: today's mode rule (Posture.derive's inputs and corner 45's test) as a pure function that the migration and the no-record open call forever; the per-ID item and escrow reads for the fold; and the RotationMarker read with today's runner's finish path, kept until one release after the switch.
The phase-1 plan's "Readers for formats 1 and 2" (U1) and "a copy with no record worked out by today's rules" (U2) then name the legacy mode reader too.

[MAJOR] 5 · design §5's release switch (1117–1131), the phase table (1101–1106), §6 "Also in scope" (1166–1170), §9; plan §2 (128–129) and §11 · The release switch is now the real-store migration moment, and it has no ticket, phase, acceptance unit, evidence or review ladder.

What's wrong: the switch migrates her Mac, her phone and every tester, and it lands §3.15's whole deletion diff in the same change. The only stated check is that "a Release build still runs today's road", which tests the old road, not the new one. Before round 3, phase 3 owned this moment and its drills.

Debug-only evidence can't reach the real-scope legs. Debug builds use the dev scope (pre-13x corner 47), and the Keychain tripwire forbids test writes to the real scope. So a byte-copy of her real store opened in Debug can't read the real <scope>-apple-key that its older key files are wrapped under, or the real-scope per-ID and escrow items. The fold takes the passphrase road instead, or keeps the file. The branch her real migration will actually take, folding through the real old shared key, runs for the first time at the switch itself.

If "compiled into Debug builds only" means #if DEBUG, the new code is also first compiled with optimisation at the switch. Meanwhile the plan's §2 says Release builds strip ProtectionGuards' off-switches, which implies the core does compile into Release, so the two documents disagree about what "Debug only" covers.

Proposed fix: give the switch its own ticket and run, with stated evidence:
- the full scenario suite and the soak under swift test -c release;
- a Release-configuration build of the switch change, run against byte-copies of her stores under the real scope, behind the A1 rail, before anything reaches /Applications;
- the restore drill;
- a Fable cold review of the switch diff, since it deletes custody code;
- her acceptance on both Macs and the phone.
And state that "Debug only" means the app's wiring: the core compiles and is tested in both configurations from phase 1, so the switch flips wiring only.

======== MINOR ========

[MINOR] 6 · design §3.6's stated limit (490–494), promise 10 (936–938), §3.10's re-arm question (703–707), §8 · The limit says a both-homes rollback "never opens what was written before the rollback to them". The re-arm question breaks that. Both homes are also cheap for this adversary: §4.1 lets them read every keychain item except a Touch ID item's, so they can copy the memory item and the library file at the same moment.

Sequence:
1. The library is in Castle on Touch ID. The attacker copies the library file, the key file and the memory item.
2. She switches to Always ask. That is no re-key, and her Touch ID item goes.
3. The attacker enrolls a finger and writes all three copies back.
4. She opens with the passphrase. Both homes say Touch ID and no item exists, so §3.10 asks "Touch ID can't open Variorum on this Mac any more. Set it up again?" — a true-sounding reason for a choice she had undone.
5. A yes makes an item for the current key, which the attacker's finger opens. The current key opens the library and, through the history, every older copy, including what she wrote before the rollback. A synced library also catches up after the rollback.

The alphabet holds both the re-arm "yes" and the both-homes replay, so promise 10's last clause goes red in the generator.

Proposed fix: ask the re-arm question only after a press fails against an item that exists — an invalidated item, which is decision 19's accepted Touch ID case. When the choice says Touch ID but no item exists, record Always ask quietly, and bring Touch ID back only from Settings with the passphrase. Or, if she prefers today's behaviour, qualify the limit: "unless you answer yes to Touch ID's question".

[MINOR] 7 · design §3.4 (311–312), §3.9's key doors (673–676), Replace All Keys (646–647) and Use Castle (613), §3.8 (596–598), §1 her ruling (63–66), §5's phase-4 row · Only the new-words door says "keep that paper", but four other doors can replace the words while an anchor exists.

What's wrong: her ruling's other half, "leaving castle doesn't make words so your current is good", holds only until some door replaces the words. These doors can do it while an anchor exists, and none says so:
- Replace All Keys, where the words are "typed or regenerated" (decision 33);
- leaving an account, in either mode, where the words are "typed or made new";
- Use Castle with regenerated words, when the passphrase changed since the leave: the anchor can't fold in, so it stays under the old words;
- sync setup's choice to replace the words.

Proposed fix: one rule — every door that replaces the words while an anchor exists says the sentence, naming the anchor's day from the route finder. Phase 4's row currently names only the new-words door.

[MINOR] 8 · design §3.9 Use Standard, synced (632–635) against the follow (652–654), promise 13; plan U3 · Round 3's m7 fix covers the acting device only, not followers.

What's wrong: the fix keeps the new sync keys and the previous corpus key in Castle-kind custody until the completing write, but only on the acting device. A follower that "follows the keys but holds its own library's re-key" also takes the previous corpus key, because it needs it to read and re-encrypt rows below the rotation seq. Nothing says which kind of custody it uses. If it uses the follow into Standard's silent item, a Castle-era corpus key is readable with the login password on that device for the whole rotation, and promise 13 ("any key made in Castle") goes red there.

Proposed fix: the same rule for followers — keys taken during a rotation in progress stay in the device's current Castle-kind custody until the completing write — with a fixed scenario on a follower.

[MINOR] 9 · design §5's release switch, §8, §1's round-3 rulings · Keeping every phase's new code out of Release also keeps its bug fixes out, and she hasn't been told.

What's wrong: these stay live in every Release build, hers and the testers', until the switch:
- VX-209's way-back revert (opening an older backup lowers Castle to Standard);
- VX-302's cross-Mac pruning;
- VX-317's banner;
- VX-107, VX-108, VX-109 and VX-113;
- VX-213's tidy-ups.
Her words accepted her own devices waiting for the new system. The design doesn't say these known bugs stay live meanwhile, and she wasn't asked whether any of them should get a separate fix on today's road first.

Proposed fix: say it in §5 and §8, and ask her, bug by bug, whether each live data-safety bug waits for the switch or gets a small separate ticket on today's road.

======== NIT ========

[NIT] 10 · design line 3 and the provenance paragraph (20–25) · The status line still reads "revised the same night at her round-2 ruling", and the provenance lists rounds 1 and 2 only. Neither design-cold-read-r3-opus.md nor design-cold-read-r3.md is mentioned.

[NIT] 11 · design §5, §3.13 step 9 · Once a Debug build from main has migrated the dev store (phase 2) and re-keyed it (phase 3's first act), Debug builds from branches that predate phase 2's merge can't open it. That includes other efforts' walks and the mobile worktree's phone build. Before the re-key, those builds write today's format-2 key files beside it. Tell the stage coordinator along with the switch note that §5 already says it gets at the merge.

[NIT] 12 · design §3.10 (697–699) · "A device with no choice yet — … a new device identity — starts on Touch ID …, the item made at that act's own press". A replacement Mac's first open isn't an act and has no consenting press. Say which press makes the item, or start on Always ask until she turns Touch ID on.

======== Clean bill — checked and found solid at HEAD ========

- Her two round-3 rulings are recorded verbatim in §1 and carried through. The release switch reaches §3.13, §3.15's timing, §5, §6, §9 and the plan's §11. The frozen anchor reaches §3.4, the key doors, rule 5, promise 5 and §8, apart from findings 3 and 7.
- Round 3's dispositions are really in the text:
  - the follower anchor under the outgoing key needs no secret in hand, which closes the Always-ask relock case, and an older build's unchanged master is left out of it;
  - the device section carries the identity and the hardware marker, "deleted" is in promise 10, and deleting the memory item alone changes nothing;
  - Re-link's library arm is in the minter list, the assessment and a scenario;
  - the current key takes step 2's mode;
  - the acting device keeps Castle-kind custody through its rotation;
  - the family tree has two homes and is seeded with unreached fingerprints;
  - the older-build exception is in promise 13 and §8;
  - the synced landing's made-new secret becomes the account's at Resume Sync;
  - the fake Keychain Access is corrected;
  - promise 10 and §3.6 are scoped to Castle, with the Standard-record guard;
  - corners 33, 6 and 27 are in §7, and N1–N7 are fixed.
- The phase-1 plan's diff tracks every design change: the record and memory fields, the anchor's two shapes, the tree's mirror, the U1 tests, U2's Standard-record guard and library arm, U3's crossings, the world's fakes, and the fixed scenarios and mutation pins, which match §4.1 one for one. Findings 1–3 and 8 reach the plan only as inherited text, not as new errors.
- §5 and §6 agree on every ticket's phases, including VX-301's library arm in phase 4 and the switch's check under "Also in scope".
- No invariant is relaxed and no lockstep event is introduced. Finding 2's fix uses an existing vault column.
- Code premises, checked this session at fbcf8794; the commits since change only documents:
  - Send Library copies the key file byte for byte;
  - the old shared key is <scope>-apple-key, and the key-file names are as the design says;
  - RestoreHoldModel.resume() clears the banner without checking that the marker was removed (VX-317);
  - today's runner turns the export off on the way into Castle and snapshots at every re-key;
  - today's leaveCastle reads or mints the Apple key and rotates nothing — the older-build leave §8 now names;
  - Standard's Replace All Keys reads the Apple key and never mints one (decision 30);
  - Standard's forgot road and the escrow family exist;
  - the lock-time copy is named from locate();
  - there are three filename parsers for the catalog to unite;
  - the vault format keeps the Apple id and the Apple wrap separately (checked at HEAD).
- Not checked in this pass, at her word: the key maps and the explainer. At fbcf8794, before the helper started, all three map pages were byte-identical to fresh generator output.
