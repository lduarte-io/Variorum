# Cold read of the finished design and plans — round 3 (VX-266): the record and the dispositions

**What ran.** Round 3 was meant to be read by two cold reviewers in parallel, at commit `fbcf8794`, with the same
prompt. Her ask, verbatim: *"run another cold review on the finished design + plans to make sure that the design has no
gaps and that the plans reflect the design."* Her word on running two: *"I will start a new fable reviewer in a new
conversation with that prompt ... i also want you to run another opus subagent reviewer with max level thinking at the
same time - the two agent strategy caught real issues"*.

- **Opus at max effort**, as the design owner's subagent: 0 BLOCKER · 5 MAJOR · 11 MINOR · 7 NIT. Its report:
  `design-cold-read-r3-opus.md`.
- **Fable**, in its own session (`round3fablecastlereviewer`), which she started with the owner's prompt: it was
  attempted twice — once more after she restarted it with a new prompt — and paused each time on its safeguards'
  `[cyber]` flag (three pauses in all, the last stuck in a retry loop). At her word — *"in 20 min if it's not doing
  anything just move on without it"* — round 3 went on without it. No Fable report was received. The asymmetry is
  circumstance, not choice. Fable's eyes on this custody design come back at her last step: a Fable reviewer checks
  the final documents and decisions before her handoff; rounds 4 and 5 are Opus at max effort, per her process.

**Her rulings during the round** (design §1), verbatim:

- the release switch: *"that's fine on my devices waiting for the new system til the end of phase 5"*, then *"yeah
  we'll wait to turn the new system on in release builds / wait to put it in release builds til i'm ready to release
  it."*
- the anchor: *"i think that it's probably good to leave it fixed on the day you left ... i think that's fine that the
  anchor doesn't follow your pasphrase and words - c opies before you left castle open with the passphrase you had when
  you lefti s solid. leaving castle doesn't make words so your current is good - solid."*

**How it settled.** Every finding was traced against the design and the cited code before any fix (the code premises of
MAJOR 1 and MAJOR 5 re-read: today's Re-link reads the old shared key and re-lands the vault under it; today's reconcile
mints when allowed). None is hollow, and none is disputed. The round-2 Fable reviewer (`variorum-vx-266-63`) weighed
in on the three largest at her ask, and the settlement with it is recorded below.

**The commits:** the Opus report `beed9951`; the design and phase-1 plan `c40fc195`; this record `e011ec1f`; the
settlement's notes `37b7bb5d`; the key maps follow.

---

## Dispositions — Opus (MAJOR 1–5, MINOR 6–16, NIT 1–7)

| # | finding | disposition | where |
|---|---|---|---|
| M1 | From phase 3's switch until phase 5, Release builds would run today's versions of the doors phases 4 and 5 rebuild, on the new storage | **Fixed by her ruling:** the whole new system stays in Debug builds until her release word, after phase 5 at the earliest; one switch in one place, with a check that Release still runs today's road; today's code stays alive on main until then, and §3.15's deletions land at the switch | §1, §3.13, §3.15, §5, §6, §9; plan §11 |
| M2 | The anchor follows the secrets only through two doors, on one device | **Fixed by her ruling:** the anchor keeps the secrets of its day and is never re-locked, so no device needs to hear about a change made elsewhere. Every re-key carries it unchanged (part (c)); the new-words door says the old paper still opens it. Promise 5 is re-worded to each copy's day | §1, §3.1 rule 5, §3.4, §3.8, §3.9, §4.1, §8; plan §3, §5, §6 |
| M3 | A follower's anchor rests on keys it doesn't hold, and on one it shouldn't use | **Fixed as proposed:** a follower's anchor goes under the outgoing Castle key — in hand, since the library is open — with that key's own locks from the device's key file copied beside it, so it opens with exactly what opened that device that day and needs no secret at the follow. The "passphrase road lands later" claim is gone. With the vault's master unchanged since Castle (an older build's leave), the master's road is left out | §3.4, §3.9, §4.1; plan §3, §5, §6 |
| M4 | This Mac's facts belong to an identity that lives only in the memory item | **Fixed as proposed:** the device section carries the identity and the hardware marker; a Mac with no memory item finds its section by its hardware; a new identity on new hardware takes over its predecessor's Apple key ids and every retired id; "deleted" joins promise 10; fixed scenarios added | §3.2, §3.5, §3.6, §3.13, §4.1; plan §3, §6 |
| M5 | Once a Standard library's own Apple key is gone, nothing can give it a new one | **Fixed as proposed:** Re-link gains a library arm (a fresh own key for every Standard key file whose own key can't be read here, local-only libraries included), the assessment offers it, and it joins the one-minter list; fixed scenario added | §3.3, §3.5, §3.9, §4.1, §5, §6; plan §4, §5, §6 |
| m6 | The migration's kind rule calls a Standard-waiting or exposed library's current key "Castle" | **Fixed:** the current key takes the mode step 2 records; the attribution rule applies to older keys only; those starting states added to the scenarios | §3.13, §4.1; plan §6 |
| m7 | During a leave's rotation, a Castle-era key sits within the login password's reach | **Fixed as proposed:** the new sync keys and the previous corpus key stay in Castle-kind custody until the completing write | §3.9, §4.1 guards; plan §5 |
| m8 | Other devices read a leave in progress as a Castle Replace All Keys | **Fixed:** one write completes the rotation and adds the account's Apple copy; a follower that sees a rotation in progress holds its re-key until that write; a lost actor's rotation is finished by another device at a press | §3.5, §3.9, §4.1; plan §5, §6 |
| m9 | The family tree has one home, so a rollback regresses it | **Fixed:** mirrored, sealed, in the memory, unioned at open; seeded with every fingerprint the catalog's key files name for the library | §3.2, §3.6, §3.7, §3.13; plan §3 |
| m10 | An older build's Use Standard falls outside every exception | **Fixed:** a residue line and promise 13's one exception, and this build's follow leaves the master's road out | §3.4, §4.1, §8 |
| m11 | A synced landing with a secret made new | **Fixed:** the made-new secret becomes the account's at Resume Sync through the account's forgot road, and the landing says so | §3.7, §4.1; plan §5, §6 |
| m12 | The plan's fake Keychain Access reads Touch ID secrets | **Fixed:** it reads every secret except a Touch ID item's; lists, edits attributes of and deletes every item | §4.1; plan §6 |
| m13 | In Standard the adversary holds the sealing key | **Fixed:** promise 10 and §3.6's claims scoped to Castle; no repair acts destructively on a Standard record's word alone | §3.3, §3.6, §4.1, §8 |
| m14 | Canon deltas missing: corners 33, 6, 27 | **Fixed** | §7 |
| m15 | The maps say things the design doesn't; the account nuance changed | **Fixed:** C-2 to the follower's truth, the "returns to Standard" clause dropped, rule 2's second exception "until that account replaces its keys or enters Castle"; §1's nuance note corrected, and she was told it changed in her favour | §1, §3.1, §3.8; maps |
| m16 | The companion explainer contradicts the maps and the design | **Fixed** in the explainer, to the final design | castle-map-fable.html |
| N1 | "The library's former account" — a field the record lacks | **Fixed:** "while signed out, the account the record still names" | §3.5, §4.1 |
| N2 | Promise 5 lacks copies whose keys the fold couldn't reach | **Fixed** by promise 5's "secrets of each copy's day" (such a copy keeps its own key file) | §4.1 |
| N3 | The re-arm question's reason is false after a delete or wipe | **Fixed:** one honest sentence | §3.10 |
| N4 | Migration step 7 before the mode is confirmed | **Fixed:** the live library's own key only once confirmed Standard | §3.13 |
| N5 | Lock-time copies can't be written with the act cleared | **Fixed:** a copy's act in flight is cleared whenever it's opened | §3.2, §3.6, §3.7 |
| N6 | Landing edge cases | **Fixed:** the confirm says when a landed Standard library has no passphrase or words; the words-typed follower's pair is covered by the new key-file text | §3.7 |
| N7 | Small gaps | **Fixed:** joining in the library's own mode keeps the key; "if it has none"; a kept anchor rides inside the next one; a follow into Castle folds the anchor in when its typed secret opens it, else keeps it; the rules box's "when it's on" | §3.4, §3.5, §3.8; maps |

## The settlement with the round-2 Fable reviewer

She asked that the round-2 Fable reviewer (`variorum-vx-266-63`) and the design's owner agree on the final design and
on how the review reports were handled. Its settlement (2026-10-14), after reading the Opus report, these dispositions
and the revised design at `c40fc195`:

- **Every disposition agreed** — M1 to m16 and N1 to N7: *"none reads hollow, her two rulings are honored verbatim (the
  frozen anchor with the new-words sentence kept; the release switch at her word with §3.15's deletions landing at it),
  and the Opus report itself is the strongest round yet (M4 and M5 are real finds I'd have wanted caught before
  build)."*
- **The four points put to it, each traced:**
  - (a) the follower's anchor under the outgoing key with its copied locks holds, with no missed reach; one note: a
    silently-joined device's anchor opens with the words only, so its copies' *Opens with* line says the twelve words;
  - (b) the lost actor's finish minting the account's key is sound (per-id names and the vault's CAS, at a press); one
    sentence: a never-landed key wraps nothing and is left alone if it surfaces;
  - (c) a successor adopting every section's retired ids is safe under O1; one edge: a living Mac cloned onto new
    hardware can retire an Apple key the original still uses — nothing is lost, and Re-link's library arm heals it —
    so a residue line and a fixed scenario;
  - (d) m13's scoping is sound, and the guard blocks nothing legitimate.
- **Its verdict:** *"With those three notes landed (one Opens-with wording, one orphan-item sentence, one clone residue
  line + scenario), I consider round 3 settled and agree the design is final for round 4."* The notes landed at
  `37b7bb5d`.

**How the reports were handled**, as the two agreed: each report is recorded unedited; every finding is traced to a
mechanism before anything changes, and fixed where real; what only she can decide goes to her, and her words are
recorded verbatim; and each round's changes are settled between the two before the next cold read.

**The ladder:** her process — *"run another Opus Max cold review on the *final* design ... then you can run another opus
max cold review if any more majors were found (that would be the fifth round). stop at that point"*.

---

## The extra, late read — dispositions and settlement

**What arrived.** On 2026-10-14, after round 3 had settled and before round 4, the session she had started as round 3's
Fable reviewer (`round3fablecastlereviewer`) finished its read on Opus, after its safeguards paused it three times.
Her word: *"it doesn't count as the review, but might as well since it read everything"*. It read the design and the
phase-1 plan at `3bdbf7bb`, with the round-3 records. Its report is recorded unedited in `design-cold-read-r3-extra.md`
(`23cc1183`): 0 BLOCKER · 5 MAJOR · 4 MINOR · 3 NIT. It isn't a ladder round, so it used no ladder slot. Its fixes land
before round 4, so round 4 reads the final design.

**A second, independent source.** While drawing the round-3 maps (`0a4e609c`), the maps helper flagged five design
ambiguities on its own. Its first is the extra read's MAJOR 3, and its third is MINOR 7. All five are dispositioned
below.

**Her words that govern the night.** Her overnight mandate: *"ok i am going to sleep. i will tell opus that when it's
done compacting. i want you two to continue through to handoff, ruling provisionally where needed. stop after the fifth
ladder even if there are more majors - at that point i'll consider it in the morning. document decisions and why they
were made for me in enough detail that i can discuss it with a session tomorrow."* On who decides, she told the
round-2 Fable reviewer: *"while it is in control of updating the docs, you have the final say. if you two cannot reach
an agreeement or seriously disagree on something during the night, that's a sign it might be good for me to review it
- flag in handoff. do not take you having the final say as a way to quickly end conversations or arbitrarily reduce
debate."* She told the design's owner: *"do not feel disempowered because it has the final say. that's so you don't get
stuck in a loop. make sure any significant diagreements go into a handoff."*

**How it settled.** The owner traced every finding against the design and the code before proposing anything. The
code checked:
- `KeyVaultFormat` keeps `appleKeyID` and `masterWrappedByAppleHeld` apart;
- the wire row pairs only the previous-key columns, and the server sets `apple_key_id` from the payload with no pairing
  check;
- today's mode reading takes the wrap's presence alone;
- `CorpusRotation`'s header: "Any enrolled device can run THE WALK and COMPLETION".

The round-2 Fable reviewer (`variorum-vx-266-63`) traced the two load-bearing premises itself and sent its views. The
owner sent traced dispositions with five points where it added or differed. The reviewer adjudicated each point, two
of them against its own earlier positions. **No disagreement was left open.**

| # | finding | disposition | where |
|---|---|---|---|
| M1 | Entering Castle retires only one of this Mac's own Apple keys for a library, but a Mac can hold several | **Fixed, all five parts:** (a) entering Castle, by the act or its follow, retires every id this Mac's section lists as its own for the library, with no sheet; (b) "leaving an account in Standard" leaves the minter list — since round 2 the account's key never locks the library, so the mint was a leftover of round 2's M9 fix; (c) a replacement Mac adopts every own id its predecessor's section lists; (d) copies under a key left in a former Apple ID — which this Mac can't delete — are rule 2's new last stated exception, named at Use Castle's door; (e) fixed scenarios | §3.1, §3.5, §3.9, §4.1, §6, §8; plan U2, U3, U4 |
| M2 | A rotation in progress doesn't say it's a leave, so a follower can complete it first (round 3's double follow, reopened), and a lost actor's finisher can't tell a leave from a Castle Replace All Keys | **Fixed as proposed, plus one case:** the leave's first vault write names the account's fresh Apple key in the existing `apple_key_id` with no wrap. The mode reads in three states: wrap → Standard; id with no wrap → leaving, in progress; neither → Castle. Only a device that reads the named key completes it; followers hold. The added case (the owner's): an older build can clear the previous key without adding the wrap, so "id with no wrap" reads as in progress whether or not a previous key stands, and the completing write is then just the wrap. The reviewer's additions: past the first write a crash resumes, never rolls back; and a fixed scenario for the older build's clear. No server change. `Sync/`: Fable's, phase 3 | §3.5, §3.9, §3.12, §4.1, §6 (VX-109), §7; plan U2, U3, U4 |
| M3 | A follower's anchor carries whatever locks that device last held, not the leave day's secrets — which falsifies her ruling's premise on followers | **Fixed as proposed, PROVISIONAL, for her confirm:** (a) a follower's anchor is also locked, at its birth, under the secret typed at its follow (it opened the vault, so it's current). This is a lock made as the anchor is written, with a secret in hand, the same class as the actor's door-typed locks. The dead "anchor follows the secrets" rule was about re-locking an anchor after it's written, which stays forbidden. (b) Rule 5 says what opens a follower's copies, and the *Opens with* line names it. (c) The round-2 residue on a follower's stale words copy is back in §8. (d) Fixed scenarios. **Options considered:** (a)+(b), or (b) alone — only telling the truth. **Why (a):** it's free (the secret was just typed), strictly safer, and makes her ruled sentence true at each device's own leave instead of false on every follower | §1, §3.1, §3.4, §3.9, §4.1, §8, §9; plan U1, U2, U3, U4 |
| M4 | §3.15 deletes, at the switch, code the migration calls after the switch ships | **Fixed:** §3.15 split. The deciding and writing roles die at the switch. Read-only legacy readers stay in the core: today's mode rule as a pure function, called by the migration and forever by copies with no record; the fold's reads of the per-ID and escrow items; and the `RotationMarker` read with today's finish path, for one release | §3.7, §3.13, §3.15; plan §2, U1, U2 |
| M5 | The release switch is the real-store migration moment but has no ticket, run, evidence or ladder; "Debug only" is ambiguous | **Fixed:** VX-329 minted (her release switch), with its own run, ladder and evidence: the suite and soak under `swift test -c release`; the real-scope branch rehearsed before her live stores migrate; a Release build on byte-copies behind the A1 rail; the restore drill; a Fable review of the switch's diff; her acceptance on three devices. Two flags for her, both PROVISIONAL. **(a)** "Off in Release" is read as the app's wiring: the core compiles and is tested in both configurations from phase 1. Her words were *"wait to put it in release builds"*; the literal option, leaving the code out of Release entirely, is named. **(b)** A rehearsal under the real scope writes into her real keychain and iCloud, just as the migration would. So how it's rehearsed is a §9 open item, decided with her; the options are a spare macOS user on the same Apple ID, the Air as a canary, or the rehearsal taken as the first leg of the real migration. The reviewer added that whatever runs logs every Apple key id it mints | §5, §6, §9; plan §1, §2, §11 |
| m6 | A rollback of both homes past a switch to Always ask, plus the re-arm question, hands the library to an enrolled finger | **Fixed, PROVISIONAL:** the re-arm question is asked only after a press fails on an item that exists. A choice of Touch ID with no item behind it records Always ask quietly, and Touch ID comes back only from Settings, with the passphrase. It narrows when round 3's question appears; VX-310's button rule is untouched. The other option, keeping the question and qualifying the limit, was set aside: a question that appears by itself can be steered | §3.6, §3.10, §4.1, §6, §7, §9 |
| m7 | Only the new-words door says "keep that paper", but four other doors replace the words while an anchor exists | **Fixed, generalized (with the helper's #4):** one rule — every door that replaces either secret while an anchor exists says one sentence, from the route finder, for this device's anchor. The words doors say "keep that paper"; change passphrase says the passphrase being replaced, or that day's words, still opens them; the reset road names that day's words, never the passphrase she has just said she forgot (the owner's refinement); and a Use Castle that can't fold an anchor in says which secrets of which day still open it | §3.4, §3.9, §5 (phase 4), §8 |
| m8 | Round 3's Castle-kind custody through the window covers the acting device only | **Fixed by the reach rule** (next row): every device holding keys during a rotation in progress keeps them the Castle way while they reach a Castle-era key | §3.2, §3.9, §4.1 |
| m9 | Keeping the new code out of Release keeps its bug fixes out, and she hasn't been told | **Stated in §5 and §8; hers.** The handoff carries a bug-by-bug table. **The settled recommendation:** **offer** small fixes on today's road for VX-302 (a data-loss class, live for testers whose Macs share a backup folder) and VX-317 (trivial); **wait** on VX-209, with a refusal as her option if she'd rather block than warn; the rest wait. **How the call moved:** the reviewer first said wait on all of them, since phase 3 rebuilds them. The owner argued for offering a VX-209 stopgap, calling it silent from its board title, and the reviewer agreed, given the stretched live window. The owner then found the title stale: VX-201 (in her installed build) shipped a confirm line that says the library leaves Castle and names the road back. With the lowering warned, not silent, both settled on wait. Nothing starts tonight | §5, §8, §9; handoff |
| N10 | The status line and provenance stop at round 2 | **Fixed** | header |
| N11 | Once phase 2 migrates and phase 3 re-keys the dev store, Debug builds from older branches can't open it | **Fixed:** said in §5, and the stage coordinator is told at the merge | §5 |
| N12 | A new device identity has no act, so no press to make its Touch ID item | **Fixed, PROVISIONAL:** it starts on Always ask until her press in Settings turns Touch ID on | §3.10, §4.1, §9 |

**The maps helper's five:**

- **#1** is M3, above.
- **#2: is the leave's custody a new item or the old one?** It's settled by the **reach rule**, the owner's option
  (ii), which the reviewer adopted over its own (i). Kind-for-life is a library key's rule: §3.2 and §3.4 always scoped
  it so. A sync key is held by what it can reach. Until the previous corpus key leaves the vault, the new master
  reaches a Castle-era key, so the new keys and the previous key are held the Castle way, in the account's Touch ID
  sync item made at the press, or in session memory under Always ask. At the completing write they move to a silent
  item, and the Touch ID item goes.
  - **The rejected option (i):** a bounded exception to kind-for-life.
  - **Why (ii):** two crisp pins ("a library key's item never changes kind"; "a sync key that reaches a Castle-era key
    is held the Castle way") instead of an invariant with a carve-out. It also explains the anchor's custody and the
    unfollowed devices' keys from the same rule.
  - Phase 3 orders the writes.
- **#3** is m7.
- **#4** (§3.9 no longer described the reset road against the anchor) is closed by m7's reset-road sentence.
- **#5** (the who-table's "the ones of that copy's day" reads as a floor): the maps' wording becomes "at least the
  secrets of its day; in Castle, whatever opens the library opens them too".

**The drift watchlist** (the three small settlements most at risk of drift), updated:

1. **A lost actor's never-landed account key is left alone,** on §3.5 point 5's precedent. This is unchanged. With
   the leave's id in the vault, the finisher waits for the named key and mints only if it never arrives.
2. **Words-only *Opens with* lines** now arise only where a device never had the passphrase typed, since every
   follower's anchor gains the secret typed at its follow.
3. **The anchor-follows-secrets rule stays dead:** no door re-locks an anchor after it's written. M3's lock is part of
   writing a follower's anchor, not a re-lock.

**The settlement, in the reviewer's words:** *"No deadlocks to flag — the handoff's her-eye set stays as already agreed
(MAJOR 3's provisional adoption, MAJOR 5's two flags, MINOR 9's table, MINOR 6's re-arm narrowing noted)."*

**One more, from the ripple survey.** While checking the website privacy brief, the owner found that the design never
said what the hardware marker is. A raw hardware UUID would have been a fair phase-1 reading, and the record — with every
device section — travels inside every copy, so whoever opens a copy would read a hardware identifier for every Mac
that opened the library. The reviewer agreed and strengthened the fix. **Fixed:** the marker is a hash of the Mac's
hardware identity with a random salt the record carries, never the identifier itself (§3.2). It recomputes on the
same hardware, after unlock where every decision runs, and a marker that leaks alone names no Mac. Phase 1's encoding
scan asserts no raw hardware identifier is written. The random salt guards only a marker that leaks alone (a log, a
Diagnostics dump, a support bundle), where the library ID would have been ambient; for anyone who can open a copy,
the salt sits beside the markers, and the design claims no more. So, at the reviewer's addition, no log line,
Diagnostics entry or support bundle ever carries a marker or the salt, and phase 1's executor tests scan the logs
for it. Other Macs' sections stay in copies, since a rollback and a
replacement Mac's adoption need them. The privacy brief's "a copy carries no device identity" stays true until the
release switch; its at-the-switch delta is VX-329's to hand the site agent. It says that a copy carries, in its
record, each device's random identity, a salted hardware hash and that device's protection settings, used only on
that device.

**The commits:** the extra read's report `23cc1183`; the design and plan revision `624f1bf0`; this record
`cb1bd4f4`; the hardware marker's clause follows.
