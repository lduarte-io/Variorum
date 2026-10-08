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
10. **Anything else that could go wrong** — her words. Look for the road nobody wrote a test
    for.
