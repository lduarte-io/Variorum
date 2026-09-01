# DESIGN MEMO — the security shapes, the recipes, and the one law
### (the founding sitting's nine-wave security-clarity thread, 2026-08-30 → 31)

> **⚠️ SUPERSEDED IN DESIGN — 2026-09-01.** The author's encryption-clarity sitting after the round collapsed this memo's three-axis model (at-open modes · escrow dial · sync custody) into TWO POSTURES, Standard and Castle: `notes/plans/pre-13x-postures-design.md` is now the binding design (its §18 carries what of this memo survives and why the rest does not). The Act 10 surfaces built from this memo are rewritten by that phase. Kept verbatim as the record of how the model was reached — her sign-off here ("prettyyyy clear") preceded her next-day verdict that the average user could not hold it.

**Provenance:** authored 2026-08-31 by the pre-13u round's FOUNDING orchestrator at the author's
instruction (*"go ahead and make a design memo where all of this information and several verbatim
exchanges from both of us are saved - this was a high value session and I do want it saved"*). This
is a P-5 design memo: the intended presentation whole, the edges enumerated, her rulings verbatim.
**She carries it to the SUCCESSOR orchestrator herself, with the ninth-wave successor block.** The
build it specifies is mostly **wording and structure** (her framing: *"it's mostly just a tutorial +
settings wording update and not a real change"*) and lands on Act 10 item 3's spec; the ONE behavior
change ruled is the escrow/posture coupling; ONE future question is deferred (Shape 3, below).

---

## 1. THE ONE LAW (everything else derives from it)

> **The passphrase protects the SERVER's copy of your writing. A readable copy in someone's hands is
> already access — no passphrase can retroactively guard a copy that opens. An enrolled device is a
> pre-assembled recipe: copy + key + sync custody, kept live.**

Corollary, ruled ultra-clear at the ninth wave (hers): **the iCloud spare key does NOT work as a
remote sync key** — it opens copies you already have, nothing more; it can never pull writing from
the server. Stated everywhere the spare key is described.

And the re-entry rule, in her closing words: *"we make it clear you don't get stuff from the server
with no passphrase. if you have a backup + key, you can change your passphrase and THATS how you get
back into sync - passphrase is still the path."*

## 2. THE FOUR CREDENTIALS

| credential | what it grants | nature |
|---|---|---|
| an enrolled, unlocked device | everything, on that device (incl. rotating secrets) | the keys themselves, behind the at-open gate |
| encryption passphrase | open any copy + enroll any device into sync — the master secret | in your head; works FULLY LOCALLY, no account needed |
| recovery phrase | identical — the twin | on paper |
| iCloud spare key (escrow) | open a SURVIVING COPY on a device signed into your iCloud | a key — never a backup, never the passphrase |

The Touch ID sentence (from her sharpest question): **"An unlocked, enrolled device is as powerful
as your passphrase. Touch ID guards this device — your passphrase is what lets a new device in."**

## 3. THE RECIPES (the user-facing format — recipes + short paragraphs; NO grand matrix)

**Open your writing (any one suffices):** an enrolled device through its gate · any copy +
passphrase · any copy + recovery phrase · any copy + the iCloud spare key on a Mac in your iCloud.

**Open nothing alone:** your iCloud password (a key with nothing to unlock) · your computer password
under a lock mode · a backup drive (post-#82) · us — the server never holds a key to anything.

**Bring sync to a new device:** account sign-in + passphrase (the front door) — or any open-recipe
+ account sign-in via Replace Encryption Keys (the reset road: new passphrase, your copy becomes the
truth). *Passphrase is still the path — the reset road just lets you mint a new one from possession.*

**The compound warning (ships in copy):** backups in iCloud Drive + the spare key ON = your Apple
account is everything (and with an iCloud address as your account email, sync too). For the person
who wants Apple to hold it all, that is the feature; for everyone else it must be a read sentence.

## 4. THE THREE SAFETY LEVELS AND THE SHAPES

Safe from **the Variorum server (us)** · from **someone in your iCloud** · from **someone at your
unlocked computer**. Every shape is which levels you keep:

- **Shape 1 — You hold the keys** (passphrase + recovery set; demanded at-open; NO iCloud spare):
  keeps ALL THREE. Doesn't stop: someone holding your secrets — or you forgetting both, which is
  the flip side of maximum security, said plainly.
- **Shape 2 — This device + a spare key in iCloud** (the default): keeps the first two — the iCloud
  level CONDITIONALLY (the compound warning) — gives up the desk level. Stops the iCloud-phishing
  attacker (they get a key with nothing to open); does not stop someone at your unlocked Mac.
- **Shape 3 — iCloud holds everything: DEFERRED, her ruling (see §8).** The roundabout route
  already exists: backups in iCloud + the spare key = the normie recovery, no custody surgery.

**Escrow follows the posture (RULED):** demanded modes do not offer the iCloud spare. Her
why-sentence, near-verbatim for the copy: *"anyone who has your computer password has your iCloud,
so the extra lock wouldn't be providing extra protection, so I don't offer this."*

## 5. WHAT *YOU* NEED, BY MODE (the four real states)

1. **Just writing (Auto, nothing set up):** daily — nothing. Computer dies — **a copy of your store
   + iCloud Keychain.** Neither: gone, which is normal for un-backed-up local software (the honest
   softener: automatic backups guard corruption/mistakes; a same-machine backup dies with the
   machine). The state-aware nudge exists to move you up from here.
2. **Auto + a secret set (the nudged state):** any copy + any one of your three keys.
3. **Sync on** (passphrase guaranteed at signup): a dead computer costs nothing — sign in anywhere +
   passphrase (or phrase) = everything, current. **What sync can never survive: losing every device
   AND both secrets — the server's copy is then sealed forever.** The ratified tier sentence:
   *"Sync brings your writing back to any device — as long as you keep your passphrase or recovery
   phrase. We can never reset it for you: that's what end-to-end means."*
4. **Biometric / Passphrase lock:** daily — **this device's Touch ID or your passphrase — never
   iCloud, never the computer password.** Computer dies — sync, or copy + secret. Both secrets
   forgotten while the device lives: Touch ID still opens it — set a new passphrase NOW (why
   rotation stays open, §7). Both gone + device gone: **gone forever, everywhere — the deal this
   shape chooses, in those words.**

## 6. THE PRESENTATION MACHINERY (Act 10 item 3's spec, extended)

The two decision ceremonies — **the lock moment** and **sync signup** (her flow: start writing
instantly; the choice arrives when you reach for the lock; sync signup asks which path). The
prominent **unchosen-state indicator** (bottom-left family) — NEVER "encryption off" (the store is
always encrypted, R13p-2; what is unchosen is the lock and the keys). Per-shape **"Who this protects
you from"** + the TWO what-ifs (*"what if I forget my passphrase" / "what if my computer explodes"*)
under every shape (drafted in the sitting replies — render, don't re-derive). Settings explains and
points at the field guide's privacy chapter. Her copy doctrine binds: structure and generous
targets; a sentence only where truly necessary.

## 7. RULED AT THIS SITTING (beyond the shapes)

- **Rotation stays open** — hers: *"in the touchid / biometric lock… you had to have touchid or the
  passphrase to get to the point where you can change the passphrase, so it's probably you."* The
  memo states the Auto corner out loud: under Auto, a session-borrower can rotate too — inherent to
  Shape 2's threat model, whose security never rested on the passphrase.
- **The state-aware nudge** (R-pre13u-4, built in Act 9): covered = gentle; exposed (Auto + no
  secrets + escrow not landing) = plain truth, device-neutral, both platforms.
- The demanded-modes escrow exclusion (§4) — the one behavior change this memo carries.

## 8. DEFERRED — SHAPE 3, her ruling verbatim

> *"I would say we're deferring a shape 3 where sync without variorum login is created - not making
> it now, I feel fairly satisfied with where things are at."*

Earlier leaning, same wave: *"idk if we even need to offer that icloud holds everything shape -
especially since the backup in icloud + icloud key + variorum sign in is an option."* The deferred
question, if ever reopened: sync custody riding iCloud Keychain for a declared profile (would bend
14b R-4/R-6 for that shape only — her call then), vs making the roundabout route deliberate-and-
legible (a backup-destination chooser that says what iCloud placement means). Also deferred with it:
posture-switching semantics. **No owner slotted — at her word, 13x-adjacent by nature.** Nothing
that exists changes meanwhile.

*[removed for publication]*
*[removed for publication]*

**Name: APPLE-HELD RECOVERY (Shape 3).** The declared profile where recovery requires only the
user's Apple identity — no passphrase memorized, no phrase on paper: *"keep iCloud on and you can't
lose your writing."* The machinery it would add, enumerated so a future kickoff can size it:

1. **A third wrap in the vault** (the suite-coherent core): a random wrapping key lives in iCloud
   Keychain (synchronizable, no ACL); the account's `key_vault` gains an apple-held wrap of the
   master beside the passphrase and recovery wraps. New device, zero secrets: read the wrapping key
   from iCloud Keychain → unwrap the master from the vault → class keys → content pulls from the
   server. The server vault stays the single authoritative custody store; iCloud holds only the
   wrapping key. **This is the deliberate bend of 14b R-4/R-6 (enrollment-by-passphrase), scoped to
   this declared profile only.**
2. **The profile itself**: a per-account choice with consent copy (*"anyone fully in your iCloud
   can reach your writing"*), offered at the sync-signup ceremony as the third path — never the
   default. **Posture switching both ways**, and the honest downgrade: leaving Apple-held mode
   re-keys (a copied key cannot be un-copied; retiring the item is not enough).
3. **Surfaces**: the shapes copy gains the third shape for real; the nudge tiers update (Apple-held
   = covered while iCloud Keychain is ON; iCloud Keychain OFF becomes that profile's exposed
   state); the recipes gain the row.
4. **For sync users this completes recovery with ZERO other machinery** — the server is the copy;
   no backup story needed. Local-only users keep the existing roundabout (escrow + reachable
   backups).
5. **Fragments inherits by construction** if built at the vault level (the unwrap chain is shared);
   its only work is skipping the passphrase prompt when the apple-held wrap exists.
6. **Security accounting, stated**: the E2EE claim widens from "only your passphrase" to "your
   passphrase OR your Apple identity" — the server still reads nothing, but the trust base grows to
   include Apple's iCloud Keychain security AND Apple's account-recovery chain (their processes for
   "convince us you're you" become a road to the writing). That is the step down, and it is the
   price of the promise.
7. **Cost shape**: engine enrollment path + vault payload evolution (Fable — `Sync/`-adjacent;
   possibly one §12 lockstep event if the vault payload needs a format version), the custody items,
   the profile/ceremony/copy work, and two drills (zero-secret enrollment on a fresh device; the
   downgrade re-key). A small phase, not a patch.

Her standing word: **not now** (*"that is another step down in security, right? so not adding that
for now"* — and the same-day Fragments ruling deferred its cousin identically). This section exists
so the future decision starts from a scope, not a memory.

## 9. THE VERBATIM EXCHANGES (why this memo exists — the turns that did the work)

**Her opening escalation:** *"I need a way clearer chart and table of what settings you can have /
what passphrase or autominted key or icloud key or whatever / what you need to log in / where. I'm
still confused which, again, it's normally a bad sign when I'm confused because it will mean my
users will be hopeless confused + scared of the worst possible thing, which is losing all of their
work. now that there are all these conditionals about Auto and when you use your password and stuff,
goodness gracious."*

**The question that surfaced the law:** *"if my sycned writing hangs on a secret only i hold - why
is my touchid enough to change that secret?"* → the architect's answer that became copy: an
enrolled, unlocked device holds the keys themselves; Touch ID guards the device, the passphrase
lets new devices in.

**The architect's correction that reframed sync** (she flagged it as the clarifier): her claim —
*"the sync they're paying for is NOT protection against loss - if they lost the logged in device,
they wouldn't have anything?"* — was wrong in the common case: sync IS device-loss protection,
conditioned on the passphrase surviving; what it cannot survive is the compound loss. The corrected
sentence is §5.3's.

**Her three-shapes convergence:** *"It sounds like we have options 1 & 2, but not 3 (whatever, just
throw it all in my icloud). am i correct that the device + icloud wouldn't be enough to stop someone
at your unlocked computer, if icloud escrow is on at all?"* (Correct — hence §4's coupling.)

**Her recipes insight:** *"so we've got to be clear that there are RECIPES for access (icloud key +
copy of store = full access). I think this recipes idea is good, I think a table will be too
confusing… I feel like someone might not realize that a copy of their store in icloud + an icloud
key = free access, basically."* → and the architect's confirmation that closed the loop: store copy
+ iCloud key = read everything; + account password = sync too, via Replace Keys — which is exactly
why the law leads the presentation.

**Her "who this stops" instinct:** *"I think clarifying more with 'Who this stops' would be good -
and we can clarify that we have two of the shapes and that the third needs to be built out still,
without changing what we even currently have."*

**The device-vs-copy distinction, hers:** *"a copy of the store + icloud is enough, so we need to be
clear if it's a device or literally just a copy of the store. right now it's unclear."* → the
architect's line that answered it: **an enrolled device is a pre-assembled recipe; a copy is
ingredients.**

**Her sign-off:** *"ok, I do think that things have ended up being prettyyyy clear… they need to
know for THEIR mode, what they need to be safe… I think things are starting to make a lot of sense
to me, which is a good sign. this was insanely thorny at the beginning - I can't believe we've gone
through so many iterations."*

## 9b. RESIDUAL TRAPS (named at the session's close, 2026-08-31 — the two worth outliving the chat)

**T1 — the re-key from a STALE copy is the sharpest unguarded edge the new model exposes.** Tonight
made Replace Encryption Keys the reset road: possession + account = new passphrase, local becomes
truth, sync resumes. But "local" might be a MONTH-OLD backup — someone recovers an old copy, re-keys,
and the wipe-and-repush clobbers everything the server learned since. The design is local-as-truth
by intent; the trap is local-as-truth when local is stale. The guard worth building when this door
is next touched: before a re-key re-push, compare recency (the server's newest change vs the local
copy's) and WARN when the server is ahead — one honest sentence, not a refusal. Also verify the
adjacent corner: a re-key from a near-EMPTY store must not silently push emptiness over a full
server. **Route: the final ladder should look at this door; if unguarded, a KnownIssues row with an
owner.** *(Refined at her question, same close: the warning can be CONCRETE without keys — ids,
dates and sequence numbers are deliberately plain in the disclosure envelope, so a keyless machine
can COUNT the notes the server has that this copy lacks, count the ones with newer changes, and name
the newest date — "12 notes this copy doesn't have, newer versions of 9 others, latest Aug 28" —
while reading no content. Her instruction: emphasize the count-and-dates form; a concrete number
stops a click-through where an abstract warning doesn't.)*

**T2 — the covered/exposed verdict needs an honest UNKNOWN.** The escrow read-back is verified on
ONE machine (hers). On machines we have never seen — iCloud Keychain off, no Apple ID, managed
devices — the probe may simply not know. The nudge tiers must not map "can't tell" onto either
"covered" (false comfort) or "exposed" (crying wolf): unknown is its own state with its own gentle
sentence. Act 10's rendering should honor the three-value truth the Act 9 brain already carries.
*(Her routing, same close — the SPLIT is deliberate: the RENDERING half (three states in the copy)
stays in Act 10 now, since the brain already carries them and a deferred rendering would quietly
ship a binary; the VERIFICATION half (proving the probe on a machine that isn't hers) rides her
Sparkle / fresh-download walk — the first real stranger machine the project will have.)*

## 9c. THE FIVE CLOSING ITEMS, VERBATIM (the architect's session-close answer to her "anything else
## you want to say, traps you see, or things for me to keep in mind?" — saved at her instruction:
## "if it matters, it should never just live in session history." Items 1–2 are §9b's T1/T2 in
## their delivered form; 3–5 exist ONLY here.)

**1. The stale-copy re-key clobber — the one genuine trap left.** Tonight's model made Replace
Encryption Keys the universal reset road: possession + account → new passphrase → *local becomes
truth*. But "local" might be a month-old backup — someone recovers an old copy, re-keys, and the
re-push flattens everything the server learned since. Local-as-truth is right by design;
local-as-truth *when local is stale* is data loss wearing the design's clothes. The guard is one
recency comparison and one honest warning sentence before the re-push. Routed to the final ladder's
attention; if it's unguarded, it gets a KnownIssues row.

**2. The covered/exposed verdict needs an honest "unknown."** The escrow round-trip is proven on
exactly one machine: hers. On machines we've never seen, the probe may simply not know — and "can't
tell" must not be dressed as either comfort or alarm. Three-value truth, three sentences.

**3. Render, don't re-derive — hold that line when reviewing the built surfaces.** The model is
right in the memos; the failure mode from here is a batch paraphrasing the tables into sentences
that are *almost* true. The keystone lines — key-not-backup, the sync sentence,
Touch-ID-guards-this-device — should land essentially verbatim. Almost-true is how the original
confusion got built in the first place.

**4. The marketing will pull against Shape 2's honest sentence.** The advertising angle is
no-theater — and the temptation, months from now, will be to imply Shape 1's properties while
shipping Shape 2's defaults. The sentence "while it's open, someone at your computer can read it —
that's what open means" has to survive contact with the landing page. Her own R13p-16 instinct is
the defense; the pressure is named here in advance.

**5. Promote the model to canon at the round's closeout.** This memo is binding but lives in
`notes/plans/` — a future phase (13x, 13y, the tier) touching these seams should *inherit* the
shapes model, not re-derive it. The pre-13u closeout should anchor this memo from the canonical
docs so it can't be drifted past.

## 10. WHAT THE SUCCESSOR BUILDS FROM THIS

Everything in §§1–6 as **wording + structure** on Act 10 item 3 (settings, the tutorial's privacy
chapter + re-seed, the indicator, the ceremonies' copy) — plus the ONE behavior change (§4's
escrow/posture coupling). §8 stays deferred with no build. The ninth-wave successor block she
carries names the same items; where the block and this memo differ, **this memo is the fuller
record and wins.**
