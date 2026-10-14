# Cold read of the finished design and plans — round 3, Opus (VX-266)

**Reviewer:** a fresh Opus reviewer at max effort, zero framing, run as the design owner's subagent at her ask: *"i
also want you to run another opus subagent reviewer with max level thinking at the same time - the two agent strategy
caught real issues"*. **Target:** the design, the phase-1 plan, the key maps and their generator, and the companion
explainer, at commit `fbcf8794`. **Her ask, verbatim:** *"run another cold review on the finished design + plans to
make sure that the design has no gaps and that the plans reflect the design."*

A Fable reviewer was started in parallel in its own session (`round3fablecastlereviewer`) with the same prompt. Its
safeguards stopped it twice, and at her word — *"in 20 min if it's not doing anything just move on without it"* —
round 3 went on without it.

The report follows, committed unedited. The dispositions are in `design-cold-read-r3.md`.

---

# Design cold read, round 3

**Scope.** This round reads design and plan documents for custody and keychain code. By subject that is Fable's mandatory scope, though no code changed (round 2's Opus reader made the same note). Re-spawn it as `fable-reviewer` if that's the call.

**What I read.** At `fbcf8794`, in full:
- the design and the phase-1 plan;
- the generator, with all three pages regenerated and compared;
- the explainer;
- round 1's and round 2's records and dispositions;
- `second-opinion-apple-facts.md`, SyncSpec, and `pre-13x-postures-design.md` §0–§7 and §14;
- the code wherever the design leans on it, cited per finding.

I needed no Sonnet lookup: the facts document carries every external fact I used.

**Result: 0 BLOCKER · 5 MAJOR · 11 MINOR · 7 NIT.** Four findings reopen problems the design had solved:
- MAJOR 1 reopens round 1's m21.
- MAJOR 4 reopens VX-313's attack and VX-301's retirement.
- MAJOR 5 reopens W-1's class.
- MINOR 9 reopens round 2's M2.

---

## MAJOR

**[MAJOR] 1 · design §5 (lines 1009–1011, 1022–1031), §3.15 · From phase 3's switch until phase 5 merges, Release builds run today's versions of every door that phases 4 and 5 rebuild, on the new storage.** This reopens round 1's m21 for two more phases, on her real store and the testers'.
- **What's wrong.** §5 keeps phase 2 in Debug builds because "an old act pressed between the two phases would leave a key the new storage doesn't name". At phase 3's switch the new road goes on for every build, and "from then on the refresh follows each phase's walk or drill".
  - But phases 4 and 5 also rebuild doors that write keys:
    - phase 4: every leave's re-key, the key doors re-wrapping the anchor, and Re-link minting fresh;
    - phase 5: the landing under a fresh key, adoption's key-file order, and retention per library and Mac.
  - Nothing says what today's versions of those doors do in Release in the meantime.
- **Evidence, from today's code:**
  - **Re-link.** It reads the old shared key (`AppleRelinkModel.swift:132,164`, `controller.readAppleKey()`) and re-lands the vault under it (`:178`, `healAppleHeldCopy`). On a post-switch build, that is this build writing under the old shared key — which §3.5 point 1 says never happens. It recreates the very hazard Use Castle's door stops for.
  - **Leaving an account.** Account deletion leaves the keys in place (pre-13x §5's Delete account row). Sync setup under another owner adopts the library by re-stamping (decision 17). Both count as "leaving an account" under §3.8, and neither re-keys. The library stays under the departed master — the F4/M9 state round 2 closed. Today's code never writes the new record either.
  - **Key doors.** Change Passphrase and Regenerate re-wrap the format-2 file that `StoreKeyEnvelope.locate` finds. The format-3 file's passphrase and words wraps, and its anchor, stay under the old secrets.
  - **Open Library.** It lands a different library keeping the sender's key. Its `CustodyCollisionRule` custody lives under the service `io.lduarte.Variorum.store-key` (`StoreKey.swift:115,266`), which the new lobby (`library-key`) never enumerates. The result is a key held by two Macs created after the change — outside rule 2's third exception, which covers only libraries sent before it.
- **Her ruling's premise.** "my mac and phone can wait for phase 3 to be done" assumes phase 3 finishes the acts that write keys. It finishes only the posture acts.
- **Proposed fix — her call; add it to QUESTIONS.** Either:
  - (a) hold the real-store switch until phase 5 closes; or
  - (b) at phase 3's switch, every door phases 4 and 5 rebuild either refuses with one sentence or routes through the executor.

  Either way, give §3.15 a phase column so phase 2's plan says which of today's writers die at the switch.

**[MAJOR] 2 · design §3.4 "It follows your secrets" (286–291) and "Within a mode" (267–269); §3.9 the key doors (618–620) and Replace All Keys (594–595); §3.8 joining (555–558); promise 5 (855–858); §8 (1142–1145) · The anchor follows the secrets only through the two key doors, and only on the device where they're pressed.** Every other way the secrets change leaves it under the old ones, which falls outside promise 5's exceptions.
- **(a) Changes made on another device.** Each device's anchor lives in its own key file, so a door pressed on device B re-wraps only B's anchor.
  - Device A takes the new secret through the vault road (pre-13x §3.6, 388–391). That road re-wraps A's local copy of the library key, which A holds. But A can't open its anchor with the new secret, and nothing asks it for the other one.
  - Sequence:
    1. The Pro presses Use Standard, typing P1 and W1.
    2. The Air follows, typing P1.
    3. Later, on the Pro: Change Passphrase P1 → P2, then Regenerate W1 → W2.
    4. The Air's copies from before the leave now open only with P1 or W1. Both were replaced on purpose; nothing was forgotten or lost.
  - That is not the one corner (290–291), which needs a forgotten passphrase and lost words. §8's follower residue covers only a stale words road.
  - The acting device's anchor goes stale the same way when the doors are pressed elsewhere, and no residue covers that at all.
  - Her own setup is three devices.
- **(b) Acts other than the two doors that change the secrets:**
  - Replace All Keys with new words (decision 33; the map's Replace All Keys step 1);
  - leaving an account with the words made new (551–553);
  - enrolling into an account whose passphrase differs. Corner 27 re-wraps the library's passphrase copy with the account's — "one passphrase from then on" (pre-13x 823–824). A Castle library joining a Standard account leaves Castle exactly this way (555–557): its anchor is born under the library's secrets, then the library's passphrase becomes the account's.
- **(c) Re-keys within a mode never say they carry the anchor.** Line 267–269 says "the old key and its history"; Replace All Keys is "with the history" (594); the plan's U1 rule (153–155) says the same. Built as written, the first Standard Replace All Keys drops the anchor from the live key file. From then on only the frozen backups' anchors exist, each under its own day's secrets, and the doors have nothing to re-wrap.
- **(d) After a declined reset, the new-words door can't open the anchor.** The anchor is then under the old passphrase and the words. The new-words door asks for the passphrase (286–287), and the passphrase it gets doesn't open the anchor. In Standard the door also has today's plain-confirm forgot road (pre-13x 532–533).
- **Proposed fix — one rule.** Every act that changes which secrets open the library, or rewrites its key file, carries the anchor into the new key file and re-wraps it under the secrets the library has after the act.
  - When the act's typed secret doesn't open the anchor, it asks once for the other current secret, as the reset road does.
  - A device taking a secret changed elsewhere does the same at that moment.
  - State what's left (a declined ask; both secrets changed elsewhere before the device was used) in promise 5 and §8, with the day the route finder names.
  - Pins:
    - two devices, both secrets changed on the other, then a pre-leave copy restored with the current secrets;
    - a Standard Replace All Keys after a leave, then both doors, then a restore;
    - a Castle library joining a Standard account whose passphrase differs.

**[MAJOR] 3 · design §3.4's follower paragraph (278–285), §3.9 into Standard (609–611); plan §3 U1 (150–151, 174–176), §5 U3 (245–246); maps FOLLOW step 4 (gen.py:1292) and CYCLE_OUT's follower step (984–992) · A follower's anchor roads rest on keys the follower doesn't hold, and on one it shouldn't use.**
- **(a) "Typed the passphrase — the anchor key goes under it and under the Castle-era master M′".** This needs M′ in hand.
  - Under Always ask, M′ lives only in session memory (§3.2, 195). It is obtained at unlock "from the typed secret through the vault" (pre-13x 261–263), and Castle relocks on sleep.
  - After any relock that follows the leave's rotation, the vault holds the new master, not M′. M′ is then reachable only through the key file's words copy, which needs the words — and they weren't typed. The same holds where an invalidated Touch ID item can't be read.
  - So an Always-ask follower that types the passphrase can seal its anchor under that passphrase alone. If she later forgets it, Standard's reset road asks for the words to carry the anchor over (288–289), and the words don't open it.
  - That device's copies from before the leave are then stranded with only one secret forgotten. Promise 5's one corner needs both.
- **(b) "Typed the words … and the passphrase road lands the next time the passphrase is verified on that device".**
  - Adding a passphrase road later needs the anchor key in hand. After the follow, the device holds neither the anchor key, nor M′ (its Castle Touch ID items go at the follow — 611, and CYCLE_OUT "gone: their Castle keys' Touch ID items"; Always ask never had one), nor the words.
  - There is no mechanism for this. The same claim appears in FOLLOW and in the explainer. And since both doors open the anchor with the passphrase, neither can re-wrap a words-typed follower's anchor either (MAJOR 2 d).
- **(c) The M′ road assumes the leave rotated the master.**
  - An older build's Use Standard doesn't rotate: it adds M′ under the old shared key to the vault (pre-13x 517–519; the world's older build "writes its wraps under it", 822–823).
  - A new-build device that then follows into Standard wraps its anchor under M′, which is now Apple-reachable through the vault. Its copies from before the leave, and its keys from before Castle, then open through the Apple account. That breaks promise 13 by this build's own write.
- **Proposed fix.**
  - The follower's anchor should need no secret in hand. Wrap the anchor key under the outgoing library key L′ — the device holds it, since the library is open. Keep the outgoing key file's own wraps of L′ beside it as copied blobs: under the secret typed at its follow into Castle, under M′, and M′'s words copy. The anchor then opens with exactly what opened that device before the leave.
  - Replace "the passphrase road lands … verified" with MAJOR 2's rule: the next door that opens the anchor re-wraps it.
  - At the follow, if the vault's master id equals M′'s, an older build left without rotating. Drop the M′ road and say so.
  - Pins: an Always-ask follower relocked after the rotation, typing the passphrase; a words-typed follower; a follow after an older build's leave.

**[MAJOR] 4 · design §3.2 record (191) vs memory (196); §3.6 (435–441); §3.10 (637–647); §3.5 "this Mac's own" (310) and retirement (327–333); §3.13 hardware marker (750–752); promise 10 (866–868); maps R-2 (gen.py:1419) and the legend (1237) · This Mac's facts belong to a device identity that lives only in the memory item.** Losing that item orphans this Mac's device section — through deletion, a keychain wipe, or Migration Assistant to new hardware.
- **The gap.** The record's device-section fields carry no identity and no hardware marker (191); both live only in the memory item (196). The design never says how a Mac finds its own section once the memory item is gone.
- **(a) The memory item is deleted** — by the world's own adversary (832) or a keychain wipe (820).
  1. The next open finds no identity and mints a new one.
  2. The old section no longer counts as this Mac's (439–441).
  3. This Mac's facts fall to §3.10's defaults for a new identity (637–639): Touch ID wherever a finger is enrolled, and the idle lock at its default.
  4. The retired Apple key ids go with the old section.
  - On a Castle Mac set to Always ask, where an attacker has enrolled a finger, the choice is now Touch ID with no item. After her passphrase unlock comes "Touch ID changed on this Mac … Use Touch ID for Variorum again?" (644–646) — with a false reason. A yes makes an item the attacker's finger opens.
  - That is VX-313's attack, by deletion instead of replay. Promise 10 lists planted, edited and replayed items, but not deleted ones (866).
- **(b) Retirement and delete on sight key on "minted and named by it" (310).** A new identity — from memory loss, or by design on new hardware (750–752) — owns none of the library's existing Apple keys. Consequences:
  - **Castle:** Use Castle there retires nothing. The predecessor's own key survives in iCloud Keychain and keeps opening every pre-Castle copy's Apple wrap, with no stated exception. Rule 2 and VX-301 are broken on a replacement Mac. Ids the old section had retired are no longer deleted on sight.
  - **Standard:** the identity has no own key and nothing can mint one (MAJOR 5), so promise 3 never settles.
- **(c) The maps contradict §3.2.** The legend and R-2 put "the device identity" among this Mac's facts "in two sealed homes".
- **Proposed fix.**
  - The device section carries the identity and the hardware marker. A Mac with no memory item adopts the section whose marker matches its hardware.
  - A new identity on new hardware, for a library this Mac holds, adopts as "followed" the Apple key ids named by the live key file's wraps, plus the record's retired ids for this library. A retired id is dead everywhere, so O1's caution doesn't apply to a successor on the same line.
  - Add "deleted" to promise 10.
  - Fixed scenarios:
    - the memory item deleted alone on an Always-ask Castle Mac with an enrolled finger changes nothing;
    - a replacement Mac entering Castle retires its predecessor's own key.

**[MAJOR] 5 · design §3.5 one minter (312–318); §3.3 Standard repair (253–255); §3.9 Re-link (621–625); §3.15 (769–770); rule 3 (170–172) · Once a Standard library's own Apple key is gone, or belongs to another Apple ID, nothing can give it a new one.** This reopens W-1's class.
- **How the key gets lost.** The design's own facts document says it can vanish without the app noticing: "Reset iCloud Keychain", a reset of end-to-end encrypted data, or a delete on any one device (facts §7.3; implication 3). A switch of Apple ID strands it with the old account (facts §6(b)(c)).
- **Today versus the design.**
  - Today's reconcile heals this by minting a fresh key for its own key file (`ProtectionController.swift:1711–1726`).
  - The design deletes that mint as a reading that writes (769–770), and mints only at deliberate acts and the migration (312–318).
  - Re-link mints only the account's key, "re-keys nothing" (621–625), and doesn't exist for a local-only library.
- **Result.**
  - After an Apple ID change, the library's Apple wrap sits under a key the current Apple account doesn't hold.
  - The Standard repair (253–255) can never be satisfied, and nothing tells her.
  - Rule 3 ("your Apple account opens your library") is false for her current account.
  - A Standard library with no passphrase or words — a state the design keeps — is one lost Mac away from gone, silently.
- **Proposed fix.** Give Re-link (or a sibling door, "Re-link this library") a library arm: it mints a fresh own key for every Standard key file this Mac holds whose own Apple key is unreadable, other libraries' key files included.
  - Offer it to local-only libraries too.
  - Have assess surface the lost Apple road with that door.
  - Add it to the one-minter list.
  - Fixed scenario: switch Apple ID, or reset iCloud Keychain → Re-link → promise 3 settles.

---

## MINOR

**[MINOR] 6 · design §3.13 step 3 (724–727) vs step 2 (715), §3.4 (262) and §3.2 (191); maps K-4 (gen.py:1439); plan §6 starting states (314–315) · The migration's kind rule calls the current key of a Standard-waiting or exposed library "born Castle", contradicting the mode step 2 records.**
- **The mechanism.** "One without [an Apple wrap] marks a Castle key" applies to the current key too. A Standard-waiting library (corner 45: a silent item and no Apple wrap) has no Apple wrap, and neither does an exposed one. Step 2 records Standard under today's rules. But §3.4 says the library's mode is its current key's kind.
- **Either reading breaks.**
  - If the key's kind wins, the record says Castle, confirmed, over a library the login password opens through its silent item. Promise 2 is then false on W-1's own victims, and the Castle repair is stuck (there is no Touch ID item to replace the silent one).
  - If the mode wins, step 7 gives a Castle-born key an Apple wrap. §3.3 calls that a planted-file fault answered with a re-key (248–249), and the re-key needs secrets these libraries don't have.
- **Proposed fix.** The current key's kind is the mode step 2 records; the attribution rule applies only to older keys. Add Standard-waiting and exposed to the fixed scenarios.

**[MINOR] 7 · design §3.9 Use Standard, synced (585–589); promise 13 (872–875); C-10 (gen.py:1406) · During a leave's rotation, a key made in Castle sits within reach of the login password.**
- **The mechanism.**
  - The new sync keys go into a silent item (586).
  - Until the rotation completes, the vault carries the previous corpus key C′ wrapped under the new master (decision 6). Today's runner also keeps the previous key in the new custody until then (pre-13x 494), and the design doesn't change that for Use Standard.
  - Keychain Access reveals the silent item to the login password (facts §12). With the session — itself a revealable generic password — the vault then yields C′.
- **Consequence.** Promise 13 ("nothing … a login-password holder can reach opens … any key made in Castle") fails at every action boundary inside the window. A crash or an offline stretch holds that window open, so the generated runs will go red. Only the Apple side was guarded (588–589).
- **Proposed fix.** Keep the new sync keys and C′ in Castle-kind custody (a Touch ID item, or session memory under Always ask) until the completing write. Move them to the silent item together with the account's Apple copy. Or scope promise 13 and C-10 to exclude the window, and say so.

**[MINOR] 8 · design §3.9 (587–589, 598–602), §3.5 (337–340) · Until the account's Apple copy lands, every other device reads a leave in progress as a Castle Replace All Keys.**
- **The mechanism.** The vault's word for the mode is whether it holds an Apple copy (pre-13x 226, decision 35; §3.13). Throughout the leave's rotation — and between the completing write, which another device may make (pre-13x §4 step 3), and the separate Apple-copy write — the vault shows a new master and no Apple copy.
- **Consequences.**
  - A follower in that window does a keys-replaced follow in Castle (600–601). It then follows again into Standard: two typed secrets and an extra Castle key, against "types one secret, once" (598).
  - If the acting device is lost in the gap, the account never reads Standard, and her act silently didn't happen.
- **Proposed fix.** The acting device makes the completion and the Apple copy one write. A follower that sees a key change while a previous corpus key is present follows the keys but holds its library re-key until the account's mode settles. A lost actor gets a road: another device finishes the last step, or the notice says the leave didn't finish.

**[MINOR] 9 · design §3.7 "Is it ours?" (487–497); §3.2 memory row (196); §3.13 step 3 (725); maps OPEN_OLD (gen.py:1301–1305) and H-5 · The family tree has one home, so a rollback or a replayed library file regresses it.** This reopens round 2's M2.
- **The mechanism.** The memory item mirrors the key file and the last mode and account, but not the tree.
  - After a Time Machine rollback past a re-key, the library's own later copies read "made on another Mac, or not by you" (promise 9).
  - A Castle-era one opened into a Standard library goes through the raise (497–499) instead of the own-line road.
  - Round 2's Opus MAJOR 7(b) asked where "the current record" comes from for a copy found at the place. The disposition answered only for this Mac's facts.
- **A second gap.** The tree's first entries are "every key the fold reaches", so a copy from before the change whose key the fold couldn't reach reads as foreign — even though its format-2 key file names its fingerprint.
- **Proposed fix.** Mirror the tree, sealed, in the memory item, and union the two at open, since a tree only grows. Seed it from every fingerprint named by the catalog's key files for this library ID, reached or not.

**[MINOR] 10 · design §4.1's older-build actor (822–823), promise 13 (872–875), §8 · An older build's Use Standard falls outside every stated exception.**
- Today's leave adds the Castle-era master's Apple copy under the old shared key, with no rotation (pre-13x 517–519). One press on any device still running an older build exposes the Castle-era master, the corpus key and every Castle-era key file's master wrap to the Apple account. Its silent follow does the same for that device's own copies.
- The world's older-build actor already writes wraps under the old shared key, so the generator will reach this, and promise 13 will fail with no stated residue.
- **Proposed fix.** Add a residue line and a promise-13 exception for an older build's leave and follow, plus MAJOR 3(c)'s guard so this build never compounds it.

**[MINOR] 11 · design §3.7 landing (500–507); AppSpec §12 restore hold; pre-13x corner 27 (823–824) · When a synced library lands and a secret is "made new", either the account answers to two passphrases or the vault is written during the restore hold.**
- **The mechanism.** A library bound to account X lands held.
  - "A new passphrase if it's forgotten" (502) sets the new passphrase in the landed key file only; the vault still holds the master under the old one.
  - At Resume Sync the device enrolls with the words, and corner 27's one-passphrase re-wrap can't run, because the account's passphrase wasn't typed.
  - The library and its account now answer to different passphrases, and VX-113's "changed on [device]" logic misreads that.
  - The alternative is a vault write during the hold, which promises that no round runs.
- **Proposed fix.** Say which happens. Simplest: for a synced pair, the made-new secret becomes the account's at Resume Sync through the account's forgot road (the words just typed), and the landing says so.

**[MINOR] 12 · plan §6 "The world" (290–292) vs design §4.1 (832–834) and facts §12.4 · The plan's fake Keychain Access "can read, edit and delete every item, Touch ID items included".**
- The design's adversary reads ordinary items and can only list and delete Touch ID items. The facts say a biometric item's secret is never revealed to the login password.
- A fake that reveals Touch ID secrets hands the adversary every Castle key, and promises 2, 8 and 13 fail in every generated run.
- **Proposed fix.** "Reads non-biometric items; lists, edits the attributes of and deletes every item, Touch ID items included; never reads a Touch ID item's secret."

**[MINOR] 13 · design §3.6's seal (431–432), promise 10 (866–868), rule 3 · In Standard the world's own adversary holds the sealing key, so promise 10 can't hold there.**
- **The mechanism.** Seals are derived from the library key. In Standard that key sits in a silent item the login password reveals (facts §12).
  - A login-password holder can therefore forge every memory and plan seal.
  - They can also open the library file and rewrite the record — its mode, account and family tree.
  - Repairs move toward the record (237), so an edited Standard record steers them. A record saying Castle trips the planted-wrap re-key (248–249); an edited account changes how new rows are stamped (533).
- **Proposed fix.** Scope promise 10 and §3.6's claims to Castle: "in Standard, a login-password holder holds the library key and can rewrite the record, as rule 3 says". Make sure no repair acts destructively on a Standard record's word alone.

**[MINOR] 14 · design §7 (1080–1112) · Three canon deltas are missing (the class of round 1's m17 and round 2's m18).**
- **Corner 33** (pre-13x 835–839): "no new library key is needed" for a library that arrives by AirDrop. §3.3's consequences paragraph (270–274) has the same arriving library carrying on with its own key. A landing now re-keys.
- **Corner 6** (802–804): only a library "Standard-born into Castle" re-keys at enrollment. A Castle library joining a Standard account now leaves Castle, with its anchor.
- **Corner 27** (823–824): enrollment's one-passphrase re-wrap must carry the anchor (MAJOR 2 b).

**[MINOR] 15 · maps (gen.py:1398 C-2; 282–283; 379; 1357–1358); design rule 2's second exception (163–164); §1 (77–79) · The acceptance artifact says things the design doesn't.**
- **C-2 and the Castle maps' chips.** "The one key file locks the current key with the passphrase and the twelve words" is false on a follower. A follower's key file holds the secret it typed, the master, and the master's words copy (603–605). Round 2's m21 fixed S-2 but not C-2.
- **t-castle-sync, "Leaving the account".** It says "and through the Apple account only if that account returns to Standard". Under round 2's shape, an account returning to Standard rotates its master, and the fresh Apple key wraps only the new one. So copies made while the library synced in Castle never open through the Apple account (except through MINOR 10). The nuance recorded in §1 that she consented to (77–79) no longer holds either. It changed in her favor, but she should hear that it changed.
- **Rule 2's second exception.** "For as long as the account stays in Standard" — a Standard Replace All Keys also ends it, because the old master leaves the vault.
- **Proposed fix.** Correct C-2 to the follower's truth. Drop the "returns to Standard" clause and correct §1's note. Make the exception read "until that account replaces its master".

**[MINOR] 16 · notes/plans/vx-266/castle-map-fable.html · The companion explainer contradicts the maps and the design.**
- **Out of Castle, steps 3 and 4.** The login password can open "nothing yet". The maps say "the server's copy, through the new sync keys' silent item" (CYCLE_OUT step 3).
- **Step 5.** The Apple account gets the server's copy "once the rotation finishes and its fresh Apple key lands". That contradicts the explainer's own step 4, and the maps, where the account's key lands before the new library key.
- **Hand-offs.** "The exception, the ledger and the caveats are gone" and "No two Macs ever share a key" contradict rule 2's third exception (libraries sent before this change).
- **Missing exceptions.** The Castle pane's "nothing / nothing", and "only you open … every copy", never mention the exceptions the maps list.
- **"Yes — always".** The who-table's "with your passphrase or words — Standard: yes — always" contradicts Standard's "if set" and the one corner.
- **Proposed fix.** Correct it, or delete it now (§4.3 already allows that at phase 5).

---

## NIT

1. **A field the record doesn't have.** "The library's former account as the record names it" (377, 894; ENTER step 1; SHARED step 3) — the record holds "none or one id" (191), and none after a leave. Say "the account the record names while signed out", or add a former-account fact.
2. **Promise 5's exception list (857–858)** lacks copies from before the change whose keys the fold couldn't reach. §3.13 keeps such a key file as that copy's only road, so the generator will flag those copies from the starting state.
3. **The re-arm question's reason.** "A finger was added or removed, or macOS was updated" (645) is false when the item was deleted or wiped, and the lobby said "isn't set up for this library" moments before (654–655). Use one honest sentence for both.
4. **Migration step 7 (741–743)** should give the live library its own Apple key only once its mode is confirmed Standard (decision 35). §3.3's guard covers this in general; step 7's wording doesn't.
5. **Lock-time copies are keyless byte copies,** so they can't be "written with the act in flight cleared" (439–441, 517–519). The open rule should clear a copy's act in flight instead.
6. **Landing edge cases.**
   - A Standard pair that lands with nothing typed drops the pair's passphrase and words roads unless she types them (503–505); say so at the confirm.
   - A pair sent from a words-typed follower opens with the passphrase alone only through the vault road while signed in — a corner of her "passphrase OR words" guarantee.
7. **Small gaps:**
   - joining an account in Castle with a library already in Castle (555): does the key stay?
   - the one minter's "joining in Standard" (315) should say "if it has none";
   - rule 4 (173) vs the raise (498–499);
   - what a kept anchor that couldn't be opened does at the next leave ("one at a time", 276);
   - whether a follow into Castle folds the anchor in with its one typed secret (606–608);
   - the map's rules box drops rule 3's "when it's on".

---

## Clean bill

- **The pages match the generator.** The target, full and cycle pages are byte-identical to fresh output (`python3 -I castle-key-map.gen.py target|full|cycle`, checked with `cmp`). The checklist's 44 rows cover every element the map draws.
- **The maps match the design**, apart from MINOR 15 and the follower-anchor text MAJOR 3 inherits. That covers:
  - the Enter, Leave, Replace, Follow, key-door, Open, Migrate and old-shared-key steps;
  - the lobby and accounts tables;
  - the five exceptions and the rules box.
- **Tickets.** §5 and §6 agree on every ticket's phases (VX-263 in phase 3, VX-317 in §2), and all 24 tickets are placed.
- **The phase-1 plan matches the design's phase-1 row:** scope, hard limits, go/no-go, the world (apart from MINOR 12), the alphabet, and the promises including the settle-only clauses.
  - Its fixed scenarios are a superset of §4.1's, and its mutation pins include all nine of the design's guards.
  - Its U1–U3 rules follow §3.4, §3.5, §3.8 and §3.9 faithfully. They inherit MAJORs 2–4 rather than adding errors.
- **Round 2's dispositions are in the text:**
  - the landing under a fresh key, with one secret and the other typed or made new;
  - a key's kind for life, and the family tree deciding "ours";
  - the anchor written first, and folded back in on re-entry;
  - promise 13 and C-10 scoped to copies;
  - the export-off step on Use Castle and every follow into Castle;
  - two sealed homes against replay;
  - the door-time vault stop, excepting the act's own account, and the last-step race;
  - the old-name delete by recorded id only, never recorded by followers;
  - the `<mac8>/` subfolders, `Acts/` with Land and SendLibrary, and U1 marked NEXT.
- **Entering Castle holds up.**
  - The history takes everything and runs backwards only.
  - Prepare-then-commit leaves a road at every crash point, on Touch ID, silent and Always-ask devices alike. The acting device writing the anchor first does the same for a leave.
  - One Apple key per library per Mac removes the account-key orphaning and the device-own special case.
  - The vault keeps one Apple copy, and nothing moves it automatically. I re-checked that today's automatic heal can't move a vault whose key id this device's key file doesn't record (`ProtectionController.swift:1663–1670`).
  - §3.5a adds no brute-force target.
- **The code premises hold.**
  - The old shared key is `<scope>-apple-key`, holding `{id, key}` (`AppleKeyCustody.swift:33–37`).
  - Today's Re-link and reconcile behave as described (`AppleRelinkModel.swift:132–178`, `ProtectionController.swift:1711–1726`).
  - Today's per-ID items live under `io.lduarte.Variorum.store-key`, so the new design leaves them unread as intended.
  - Send Library copies the key file byte for byte (`LibraryHandOff.swift` header).
  - The export-off step runs on the follow too (`PostureSwitch.swift:976–1002`, `1241–1248`).
  - Standard's forgot road exists (`KeyDoorCopy.swift:49–51`).
  - The A1 rail's copies stay out of the app's own backups and out of the aside lister (`StoreBackup.swift:690–700`, `LibraryAsideCopies.swift:20`).
  - Every file the plan names exists. The only custody-adjacent file main has touched since the branch base is `Migrations.swift`.
- **No invariant is relaxed,** and no lockstep event or server change is needed: the record and export-identity tables are local-only, and the vault protocol is unchanged. Phase 1 writes no `Sync/` line.
- **Her §1 rulings each have a home in the body.** The consequences not yet honored are findings 1, 3(a) and 4(b).
