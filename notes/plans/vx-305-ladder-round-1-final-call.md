# VX-305 ladder round 1 — the reviewer's FINAL CALL (the cross-model flow's third step)

**Reviewer:** the round-1 fable-reviewer (same session), 2026-10-16, after reading
`notes/plans/vx-305-ladder-round-1-answer.md` in full. **Verified, not trusted:** I ran the implementer's untracked
pin suite myself — `✘ Test run with 6 tests in 1 suite failed after 0.532 seconds with 10 issues`, the MAJOR red in
all four cases with the exact traced refusal (`Use Standard → .refused("noLiveKeyFile")`, the stray file live, the
mirror gone, `rekeyForFault` unanswerable). Its two structural claims check against my own round-1 reads: the
generator's `step` brackets every tamper with launches (Generator.swift:27–37, 67–75 — two tampers can never
compose, none can land inside a crash window), and the `libraryFileLosesToMemory` arm (Assess.swift:232–235) must
keep reading a live file of a DIFFERENT key. The widened reachability (a planted plan via the `.unsealed` arm; the
no-crash earlier-key's-file replay) follows the same mechanism I traced and is accepted.

**FINDER-FIXES: none.** Nothing here is `Sync/`, and the implementer's answer shows full command of every
mechanism. The implementer applies all confirmed fixes below, each with its red-on-old pin, the suite green after.

---

## Final call per finding

### 1. MAJOR — the stray-file wedge: **CONFIRMED. Fix as specified below.**

**Framing amended (the implementer's correction accepted):** the broken contract is **§3.3's "Always: the record,
what this Mac remembers and the key file agree"** — no repair restores agreement, permanently. §3.6's letter holds
for the act in flight (it did roll back — pinned); what returns is VX-235's *disease* (a state no future act can
leave), through §3.3, not §3.6's sentence. Severity stays MAJOR: permanent, and in the Use-Castle variant nothing
reports it.

**THE FIX — four pieces, in this order:**

**(a) Widen `restoreKeyFileFromCopy`'s gate in BOTH places** — `assess` (Assess.swift:281) and the executor's own
guard (ExecutorRepairs.swift:202). The precondition, exactly:
- nothing is in flight on this device (the standing repair rule — already enforced by `runRepairs`);
- the live place holds **no format-3 file of the CURRENT key** — absent, **or another key's file** (the widening);
- the memory's mirror is absent or not the current key's (unchanged);
- a catalogued frozen format-3 key file of the CURRENT key exists, same library ID — the newest by
  `(frozenAt, id)`, as today.
The executor verifies before any write, as the both-deleted arm does: the copy decodes, `copy.fingerprint ==
library.fingerprint`, `copy.libraryID == record.libraryID`; Apple wraps stripped (never re-added by a repair).

**(b) The stray file goes ASIDE, never deleted.** When the live place holds another key's file, the repair moves it
to today's set-aside shape (`.stale-<epoch>.json` — the catalog already parses it, role `.setAside`) before writing
the restored file. Never destructive: the stray file may be the only carrier of a crashed act's anchor or an
adversary's artifact worth keeping visible. (Content-safety note: in the Use-Standard wedge the stray file carries
the leave's anchor — its contents are exactly the current key and its history, which the live state still holds, so
nothing is lost even where the stray file were deleted; setting it aside is belt on braces.)

**(c) The checker/world gains BOTH halves, so this class is soak-visible — yes to both:**
- **Promise 1 (Known) gains the live-key-file agreement clause:** with the device open, nothing in flight and no
  `restoreKeyFileFromCopy`/`restoreKeyFileFromMirror` owed by the assessment, the live place's format-3 file is the
  record's current key's. (Keyed on "no repair owed" so the fixed tree passes while a repair is pending its run, and
  today's tree — where nothing is owed — violates. This is the checker-blindness I named, closed.)
- **The generator gains tamper composition:** a compound action (e.g. `.tamperSequence(name, [Tamper])`, weight ~1)
  that applies two or three tampers in ONE closed window — the world's pre-launch settle runs ONCE before the group
  (the seed-9 lesson stands: her pending resume settles before any tamper takes a lock), the posture capture before
  the group, the single relaunch and promise-10 check after it. The generator may also wrap the compound in
  `.crash(...)` exactly as it wraps single actions, which lands a tamper group inside a crash window. This closes
  the structural gap the implementer found; the existing single-`.tamper` action and its bracketing stay unchanged.

**(d) The MAJOR's pins** (adapted from `LadderRound1Pins.swift`, which joins the tree as the fixed scenarios'
sibling once flipped to assert the FIXED behaviour):
- the four-case planless-rollback scenario → the repair is owed and runs; Use Standard then succeeds; the stray
  file is catalogued as set-aside; promise 1's new clause green;
- `aPlantedPlanInsteadOfAReplayedOne` and `anEarlierKeysFileReplayedWithTheMemoryGone` → same outcome by both
  widened roads;
- `theUseCastleVariant` → the repair is owed (no more silent perpetual `landAppleWrap` skip), Use Castle succeeds;
- **the stale-copy case** (coordinator point 3): the pin INCLUDES a key door between the backup pair and the
  tampers — after the restore, the live file's locks are of the copy's day: the door typed with the CURRENT
  passphrase refuses `passphraseDoesNotOpen`, the copy-day passphrase opens, and the library stays open throughout
  (custody/history). This asserts the inherited behaviour honestly rather than hiding it (see point 3 below).
- Red-on-old is already demonstrated: I watched all of these red on today's tree.

### 2. MINOR — assess reasons over another key's live file: **CONFIRMED, with the implementer's caution adopted
as part of the fix.** Guard at Assess.swift:303's LOCAL `live` only (the mode-specific repair/fault arms and
`relinkSubjects`' live-file reads follow from it), **never inside `liveKeyFile()`** — the
`libraryFileLosesToMemory` arm (Assess.swift:232–235) and the widened restoreKeyFileFromCopy gate both need the raw
live file whatever its key. Surface the mismatch as its own typed fault (e.g. `Fault.liveKeyFileIsAnotherKeys
(keyFileID:)`) — which is also the MAJOR's honest face until its repair runs. Pin: the unit test I specified in
round 1 (a catalog whose live file is another key's: today `appleWrapOnCastleKey`/`landAppleWrap`, after the fix
the new fault and neither of those).

### 3. NIT — DeviceActs dead "memory" arm: **CONFIRMED.** Remove the unreachable switch case (keep the early
return with a comment saying it serves both the plan-less finish and the ordinary flow). No pin — dead code.

### 4. NIT — P-U3-7 → P-U3-5 misnumber: **CONFIRMED.** Fix the comment. No pin.

### 5. NIT — `takingOver`'s `.first` standing old-shared pick: **CONFIRMED, fix with the implementer's
refinement, shaped to stay pure.** The principled signal is already in the caller's hand without any leaf read:
the key file `unlock` passes (`ownFile`) carries `sharedApple?.keyID` — the old-shared id that actually wraps THIS
library's key. Thread it as a new parameter (`keyFileSharedAppleKeyID: String?`) through
`thisMacsSection`/`takingOver` beside `keyFileOwnAppleKeyIDs`, and pick: a standing record whose id MATCHES it
first; else the deterministic tie-break (smallest id). The retired-record arm above stays untouched. The residue
where no record matches remains P-U4-1's ratified known-leftover class under her P-U4-9 "any standing record"
wording — recorded, not chased. Pin (red-on-old): two sections with different standing ids where the live file's
shared wrap names the one `.first` does NOT pick — today `takingOver` adopts the wrong id; after the fix, the
matching one.

### 6. NIT — the lobby's Touch ID line pre-unlock: **CONFIRMED. Fix by the fallback, which is VX-310's letter:**
when `fingerprint` is nil (no live key file, no memory — both gone), `itemExists` falls back to "any `.touchid`
custody item in this scope" — the button shows, a press verifies itself (a wrong-key item's press fails honestly
into the passphrase road), and the lying quiet line disappears. This is her pick read to its words ("the button
whenever a Touch ID item exists"), not new product behaviour. Pin: facts with nil hint + a touchid custody item →
`button == true`, `quietLine == nil`; red on today's tree. If the implementer finds this ripples into existing
Touch ID pins in a way that changes their SENTENCES (not just their fixtures), stop and record it for round 2
rather than bending the pins — but I expect none: the state is reachable only with both hint sources gone.

---

## The coordinator's numbered points, answered

1. **Fix shape:** as §1(a)–(d) above — both gates widen; the checker gains promise 1's live-key-file clause AND the
   generator gains the compound-tamper action, so the class (and its neighbours) becomes soak-visible. Both halves
   are required, not optional: the promise without the composition can still never be REACHED by the generator, and
   the composition without the promise finds nothing.
2. **The copy-less case: NOT gating for phase 1 — recorded as a PROVISIONAL hand-forward,** bundled for the author
   at the closeout (call it **P-R1-1**). The state needs a third deletion (the backups too), the library still
   opens by her roads, and the honest refusal stands. Options for the bundle: (a) a phase-2/4 door-shaped act that
   REBUILDS the live key file from the key in hand, locking it under a passphrase and words typed-and-set at that
   door (a secrets-setting act, the key doors' sibling — my recommendation, since it also answers the stale-copy
   residue below); (b) accept as a stated limit with the honest face. This is design ground beside her P-U4-13
   ruling (the phase-2 mirror road), and the same sitting can take both.
3. **The stale-copy caution: the pin must and will include a key door between the copy and the tampers** (§1(d)
   above), asserting the inherited behaviour. The behaviour itself — a restored frozen file's locks are of its day,
   so a door typed with the current passphrase refuses until the copy-day secret (or the vault road, synced) opens
   — is PRE-EXISTING (U3's both-deleted repair, shipped and pinned), honest (the refusal is true; promise 9's walk
   holds), and its proper cure is the same rebuild-under-current-secrets door as point 2 — so it rides the SAME
   P-R1-1 hand-forward, with one sentence in the record naming it ("a restored key file keeps the locks of its
   day; re-locking under current secrets is the hand-forward's door"). Not fixed this round.
4. **Framing correction: ACCEPTED** — the finding now reads §3.3's agreement contract as the broken one, §3.6
   satisfied for the act itself; VX-235's class returns through the repair gap, not through the plan runner.
   Severity unchanged (MAJOR).
5. **The `.first` NIT: fixed this round** per §5 above — the principled pick threaded as pure data from the key
   file in hand (no leaf read, `takingOver` stays pure), matching-id first, smallest-id tie-break, red-on-old unit
   pin; the no-match residue recorded under her P-U4-1/P-U4-9 frame, not chased.
6. **P-U4-10 adjacency: confirmed and worded into the record** — the fix is an automatic §3.3-class repair of the
   LIVE KEY FILE from this Mac's own catalogued frozen pair. It never offers, opens or restores a library COPY,
   never touches the library file, and adds no unlock-screen face — so it neither reopens nor resembles her
   dropped newest-copy offer ("lets drop the healthy copy deal", P-U4-10). The record and any doc comment near the
   repair should carry that sentence.

## For round 2's fresh reviewer

Re-check: the two widened gates agree (assess owes exactly what the executor will run); the set-aside write is
non-destructive and catalogued; promise 1's new clause is keyed on "no repair owed" (not blind-green on the fixed
tree); the compound-tamper action preserves the seed-9 pre-settle; the MINOR's guard did not break the
`libraryFileLosesToMemory` arm (its existing pins stay green); the `.first` pin is red-on-old; the Touch ID
fallback ripples nowhere. The pins file flips from red-by-design probes to fixed-scenario assertions and joins the
tree; the protection set, the pins-off mutation runs and a generator slice (now with tamper composition) run green
in Debug, the compiled subset under `-c release`.
