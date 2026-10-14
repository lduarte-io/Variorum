# Cold read of the finished design and plans — round 2, Opus (VX-266)

**Reviewer:** a fresh Opus reviewer at max effort, zero framing, run as the design owner's subagent at her ask:
*"maybe launch a new Opus Max effort cold review here as your own subagent since the plan has changed yet again. let
it review first fully and then ask it if it has ideas on how to improve the system - key rotation fixed a lot of
problems, to be clear. are there still problems / weird edge cases in our solution that are hard to understand?"*
**Target:** the same files at commit `8ca19287`, with the same prompt as the Fable reviewer
(`design-cold-read-r2-fable.md`); neither saw the other's report. **Her ask, verbatim:** *"run another cold review on
the finished design + plans to make sure that the design has no gaps and that the plans reflect the design."*

The report follows, committed unedited. After it come her follow-up question, put to the same reviewer once its report
was in, and its answer, also unedited. The dispositions for both reports will be in `design-cold-read-r2.md`.

---

# Design cold read, round 2

**Scope note, said first (my brief's rule).** This round reviews custody and keychain design. That subject is Fable's mandatory scope even though the diff is documents, not code. Round 1's record ("The ladder") also says Fable would take round 2. I ran the round because variorum-08's brief asked for it. Re-spawn it as `fable-reviewer` if that's the call.

**What I read.** At `8ca19287`, in full: the design (980 lines), the phase-1 plan, the generator (1,280 lines), round 1's record and dispositions, the second opinion, the Apple facts, the first designer's review, the design proposal, `pre-13x-postures-design.md` §0–§17 and SyncSpec. I read the code wherever the design makes a claim about it; the clean bill lists those files. I needed no Sonnet lookup and wrote nothing in the repo.

**The result:** 0 BLOCKER, 9 MAJOR, 12 MINOR, 10 NIT. Her latest ruling, *history flows into Castle, never out*, undoes or strains five things the design had settled (findings 1, 2, 3, 5 and 8, plus MINOR 10). Each needs a stated rule before phase 1's promises can be built.

---

## MAJOR

**[MAJOR] 1 · design §3.4 lines 236–238; promise 13 (lines 740–741); C-9 (gen.py:1126); map lines gen.py:341, 560, 782–783, 1179, 1230 · "Nothing … ever opens anything written in Castle" is false by construction. Promise 13 and C-9 can't pass as written, and the maps promise her more than her ruling buys.**

- **What's wrong.** Rule 5 (lines 150–152) is worded right: it protects *copies made while in Castle*. Five other places promise the *writing*:
  - §3.4's last sentence;
  - promise 13;
  - C-9;
  - the target page's opening box ("what was written in Castle stays Castle's");
  - the cycle's end line ("never what was written in Castle") and step 11 of entering Castle ("never what was written here").
- **Evidence.**
  - Use Standard re-encrypts the live library under L″, wrapped under a fresh Apple key (lines 500–502).
  - The live library still holds everything written in Castle: every block, every savepoint (`commit_point` is append-only, I5) and every tombstoned row (S2, kept until a purge). After leaving, the Apple account opens all of it, and so does a login-password holder through Keychain Access.
  - In a synced library the corpus is re-encrypted under C″, which sits under M″, which sits under the Apple key. The rotation is "as Use Castle's" (line 498), and its protocol is "kept exactly as today" (§3.12). So for the rotation's duration, the vault also holds the Castle-era corpus key C′ wrapped under M″ (pre-13x decision 6). Anyone with the Apple key and a server backup of that window's vault row can read the Castle-era ciphertext in the server's own backups.
  - Rule 4 also lets her open a Castle-era copy into the Standard library (line 423).
  - What actually stays sealed is only what exists solely in Castle-era copies: uncommitted buffer states overwritten since, and purged rows. Retention prunes those copies within weeks (14 kept in the container).
- **Consequences.** The generated runs check promise 13 after every action, so the go/no-go can't pass. C-9 "blocks the effort's close" (§4.3). And §1 records her choice as "those copies now stay safe", while the pages she reads say the writing does.
- **Fix.**
  - Reword §3.4's sentence, promise 13, C-9 and the map lines the way rule 5 is worded: copies made in Castle and the keys made in Castle.
  - Exempt a Castle-era copy she opens into a Standard library.
  - Say on the leave screen that the library's text, its commits and its deleted-blocks tray open through the Apple account from then on.
  - Optionally, finish the leave's rotation (clear the previous corpus key) before the vault gets its Apple copy of M″, so C′ is never Apple-reachable.
  - Then show her the ruling's real reach beside its costs (findings 2, 3 and 8). Her ruling stands; she should see what it buys.

**[MAJOR] 2 · design §3.7 lines 421–426; map gen.py:1057, 1063; T-4 and T-5 (gen.py:1140–1141) · After leaving Castle, the open rule calls this library's own Castle-era copies "made on another Mac, or not by you" and raises the library back to Castle. The "never out" ruling undid round 1's m13 fix.**

- **Evidence.**
  - The design's only test for "made elsewhere" is "its key isn't in the library's history" (lines 421 and 425).
  - After Use Standard, the history leaves out every key made in Castle, by design (line 236).
  - Nothing else lists past keys. The record holds only the current fingerprint (line 163); the memory holds the current fingerprint and epoch (line 168).
- **Sequence.**
  1. The library is in Castle under L′, with backups b1…bn.
  2. She uses Use Standard: the key becomes L″, and its history holds only the pre-Castle keys.
  3. She restores b3, whose key is L′. The restore list and the confirm say "made on another Mac, or not by you", which is false: she made it here.
  4. Because b3 counts as "a Castle copy … of a library this Mac remembers in Standard", the open runs Use Castle's steps.
- **What breaks.** This contradicts line 423 ("A Castle-era copy from this library's own line takes the library's current mode") and rule 4, so promise 9 fails. OPEN_OLD step 2 and T-4 ("nothing more typed") are false for these copies too: only that day's passphrase or words reach them.
- **Fix.**
  - Keep a non-secret list of every key fingerprint the library has had, Castle-era included, in the record and its mirror. A known fingerprint means "own line"; an unknown one means "made elsewhere".
  - A known Castle-era copy opened into a Standard library takes the current mode. The confirm says its writing will then open through the Apple account, and the route finder names "the passphrase or words you had on [day]".
  - Correct T-4, T-5 and OPEN_OLD to match, and add a fixed scenario.

**[MAJOR] 3 · design §3.5 lines 276–277; §3.9 lines 509–512; map LEAVE step 7 (gen.py:1042) and CYCLE_OUT step 6 (gen.py:770–773) · The waiting state of the follow into Standard contradicts her ruling, and no road is stated for when the new Apple key never arrives.**

- **Where the sentence comes from.** "The other devices wait for it to arrive, keeping their keys in silent items meanwhile" is carried over from the second opinion §3, point 4 ("Their keys move to the silent item meanwhile"). That was written when leaving Castle didn't change the key.
- **Why it now exposes Castle keys.**
  - Under her ruling, the follower re-keys at the follow (line 511), and it can't do that until it holds M″ (the new key file needs it).
  - So while it waits, "their keys" are its Castle keys — L′, M′ and C′ — sitting in items the login password reads (facts §12).
  - The wait has no bound (facts §6(e), corner 46). L′'s history opens every older copy on that device.
  - So promise 13 fails, and so does promise 2, because the follower's record still says Castle.
- **Why it can stall forever.**
  - With the follower's iCloud Keychain off, or on another Apple ID (the world has two, line 669), the new key never arrives.
  - The map has the follow happen "once the fresh Apple key arrives". Meanwhile the follower's sync rounds are refused, because its key proof is M′'s.
  - Only §3.9's generic "Until you type the secret…" (line 509) hints at a typed road, so promise 7 can't settle.
- **Fix.**
  - While waiting, custody stays as it is (a Touch ID item, or none).
  - The passphrase-or-words road (the vault's copies of M″ under the passphrase and the words) is offered at once, with the banner.
  - The silent item is made only for the new key, and its Apple wrap waits for the Apple key.
  - Say this in §3.5, §3.9 and the map.
  - Add a fixed scenario: a follow into Standard with the follower's iCloud Keychain off, checked against promises 2, 7 and 13.

**[MAJOR] 4 · design §5 lines 854–860 · Phase 2 can reach her Mac, her phone and the testers through main before phase 3, against her ruling.**

- **Evidence.**
  - §5 holds back only this effort's own refresh.
  - Each phase closes by merging to main (CLAUDE.md's closeout; the phase-1 plan §11, line 378), and CLAUDE.md ends every Mac-app change with an `/Applications` refresh.
  - The runway on main (`notes/plans/vx-33-release-runway.md`) runs five other efforts in parallel. Each merges, refreshes and cuts beta builds as it finishes.
  - So once phase 2 merges, the next of those puts the new storage and migration on her real store or a tester's while the acts that write keys are still today's. That is the state §5 itself says leaves "a key the new storage doesn't name". Her words: *"my mac and phone can wait for phase 3 to be done"*.
- **Fix.** Either merge phase 2 only together with phase 3, or merge it with the migration and the new road dormant in Release builds behind a switch phase 3 turns on. State which in §5 and in the runway or coordinator notes.

**[MAJOR] 5 · rule 2's third exception (lines 139–144); §3.4 line 236; fixed scenario at lines 768–771 · A Castle library sent to another Mac re-exposes the sender's pre-Castle copies when the receiver leaves Castle. "A copy sent while in Castle exposes nothing" is false.**

- **Sequence.**
  1. Mac A is in Castle under L1. Its history holds L0, from before Castle, and its own Apple key was retired at Use Castle.
  2. Send Library copies the live key file byte for byte (`App/Variorum/Shared/LibraryHandOff.swift`, header comment), and format 3 carries the history.
  3. Mac B lands the copy keeping L1 (her ruling).
  4. Mac B uses Use Standard, or joins or moves into a Standard account. It mints L2 under a fresh Apple key, and L2's history "takes back only the keys from before Castle" — that is, L0.
  5. Through L2 → L0, the Apple key now opens every pre-Castle copy on Mac A: the container, the far folder in iCloud Drive, Time Machine.
- **What breaks.**
  - Mac A is still in Castle and its surfaces say so, but rule 2 (lines 126–128) and promise 2 fail there.
  - With one Apple ID, a login-password holder on Mac A reads Mac B's new Apple key in Keychain Access (facts §12.1). After that they need only Mac B's key file, and a shared far folder is VX-302's own setup.
  - Neither the third exception (which covers Standard hand-offs) nor rule 5 (which covers the library that leaves) covers this.
  - The design's own fixed scenario asserts the false claim, so it will fail when it's built.
- **Fix (her call; add it to QUESTIONS).**
  - (a) A library that lands in Castle counts every key it arrived with as Castle's, so leaving Castle there takes back only keys made in Standard on that Mac. That is "history flows into Castle, never out", applied per copy.
  - (b) Or say it at Send Library in Castle, and on Mac A's Castle surfaces once its record notes the hand-off.
  - Rewrite the fixed scenario to match whichever is chosen.

**[MAJOR] 6 · design §3.9 Use Castle (lines 483–494) and the follow; §3.12; map ENTER (gen.py:1024–1034) · Entering Castle no longer turns the scheduled plaintext export off.**

- **Evidence.**
  - Today, both Use Castle and the follow into Castle turn the scheduled `.md` insurance off, with one notice (pre-13x decision 6; `PostureSwitch.swift:1362-1368`, behind `entersCastle`).
  - The design's acts, its §3.12 "kept exactly as today" list and the map's entering steps all omit this.
  - The setting now lives in the record, per device (line 163), and nothing resets it.
  - Built as written, a library whose export was set up in Standard keeps writing plaintext copies after entering Castle. They land in a folder the login password reads, and in iCloud Drive the Apple account reads it too. Those are "copies Variorum made", which rule 2 says nothing reachable that way opens.
- **Fix.** Keep the step in Use Castle and in every follow into Castle: turn off this device's entry in the record, with one notice. Add rule 2's exception for an export she re-enables in Castle after the warning; the who-table already says "Markdown exports you made are plain text".

**[MAJOR] 7 · design §3.2 (record line 163, memory line 168, key file line 165); §3.6 lines 371–373; §3.7 lines 416–418; promise 10 · The record's security facts have one home, so a library file replayed or rolled back on its own regresses them — which promise 10 and the open rule say can't happen.**

- **Evidence.** The settings, the retired ids, the ids of every Apple key ever used, the hand-offs and the act in flight live only in the library file. Neither the memory nor the key file holds any of them, or a record version.
- **(a) Same key.**
  1. In Castle she switches from Touch ID to Always ask. That's a wrap-free act (decision 33), so no re-key happens.
  2. A login-password holder enrolls a finger and writes back an earlier copy of the library file. It opens under the current key, and the memory's fingerprint, epoch and mode all still match, so nothing notices.
  3. The record reads Touch ID again. After her passphrase unlock, the re-arm question (lines 538–542) tells her "Touch ID changed", and a yes builds an item the attacker's finger opens.
  4. This breaks §3.6's "no edited or replayed file … reaches" the record, the adversary action "replay … library file — one at a time" (line 699), and promise 10.
- **(b) An older copy found at the place.**
  - After a Time Machine rollback (map OPEN_OLD step 1; §3.3 line 205), the copy "takes the library's current record … settings and retired ids" (lines 417–418).
  - But that record existed only in the file the rollback replaced. The memory keeps the mode and account and nothing more, so the retired ids regress.
  - Example sequence:
    1. She uses Use Castle while this Mac's iCloud Keychain is off (the residue at lines 962–963), so the library's own Apple key is deleted only on this Mac.
    2. Time Machine rolls the library back to a pre-Castle copy. The restored record lists that Apple key as live.
    3. When sync returns and the key comes back, delete on sight doesn't fire. The pre-Castle copies open through the Apple account, and no exception is shown.
- **Why round 1 didn't close it.** Round 1's M1 disposition moved the point where a replay lands from the memory to the library file. It didn't remove it.
- **Fix.**
  - Give the monotonic security facts — the settings, the retired and ever-used ids, the hand-offs and a record version — two sealed homes: the record, plus the memory or the key file.
  - At open, take the newer version and the union of the retired ids. Then only an all-at-once rollback, the stated limit, can regress them.
  - State where "the current record" comes from for a copy found at the place.
  - Pin a library-file-alone replay and a rollback across a retirement.

**[MAJOR] 8 · design §3.4 lines 234–238; key doors line 518; promise 5 (lines 723–726); C-5 (gen.py:1122); the Castle road "Older copies" (gen.py:310) · Leaving Castle reopens "copies keep only their own day's keys" (diagnosis 4, W-1's class) for Castle-era copies, and entering Castle again doesn't bring them back.**

- **Evidence.**
  - Keys made in Castle stay "openable only through their own copies' passphrase and words locks — for good". Use Standard's door may regenerate the words (decision 33's rule, line 496), and afterward the key doors "re-lock nothing else".
  - So: leave Castle, regenerate the words (there or later) and change the passphrase once, and every Castle-era copy opens only with secrets she no longer holds. That's outside promise 5's exceptions, no door says so, and rule 5's "keep opening only with your passphrase or your twelve words" becomes false.
  - Castle → Standard → Castle: the second Use Castle "carries every older key" (line 234) only from the Standard key's history, which never held the first Castle era's keys. So C-5, the Castle road "every older backup opens with nothing more typed", and T-4 are false then.
  - Promise 5's "the secrets the model says you hold" is never defined. The proposal's promise 6 had "or had when a copy was made".
- **Fix.**
  - (a) At every entry into Castle, fold earlier Castle eras' keys back in. The door's typed passphrase and words open the newest earlier-era key file the catalog knows, as long as those secrets haven't changed. History may flow *into* Castle.
  - (b) State the residue in rule 5 and promise 5 ("…with the passphrase or words you had when you left Castle"). Say it at Use Standard's regenerate choice, and at Change Passphrase and Regenerate while Castle-era copies exist, with Export offered.
  - (c) Define which secrets promise 5 counts as held.
  - (d) Add a fixed scenario: leave Castle, regenerate the words, change the passphrase, then restore a Castle-era copy.

**[MAJOR] 9 · design §3.8 lines 469–473; the one-minter list (lines 251–256); rule 2's second exception (lines 136–138) · A Standard library that leaves its account keeps its key under the account's Apple key, with no way to get a key of its own.**

- **Evidence.**
  - Only a Castle library re-keys when it leaves an account, and no minter covers a Standard library leaving.
  - The Standard repair wants "the library's or account's own key"; otherwise it says "waiting" (lines 222–223).
  - Every delete waits for its replacement (line 196), so the account's wrap stays in the live key file and in every later backup.
- **Sequence.**
  1. The library is Standard, synced with account X.
  2. She uses Stop syncing here, deletes the account here, or moves the library to another account.
  3. Weeks of backups follow, each carrying the wrap under X's Apple key.
  4. She uses Use Castle locally. It retires "the Apple keys this library alone uses" (line 265), which doesn't include X's.
- **What breaks.**
  - The copies made after leaving keep opening through X's Apple key for as long as X stays Standard. The second exception only covers copies "from while it synced".
  - If instead the library stays Standard and X later enters Castle on another device, the library's only Apple road dies and nothing can mint a new one. Rule 3 is then false, and the assessment says "waiting" forever.
- **Fix.** Add "a Standard library leaving an account" to the one-minter list. At the leave, mint the library's own key and wrap under it, then drop the account's wrap once the new one verifies. Add a fixed scenario.

## MINOR

**[MINOR] 10 · design §3.4 lines 243–246; §3.6 lines 376–378 · Under "never out", the crash reasoning for the acts that leave Castle is wrong, so promise 6 depends on an old backup's secrets.**

- **Evidence.**
  - §3.4 says a crash always leaves "the old custody item, the new key, or the new key through the history".
  - When leaving Castle, the new history can't hold the outgoing Castle key. The one key file is rewritten for L″ before the swap (lines 500–502), so L′'s wraps under the passphrase, the words and M′ are gone.
  - §3.6's "the old key's file … still open the library" names a file that format 3 doesn't keep.
  - On Always ask there's no custody item. After a crash between the key-file write and the swap, the file is still under L′, and the only road is the newest backup pair under L′. Today's runner takes one at every Castle re-key (`PostureSwitch.swift:1241-1243`). It opens only with that day's passphrase or words.
  - If she has changed the passphrase since that backup and regenerates the words at the Use Standard door, no road remains.
  - The memory's mirror of the old wraps could serve: it's rewritten after the swap (line 503). But it isn't one of §3.3's lobby roads (lines 197–207).
  - A silent follow into Standard on an Always-ask device has the same gap.
- **Fix.** Keep the outgoing key's own wraps — never under anything Apple-reachable — in the key file until the swap commits, or make the memory's mirror a lobby road that moves only after the swap. Add crash-at-every-step runs for Use Standard and for the silent follow on an Always-ask device.

**[MINOR] 11 · design §3.5 point 4 (lines 313–316, 329–330, 334); rule 2's first exception (lines 134–135) · Use Castle's retirement can be stopped after its commit point, leaving a state the design says can't exist.**

- **Evidence.**
  - A readable vault still on the old key, "read fresh again at the last step", "stops the retirement". But the last step comes after the re-key commits.
  - That leaves a library that entered Castle after this change with the old key alive. This contradicts "never has this exception" and "the one way a library can be in Castle with the old key alive".
  - The text doesn't say whether Use Castle refuses at the door when the pre-sheet check finds such a vault. That's reachable: a local-only library on a Mac signed in to a pre-change Standard account. The door condition (line 331) would show the exception, so the behavior is honest, but the prose isn't.
  - Signed out, the one-road Use Castle can't read the library's own former account, which the record lists as still on the old key. So the retirement goes ahead and costs that account's other devices their Apple copy. The sheet only says the account "can't be checked".
  - The retirement deletes "the key" by its old name. If an older build re-minted it under an id the record never listed, it belongs to another library or account.
- **Fix.** Refuse at the door when a readable or record-known vault names the old key, and say the way through. For the race at the last step, land with the door and exception showing, and reword lines 135 and 329. Delete the old-name item only when its id is one this record lists.

**[MINOR] 12 · design §3.10 lines 536–552; memory row (line 168); map lobby table (gen.py:1108–1113); L-1 · VX-310's lobby rule rests on facts that are unreadable or "decide nothing" before unlock, and it treats the biometry hash as a verdict.**

- **Evidence.**
  - "Working" means the memory's stored hash equals `domainState.biometry.stateHash`.
  - Apple facts §4.7 and implication 8 say a major OS update can raise a false alarm: "Treat a changed hash as a hint, never a verdict."
  - After such an update with no enrollment change, a valid item reads "not working". That means no button (against her pick, line 91: "the button whenever a Touch ID item exists"), the wrong line, and a re-arm question whose "no" records Always ask.
  - The lobby table's fourth row decides on "while the record says Touch ID", but the record is encrypted until unlock.
  - "The keychain wiped" removes the memory item too.
  - And the memory, which "decides nothing", decides the button.
- **Fix.** Show the button whenever an item for the current key exists. Use the hash only to choose which line to show after a press fails. Say that the lobby's Touch ID display reads the unverified memory as a hint, for display only.

**[MINOR] 13 · design §3.2 key-file row (line 165); plan §3 lines 139–142 · Nothing records which history keys were made in Castle.**

- **Evidence.**
  - "Never out" needs that fact for each history entry.
  - Format 3's entries carry only "fingerprint, epoch and retirement date", and the record keeps no mode per epoch.
  - The migration can't infer it from format-2 key files. A missing `apple` field means either Castle-era or exposed Standard — corner 45's own ambiguity.
- **Fix.** Add an era mark to each entry, written at every re-key from the record's mode. Give the migration a rule for unknown eras: treating them as Castle (left behind) is the safe default, and the design should say what that strands.

**[MINOR] 14 · design §3.6 lines 374–378; §3.7 lines 439–441; promise 6 (lines 727–728) · Copies can carry the record's act in flight.**

- **Evidence.**
  - The record names the act from its start, but copies pause only between the prepare and the swap.
  - So a backup, lock-time copy or Send Library taken during a synced act's rotation (before the prepare), or after the swap (before the last steps), carries "act in flight".
  - That breaks the letter of promise 6, and nothing says what a landed copy, or a backup opened on a new Mac, does with it.
  - "After it, the act's remaining steps … finish from the record" would then retire the old shared key on that Mac without that Mac's checks.
- **Fix.** Write copies with the act cleared, or have the open and the landing discard a copy's act in flight.

**[MINOR] 15 · rule 2 (lines 126–144); promise 2 (lines 713–716); §8 lines 962–963 · A retirement made while iCloud Keychain is off is in neither rule 2's nor promise 2's exceptions.**

- **Evidence.**
  - §8 states the residue, but no surface can say it, because Variorum can't see the switch (corner 46).
  - For a local-only library, no other device knows the id is retired. If that Mac's iCloud Keychain stays off, the key lives on in iCloud and on every other device of the Apple account indefinitely, while the library says Castle with no exception.
  - Promise 2, checked after every action, will flag it.
- **Fix.** Hedge rule 2 the way rule 3 is hedged ("…once iCloud Keychain carries the deletion"), and add the case to promise 2's exceptions or check that clause only once the world settles.

**[MINOR] 16 · design §4.1 lines 673–705; plan §6 lines 249–251; plan §2 lines 111–114 · The scenario world drifts from the Apple facts and from the design.**

- (a) "What a device makes while it's off never leaves that device" contradicts facts §6(a): items added with iCloud Keychain off sync once it's turned on. The fake would hide keys that arrive late, and it would make a follower wait forever in a case where the real one wouldn't.
- (b) The plan's fake iCloud Keychain drops round 1's same-name rule (m12(c)). The design's world keeps it (lines 674–675).
- (c) The adversary "read[s] or delete[s] keychain items … never Touch ID items" (line 701). The facts say Keychain Access "can presumably delete what it lists" (§12.7), and nothing says it can't list an access-controlled item. A deleted Touch ID item then brings the re-arm question with a false reason. This is SPECULATIVE about the real behaviour; one check on a throwaway scope settles it.
- (d) "Every user act is in its action alphabet" (line 679), but the alphabet lacks: the gate-style change, the answer to the re-arm question, the idle lock, the scheduled export, corner 45's notice, the offer's delete (which promise 11 and K-3 test), making a plaintext export, and removing a finger. The plan's act files lack Send Library (the record's hand-off note) and the offer's delete (which deletes an Apple key).
- **Fix.** Correct (a), restore (b), model (c), complete (d).

**[MINOR] 17 · phase-1 plan · The plan understates or contradicts the design in seven places.**

- §6 line 284: promises are "checked after every step". That drops "3 and 7 once the world settles" (design line 709, round 1's m15).
- §5 line 235: the test "a failed seal: … the setting reads the stricter value" exercises a mechanism the design replaced. The settings now live in the record.
- §3 lines 133–135: the record's fields omit the hand-offs.
- §3 line 143: `Backups/<library8>/` drops the `<mac8>/` level (design line 165; first designer R3-3).
- §4 lines 193–196: the retirement-list oracle omits "every hand-off the record knows" (design lines 311–312).
- §6 lines 336–339: the mutation pins name five guards, but not the five the design names (lines 789–791).
- §1 line 92, and design §5 line 829, say Fable orchestrates. Her later cast call on main, made after this branch froze (`5e3d86f6`, `vx-33-release-runway.md` §3), says *"each run is orchestrated by Opus … Castle's Sync/ lines stay Fable-written"*. That's hers to apply at kickoff.

**[MINOR] 18 · design §7 lines 905–938 · The canon deltas for "leaving Castle re-keys" are incomplete (round 1's m17 class).** Decision 7 is listed. These are not:

- decision 9;
- decision 33's "Touch ID confirms only wrap-free acts (leaving Castle, …)" (pre-13x line 164);
- the Castle table's "at the switch to Standard" column, and the two-switches table's Castle → Standard column ("the same key", "NO rotation");
- §4's Castle → Standard paragraph ("Nothing rotated");
- §7's follow into Standard ("nothing typed, nothing rotated");
- §12's "a Castle→Standard switch propagates silently".

**[MINOR] 19 · design memory row (line 168) · The device identity's new home rests on a fact the design's own research contradicts.**

- **Evidence.**
  - The design says the memory item is "device-only, so a new Mac — Migration Assistant, Quick Start — starts its own".
  - Apple facts §3.4 and implication 5: Quick Start has been seen carrying ThisDeviceOnly items to a new iPhone, and Migration Assistant and Time Machine behaviour on macOS is unknown.
  - The second opinion §2.5 asked to "re-mint the identity when the hardware changes", and round 1's m20 named it, but the disposition swapped it for the device-only claim.
  - A cloned identity shares a device cursor (corner 37, the purge horizon) and a `<mac8>` folder. Two Macs' retention could then prune each other again (VX-302).
  - SPECULATIVE for macOS.
- **Fix.** Keep the re-mint guard (a hardware-bound marker in the memory) and pin it.

**[MINOR] 20 · design §3.7 line 427; §3.15 lines 644–645 · A copy with no record has no rule for its mode.**

- **Evidence.**
  - Every backup, older library and hand-off made before this change carries no record.
  - "A different library keeps its own mode" needs one, but corner 45 and `Posture.derive` are deleted.
  - The proposal's rule — "opening one works its mode out once with today's rules, like the migration" (`design-proposal.md` §7) — didn't survive the merge.
  - Watch the trap: defaulting such a copy to Castle strands an exposed-era Standard copy that has no passphrase.
- **Fix.** Restore the proposal's rule, scoped to copies with no record.

**[MINOR] 21 · key maps (gen.py) · The acceptance artifact carries pre-ruling and lagging text.**

- Line 1053, step 4 of "Another device follows", on both pages: the notice says *"your Apple account can now open this library and every copy Variorum kept of it, including copies made while you were in Castle"*. That is the opposite of rule 5 and her ruling.
- Line 1069, migration step 2: it says only "nothing Apple-reachable is written". The design (lines 606–607) says no custody repair in either direction (round 1's m7).
- Line 1028, entering step 4: the pill reads `{L′} · locked with {M}`; it should be M′.
- S-2 (line 1128) says the key file locks the current key with the passphrase and the words. That's false after a silent follow into Standard: that device's new key file can't carry those wraps, because no secret was typed. The words still open it, through the master's words copy.
- The lines in MAJOR 1 and MAJOR 2 apply here too.

## NIT

1. §5 phase 3's members (line 841) omit VX-263, which §6 (line 873) places in phase 3.
2. §2's ticket list (line 115) omits VX-317, which line 892 places.
3. §4.3 (line 819) puts the map table at "the final phase's closeout", which §5 makes phase 6. §5's phase 5, the map page and the plan all say phase 5.
4. The outside-the-project list (lines 899–901) doesn't mention VX-81 or VM-15, which the runway asks the Castle session to weigh. VX-301 largely settles VM-15; say so.
5. Corner 45's interim state:
   - Promise 2 isn't exempted for a library recorded as Castle but not yet confirmed, which keeps its silent item by design (lines 606–607).
   - "Use Standard one press away" (line 604) is now a two-secret re-key.
6. The retire ask and its door live in each device's own record. Say that it's asked once per device, so the phone's stale exception after the Pro has retired the key isn't a surprise.
7. Defaults are unstated for a device with no entry in the record's per-device settings (a landed copy, a follow into Castle, a new identity). Whether a follow into Castle makes a Touch ID item depends on this.
8. Send Library's sentence (lines 432–434) says whatever opens the copy opens "this library's copies under that key". With format 3's history, it opens every older copy too.
9. The stated limit says a whole-state rollback "never opens the library to them" (lines 386–387, promise 10). After a rollback to a Standard-era state, the Standard repair rebuilds a silent item, so what she writes afterward is login-readable. Scope the sentence to what was written before the rollback.
10. The plan's LIVE STATUS (lines 350–354) names no unit as NEXT, though the kickoff says to do "the unit named NEXT".

## Clean bill

- **The pages match the generator.** The three published pages (target, full, cycle) are byte-identical to fresh generator output.
- **The code premises hold:**
  - the old shared key: `AppleKeyCustody.swift:124-135, 189-195` (service `apple-key`, account `<scope>-apple-key`, value `{id,key}`, "never deleted in production");
  - the silent item: `StoreKey.swift` (`<scope>-<storeID>-bound`, `WhenUnlockedThisDeviceOnly`);
  - the 13p escrow item: `StoreKeyGuard.swift:223, 450-455` (a raw key, synchronizable, its account the store id);
  - the device identity in `SyncCustodyRecord`, plus the identity-only item: `EncryptionKeychain.swift`;
  - Send Library copies the key file byte for byte: `LibraryHandOff.swift`;
  - today's runner takes a fresh snapshot at every re-key and turns the export off on the way into Castle: `PostureSwitch.swift:1241-1243, 1349-1384`;
  - `refuseIfRekeyIncomplete`, `KeychainTestTripwire` and `VX209WayBackRoundTripTests` exist, as does every file the phase-1 plan names;
  - an older build's Open Library refuses a newer-schema copy (`LibraryClassifier.swift:236-244`), and the live store has no such check, so §3.13 step 9's road back holds for the live library and the A1 copy.
- **Entering Castle holds up.**
  - The history runs backwards only.
  - Keeping the old key in the new history leaves a road at every crash point, on Touch ID, silent and Always-ask devices alike.
  - The library's own Apple keys are retired; the account's key goes with the account's rotation.
  - Delete on sight acts on recorded ids only.
  - No key is ever written under a shared name, and no vault moves automatically.
- **§3.5a** adds no brute-force target and covers the silently joined device.
- **Round 1's fixes that hold:**
  - M4: old-key accounts get a key of the device's own when a device joins, and Replace All Keys re-links first, so decision 30 holds under the account's own key.
  - m6: escrow items are folded into the history, then removed.
  - m8: the record is written into the staged file before the swap, with copies paused.
  - m19: the lobby's roads.
  - R3-1: the move off the old key only adds roads.
- **Tickets and the plan.**
  - Every ticket has a phase, and §5 and §6 agree except for NIT 1.
  - The phase-1 plan matches the design on scope, hard limits, go/no-go and crash testing at every step.
  - Its fixed scenarios cover the design's list, with sound additions.

---

## Her follow-up question, put to the same reviewer after its report

Her words: *"ask it if it has ideas on how to improve the system - key rotation fixed a lot of problems, to be clear.
are there still problems / weird edge cases in our solution that are hard to understand?"* Its answer, unedited:

# Round 2 follow-up: improving the system

Changing the key at every switch is the right spine. It means no key ever has to be moved from one kind of keychain item to another or gain an Apple lock later, and it keeps Castle's keys away from the Apple account for good. Most of what I found in round 2 comes from three places where the design still treats something as movable or shared:

- the history is also the only list of which keys belong to the library;
- this Mac's own settings ride inside copies of the library file;
- a synced library uses its account's Apple key for its own key file.

Fixing those three closes many findings at once. None of the changes below touches the server.

## 1. Ideas: simpler shapes, keeping what the key change fixed

**1. A key is born Castle or Standard and stays that way for life.** This follows directly from her ruling.
- A Castle key only ever lives behind Touch ID, or nowhere under Always ask. A Standard key only ever lives in a silent item, and only Standard keys ever get an Apple lock.
- When a key is replaced, its keychain item goes with it. Nothing ever moves a key from one kind of item to the other. The only change left within a key's life is Touch ID ↔ Always ask, which adds or removes its Touch ID item.
- This removes the key-moving code and its races, and the follow's "silent items meanwhile" exposure (finding 3).
- It removes the "if an Apple lock is ever found on a Castle key" repair. That can no longer happen.
- It answers "which history keys were made in Castle" for free (MINOR 13): it's each key's birth kind.
- The library's mode becomes simply the kind of its current key.
- The one spot that would still move a key is the migration's guessed-Castle case (corner 45). On confirmation it should change the key rather than move it.

**2. Keep the library's family tree separate from its roads.**
- One non-secret list of every key the library has ever had: its fingerprint, Castle or Standard, which Mac made it, and when it was retired. The history then holds only roads (locked copies of keys).
- "Is this copy ours?" reads the list, never the history. That fixes the false "made on another Mac, or not by you" and the unwanted raise back into Castle (finding 2).
- The route finder can say exactly "opens with the passphrase or words you had on 12 October".
- "History never flows out of Castle" becomes a rule over the list, not a side effect of what happens to be locked where.

**3. Leaving Castle seals the past in one place: a Castle anchor.**
- At the leave, before anything else is written, Variorum writes one sealed copy of the outgoing Castle key with its whole history. It is locked only under the passphrase and the twelve words typed at the leave, never under anything the Apple account can reach.
- Two versions, and the pick is hers:
  - **(a) The new Standard key takes back nothing.** This is the simplest and strictest: everything from before the leave stays behind Castle's locks. Rules 3 and 5 would then read: "your Apple account opens your library from now on — nothing from before". This also closes the Send Library exposure (finding 5) by construction.
  - **(b) Close to her ruling.** The new key takes back only the Standard keys this Mac itself held, read from the family tree. Her pre-Castle copies on this Mac reopen as ruled, and finding 5 still closes, because the other Mac never held those keys in Standard.
- Either way, the anchor gives the leave its crash road (MINOR 10), and entering Castle again folds the anchor back in (half of finding 8).
- The simplest honest rule for the words: the leave door asks her to type her current twelve words and never offers new ones. Then "keep the paper you had when you left Castle" is true. A later regenerate can re-lock the anchor if she types the old words; otherwise the old paper keeps working for that era.

**4. A library's key file is always locked under this Mac's own Apple key for that library. An account's Apple key only locks the account's master key in the vault.**
- Synced libraries stop borrowing the account's key for their own file.
- This removes finding 9: leaving an account then needs nothing.
- It removes the special "device's own key" case for accounts still on the old shared key, because every device already has its own.
- It removes the "keys this library alone uses" question. Entering Castle always retires exactly one Apple key per library per Mac, and the account's key goes with the account's own key change.
- A new device still sets up silently: the account's key opens the master in the vault, and the master opens the library key.

**5. The library's own facts travel with copies; this Mac's facts don't.**
- A copy carries what the library says about itself: its mode, account and family tree.
- This Mac's facts stay on this Mac, in two places: a device section of the record and what this Mac remembers. Each is sealed, and the newer one wins. Those facts are:
  - the gate style, the idle lock and the scheduled export;
  - the retired Apple key ids and the hand-offs;
  - the act in flight and the device identity.
- This removes the single-file replay (finding 7) and copies carrying an act in flight (MINOR 14). It also settles what a landed copy does with another Mac's settings: it simply doesn't have them.
- Only rolling back both places at once goes back in time, which is already the stated limit.

**6. Use Castle either finishes or doesn't start.**
- Run the old shared key's checks at the door. If something would stop the retirement, say so before any step. The rare last-moment race lands with the door and the exception showing (MINOR 11).
- Keep today's step that turns the scheduled plaintext export off on the way in (finding 6).

**What stays exactly as designed:** a new key at every switch, the history running backwards only, prepare-then-commit, Apple keys retired on entering Castle, delete on sight by recorded id, sealed plans, the catalog and route finder, and copies attributed to a library and a Mac.

**One process point, not design:** phase 2 should stay switched off on main until phase 3 is built (finding 4). Otherwise her Mac picks it up through another effort's refresh.

## 2. Still hard to understand, even where the design is consistent

1. **Leaving Castle doesn't keep what she wrote in Castle private.** After leaving, the library itself opens through the Apple account: every block, every commit and the deleted-blocks tray. Only the old Castle-era backups stay sealed, and most of what's in them still lives in the library. Leaving "for a minute" exposes everything written in Castle. This is the one I'd most want her to see in plain words. The key change protects old copies, not the library she keeps. (Finding 1.)
2. **After leaving Castle, the old backups open only with the secrets she had on the day she left.** A later new passphrase or new words leaves them shut unless she kept the old paper, and nothing in Standard's everyday screens reminds her. (Finding 8.)
3. **The old shared Apple key.** One key serves every library and account on an Apple account, and retiring it deletes it everywhere at once. Variorum can't see her other devices or tell whether iCloud Keychain is on. For her (all Castle) it costs nothing, but she'll be asked once on each device. For a tester with a Standard phone beside a Castle Mac, the cost is real, and the sheet can only describe it with hedges.
4. **A sent library isn't independent.** After Send Library, both Macs share the key and its whole history: whatever opens one Mac's copy opens the other's older copies too. That holds through the other Mac's Apple account while it's in Standard, and, as written today, once it leaves Castle. People will assume a copy is just a copy. (Finding 5; NIT 8.)
5. **Which account can open which backup.** After leaving or changing accounts, copies from the synced period open through that account's keys while it stays in Standard, and stop once it replaces its keys or enters Castle. It's correct, but nobody can hold it in their head. Only a per-copy "opens with" line makes it readable.
6. **Touch ID after a macOS update.** If an update moves the fingerprint hash, she's told "Touch ID changed — use it again?" when nothing changed, and answering no turns Touch ID off. The button can also vanish for reasons she didn't cause. (MINOR 12.)
7. **"Standard" on a device that can't see the Apple key.** On a device with another Apple ID, or with iCloud Keychain off, the library is Standard but "waiting" forever, and the passphrase and words are its real way back. Rule 3's "your Apple account opens your library" is true for the account, not for that device.
8. **"Anyone who can sign in to this Mac" in Standard.** The login password reveals the silent item and the Apple key — her own Keychain Access check showed it. The Standard card says so, but most people won't believe it until they see it. A "try it yourself" line in the field guide would land it.
9. **Markdown exports.** They're plain text and outside every promise. Left scheduled, they quietly make Castle not Castle. (Finding 6.)
10. **Testers recorded as Castle by the migration's guess.** "Use Standard, one press away" is now a full two-secret key change, just to stay where they thought they were.

**One suggestion for legibility:** make the route finder's per-copy line ("Opens with: Touch ID · your passphrase · your words", or "Opens with: the passphrase or words you had on 12 October") the single explanation everywhere — the restore list, the offer, the confirm and the field guide. Treat any copy whose line a person wouldn't understand as a design bug, not a wording problem.
