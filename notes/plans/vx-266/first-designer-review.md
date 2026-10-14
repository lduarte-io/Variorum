# VX-266 — the first designer's review of the merged design, and its dispositions

**What this is:** the record of three review rounds of `notes/plans/vx-266-castle-backups-prelaunch.md` by
**firstcastleredesigner**, the session that wrote the first design (`design-proposal.md`), at the author's ask on
2026-10-13. It changed no file. Round 1 reached the design's owner (variorum-08) through her; round 2 came back
directly, answering the owner's proposed resolutions; round 3 answered the commit that folded round 2 in
(`5e9dc070`). Every finding is dispositioned below; the design, the phase-1 plan and the target key map changed with
each round.

Her standing instruction for this work, verbatim: *"DO NOT get into a game of whackamole - do not solve this issue in a
way that brings back one of the other issues that your design resolved. … focus on a robust design that handles the
whole situation thoroughly."*

---

## Round 1 (relayed by her, verbatim)

> I read the new plan in full (notes/plans/vx-266-castle-backups-prelaunch.md), plus its phase-1 plan, the target key
> map and the second-opinion sections it relies on. I changed nothing and sent nothing.
>
> Overall it's solid. The key map matches the plan, and the cold-read fixes are in, except the history-key exposure,
> which your rulings now accept with a stated warning. I found one glaring design error and one process error.
>
> The glaring one: retiring the old Apple key reaches other libraries
>
> Today's Apple key is shared by every Variorum library and account on one Apple account, on every Mac and phone (the
> plan says so in §3.5). Deleting it from iCloud Keychain deletes it on all of those devices, with no recovery. That's
> the second opinion's own fact.
>
> The plan has Standard libraries keep using that shared key until they enter Castle. Its "one minter" rule only lets
> a new Apple key be made at sync setup, Use Standard, or a new library. So an existing Standard library never gets a
> key of its own.
>
> So when one library enters Castle and answers "yes" to retiring the key, any other library on that Apple account
> that's still in Standard does this:
> - The current library loses its Apple-account recovery. It still opens on its own Mac through the Keychain item
>   there, but nothing replaces its Apple key, so it sits in "waiting" forever. A new Mac or a wiped Keychain can no
>   longer bring it back through the Apple account.
> - Its older backups lose their only road if it has no passphrase or twelve words. Standard allows having neither. If
>   that device hasn't run the new version yet, its migration can't fold those backups' keys into its history either,
>   because the key it would use is already gone.
>
> The question's wording understates this. It says the other library "will keep opening it, but its own older copies
> will then need your passphrase or twelve words". For a library without those, its older copies simply become
> unopenable.
>
> You're in Castle everywhere, so it costs you nothing. But the question goes to every user, and a Mac in Castle beside
> a phone or second Mac in Standard is a normal setup. Phase 1's scenario list doesn't include two libraries sharing
> the old key, so the test may not catch it.
>
> The fix shape is your call:
> - give every Standard library and account its own key before the shared one can ever be retired;
> - make the question name the real cost, or ask the user to confirm they have no other Variorum library in Standard;
> - add that two-library setup as a fixed scenario in phase 1.
>
> The process one: the D1–D10 numbers
>
> The plan cites rulings as "D1"–"D10" throughout. That breaks your one-numbering rule from today: VX tickets only,
> and every ruling gets a ticket even with no work. D3, D6, D2 and D9 have tickets; D1, D5, D7, D8 and D10 don't.
>
> Worth a look, not glaring
>
> - Rule 2 overclaims if the question is declined. It says "nothing reachable through your Apple account… opens your
>   library or any copy Variorum ever made of it". If someone declines retiring the old key, pre-Castle copies still
>   open that way; the plan's own prose admits it. Your new closeout rule about "every / all / ever" wording is aimed at
>   exactly this.
> - The old per-library-ID Keychain items are kept "unread, for one release" (§3.13 step 4). A Standard library's old
>   silent item has to be deleted when it enters Castle. Otherwise it keeps a pre-Castle key readable by anyone with
>   the login password. The plan implies this but never says it outright.
> - VX-310: you said "there should always be a button". The plan drops the button when no finger is enrolled, and shows
>   a reason instead when Touch ID is temporarily unusable. That's probably right, but it departs from "always", so it
>   should go to you.
> - A narrow gap from retiring the account's Apple key. A synced device that joined silently has no passphrase copy in
>   its key file. If it loses its Keychain before it follows the account into Castle (Migration Assistant, a
>   reinstall), it can't open its local file. Its synced writing survives on the server; its unsynced edits don't.

Her direction on the numbering, verbatim: *"i'm not particularly worried about the D- when it's just a decision made on
one ticket (just add it to that ticket in the plan or in linear) but if the d ticket became a real work ticket, do add
it to linear and make its actual # clear, the other session has a point there."*

## The owner's proposed resolutions (sent to the reviewer, verbatim)

> 1. Retiring the old shared Apple key strands other libraries.
>    a) The migration rehomes every live Standard library onto a key of its own: local-only gets a per-library key; a
>    synced account gets the account key, and the vault's CAS picks the one device that mints it. Per-id names mean no
>    same-item conflict. It only runs with a fresh vault read confirming Standard. It folds older keys into the history
>    first, while the shared key is still readable. After that, an updated device depends on the shared key for
>    nothing: its live library has its own key, and its older copies are covered by the history. A local-only Standard
>    library never re-keys without sync, so even an un-migrated one opens its backups with the key in its silent item.
>    The residue is old-build backups on a silently-joined device under a key retired by a Standard Replace All Keys,
>    made before that device updates.
>    b) Retiring the shared key stops being a one-time question in the Castle flow. It becomes an explicit act.
>    Settings ▸ Protection always has it; Use Castle offers it when this library has copies locked with the shared key.
>    Default: Not now. Its sheet lists the devices that have moved off the shared key. Each updated device writes a
>    small, non-secret, synchronizable marker (device name and date) into iCloud Keychain; the list is information
>    only, never a decision input. The sheet names the real cost: "Before you retire it, open the latest Variorum on
>    every device signed into this Apple account. Any that hasn't keeps opening its library there, but its older
>    backups without a passphrase or twelve-words copy could become impossible to open."
>    c) Rule 2 carries an explicit exception until the shared key is retired, on every Castle surface: copies made
>    before Castle still open through your Apple account, and on this Mac for anyone with its login password. Until
>    then, the promise holds for every key the new build makes.
>    d) Fixed scenarios: a Castle Mac plus a Standard local-only phone sharing the shared key, with the phone migrated
>    and not; with and without a passphrase; retire, then check nothing is stranded beyond the act's warning.
> 2. D-numbers. Every D maps to its ticket in the plan. D5 (seals) and D7 (rows owned by the library's account) are
>    real work, so they get new tickets. D4 is withdrawn.
> 3. Rule 2 overclaims if declined: covered by 1c.
> 4. Old per-library-ID items left for one release: Use Castle deletes them for this library, along with the format-1
>    and format-2 key files beside it, after the fold. The custody law becomes literal: no silent item for any key the
>    library has had, old names included.
> 5. VX-310 "always": the button shows whenever a Touch ID item exists for the library's key, whatever the momentary
>    availability. Pressing it with the lid closed or the keyboard away says why. With no working item (no finger
>    enrolled, or invalidated), there's no button, just one quiet line ("Touch ID isn't set up on this Mac") and the
>    passphrase road. I'll ask her to confirm.
> 6. The silently-joined device whose Keychain dies before it follows: every key file that has a master wrap also
>    carries that master wrapped under the twelve words, copied from the vault's recovery wrap. It's non-secret and
>    128-bit, so it adds no new brute-force target; I deliberately left out the passphrase-wrapped master for that
>    reason. It refreshes while that master is current and is replaced only when the key file's master wrap is
>    replaced at the follow. So the words always open the file, even after the master rotates and the account's Apple
>    key is retired, and a backup's frozen key file gains the same road. No server change.

## Round 2 (the reviewer's answer, verbatim)

> Your six fixes mostly hold; below are where I could break them, by your numbers.
>
> 1a holds for live libraries, with three gaps:
> - Older libraries of OTHER libraries aren't live, so the migration never rehomes them. That covers Previous Libraries
>   entries and adoption safety copies of a different library ID, plus hand-offs. A Standard-era one with no passphrase
>   whose only road is the shared key gets stranded by retirement. Fix: at migration, while the shared key is still
>   readable, give each such copy a per-key silent item on this Mac. Or have the retire act list every catalog copy
>   whose only road is the shared key, and hold until each is opened or exported.
> - A window after rehoming. The newest backup pair still carries the shared-key wrap until the next scheduled backup.
>   If the shared key is retired and that Mac is lost in that window, a never-re-keyed local library's backups can't be
>   opened anywhere else. Fix: end the migration by writing a fresh pair.
> - Mixed builds. On an un-updated device, Re-link Apple account (AppleRelinkModel.swift:178 → healAppleHeldCopy →
>   relandAppleHeldCopy) rewrites the vault's Apple copy under the one key it can read, which is the shared key. That
>   undoes an account's rehoming, and a later retirement then strands the account's Apple road. The automatic
>   reconcile arm won't fire after a rehome (key file id ≠ vault id); this manual door will. Fix: the retire act
>   refuses while a fresh vault read, or any key file this device knows, still names the shared key's id. Add it as a
>   scenario.
>
> 1b, two notes:
> - The sheet understates the cost. On an un-updated device the live library also loses its Apple-account recovery,
>   not just its older backups. Suggested: "…keeps opening its library on that device. But if that device is lost or
>   reset before it updates, that library and its backups open only with a passphrase or the twelve words — and
>   without either, not at all."
> - The device list misses devices with iCloud Keychain off, because their markers never sync. Say the list can be
>   incomplete. Also, her D3 words were to delete the key on entering Castle. Turning the shared key's retirement into
>   a separate act that defaults to Not now departs from that, so confirm it with her. Per-library and per-account
>   keys still retire automatically, so most of D3 stands.
>
> 1c holds, with one scope gap. "Any copy Variorum ever made of it" is false for a local-only library that also lives
> on another Mac (Send Library, no sync). That Mac mints its own per-library key for the same library ID, and this
> Mac's Castle entry doesn't retire it, so that Mac's Standard copies still open through Apple. Scope rule 2 to this
> Mac's copies. Make "delete on sight" match only key ids this device recorded as retired. Attributing by library ID
> would delete the other Mac's Standard key.
>
> 1d: add that Previous Libraries case (a different Standard library with no passphrase), the post-rehoming window, the
> mixed-build Re-link, and two Macs holding the same local-only library with one in Castle and one in Standard.
>
> 2 holds only if the docs then cite the tickets and drop the D labels; "D5" next to "VX-NNN" is still a second scheme.
> D4's withdrawal is a ruling too, so under her rule it gets a ticket or a line on VX-209/VX-266.
>
> 3 is covered.
>
> 4 holds, with one condition. Delete a format-1 or format-2 key file only after verifying its key is in the history.
> A key the fold couldn't reach keeps its file, because that file is the copy's only road. Example: a key wrapped only
> under a past passphrase she no longer remembers.
>
> 5 holds, but fix the wording. An invalidated item doesn't mean "Touch ID isn't set up on this Mac"; Touch ID is set
> up and it changed, which is the re-arm question's case. Use two lines: one for no finger enrolled, one for changed
> since you set it up.
>
> 6 holds; I can't break it. W already opens L directly, so M under W adds no new reach. One residue: if the words are
> regenerated while a silently-joined device is offline, its key file keeps M under the old words until it refreshes.
> If that device's Keychain dies first and the account key was retired, only the server copy recovers it, and its
> unsynced edits are lost. List it with your other residue.

## Round 3 (the reviewer's message after commit 5e9dc070, verbatim)

> §3.5 still breaks in one place: the move off the shared key can quietly turn Apple-account recovery into this-Mac-only recovery when the Mac's iCloud Keychain is off.
>
> The mechanism: point 2 moves the live library to its own Apple key and drops the old-key wrap "only after the new wrap verifies". But that check can only read the key back on this Mac. If iCloud Keychain is off, which macOS can't detect (corner 46), the new key never leaves the Mac. The old shared key may well be in iCloud from before it was turned off. The library has now traded a cloud-backed road for a local-only one, and nothing can tell.
>
> The retirement checks won't catch it either: from this Mac everything still opens, so the list is empty and the key is retired. If that Mac is later lost, a Standard library with no passphrase or words has no road anywhere, though before the migration it would have opened through the Apple account. The same applies to the per-library keys minted for other libraries' copies: "exactly as before" holds only until retirement.
>
> Two fixes, both cheap:
> (a) The live key file keeps its old shared-key wrap beside the new one until retirement. Keeping it isn't writing under it, so "never writes under it" still holds.
> (b) The retirement checks flag every Standard library this Mac holds that has no passphrase or twelve words, because its only portable road is an Apple key whose arrival in iCloud can't be verified. The sheet says "set a passphrase first, or this library opens only on this Mac if iCloud Keychain isn't carrying its key". The route finder can already see that no passphrase or words road exists.
>
> Smaller: the format-3 key file written for other libraries goes to Backups/<library8>/. In a shared far folder that path is common to every Mac. Two Macs' migrations would overwrite each other's file, or leave iCloud Drive "… 2.json" conflict copies, each under its own Apple key and with its own history. Put it under <mac8>/ or merge on write.
>
> No reply needed.

---

## Dispositions

**The whole-situation answer to the glaring finding** (design §3.5, "the old shared key"), as it stands after round
3. The fix is not a better question; it is giving everything a road of its own before the shared key can go, without
taking any road away until the author retires it:

1. **This build never writes under the old shared key** — it reads it, and keeps the wraps that already exist.
2. **Each device's migration gives everything it holds in Standard a key of its own, beside the old one:** the fold
   first; then every other library this Mac holds copies of whose newest copy is in Standard gets this Mac's own key
   file for it (in `Backups/<library8>/<mac8>/`, beside its copies) under an Apple key of its own; then a local-only
   live library gains its own Apple key, its old-key wrap kept beside it; then a fresh backup pair. **The move only
   adds roads** (promise 12), so iCloud Keychain being off — which macOS can't report — costs nothing before
   retirement.
3. **Accounts stay on the old key until they enter Castle or are re-linked.** The vault holds one Apple copy, so a
   move would trade a key other devices can read for one that may never have left this Mac. Nothing moves a vault
   automatically, which also leaves an older build's Re-link nothing to undo.
4. **Retirement stays Use Castle's step** — her VX-301 ruling's shape — after checks: the move again; the route
   finder, with the old key taken away, over every copy this Mac can see (other libraries' and other Macs' in a
   shared folder included) and every vault it can read. The sheet lists what would stop opening, and every Standard
   library or copy here with no passphrase or words; a vault still naming the old key stops the retirement; the
   sheet says what the Mac can't see. **No keep-for-now** (her question below): cancel, fix, come back. A library
   already in Castle before this change gets one calm ask and a door that goes once pressed. **PROVISIONAL, hers to
   confirm** — the reviewer is right that her ruling's question didn't show her the key's reach.
5. **Retiring records the key's id**; delete on sight acts on recorded ids only.

**Why this doesn't bring back what the design solved:** no shared-name item is ever written (the F2/F3 races stay
gone); every new key has a fresh id, the migration mints no account key, and an account keeps one key through the
vault's CAS at the deliberate acts (the second opinion's cold read, M1); no vault this device can read is orphaned,
because a vault on the old key stops the retirement, and the ones it can't read are named on the sheet; the move is
an executor act that removes nothing; nothing decides before unlock; and Castle's promise is kept by construction once
the key is retired, with the one exception stated wherever it applies until then.

| # | finding | disposition | where |
|---|---|---|---|
| R1-1 | Retiring the shared key strands other Standard libraries and accounts | **Fixed** by the whole-situation answer above | design §3.5, §3.13 steps 5–8 |
| R1-2 | D-numbers are a second numbering | **Fixed**: the design cites tickets only; D5 → VX-313 and D7 → VX-314 minted (real work); D4's withdrawal is a line on VX-266; the trace lives at the top of `second-opinion.md` | design §1 |
| R1-3 | Rule 2 overclaims when the key isn't retired | **Fixed**: rule 2 scoped and its stated exception written where it applies | design §3.1, §4.1 promise 2 |
| R1-4 | Old per-ID silent items must go when entering Castle | **Fixed**, said outright | design §3.3, §3.9, §3.13 step 4 |
| R1-5 | VX-310 departs from "always" | **To her**, PROVISIONAL with the R2-8 wording | design §3.10, §9 |
| R1-6 | A silently-joined device whose Keychain dies before it follows | **Fixed**: the master's twelve-words copy in key files | design §3.5a |
| R2-1 | Older libraries of other libraries aren't rehomed | **Fixed**, more fully than suggested: a key file and Apple key of their own *when their newest copy is in Standard* (a silent item wouldn't survive a Mac replacement); a library whose newest copy is in Castle gets none, since its pre-Castle copies are what retirement is for; backups-only libraries included. The key file's place moved to `<library8>/<mac8>/` in round 3 | design §3.5 point 2, §3.2 |
| R2-2 | The window after rehoming | **Fixed**: the migration ends with a fresh pair | design §3.5 point 2, §3.13 step 7 |
| R2-3 | Mixed builds: an older build's Re-link undoes the move | **Fixed, then simplified in round 3**: the migration no longer moves vaults at all, so there is nothing to undo; a vault this device can read that still names the old key stops the retirement; our own Re-link mints fresh. (Round 2's move-back repair is withdrawn: it was a vault move by another name.) | design §3.3, §3.5 points 3–4, §3.9 |
| R2-4 | The sheet understates the cost | **Fixed**: the reviewer's sentence, adopted | design §3.5 point 4 |
| R2-5 | The device list misses devices; the separate act departs from her D3 | **Withdrawn markers** (the catalog's concrete list replaces them); retirement **returned to Use Castle's step**; *keep it for now* first offered when something was listed, then **dropped** after her question (below); **to her** for confirmation | design §3.5, §9 |
| R2-6 | Rule 2's scope: a library sent to another Mac without sync | **Fixed**: rule 2 scoped to this Mac's copies and the account's devices; delete on sight by recorded id only | design §3.1, §3.3, §3.5 |
| R2-7 | Fixed scenarios | **Added**: two libraries on one Apple account; an older library of another library (in Standard, and later in Castle); the window after the move; an older build's Re-link; one library on two Macs; a silently-joined device | design §4.1; `vx-305-castle-core.md` §6 |
| R2-8 | Drop the D labels; D4 needs a home | **Fixed** (R1-2) | design §1 |
| R2-9 | Delete old key files only after verifying their key is in the history | **Fixed** | design §3.3, §3.9, §3.13 step 6 |
| R2-10 | VX-310 wording: two lines | **Fixed**, still hers to confirm | design §3.10 |
| R2-11 | Residue: words regenerated while a silently-joined device is offline | **Listed** | design §3.5a, §8 |
| R3-1 | The move can trade an Apple-account road for a this-Mac-only one when iCloud Keychain is off | **Fixed, and generalized**: the move only adds — key files keep their old-key wrap beside the new one until retirement (keeping isn't writing); the same trap in the vault's single Apple slot is why accounts no longer move at migration; promise 12 and a fixed scenario (iCloud Keychain off) pin it; rule 3 now says "through iCloud Keychain, when it's on" | design §3.1, §3.5 point 2, §4.1 |
| R3-2 | The retirement checks can't see that risk | **Fixed**: the checks list every Standard library or copy here with no passphrase or words; the sheet asks for a passphrase first; the sentence covers other devices' libraries too | design §3.5 point 4, §8 |
| R3-3 | Other libraries' key files collide in a shared far folder | **Fixed**: `Backups/<library8>/<mac8>/`, this Mac's own, in the container and beside this Mac's (or unattributed legacy) copies in the far folder | design §3.2, §3.5 point 2 |

The owner's own residue (1a) is listed too: backups an older build made on a silently-joined device, under a key a
Standard Replace All Keys retired before that device updated (design §8).

## After round 3: her question about *keep it for now*

Asked to confirm the retirement's shape, she asked instead, verbatim: *"if keeping it for now is offered, what are the
implications of that? what risk does it expose? do you think it's owrth having to keep that door open forever?"*

The owner's answer: not worth it.

- **What it would expose:** a library that says Castle while every copy from before Castle — backups, older
  libraries, Time Machine, the iCloud Drive folder — still opens through the Apple account, and on that Mac for anyone
  with its login password. That is exactly the halfway posture she ruled out (*"in castle = safe. out of castle = not
  safe"*). It would last as long as nobody pressed the door, with the exception sentence on every Castle surface the
  whole time.
- **What it would buy:** time to update another device or give a library a passphrase before the key goes. Cancel
  buys the same, with no halfway state: fix what the sheet listed, then Use Castle.
- **The one door that has to exist:** a library that was already in Castle before this change can't press Use Castle
  again, so it gets one calm ask and a door in Settings ▸ Protection (her calm-asks rule: an ask is always answerable
  in Settings). The door shows only while copies of that library still open through an old shared key, so it goes
  for good once pressed, and no library entering Castle after this change ever sees it.

The design now says so (§3.1 rule 2, §3.5 point 4, §3.13 step 8), still PROVISIONAL until she confirms. Her VX-310
answer, same question set: the designed reading (§3.10), recorded in the design's §1.
