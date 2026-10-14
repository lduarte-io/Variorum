# VX-266 — Castle & backups before launch: the design handoff

**For Lillian, the morning of 2026-10-14.** This file stands on its own; a fresh session can work from it alone.

Everything is on branch `vx-266-castle-backups-before-launch` (worktree `~/dev/variorum-vx-266`), pushed and not
merged. The key files:
- the design: `notes/plans/vx-266-castle-backups-prelaunch.md`;
- the phase-1 plan: `notes/plans/vx-305-castle-core.md`;
- the acceptance artifact: `notes/plans/vx-266/castle-target-key-map.html`.

Nothing is built: this is design and plan only.

## Your checklist

1. **Confirm or change the six calls made overnight** (the next section; the design's §9 marks each PROVISIONAL). Each
   was settled between me and the round-2 Fable reviewer, which had the final say at your word. A cold Fable reviewer
   (round 4) then traced each one as ordinary design text: each holds, and each is rightly yours to confirm.
2. **Today's bugs in Release:** say which get a small fix on today's road before the release switch (the table
   below). The recommendation is VX-302 and VX-317 yes, VX-209 wait.
3. **The final Fable review** of this handoff, the branch and Linear: <the result, filled in when it reports>.
4. **Approve the branch.** Then:
   - merge `origin/main` into the branch;
   - open the PR "VX-266: Castle & backups before launch — the design and the plan" and merge it with a merge
     commit;
   - on latest main, update the release runway's Castle section (every phase Debug-only; the release switch is
     VX-329, at your word);
   - log the overnight calls in `notes/QUESTIONS.md`;
   - tell the stage coordinator about VX-329 and the dev store's note (design §5).
5. **Phase 1, when you're ready:** `/architect-phase vx-305` (recommended: custody and design-heavy) or `/run-phase
   vx-305`. The cast is yours at kickoff. The plan's kickoff message is at its top.
6. **The release switch (VX-329) stays dark until your word.** It turns the new system on in Release after phase 5 at
   the earliest.

## The calls made overnight, and why

Your words that allowed them: *"i want you two to continue through to handoff, ruling provisionally where needed ...
document decisions and why they were made for me in enough detail that i can discuss it with a session tomorrow."*
Each call below gives the decision, the other option, why this one, and what changes if you pick the other.

### 1. A follower's anchor is also locked under the secret typed at its follow (design §3.4, rule 5 in §3.1)

**The problem it answers** (the late extra read's MAJOR 3). Your ruling: *"leave it fixed on the day you left ...
copies before you left castle open with the passphrase you had when you left"*. On the Mac that presses Use Standard,
that's exactly true. On your other devices it often wasn't: each device's anchor was locked only with what that device
happened to hold, so it carried locks that could be stale. For example:
- you change the passphrase on the Pro;
- the Air keeps its key under the old one, opening by Touch ID every day;
- you leave Castle on the Pro;
- the Air's copies from before the leave would then open with the old passphrase, not the one you had when you left.

**The decision:** when a device follows you out of Castle, it types one secret anyway, for the new master. That same
secret now also locks its anchor as the anchor is written. So each device's older copies open at least with the secret
you typed there to follow. Rule 5 now says so:

> *"Your other devices each follow with one secret typed, so their own copies from before open with the words, and
> with the passphrase when it was the one you typed there to follow; each copy's Opens with line says which, and from
> which day."*

**Why:**
- It's free: the secret was just typed.
- It only adds a road, under a secret nothing Apple-reachable holds.
- It makes your sentence true at each device's own leave instead of false on every follower.
- It isn't the dead "anchor follows your secrets" rule: nothing re-locks an anchor after it's written. This lock is
  part of writing it.

**The other option:** change nothing, and only say the truth — on a device that followed, copies from before open with
whatever opened that device that day, often not the passphrase you had when you left. The *Opens with* line would name
it.

**The residue either way** (design §8): words made new during Castle while a device was offline, or a passphrase changed
elsewhere and never typed there, can leave a follower's older copies opening only with that day's other secret. Their
*Opens with* line names what opens them.

### 2. "Off in Release" means the app's wiring (design §5)

**The decision:** your words were *"wait to turn the new system on in release builds / wait to put it in release builds
til i'm ready to release it."* I read "off in Release" as: the new core is compiled into Release builds but dormant,
and nothing uses it until your switch flips the wiring. It's tested in both build configurations from phase 1.

**Why:** that way no new code meets Release's optimizer for the first time at the switch, the riskiest moment, and the
code needn't sit behind compile flags for months. Nothing new runs in Release either way.

**The other option, the literal one:** leave the new code out of Release builds entirely until the switch, with Release
-configuration test runs from phase 1 as the mitigation. If you'd rather, it's a one-line change to §5 and the phase-1
plan's §2.

### 3. How the migration's real-scope branch is rehearsed (design §5 and §9, open)

Debug builds use the dev store's keychain scope, and tests are barred from your real one, so the migration's fold
through your real old shared Apple key would otherwise run for the first time on your own store. The design requires
rehearsing that branch before your live stores migrate. **The method is yours, decided at VX-329's plan.** The
options:
- a spare macOS user on the same Apple ID;
- the Air first, as a canary;
- accepting the rehearsal as the first leg of the real migration — it writes into your keychain and iCloud exactly as
  the migration would.

Whatever runs logs every Apple key id it mints, so a stray key can be deleted by id.

### 4. Today's bugs in Release until the switch (design §5, §8, §9) — your call, bug by bug

| ticket | what it does in today's Release builds | recommendation | why |
|---|---|---|---|
| VX-209 | Opening a Standard-era copy into a Castle library brings the library back in Standard. VX-201's shipped confirm line says so and names the road back: *"This copy isn't in Castle, so once it's open your library opens the old way — press Resume Sync, then choose Use Castle again in Settings ▸ Protection to put it back in Castle."* The field guide warns too | **wait** (a refusal is your option) | It's warned, not silent: the ticket's title predates VX-201. It's the interim behaviour you once said yes to. A refusal would only block a click-through, at the cost of a mini-ladder on code the switch deletes |
| VX-302 | Two Macs sharing a backup folder prune each other's backups | **offer a small fix on today's road** | A data-loss class, live for any tester whose Macs share an iCloud Drive backup folder (your Air doesn't share the Pro's) |
| VX-317 | Resume Sync clears the hold banner even when removing the marker failed, so the next launch comes up held with no explanation | **offer** | Trivial, and it confuses without warning |
| VX-107, VX-108, VX-109, VX-113, VX-213 | the follow's double-crash sentence; the doors reading a stale posture; `begin` re-fetching the vault; the changed-elsewhere refusal's words; the encryption tidy-ups | **wait** | Phase 3 rebuilds each wholesale, so a today-road fix would be thrown away |

**How the call moved:**
1. The Fable reviewer first said wait on all of them.
2. I argued for a VX-209 stopgap, calling it silent from its title, and the reviewer agreed, given how long the live
   window now runs.
3. I then found the title stale: VX-201's confirm line ships in your installed build. With the lowering warned, not
   silent, we both settled on wait.

Each "offer" would be its own ticket and run, at your word. Nothing has started.

### 5. The Touch ID re-arm question asks only after a press fails on an item that exists (design §3.10)

**The problem** (the extra read's MINOR 6). Someone with your login password copies the library and memory item while
you're on Touch ID. You switch to Always ask. They enrol their finger and write the copies back. Both copies say "Touch
ID", no item exists, and round 3's question — *"Touch ID can't open Variorum on this Mac any more. Set it up again?"* —
would appear by itself. A yes makes an item their finger opens.

**The decision:** the question follows only a press that fails on an item that exists, which is the case of a fingerprint
change invalidating it. When the choice says Touch ID but no item exists — deleted, a wiped keychain, or that rollback —
nothing is asked. Always ask is recorded quietly, the lobby's quiet line says Touch ID isn't set up for this library,
and you turn Touch ID back on in Settings with the passphrase.

**Why:** a question that appears by itself can be steered; a press you make in Settings can't.

**The cost:** after a genuine keychain wipe, you turn Touch ID back on in Settings instead of answering a prompt. Your
VX-310 rule, the button whenever an item exists, is untouched.

**The other option:** keep round 3's question for every missing item, and add to the stated limit "unless you answer
yes to Touch ID's question".

### 6. A new device identity starts on Always ask (design §3.10)

**The decision:** a replacement Mac (Migration Assistant, Quick Start) has no act and no press of yours to make its
Touch ID item, so it starts on Always ask. You turn Touch ID on in Settings.

**Why:** it's consistent with call 5: no item-making question appears by itself.

**The other option:** a one-time offer after its first passphrase unlock. The exact words come to your phase-4 walk
either way.

## The review, tonight

- **Round 3's late extra read** (the session started as round 3's Fable reviewer, finished on Opus; not a ladder round,
  at your word): 0 BLOCKER · 5 MAJOR · 4 MINOR · 3 NIT. Every finding was fixed or handed to you as above. The biggest
  fixes:
  - entering Castle retires every Apple key this Mac holds for the library, not just the one in use;
  - a leave in progress is marked in the vault, by the new Apple key's id with no wrap, so no other device can finish
    it wrongly and bounce your account through Castle and back;
  - today's code the migration needs survives the switch read-only;
  - the release switch got its own ticket, VX-329, with its own evidence.
- **From my check of the briefs:** the design never said what the hardware marker inside the library file is. It's now
  a hash with a random salt, never the identifier, and never in a log.
- **Round 4** (a fresh Fable reviewer, my subagent, at your word): 0 BLOCKER · 0 MAJOR · 1 MINOR · 1 NIT, both fixed:
  - an old build's crashed act on a store that skips a release is now resolved from disk;
  - a phase-table mismatch.

  **No new major, so the ladder closed. No round 5 ran.**
- **The key maps and the explainer** were brought to each revision and co-signed. The three map pages regenerate
  byte-identically from the generator, and the checklist has 47 rows.

The records, each report unedited with every finding's disposition:
- `notes/plans/vx-266/design-cold-read-r3-extra.md`, with its dispositions in `design-cold-read-r3.md`;
- `design-cold-read-r4-fable.md` and `design-cold-read-r4.md`;
- rounds 1–3 are beside them.

## Disagreements

**None left open.** Every point was settled between the two sessions, and the reviewer used its final say only to
adjudicate, never to cut a debate short. Two corrections landed, one in each direction:
- my VX-209 "silent" claim (call 4);
- the reviewer's first framing of the hardware marker's salt, which I corrected and it accepted.

## Every surface whose words change, and its phase

A shipped string changes only in the phase that changes the behaviour behind it, and only in Debug builds until your
switch. The website changes at the switch.

| surface | where its words live | what changes | phase |
|---|---|---|---|
| Use Castle's door and sheet | `PostureCopy.swift` (§2b) | both secrets typed; the floor; *Export a plain copy first*; the old shared key's checks and sheet; copies under a key in a former Apple ID named | 3 (VX-307) |
| Use Standard, the leave screen | `PostureCopy.swift` (§2c) | rule 5's sentence and the other-devices clause; the words typed, never made new | 3 |
| The follow's typed step and banner | `PostureCopy.swift`, `PostureFollowModel` | one secret typed; rule 5; *"Finish leaving Castle, started on [device] on [day]"* | 3 |
| The key doors | `KeyDoorCopy.swift` | the per-door sentences about copies from before a leave (design §3.9) | 4 (VX-308) |
| Re-link and its library arm | `PostureCopy.swift` (`relinkConsent`), `AppleRelinkModel` | a fresh key; the library arm's consent | 4 |
| The lobby and the Touch ID re-arm | `PostureCopy.swift` (§3) | the button rule (VX-310); the re-arm question only after a failed press; the quiet no-item line | 2 (lobby), 4 (re-arm) |
| The signed-out screens and the account acts | `PostureCopy.swift` | VX-264's words; every leave re-keys | 4 |
| Settings ▸ Protection, the cards | `PostureCopy.swift` (§1) | the Standard card's login-password truth: "anyone who can sign in to this Mac" | 5 (VX-309) |
| Data Safety, the restore list, Open Library | `DataSafetyCopy.swift`, `LibraryOpenCopy.swift` | the *Opens with* line per copy; the concrete confirm; "made on another Mac, or not by you"; a landing's other secret; Send Library with no sharing sentence; the "leaving Castle" confirm line retires | 5 |
| The field guide's privacy chapter | `ProtectionCopy` (`PostureCopy.swift`), rendered by `TutorialSeeder` | the older-copy warning retires; the try-it-yourself line arrives | 5 |
| `RESTORE.md` in every backup folder | the backup service | the new roads | 5 |
| The copy file, the one source of the app's words | `notes/plans/pre-13x-copy.md` | every entry above (design §7) | 3–5 |
| The website's privacy policy and FAQ | `notes/stargazing-castle-rebuild-delta-brief.md` | the facts that flip — old backups after Castle, Send Library, restoring, leaving Castle, what a copy carries | at the switch (VX-329) |

## Linear

All of it is co-signed by the round-2 Fable reviewer.

- **Minted:** VX-329, *Castle rebuild, the release switch — the new protection system on in Release builds, at her
  word*. It sits after VX-309, beside VX-212; the order is yours.
- **Retitled:** VX-301, now *Retire the Apple key when entering Castle (one per library per Mac, one per account for its
  vault only, each named by its own id)*.
- **Re-bodied:**
  - VX-266, the flagship, with a comment carrying your rulings tonight verbatim;
  - VX-263, VX-301 and VX-313;
  - the phase tickets VX-305 to VX-309. VX-306 now says *"on in Debug builds only, like every phase's new code, until
    her release switch (VX-329)"*. VX-307 no longer carries a switch, and VX-308 carries the key doors' sentences and
    the re-arm narrowing.
- **"Settled by the design", appended with the history kept:**
  - VX-109, with the leave's rotation folded in — the id with no wrap, the three states, the completer that reads the
    key, the older-build clear, the named finish, the reach rule;
  - VX-107, VX-235, VX-228, VX-264, VX-265, VX-210, VX-314, VX-212 and VX-213;
  - VX-302 and VX-317, each noting it's live in Release until VX-329 and that the bug table recommends a today-road fix;
  - VX-310, whose stale "temporarily unusable" rule is corrected to the button-stays rule, plus your ruling and the
    narrowed re-arm;
  - VX-209, whose title's "silently" is explained (VX-201's confirm line warns). Its status moved from Needs Lillian to
    Todo, since its design question is answered; the stopgap question is the table above;
  - VX-329, with the delta brief, the dev-store note and the rehearsal's key-id log.
- **Comments outside the project:**
  - VM-15: the typed follow settles it. Until the phone follows, its own Apple key is untouched by design. My first
    comment said otherwise and was corrected in place.
  - VX-81: phase 3 re-checks the crash on the new road.
  - VX-102: its premise shifted.
- **Unchanged and correctly placed:** VX-108, VX-113, VX-211, VX-233, VX-239 and VX-243.

## For a fresh session picking this up

- Read this file, then the design's §1 (her rulings, verbatim) and §9 (what's still hers).
- The branch is docs-only. Nobody else pushes it; the untracked `default.profraw` at the worktree root isn't ours.
- The maps come from `notes/plans/vx-266/castle-key-map.gen.py`. Regenerate from inside that folder with `python3 -I
  castle-key-map.gen.py target|full|cycle <out>`; the committed pages must match byte for byte.
- The round-2 Fable reviewer session `variorum-vx-266-63` co-signed every piece tonight. If it's still alive, it's the
  one to ask about how anything settled.
