# Phase 13x — Review foci (for ladder round 4)

**Her ruling (2026-10-07 evening, verbatim):** *"we can go past 3 rounds - let's get another
Fable review. standard cold review prompt but also tell it to proactively consider interactions
and issues that could be problematic - wrong key, ability to enter key, different key for backup
library versus current library and how that would interact with the keys, idk anything else that
could go wrong. I feel like this phase is actually just as tricky as encryption in a sense
because it deals so much with it and I'm concerned that we're missing something still."*

So: round 4 exceeds CLAUDE.md's three-round cap BY HER WORD (an author-only relaxation, made by
her). The prompt stays `notes/REVIEW_PROMPT.md` verbatim; her concern reaches the reviewer
through this file, which the prompt's standing context makes MANDATORY (every focus answered —
a finding, or a named line in the clean bill). These foci carry no implementation narrative:
they are QUESTIONS to answer from the code, not claims about it.

**The stance she asked for:** treat this phase as encryption-grade. Proactively hunt
INTERACTIONS — two correct pieces composing into a wrong state — not only single-function bugs.
For each focus, trace the real code road end to end and say what the user sees, what lands on
disk, what custody holds afterward, and whether the library (both the adopted one AND the
moved-aside one) can still be opened afterward, by which credential.

## The foci

1. **Wrong key.** Every road where the key in hand does not open the store in front of it: a
   key file belonging to another library; a stale key file beside a store; a typed passphrase
   or twelve words that unwrap a key file but that key file is not this store's; an Apple
   (iCloud Keychain) key from another account or another era. Does each road refuse with a
   TRUE sentence, change nothing, and leave every library openable?
2. **Entering the key.** The typed roads: passphrase, twelve words, Touch ID / the biometric
   gate. Wrong entries, repeated wrong entries, cancel mid-entry, cancelling Touch ID, a
   word list with a typo or wrong order, an empty field. Is the UI always able to accept the
   right key afterward? Is any secret logged, kept, or written where it should not be?
3. **The backup's key differs from the current library's key.** Same library (same store id)
   from before a Replace All Keys / before Castle / before the words were regenerated; a
   DIFFERENT library with its own key; a Standard-era copy onto a Castle account and the
   reverse. After adoption: what does custody hold, does the NEXT LAUNCH open silently or ask
   the right question, does sync's key (M/C, the account side) still agree with the library's
   key, and can the moved-aside library still be opened by its own key file roads?
4. **Two or more key files beside one store** (a hand-off pair dropped into a folder that
   already holds key files; an aside home; Downloads). Which one is used, by what rule, and
   can the rule pick the wrong one?
5. **Posture on both sides.** Standard / Castle / Always ask on the arriving copy × on this
   Mac's current library × on the account. Every combination the door can meet: does the
   landing obey the account's posture law, and is any combination silently weaker (openable
   without asking when it should ask) or locked out (nothing can open it)?
6. **Interrupted roads.** A crash, quit, power loss or force-quit at each step of the adoption
   (after the safety copy, after the hold write, between move-aside and landing, after landing
   but before custody is written, after custody but before the reopen). After relaunch: what
   opens, what asks, what is recoverable and by which road — is there any state with NO door
   (the VX-80 class)?
7. **The restore hold × keys.** A hold standing while a key ceremony is pending or crashed
   (a follow, Replace All Keys, Use Castle); Resume pressed while the library's key and the
   account's key disagree; the hold surviving a relaunch onto a store that now asks for a key.
8. **Accounts.** Adopting a copy from a different account, from no account, while signed out,
   on a Mac whose iCloud Keychain does not have the Apple key (a new Mac). Does each say the
   right thing and never merge one account's library into another's sync?
9. **The same library on two Macs after a hand-off.** Same store id on both machines: device
   identity, cursors, the outbox, conflict-as-variant — does anything collide or double-push?
11. **(Her addition, 2026-10-07 — answered as its own focus, not folded into 3/5.) A backup
    from one posture opened into an account that is now in the OTHER posture, BOTH directions:**
    (a) a **Standard** backup (its key file Apple-wrapped, openable silently through iCloud
    Keychain) opened into an account that is now **Castle**; (b) a **Castle** backup (its key
    file passphrase/words-wrapped, opening behind the demanded gate) opened into an account
    that is now **Standard**. Each on the SAME Mac and on a NEW Mac. Round 1's BLOCKER was
    direction (a) on the same Mac (the fourth reconcile arm, `castleKeyFileAppleOpenable`) —
    re-verify that fix END TO END rather than trusting it, and trace (a) on a new Mac and
    BOTH legs of (b) from scratch: what the user is asked at open, what custody holds after,
    what posture the landed library actually ends in versus what the account says it should
    be, whether any key file left beside it still opens it more weakly than the account's
    posture allows, what the next launch does, and whether sync's follow/re-key roads fire
    when they should and stay quiet when they should.

12. **(Her addition, 2026-10-07: "what happens if you re-keyed should be clear.") Re-keying —
    the mechanics AND what the user is told.** Replace All Keys (and any other re-key: the
    Castle entry, a follow) relative to every copy this phase touches:
    (a) **a backup from BEFORE the re-key** — which credential opens it now (the day's
    passphrase · the words unless regenerated · a Standard-era Apple copy — decision 11), which
    no longer does, and what happens to custody and the live library when it is adopted (the
    custody-collision rule's `adoptOpeningKey` road), including whether the account's sync keys
    and the adopted library's key end up disagreeing and what sync then does;
    (b) **a hand-off pair produced BEFORE a re-key, opened AFTER it** (on either Mac);
    (c) **a re-key started WHILE a restore hold stands**, and a hold set on a library whose
    re-key crashed mid-way (the VX-80 window);
    (d) **the moved-aside previous library after a later re-key** — can it still be opened, by
    what, and does anything tell the user so;
    (e) **CLARITY — her word.** Read every sentence the user sees on these roads (the Restore
    rows' credential lines, the confirm, the refusals, the follow notices, the banner) and
    judge whether a person who re-keyed last month would understand which password or words
    open which copy, and what will happen when they open it. A sentence that is technically
    true but leaves her guessing is a finding (word it as a proposal; the words themselves are
    13s's to re-voice, the FACTS they state are this phase's).

10. **Anything else that could go wrong — and this one is NOT optional and NOT bounded by the
    list above.** Her explicit instruction (2026-10-07): the reviewer must go BEYOND what her
    prompt and foci 1–9 cover and really *think* — independently and adversarially — about
    what different problems could arise. Foci 1–9 are where she happened to look; she is
    concerned something is still being missed precisely because nobody has thought of it yet.
    So: before closing, spend real effort generating your OWN failure scenarios for a phase that
    moves encrypted libraries and their keys between files, folders, Macs, postures and
    accounts — new combinations, unusual user sequences, filesystem and OS behaviors, timing,
    partial states, things a real person would plausibly do that no test imagines. Trace each
    candidate in the code. Report every one you generated in a dedicated **"Beyond the foci"**
    section: the scenario, the traced outcome, and its verdict (a finding with severity, or
    SAFE with the mechanism that makes it so). An empty or token section is itself a failure of
    this focus.
