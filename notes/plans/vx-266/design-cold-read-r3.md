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

**The commits:** the Opus report `beed9951`; the design and phase-1 plan `c40fc195`; this record and the key maps
follow.

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

*Pending: the design's owner and the round-2 Fable reviewer (`variorum-vx-266-63`) are settling round 3's changes, as
she asked. Their agreement — and how each report was handled — is recorded here when it's reached.*

**The ladder:** her process — *"run another Opus Max cold review on the *final* design ... then you can run another opus
max cold review if any more majors were found (that would be the fifth round). stop at that point"*.
