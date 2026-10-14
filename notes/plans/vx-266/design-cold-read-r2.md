# Cold read of the finished design and plans — round 2 (VX-266): the record and the dispositions

**What ran.** Two cold reviewers read round 2 in parallel and independently, at commit `8ca19287`, with the same
prompt. Her ask, verbatim: *"run another cold review on the finished design + plans to make sure that the design has
no gaps and that the plans reflect the design."*

- **Fable**, in its own session, which she started with the design owner's prompt: 1 MAJOR · 5 MINOR · 5 NIT. Its
  report: `design-cold-read-r2-fable.md`.
- **Opus at max effort**, as the design owner's subagent, at her ask: *"maybe launch a new Opus Max effort cold review
  here as your own subagent since the plan has changed yet again. let it review first fully and then ask it if it has
  ideas on how to improve the system - key rotation fixed a lot of problems, to be clear. are there still problems /
  weird edge cases in our solution that are hard to understand?"* 0 BLOCKER · 9 MAJOR · 12 MINOR · 10 NIT, then its
  answer to her follow-up question: six structural ideas and ten edges that stay hard to understand. Its report and
  answer: `design-cold-read-r2-opus.md`.

**How it settled.** Every finding was traced against the design and the cited code before any fix. None is hollow,
and none is disputed. The design's owner then reconciled the two reports with Opus's ideas and with the Fable
reviewer's positions, over messages; the Fable session relayed her direction verbatim. The reviewers and the owner
agreed one shape, and she ruled it:

- her direction: *"hmm I like the idea of landing the key instead of the history. this is what my opus session
  proposed to me - where do you agree and disagree? I want the system to feel very easy to understand to people - so a
  different library landing requiring a new key makes sense to me and is is similar to what I was thinking with rotate
  key at change into / out of castle, rotate key when you leave an account, etc. i don't really want disclaimers i want
  simple and clear system even if it is more onerous to switch between and switching makes your backups hard to open -
  that's fine. standard library leaving account - if they've forgotten their passphrase cant they just reset it if
  they're in standard anyway?"*
- her ruling, on the combined shape and on phase 2: *"yes i agree and yes phase 2 will stay in debug builds until
  phase 3"*.

**The shape** (design §1, §3):

- a fresh key whenever the library crosses a line — into or out of Castle, out of an account in either mode, onto
  another Mac;
- leaving Castle takes nothing back: every copy from before the leave is sealed in the Castle anchor, under the
  passphrase and the words, which the anchor follows when they change;
- keys born Castle or Standard and keeping that kind for life;
- a family tree of every key the library has had, which decides "is this copy ours?";
- one Apple key per library per Mac, and an account's only for its vault;
- this Mac's facts in two sealed homes, the newer winning; copies carry only the library's own facts;
- Use Castle checking everything at its door, and keeping today's export-off step;
- a landing that takes one secret and has the other typed or made new;
- every follow into or out of Castle typing one secret, once;
- phase 2 compiled into Debug builds only until phase 3's switch.

**The Fable reviewer's conditions for the agreed shape**, all in the design: the zero-secret Standard landing;
decision 33's stated asymmetry (a landing takes one secret; raising your own library keeps both); the copy-scoped
leave sentence; the anchor's home and travel rule; the unopenable-anchor rule; the reset door's one ask for the words,
with the double-forget corner as promise 5's one exception; and three lines for a follower's anchor — its words road is
as fresh as that device's words copy, a words-typed follow never gains a master-under-passphrase copy, and the road
through the Castle-era master is a birth road that any later door replaces.

**The commits:** the design `24a81aba`; the phase-1 plan `a4488456`; this record `24049659`; the key maps `890dfe89`,
with six clarifications the maps needed written into the design: when the account's Apple key goes in Use Castle, where
Use Standard writes the anchor, when the old sync keys' Touch ID item goes, what a follower's new key file is locked
under, that Replace All Keys in Standard mints nothing for the library, and that a keys-replaced follow in Castle types
one secret too.

**The Fable reviewer's sign-off** (2026-10-14), after reading this record and checking the revised design and plan
against every disposition: no pushback, and round 3 is clear to go to a fresh session. Opus's findings were all
adopted as it proposed, so nothing of its was disputed.

---

## Dispositions

### Fable (F1–F11)

| # | finding | disposition | where |
|---|---|---|---|
| F1 | MAJOR — a Castle hand-off carries the sender's pre-Castle history, and the receiver's later leave reopens it | **Fixed by her ruling.** A different library lands under a fresh key with an empty history, so no key is held by two Macs, and leaving Castle takes nothing back. "A copy sent while in Castle exposes nothing" is now true by construction; the fixed scenario is rewritten | design §1, §3.1, §3.4, §3.7, §4.1; plan §5, §6 |
| F2 | MINOR — history entries carry no era | **Fixed.** The family tree records each key's kind for life and its Mac. The history no longer needs an era: into Castle, everything; within a mode, forward; out of Castle and at a landing, nothing. The migration's attribution rule is stated (an Apple wrap marks Standard; otherwise Castle; unknown counts as Castle, which strands nothing) | §3.2, §3.4, §3.13; plan §3 |
| F3 | MINOR — Castle-era copies after a leave need the secrets of their day | **Fixed.** The anchor holds every key from before the leave under the current passphrase and words; the key doors re-wrap it; Standard's reset road asks the words once. The one corner left (both lost and replaced before a re-wrap) is promise 5's single exception, and the route finder names the day | §3.4, §3.9, §4.1, §8 |
| F4 | MINOR — a Standard library leaving an account stays under that account's master | **Fixed by her ruling:** every leave re-keys, in both modes. Her question — a forgotten passphrase in Standard — answered yes: this Mac holds the key, and today's forgot road already sets a new one (`KeyDoorCopy.swift:49`) | §1, §3.8, §3.9, §4.1 |
| F5 | MINOR — VX-263 missing from phase 3's members | **Fixed** | §5 |
| F6 | MINOR — the follow into Standard's "silent items meanwhile", and the stuck case | **Fixed.** A key keeps its kind for life, so no custody moves; every follow into or out of Castle types one secret through the vault, so nothing waits on an Apple key | §3.2, §3.5, §3.9; maps |
| F7 | NIT — the record's mode has no "not yet confirmed" | **Fixed:** the record carries the mode and whether it's confirmed | §3.2 |
| F8 | NIT — promise 13 fails on the live file | **Fixed**, with Opus MAJOR 1: copy-scoped | §3.4, §4.1; maps |
| F9 | NIT — the login-password rows lack the older-stores caveat | **Fixed** in the generator | maps |
| F10 | NIT — no hand-off act in the plan's `Acts/` | **Fixed:** `Acts/` names Land and SendLibrary, and every other act in the alphabet | plan §2 |
| F11 | NIT — her refresh ruling's two quotes | **Ruled:** *"yes phase 2 will stay in debug builds until phase 3"* | §5 |

### Opus (MAJOR 1–9, MINOR 10–21, NIT 1–10)

| # | finding | disposition | where |
|---|---|---|---|
| M1 | "Nothing … ever opens anything written in Castle" is false | **Fixed.** Copy-scoped everywhere (§3.4, promise 13, C-9, the maps). Rule 5 and the leave screen say plainly that the library itself, with everything written in Castle, opens through the Apple account from the leave on. A Castle-era copy opened into a Standard library is her act, said at its confirm. The account's Apple copy joins the vault only after the leave's rotation completes, so the previous corpus key is never Apple-reachable (a `Sync/` line for phase 3). She was shown the real reach before she ruled | §3.1, §3.4, §3.5, §3.7, §3.9, §4.1; maps |
| M2 | After a leave, this library's own Castle-era copies read as "made on another Mac" and raise the library | **Fixed.** The family tree decides "ours". A known Castle-era copy takes the current mode and opens through the anchor with the passphrase or words, and the confirm says so. T-4, T-5 and OPEN_OLD are fixed; a fixed scenario is added | §3.2, §3.7, §4.1; plan §4, §6; maps |
| M3 | The follow into Standard's waiting state exposes Castle keys and can stall | **Fixed** as F6, with a fixed scenario: a follow with the follower's iCloud Keychain off | §3.5, §3.9, §4.1 |
| M4 | Phase 2 could reach her store through main before phase 3 | **Fixed, her ruling:** phase 2's road and the migration are compiled into Debug builds only until phase 3's switch. The runway and the stage coordinator are told at this design's merge | §5, §3.13; plan §11 |
| M5 | A Castle library sent to another Mac re-exposes the sender's pre-Castle copies | **Fixed** as F1 (its fix (a), per copy, became a fresh key at every landing) | as F1 |
| M6 | Entering Castle no longer turns the scheduled export off | **Fixed:** today's step is kept, on Use Castle and on every follow into Castle, with one notice. An export she turns back on in Castle is one of rule 2's stated exceptions | §3.1, §3.9, §3.12, §4.1; maps |
| M7 | The record's security facts have one home, so a replayed library file regresses them | **Fixed:** this Mac's facts live in two sealed homes — the record's device section and the memory — the newer wins, and the retired ids are unioned. Copies carry only the library's facts, and the stated limit is now both homes rolled back together. Pins: a library-file replay, and a rollback across a retirement | §3.2, §3.6, §3.7, §4.1 |
| M8 | Castle-era copies after a leave need old secrets, and a re-entry loses the first Castle era | **Fixed:** the anchor, folded back at re-entry and following the secrets; promise 5 defines which secrets count as held; fixed scenarios added | §3.4, §3.9, §4.1 |
| M9 | A Standard library leaving an account stays on the account's Apple key, with no way to a key of its own | **Fixed:** one Apple key per library per Mac (the account's key locks only its vault), and every leave re-keys | §3.2, §3.5, §3.8 |
| m10 | The crash reasoning for leaving Castle is wrong under "never out" | **Fixed:** the anchor is written first, under the typed secrets, so a crash at any step keeps a road (the anchor, under Always ask). Crash-at-every-step runs cover Use Standard and a follow on an Always-ask device | §3.4, §3.6, §4.1; plan §5 |
| m11 | The retirement can be stopped after the commit point; the old-name delete | **Fixed:** Use Castle checks at its door, and a readable or record-known vault on the old key stops it before anything starts. The last-step race lands with the door and the exception showing, and the prose says so. The old-name item is deleted only by its recorded id | §3.1, §3.5; plan §4, §5 |
| m12 | VX-310's lobby reads unreadable facts and treats the hash as a verdict | **Fixed, to her pick's words:** the button whenever an item exists; the hash only chooses the line after a failed press; the lobby reads the memory as a display hint | §1, §3.10; maps |
| m13 | Nothing records which history keys were made in Castle | **Fixed** as F2 | as F2 |
| m14 | Copies can carry the act in flight | **Fixed:** every copy is written with the act in flight cleared, and a device section counts only on its own Mac | §3.2, §3.6, §3.7, §4.1 |
| m15 | A retirement while iCloud Keychain is off is in no exception | **Fixed:** it's one of rule 2's stated exceptions, and promise 2's retired-key clause is checked once the world settles | §3.1, §4.1 |
| m16 | The scenario world drifts from the facts and the design | **Fixed:** (a) items made while off sync once it's on; (b) the same-name rule restored in the plan; (c) Touch ID items deletable in the world, and checked by phase 3's drill (SPECULATIVE, as marked); (d) the alphabet completed | §4.1, §4.2; plan §6 |
| m17 | The phase-1 plan understates or contradicts the design in seven places | **Fixed:** the settle-only promises; the seal test; the record's fields (the hand-off notes went with shared keys); `<mac8>/`; the retirement oracle; the design's guards; the cast at kickoff | plan §1–§6 |
| m18 | The canon deltas for "leaving Castle re-keys" are incomplete | **Fixed:** decisions 7, 9 and 33 (its wrap-free list and two narrowings), the Castle and two-switches tables, §4, §7, §12, corner 34, and SyncSpec's ordering line | §7 |
| m19 | The device identity's new home rests on an unproven fact | **Fixed:** a hardware marker mints a new identity on other hardware, pinned (SPECULATIVE for macOS, as marked) | §3.2, §3.13, §4.1 |
| m20 | A copy with no record has no rule for its mode | **Fixed:** its mode is worked out once with today's rules, never defaulting an exposed-era Standard copy with no secrets to Castle; scenario added | §3.7, §4.1 |
| m21 | The acceptance artifact carries pre-ruling and lagging text | **Fixed** in the generator: the follow's notice, the migration step, the pill naming, S-2, and MAJOR 1's and 2's lines | maps |
| N1 | VX-263 missing from phase 3 | **Fixed** (= F5) | §5 |
| N2 | VX-317 missing from §2's ticket list | **Fixed** | §2 |
| N3 | §4.3 named "the final phase's closeout" | **Fixed:** phase 5's closeout | §4.3 |
| N4 | VX-81 and VM-15 unplaced | **Placed:** VX-81 is re-checked by phase 3, whose executor replaces that runner; VM-15 is settled by VX-301 and the follow's typed secret | §6 |
| N5 | Corner 45's interim state | **Fixed:** promise 2 exempts a library recorded Castle but not yet confirmed; the notice offers Use Standard as the key change it now is | §3.13, §4.1 |
| N6 | The retire ask is per device | **Fixed:** said | §3.1, §3.5 |
| N7 | No defaults for a device with no settings | **Fixed:** Touch ID where a finger is enrolled (made at that act's press), else Always ask; the idle lock at its default; the export off | §3.10 |
| N8 | Send Library's sentence understated what a pair opens | **Gone:** nothing is shared now, and a pair opens with its own locks like any backup | §3.7 |
| N9 | The rollback limit over-claims | **Scoped** to what was written before the rollback | §3.6, §4.1 |
| N10 | LIVE STATUS names no NEXT | **Fixed:** U1 is NEXT | plan §7 |

### The design owner's own find

| # | finding | disposition | where |
|---|---|---|---|
| O1 | A follower recorded the old shared key as retired, so delete on sight could delete it after the acting Mac's last-step check had held it back | **Fixed**, in the shape the Fable reviewer confirmed: only the retiring act's own device section records the old shared key as retired; followers record the account's key and their own | §3.5 point 5 |

### Opus's answer to her question

**The six ideas, all adopted** (with the Fable reviewer's agreement and her ruling): a key's kind for life; the family
tree; the Castle anchor, in the version that takes nothing back at a leave; one Apple key per library per Mac; this
Mac's facts kept at home; and Use Castle checking at its door, with the export-off step. Its process point — phase 2
off on main — is her ruling, and its readability suggestion is §3.11's one *Opens with* line per copy.

**The ten hard-to-understand edges:**

1. **Leaving Castle opens the live library.** Said plainly in rule 5 and on the leave screen.
2. **Old backups needed the secrets of the day you left.** Gone: the anchor follows the secrets. The one corner left
   is named by the route finder.
3. **The old shared key.** Unchanged: asked once on each device; the sheet's hedges describe a past we can't see.
4. **A sent library wasn't independent.** Gone: a fresh key at every landing.
5. **Which account opens which backup.** The *Opens with* line on every copy.
6. **Touch ID after a macOS update.** Fixed (m12).
7. **Standard on a device that can't see the Apple key.** Now only silent setup waits. The device's own key file
   never waits, and the passphrase or the words open the vault.
8. **The login password in Standard.** The field guide's try-it-yourself line (§3.11, phase 5).
9. **Markdown exports.** Off on entering Castle (M6).
10. **Testers recorded as Castle by the migration's guess.** The notice offers Use Standard as the key change it is.

---

**Why none of this brings back what the design solved:**

- No key is ever written under a shared name, and after this change no key is held by two Macs — now hand-offs
  included.
- No vault moves automatically, and the account's key dies only with the account's own rotation.
- Plans stay beside the library and a missing plan never blocks; the act's identity lives in this Mac's device
  section, in two homes.
- Prepare-then-commit keeps a road at every crash point, the anchor written first.
- Every new mint is per id, at a deliberate act or the migration.

**The ladder:** round 2 found new MAJORs, so round 3 runs in a fresh session with the same prompt and "round 3".
