# Mobile Round 2 — BATCH 4.5 SUB-BATCH BRIEFS

> # ⚠️ READ THIS FIRST — PART OF THIS FILE IS REVOKED
>
> **Her ruling, 2026-08-23:** *"we're in a new week and I want to go back
> to the one subagent at a time approach."* **Everything in this file
> about running sub-batches in PARALLEL is revoked**, including every
> *"another session is live in this tree"* warning, every per-sub-batch
> **simulator UDID** and **DerivedData** assignment, and the **wave**
> structure. There were fifteen such references; they are left in place
> rather than stripped because they are the record of how the built
> sub-batches actually ran — **but a session reading this file now must
> not follow them.**
>
> **What survives, and it is most of the file:** the per-sub-batch WORK,
> the file lists (now **scope discipline** rather than collision
> avoidance), the pin-quality rules, the hygiene rules, the review
> briefs, and §6's exit condition. **One simulator is fine — but STILL
> ARM ITS ACCESSIBILITY FLAG** (that hazard is per-simulator, not
> per-session, and without it sixteen real pins fail as phantoms).
>
> **The successor handoff's §1** (`mobile-round-2-orchestrator-handoff.md`)
> is the full account.

**Written 2026-08-22 by the incoming architect, BEFORE dispatch.**
Repo-first: the consistency audit's finding 11 was that *six of eight
dispatches in this round have no brief in the record*, so nobody could
verify a delivery against what it was told to build. Every 4.5 dispatch
has its brief here, and **its cold-review brief beside it**, written at
the same moment (R28: the review is inside the batch, and its brief is
written at dispatch time, never after).

**The schedule is the batch map** (`mobile-round-2-orchestrator-handoff.md`
§3). **The enumeration is `mobile-round-2.md` §52.** This file is the
per-session brief only, and it never competes with either.

---

## 0. WHAT EVERY 4.5 SESSION IS TOLD (the common preamble — each brief cites it)

**Read first, in full, yourself. Do not work from a summary:**

1. `CLAUDE.md` — binding build rules, the invariant list, the author-only calls.
2. `notes/MobileSoul.md` — canon for mobile: §2 the performance bar (P1–P3 **plus a memory ceiling**), §3 **brains in core/`Shared`, faces per platform**, §4 the decision grammar.
3. `notes/plans/mobile-round-2.md` **§5** (the binding principles — the 13b constitution P-1…P-9 *and* this round's M-A…M-E, **noting M-E's 2026-08-22 amendment**), **§9** (the environment, binding verbatim), and **§52** (batch 4.5's enumeration and its fence rule).
4. Your own findings' source sections, named in your brief. **Read them in the repo, in full** — the brief names them, it does not restate them.
5. The code you are changing.

**THE FENCE RULE, and it is not negotiable.** Your brief lists the files
you own. **If a fix needs a file outside that list, STOP AND REPORT.**
The architect rules in-batch forks (the implementer proposes, the
architect rules). Other sessions are live in the other files right now;
this round has already paid twice for two writers in one file — once
corrupting a half-written record with `git add -A`, once with a session
whose build kept being terminated by another's.

**⚠️ NEVER BACK UP OR RESTORE A WHOLE DIRECTORY IN THIS TREE** (added
2026-08-22 after a live incident — `mobile-round-2.md` §62). A session
created `App/Variorum/.bak-VariorumMobile/` and restored from it over a
fenced file it did not own: another session's `MobileQuickNote.swift`
went **backwards in time** and one live edit vanished, caught only
because a pin failed with pre-fix values. **A whole-directory
backup-and-restore is a fence violation wearing another name** — it
reverts every other session's files in that directory, silently, with no
compile error to announce it. **Back up the files you own, BY PATH, or
`git stash push -- <your paths>`. Never a directory. Never a restore that
spans a fence.**

**PIN QUALITY — the round's hardest-won rule, in final form.** This
round hit "green over nothing" **five** times.

> **A pin asserting a view model's number, or a view's configured
> property, proves nothing about what renders. Drive the real surface —
> AND verify the path you drove is the path you meant.**

The second clause is not decoration. On this platform
`UITextView.deleteBackward()` and `UITextInput.replace(_:withText:)`
**mutate storage without consulting the delegate**, so a test driving
them exercises the recovery road and never reaches the gesture it names
(M25). To drive ⌫ on the phone, call
`textView.delegate?.textView?(_:shouldChangeTextIn:replacementText:)` —
the exact call UIKit makes. `MobileSurfaceDriver.swift` is the existing
real-surface harness; read it before writing a new one.

Two more, both earned this round:

- **A pin whose red depends on a state the product cannot produce pins a
  fiction.** Say so and skip it rather than manufacturing a
  precondition. Naming a test as *coverage* rather than as a *pin* is
  the discipline, not a weakness — do it explicitly.
- **A pin must not be blinded by the property the fix exists to
  address.** Batch 1's guard-3 pin first settled on
  `documentLength == storage.length` and went green on the FIXED tree,
  because the bug is *"the totals agree while the content is wrong"*.
  When that is the bug, no oracle derived from the totals can witness
  it. Settle on the text.

**⚠️ A HARNESS INTERACTION — STATED AS WHAT WAS MEASURED, because the
first version of this paragraph stated an inference as a fact and a cold
reviewer falsified it** (`mobile-round-2.md` §60 as corrected, and §61).

**What is ESTABLISHED:** one specific test harness — 4.5d's original
geometry host, a window with **no `rootViewController`** that
bare-`addSubview`s a toolbar and calls `makeKeyAndVisible()` — killed the
full mobile suite run, reproducibly, surfacing as
`MobileEditorViewModel.swift:1540: Fatal error: mobile editor surface
desynced from the block index`. Isolated three ways (its files reverted →
clean; its source change alone → clean; source **+** that harness →
crash). **Removing `makeKeyAndVisible()` from that host fixed it.**

**What is NOT established — and this is the part that was wrong:** that
key-window theft is the mechanism, or that "a second key window" is the
trigger. **The tree already contains three other key-window hosts**
(`MobileTakesBrowserTests.swift:770` and `:946`,
`MobileLivenessTests.swift:199`), untouched by this round, present when
the suite was green at 449/75 alongside `MobileSurfaceDriver.swift:253`.
**Four simultaneous hosts, one clean run.** The distinguishing factor was
never traced; the missing `rootViewController` is the leading candidate
and is UNTRACED.

**THE RULE, in its safe form:** if you add a **new** hosting window,
prefer `window.isHidden = false` (visible, never key) — 4.5d verified the
glass cells materialize identically that way. **`HostedSurface`'s own
`makeKeyAndVisible()` is not implicated** and is not to be changed on the
strength of this note.

**AND THE THING NOT TO CARRY FORWARD:** *"a desync fatal is harness
noise."* **`EditorAssertionSeam.fire` defaults to `assertionFailure`
precisely to surface routing failures that `desyncRecovery()` then
heals.** A standing instruction to read it as noise is this round's
green-over-nothing failure **inverted** — the next session to trip it in a
genuinely broken state would file it under a plan section and move on.
**If you hit that fatal, treat it as real until YOU have isolated it.**

**RED-ON-OLD IS ABSOLUTE.** No bug-class fix lands without a pin proven
**red on the pre-fix code by behavioural revert** and green after. That
verification is the deliverable, not a formality. Architectural or
copy-only fixes need no pin but **do** need the traced mechanism written
down.

**HYGIENE, checked at your close and reported as numbers:**
`git diff -- Sources/` **must be empty** · zero
`Sources/VariorumCore/Sync/` lines · **no build configuration added**
(the 4G trap: SPM deps build Release under any configuration not named
exactly "Debug", silently stripping VariorumCore's DEBUG-gated oracles
out from under the tests) · zero schema.

**BASELINES — VERIFIED ON THIS TREE 2026-08-22, not inherited:**

| suite | count | how to run |
|---|---|---|
| core | **1350/141** | `swift test` from the repo root |
| Mac | **1568/272** | from `App/Variorum/`, scheme `Variorum`, `-destination 'platform=macOS'` |
| Mac spine | **63/8** | `VariorumTests` tutorial spine |
| mobile | **449/75** | your simulator + your DerivedData, below |
| mobile spine | **33/7** | `MobileTutorialWalkTests` (25/6) **+** `MobileWalkTests` (8/1) |

Report counts as `passed/skipped` and name any red with its identity.
**Run only the suites your files can affect** — but if you touched
`App/Variorum/Shared/` or any Mac file, you touched both platforms
(M-B) and you run **both**, plus core and both spines.

**WHAT NOBODY IN 4.5 TOUCHES:** `Sources/` at all · schema · `Sync/` ·
**`planVisibleTakeEdit`'s ROUTING** (her personal fence — a cross-block
span touching a block with takes keeps refusing on the phone; 4.5c
fixes that method's O(N²) *walk*, never its routing) · **Mac
FEATURES** (R8 authorizes fixing shared *defects*, not building Mac
capability) · her real store.

**COMMITS: do not commit.** Report; the architect commits, so the batch
map and 13l's manifest move in the same commit as the code.

---

## 1. BRIEF — SUB-BATCH 4.5a · CAPTURE & APP LIFECYCLE (the two BLOCKERs)

**This is the highest-consequence work in the round.** The batch whose
whole promise is *"nothing you type is lost"* breaks that promise in two
traced ways, and it has been on her phone since 2026-08-21 23:49. She is
working around it by hand right now (*no multi-paragraph pastes into the
quick note*).

**Read §0 above, then `mobile-round-2.md` §45 in full** (your findings),
**§11** (the ruled design of the quick note — A5-1…A5-8, which is what
the fixes must stay true to), and **§40/§41** (R26/R27's shelf layout,
which is batch 5 and will land in the same neighbourhood after you).

### Build, in this order

**1 — 🔴 Q1: the clamp destroys her stored text.**
`MobileQuickNote.swift:286-306`. The reviewer executed the two pure
functions to confirm it. Trace, exactly: paste `"Kept.\n\nEditable."` →
the clock mints → `importPost` segments → `frozenPrefix == "Kept.\n\n"`,
the box owns block 2 → **she fixes a typo in the FIRST paragraph** →
`text.hasPrefix(frozenPrefix)` is now false → the clamp fires, writes
back the prefix, and `recordTail()` derives the tail from the **clamped**
text and gets `""` → the next flush writes `""` into the owned variant.
**"Editable." is gone from the box and from SQLite**, and it is
unrecoverable: `autosave` registers no undo entry, and no `commit_point`
exists yet (`closeAutoCommit` only runs at a leaving, and a leaving
resets the box).

**The header comment and the existing pin both assert the clamp is only
reachable after deleting back through the whole tail — that is the only
case tested and it is not the only case reachable.** Fix the code AND
the comment; a comment asserting a completeness it lacks is the class
§44's MINOR 6 exists to catch.

*Design note, and it is yours to propose rather than assume:* the box
owns ONE block by A5-2's ruling. What should editing the frozen prefix
DO — refuse the edit visibly, re-derive ownership, or widen what the box
owns? **Propose with a traced consequence for each; the architect
rules.** What is NOT open: her text may not be destroyed, and a silent
revert of her keystrokes is its own defect (the finding names both).

**2 — 🔴 Q2: a refused mint at a leaving wipes the box AND the error.**
`MobileQuickNote.swift:483-506`. `file()` reaches `reset()`
**unconditionally**; `reset()` does `write("")` *and* `lastError = nil`.
So a throwing `mintNow` discards her text and erases the refusal that
caused it. **The reachable input is the one this app's own comment
names** (`VariorumMobileApp.swift:73-76`: *"If the device locks mid-round,
file protection may cut the store off"*) — lock the phone with un-minted
text in the box → box cleared, no note, no message. The same road runs
on an ordinary **tab switch**, where the app is not going away at all and
she watches the box empty itself. **A leaving that fails must keep her
text and say why.**

**3 — 🟠 Q4: the background grant introduced a termination class that
did not exist.** `MobileShellRouter.swift:86-88`. The grant is taken
**asynchronously, one hop after the phase change** — Apple's
documentation names exactly this as the anti-pattern — and **with no
expiration handler**. Two documented consequences: an ungranted
assertion means the flush writes SQLite unprotected (`0xdead10cc`, the
"held a database lock during suspension" termination), and an overrun
with no handler is **fatal** (`0x2182bad2`) rather than recoverable —
and the flush's last leg is a **network** round. **Before this round no
grant existed and iOS simply suspended; the change created the class.**
Take the grant synchronously in the phase-change handler and give it a
real expiration handler that ends the task. *You may use ONE Sonnet
lookup subagent for the Apple documentation on `beginBackgroundTask`
semantics — external facts only.*

**4 — 🟠 Q3: an emptied box leaves a live, empty, untitled note.** Type
`a` (mints a real post), delete it, leave → nothing tombstones the post,
and a blank date-titled note is permanently in the library. A5-3
disclosed *"an abandoned one-word note"*; it did not sanction a note
with **no content at all**, which is the case where she withdrew
everything she typed. **The note now has a real delete road** (batch 4
shipped it) — compose it; do not invent a second deletion rule.

**5 — 🟠 B45-1: `AppBootstrap.init` opens the store and runs the
migration set SYNCHRONOUSLY ON THE MAIN THREAD before first paint**
(`VariorumMobileApp.swift` constructs it as `@State`). This is a **P2
violation** — OverallModel §5: all DB I/O off the main thread — on the
app's very first act, on every launch. It is the same family as the
synchronous Keychain load 13e batch 9 moved off-main.

> **MEASURE FIRST, THEN FIX — and the measurement is a deliverable of
> its own.** The stability survey said *"a measurement is one signpost
> away"* and nobody ever briefed one. Add launch-path coverage to
> `MobilePerfWalkTests` (which already holds this round's perf pins) and
> **record the number in your report**: main-thread time in
> `AppBootstrap.init` on a cold open, at the ordinary store and at the
> 100k proving-ground fixture. Then fix it, and re-measure. A fix
> without both numbers cannot be judged. **The fix must not introduce a
> window where the UI can touch a store that is not ready** — the
> existing `MobileStoreFailureView` is the precedent for a store that
> is not available yet; read it before designing.

**6 — Q5–Q10 and the 5 NITs**, each with a written disposition in your
report: a stated red-on-old recipe that is false and an "order is
binding" claim that isn't (Q5) · **⏎ over a SELECTION is not
recognised, so a literal newline lands where A5-1 says one can never
exist** (Q6) · a raw enum dump in the refusal (Q7) · an emptied box
rendering three contradictory faces at once (Q8) · **no pin mounts the
view at all** (Q9 — and §0's pin rules are why that matters) · §38's
one-sentence batch record (Q10 — record work; report it, the architect
writes records).

**7 — ACT 1's ADDITIONS (§56), all yours:**
- **A1-21 — `Shared/AppSession.postAutosaves` has NO removal path** (no
  `removeValue` anywhere). Pre-existing and bounded for editors (notes
  opened), **but the quick note now adds one coordinator PER CAPTURE**,
  and `flushEveryOpenPost()` iterates every one of them on every filing
  and every background flush — so the cost of leaving the box grows with
  how much she has captured this session. **REPORT THE SHAPE BEFORE
  FIXING:** a removal path in `Shared/` is a both-platform change (M-B),
  and the architect rules that fork.
- **A1-15 — two `Shared/AppSession.swift` comments state reasons that are
  false.** `:89` says the phone registers structural entries *"with no
  undo UI yet"* (M20 shipped it at batch 4). `:240-245` says the quick
  note *"mints its note through the operations layer, so there is no
  buffer to flush and no reason to grow one"* — **inverted**:
  `MobileQuickNote.adopt` (`:408-411`) calls `session.autosave(forPost:)`,
  which mints **and caches** a coordinator, and the box's post-mint
  keystrokes ride it. **The behaviour is fine; the stated reason is
  wrong**, which is the class that makes the next reader wrong.
- **A1-19 (`SPECULATIVE`, and treat it as a SHAPE fix, not a bug fix) —
  an unfound anchor makes the box own text it does not own.**
  `frozenPrefix` (`:435-441`) returns `""` both when there is one block
  **and** when the backwards `range(of: ownedText)` fails at
  `blockCount > 1`; in that second state the box owns the **whole** text
  and `recordTail` writes earlier paragraphs into the last block's
  variant. **Its own pin encodes this as intended**
  (`MobileQuickNoteTests.swift:509-511`). Act 1 could construct no
  reachable input and labelled it honestly. **Do not manufacture a pin**
  (that is the fiction rule). Fix the failure *mode*: an unfound anchor
  should **refuse ownership** — stop autosaving — never claim everything.

**One detail Act 1 adds to Q1, and it matters for your fix:** the
existing pin already encodes the collateral as if correct —
`storedBlockTexts == ["Kept.\n", ""]`, **an empty trailing block left
inside a real note.** Your fix changes that expectation; make sure the
pin asserts the new truth rather than being edited to match whatever the
code now does. *(The difference between a pin and a transcript — batch 1b
made exactly this correction to itself.)*

**One sweep item to check while you are in this file, and report either
way:** the quicknote survey recorded an **`isDirty` honesty trap** — a
refused flush leaves `isDirty` true, so a "saved" indicator reading a
different source can claim saved when nothing was. A5-7 ruled the three
STATES (typing → saving → saved) but never named the ORACLE. **Verify
what the indicator actually reads** and report; if it can lie, it is a
finding and it is yours.

### Files you own — and nothing else
`App/Variorum/VariorumMobile/Features/Shell/MobileQuickNote.swift` ·
`Features/Shell/MobileShellRouter.swift` ·
`App/Variorum/VariorumMobile/VariorumMobileApp.swift` · tests:
`VariorumMobileTests/MobileQuickNoteTests.swift`,
`MobileShellTests.swift`, and the launch-path additions to
`MobilePerfWalkTests.swift`.
**`MobilePerfWalkTests.swift` is shared with no one in this wave** —
but say so in your report if you add to it, so the architect can fence
later waves.

### Environment
*[removed for publication]*
DerivedData
`/private/tmp/claude-501/-<home>-dev-variorum-mobile/42e1bf39-6409-49be-8c11-95e77e7feb86/scratchpad/dd-45a`.
**Both are yours alone** — target the simulator by UDID, never `booted`;
three other sessions hold the others, and sharing either breaks both
builds mid-run. You touch no `Shared/` and no Mac file, so core and Mac
need not run — **verify that claim with `git diff --name-only` before
you assert it.**
Her device is on **iOS 26.6**; this simulator is 26.2. Anything on the
UIKit input path that does not reproduce here is a **RUNTIME GAP**,
never a clean bill.

---

## 2. BRIEF — SUB-BATCH 4.5b · DELETION DOORS & THE CONFIRM BLOCKER

**Read §0 above, then `mobile-round-2.md` §49 in full** (your findings,
with its substantial clean bill — it tells you where NOT to spend),
**§44's NIT 7**, **§15's two traps** (the dead-door defect and
*pins must drive the real button*), **§46** (batch 4's own record,
including what its surface driver proved can and cannot be driven), and
**§28** (the established recovery picture — what is recoverable from
where, which the copy must not overstate).

### Build, in this order

**0 — 🟠 FIRST, AND IT GATES YOUR OWN PINS: the accessibility harness is
armed by a MACHINE-LOCAL SIMULATOR SETTING, not by anything in the repo**
(Act 1's MAJOR 4; `mobile-round-2.md` §56 and §9's amended environment
block). Without
`xcrun simctl spawn <UDID> defaults write com.apple.Accessibility ApplicationAccessibilityEnabled -bool true`
every `HostedSurface` pin reports **`labels were []`** — the tree comes
back empty and **every real door reads as ABSENT.** Sixteen pins.
Measured both ways on one simulator, one suite, one tree: clean →
`labels were []`; armed → **10/10 passed**. **All five of this round's
simulators were armed 2026-08-22**, so your runs are safe — **a fresh,
reset, or other-machine simulator is not.**

**This is the round's green-over-nothing class INVERTED — red over
nothing — and it is the more dangerous direction**, because the honest
response to a phantom failure is to change working code.

**You own `MobileSurfaceDriver.swift`, so you own the durable fix, and
it has two halves — ship both:**
1. **Arm it from inside the test bundle at launch** (or a scheme
   environment variable), so a clean machine cannot produce a false red.
2. **Make `HostedSurface` FAIL LOUDLY WITH A DIAGNOSTIC when a surface
   known to have content yields an empty tree** — *"the accessibility
   server is not armed"*, not *"door absent"*. **Half two is the more
   important half:** arming can regress on a new machine, and the whole
   point is that "not armed" must never again be indistinguishable from
   "the door isn't there."

**Red-on-old is free and the recipe is proven:** delete the key, run,
watch the phantom failures; restore it, watch them pass. Leave the
simulator as you found it (armed).

**1 — 🔴 The BLOCKER: four confirm buttons read back state SwiftUI has
already cleared.** Apple's contract: *"When the user presses or taps one
of the alert's actions, the system sets this value to `false` and
dismisses."* Each action closure does nothing but enqueue
`Task { await model.confirm() }` — so **the write-back lands
synchronously within tap handling, while the `Task` cannot resume until
that handling yields.** Each bound setter clears exactly the state its
confirm guards on:

| Door | What actually happens |
|---|---|
| **Delete Now / Empty Trash** | `pendingConfirm = nil` → **nothing is purged**, no intent, no receipt |
| **Library row → Delete Note** | `pendingDeleteNote = nil` → **the note is not deleted** |
| **Shelf row → Delete Book** | `pendingDeleteBook = nil` → **the book is not deleted** |
| **The A12 destructive-undo warning → Undo** | `cancelPendingUndo()` → **pressing Undo CANCELS it**, and reports *"Undo cancelled — nothing changed."* |

**Fix: capture the value before the `Task`, or use
`alert(_:isPresented:presenting:)`** — every other value-carrying
confirm in BOTH codebases uses `presenting:`, which captures the value
into the closure; these four are the first to read it back.

**THE PIN IS THE HARD PART, and the reviewer named the settling
experiment first** — *invoke the live `UIAlertAction`'s handler from the
existing hosted surface and assert `purge_intent == 1`.* Do that. **Why
nothing caught this:** batch 4's driver records honestly that a
`UIAlertController`'s buttons cannot be activated in process, so every
pin presents the alert and then calls the confirm method **directly,
while the pending value is still set**. The confirm→act edge is the only
edge where the binding setter and the deferred `Task` meet, **and it was
the only edge with no coverage.** *The honestly-stated gap is where the
defect lived.* If the live handler genuinely cannot be invoked, say so
plainly and pin the closest thing that is real — **but try it first, and
report what you found either way.** This is the round's fifth
green-over-nothing defect; the sixth is not acceptable.

**ACT 1 WIDENED THIS FINDING AND SETTLED ITS MECHANISM** (§56). There
are **FIVE** sites, not four — **the fifth is the MAC's `RecoveryView`**,
which is her own live report (*"pressed Delete Now on my Mac, nothing
happened"*). **The Mac's fifth site is NOT YOURS** — 13l owns it by her
ruling and its plan now carries the derived mechanism and the one-line
fix. **Yours are the four on the phone.** Two things from Act 1 that
sharpen your work:

- **The blast radius is exactly five hosts**, established by enumerating
  all **27** `isPresented:` sites in `VariorumMobile/`: only the four
  model-computed bindings are affected; every other is a plain `@State`
  Bool and is immune. **Enumerate them yourself and confirm the count** —
  if you find a sixth, that is a finding.
- **The rule this round cited names a SYNTAX, not the mechanism.** *Never
  a computed `Binding(get:set:)` over an `@Observable` property* — **your
  four sites obey that rule to the letter and are dead anyway.** When you
  write the comment that replaces it, name the **property that matters**:
  *the setter must not clear state the action's continuation will read
  back.* A rule that names a shape will be obeyed into the same bug.

**Note the asymmetry that would have hidden this from a device walk:**
the ⋯ sheet's Delete Note and book-details' Delete Book pass **no
pending state** and **do work**. She would have tested deletion, seen it
work, and never learned the purge doors and both row doors were dead.
**Your fix must leave both kinds working, and your pins must cover
both.**

**2 — 🟠 Deleting a note from the Library leaves a LIVE EDITOR on the
tombstone.** Both tab stacks are alive by design. The in-note door pops
the screen; **the Library row door passes no `onDeleted`.** So: open a
note, switch tabs, delete it from the Library row → the editor stays
mounted, is re-granted liveness on return, blanks its title, and
**remains editable over a deleted note** — keystrokes there autosave
into tombstoned variants and are **lost**. The batch's own in-note door
handles this correctly; compose that, do not invent a parallel road. *If
the fix needs `MobileShellRouter.swift` or `MobileWriteView.swift`,
**stop and report** — 4.5a and 4.5c hold those.*

**3 — 🟠 `MobileTrashModel` is a near-verbatim copy of the Mac's
`RecoveryViewModel`.** M-C forbids it at birth, and **it is already
drifting on day one**: the phone words its receipt from `restoreBlock`'s
landing, the Mac discards it — so the two recovery surfaces already
answer *"where did it go?"* differently. **The batch hoisted the WORDS,
the purge-table mapping and `PreservedOriginPutBack`, then stopped one
layer short of the DECISIONS.**

> **This is a HOIST, never a byte-copy** (MobileSoul §3). The proof this
> repo asks for is **the Mac suite riding UNMODIFIED** — that is what
> makes a hoist an address change rather than a behaviour change (the 3C
> pattern; batch 1b and batch 3 both produced it). Keep every pre-move
> name as a computed forward or typealias so existing pins compile and
> pass **unedited**; zero test edits is the parity proof. **You will
> touch Mac files, so M-B binds: run core + Mac + both spines + mobile,
> and report all five.** **Report every Mac-side file you touch and what
> changed in it** — it goes into 13l's manifest in the architect's
> commit, and a manifest completed at closeout is how that one went
> stale once already.
>
> **Scope honestly.** If the full decision-layer hoist is larger than
> this batch can land well, hoist the drifting decision that the finding
> names (the receipt) and **report exactly what remains, as a proposal**
> — the architect rules whether the rest is 4.5, a later batch, or a
> named owner. **Do not report it done when only the easy half is done**;
> that is a named failure mode of this round.

**3b — 🟠 `MobileBlockMenu` fires TWELVE bare `Task { await … }` doors
with no in-flight latch** (§53 finding 3). Lines 116, 123, 127, 131, 145,
150, 158, 189, 197, 214, 269, 278; `grep -n "inFlight\|isRunning"` in
that file returns **nothing**, while `MobileStructural` (`:55, :72,
:191`) and the view model's `mintInFlight` both latch. Rapid double-taps
run concurrent operations — **a lost update, never corruption**, which is
why the stability survey ranked it lowest. **You own the file and it is
about an hour**, and left alone it survives into **batch 7**, which adds
more take/block rows to this same menu. Latch it the way its two
siblings already do — **do not invent a third latching idiom.**

**3c — 🟠 CLOSE `MobileSurfaceDriver`'s OTHER TWO BLIND SPOTS, or own
them by name** (§53 finding 4). Its header records honestly that a
SwiftUI `Menu`'s rows and a `.contextMenu`'s rows are **undrivable in
process**, so the Library-row and shelf-row delete doors are pinned only
at their model act plus their confirm's *presentation*.

> **§49's MAJOR — the Library delete leaving a LIVE EDITOR on a tombstone
> — lived in exactly this blind spot.** You are fixing that defect at
> item 2; **fixing a defect without closing the blind spot that hid it
> leaves the next one just as invisible**, and the same class covers
> **batch 6's** PR3/PR5/PR6 context-menu doors. Item 1's settling
> experiment (invoke the live `UIAlertAction`'s handler from the hosted
> surface) closes half of it — **report what you learn about the other
> half either way.** If a class genuinely cannot be driven in process,
> say so plainly **and name what compensates** (a device-walk item, a
> different seam), so the gap has an owner rather than a header comment.

**4 — §49's four MINORs and four NITs, plus §44's NIT 7**, each with a
written disposition: a no-flush justification the shell's architecture
falsifies · a refusal spoken *behind* the presenting sheet · a rolled
observation duplicating the core wrapper · a success sentence in the red
slot · and **the ⋯ door's `confirmDelete` FAILS OPEN when its seam is
nil** (§44's NIT 7 — a destructive door that proceeds when its confirm
machinery is missing is exactly backwards).

**5 — A1-18: THREE deletion refusal-wording homes on the phone**, after a
batch whose stated purpose was one home for the deletion vocabulary —
`MobileEditorViewModel.deleteNoteRefusal:958`,
`MobileTrashModel.refusal:351`, `MobileBookDetailsModel.refusal:171`
(which `MobileShelfViewModel.confirmDeleteBook` also borrows). Each maps a
different subset of `OperationError`; each falls back to
`String(describing:)`, which is how a raw enum dump reaches her. **This is
item 3's finding one layer out** — fold it into the same hoist rather than
making a fourth home.

**6 — A1-15 (your third): `MobileCrossBlockEditTests.swift:598` asserts
*"there is no undo door on this phone yet"*.** M20 shipped it at batch 4.
*(The two `Shared/AppSession.swift` lines in that finding are 4.5a's.)*

**Copy discipline for every string you touch:** name no Mac door
(MobileSoul §4's no-redirect); do not say "gone forever" of a tombstone;
promise no recovery the phone cannot deliver; and check §28 for what is
actually recoverable from where before writing a sentence about it.
**M-E binds every door in this sub-batch** — its R13 carve-out covers
only the in-editor ⌫ keystroke, which is not yours.

### Files you own — and nothing else
`Features/Shell/MobileTrashView.swift` · `MobileTrashModel.swift` ·
`MobileLibraryView.swift` · `MobileLibraryViewModel.swift` ·
`MobileShelfView.swift` · `MobileShelfFaces.swift` ·
`MobileShelfViewModel.swift` · `MobileBookDetails.swift` ·
`Features/Write/MobileUndoDoor.swift` · `MobileNoteActions.swift` ·
`MobileBlockMenu.swift` · `App/Variorum/Shared/RecoveryCopy.swift` ·
`Shared/StructuralUndoCopy.swift` · **and, only for the hoist's Mac
side**, `Variorum/Features/Library/RecoveryView.swift` ·
`Variorum/Features/Tray/TrayPanel.swift` ·
`Variorum/Registry/ShellActions.swift` · tests:
`MobileTrashTests.swift`, `MobileDeletionTests.swift`,
`MobileUndoDoorTests.swift`, `MobileBlockMenuTests.swift`,
`MobileSurfaceDriver.swift`, and the Mac twins for anything you hoist.

### Environment
*[removed for publication]*
DerivedData `…/scratchpad/dd-45b` (mobile) and `…/scratchpad/dd-45b-mac`
(Mac). **Yours alone**; target by UDID, never `booted`.
**Her Mac app is currently QUIT** (she quit it at the architect's
report, 2026-08-22) — so Mac suites may run freely. **Check before you
run** with `pgrep -fl 'Variorum.app/Contents/MacOS'`: if it is live
again, it is her real-store daily drive — **never quit it, never kill
it**, and no Release build or `/Applications` refresh while it lives.

---

## 3. BRIEF — SUB-BATCH 4.5c · THE EDITOR & THE SHARED BRAIN

> ### ⚠️ THIS BRIEF IS SUPERSEDED IN SCOPE — read before dispatching it
>
> **Two rulings landed after it was written (2026-08-23), and both change
> what this sub-batch is:**
>
> **1 · ITS MAC AND `Shared/` WORK IS GONE — to the Mac phases.** Her
> ruling: *"I thought I asked for 4.5c's mac work to be added to what 13l
> is supposed to accomplish? so the mobile session shouldn't have mac /
> shared work to do when I return to it"*, under her principle *"do the
> mac phases in order so that the shared brain is 100% solid and
> stable."* **13l took the data-safety-shaped items (L-a…L-d); 13u took
> the editor-seam ones (its item 8).** **VERIFY WHAT THEY BUILT before
> planning anything below** — the itemisation here is the record of the
> FINDINGS, not your work list.
>
> **2 · 13u RULES THE CROSS-BLOCK SEMANTICS, AND IT RUNS FIRST.** Her 13u
> item 5 ruling (2026-08-21, on `main`) settles what these gestures DO
> for **both** platforms: cross-block edits **stop refusing**; the
> edge-join **merges** mid-paragraph and **not** at a paragraph break;
> and **the FANNED case is RULED OPEN** — a fanned *middle* block deletes
> whole to the tray, a fanned *edge* block's edit touches the chosen take
> only.
>
> **🔴 SO ONE INSTRUCTION BELOW IS NOW WRONG.** Where this brief says
> *"she fenced the fanned case off herself… the fanned case must keep
> refusing"* — **she has since ruled it open.** Fixing the fan fence's
> **SOURCE** (never authorize from a stale projection) is still right and
> still wanted; **hardening the fanned REFUSAL is not.** Compose to 13u's
> rule.
>
> **3 · "Write it into 13l's manifest" is stale wherever it appears
> here.** 13l will have CLOSED. New Mac-side work goes to the second
> manifest — the successor handoff's §6b and closeout obligation 13.
>
> **What still stands:** the pin-quality rules, the hygiene rules, the
> fence discipline, the review brief in §5, and every phone-local item.



**The most dangerous sub-batch in 4.5**, because everything in it is
shared: a mistake here is a mistake on both platforms, in the machinery
AppSpec §15 names the project's single riskiest subsystem.

**Read §0 above, then `mobile-round-2.md` §45's batch-3 section and §44
in full** (your findings), plus **§13** (the crash trace's landing —
the mechanism the whole family rests on), **§17/§18/§20/§21/§22**
(batch 1's build, both ladder rounds, and the M15 verdict — *do not
reopen M15*), **§30/§31** (merge-then-edit's ratified conditions and the
four-case refusal table), **§38** (the O(N²) find), and
`notes/plans/mobile-round-2-crash-trace.md` **in full** (B45-3 is its
unowned tail). Also `notes/TEXTKIT2_NOTES.md` §3 and §4 — binding
practice.

### Build, in this order

**1 — 🟠 The fan fence is enforced from a deliberately FROZEN
projection**, so **a block with takes can be merged away mid-typing**.
The repo states this exact law forty lines away, and the sibling seam
road obeys it. This is her personal fence being enforceable in name only
— *she fenced the fanned case off herself and is handling it Mac-side.*
**Fix the fence's SOURCE, not its routing:** the fanned case must keep
refusing. `git diff -- '*.swift' | grep -c planVisibleTakeEdit` reading
a **routing** change is the tripwire; a fix to where the fan ARITY is
read from is not that. State in your report which you changed.

**2 — 🟠 The O(N²) twin SURVIVES in `planVisibleTakeEdit`**, one
`else if` later, **on a road that runs** — so §38's *"the Mac inherits
the fix"* is **overstated in three places**. This is the round's
signature failure class (*a fix claimed complete whose twin lives*)
caught in the round's own headline find.

> **Fix it the way the original was fixed** (`starts[i] = Σ(length+1)`
> — an accumulation pass; it is *by definition* what
> `index.range(ofEntryAt:)` computes from zero each call), **pin the
> equivalence against the accessor itself on an irregular tiling
> including empty entries** (that is how the first one was proven), and
> **MEASURE**, because the first one measured **23.8 s → 0.003 s at
> 20,000 entries**. A performance claim without a number is not a
> claim. **Then sweep the class to completion**: enumerate EVERY caller
> of `range(ofEntryAt:)` inside a loop, in both platforms' code, and
> verdict each **FIXED with a named pin** or **provably SAFE with the
> mechanism stated** — the class-completeness table this repo requires
> when a fixed class recurs adjacent. Half a sweep is what put this
> finding here.

**3 — 🟠 §44's MAJOR: the Mac gets the gap fence's REFUSAL but not its
FACE**, and **§34(a)'s accepted trace is FALSE** on two counts —
merge-then-edit intercepts first (`CrossBlockEditPlanner.plan` collects
touched entries by `NSIntersectionRange(...).length > 0`, and **a gap
renders zero-length, so it can never be touched**), and
`CrossBlockRefusal.diagnose`'s own step 3 uses the same intersection
test, so a zero-length gap is invisible to it too. Result: `ops.merge`
reads the gap's placement as the next live one, throws
`.blocksNotAdjacent`, and `EditorViewModel.operationMessage` **has no
case for it** — she reads a raw enum dump.

**Three parts, all with red-on-old pins available:** give the Mac the
phone's fence arm; make `diagnose` step 3 treat a zero-length entry
inside the span as touched; give the Mac the `.blocksNotAdjacent`
sentence its phone sibling already has. **This is R8 work** (a
shared-defect consequence this round created Mac-side) and it is an
explicit item in **13l's manifest** — report exactly what you changed
Mac-side so the architect can complete that manifest in the same commit.

**4 — 🟠 An EMPTY block inside a span yields a plan that can never
execute**, refusing an ordinary gesture with a sentence naming a cause
that isn't there. Both halves are defects: the plan, and the words.

**5 — 🟠 The phone never wired A7/#34's seam carves**, so
**backspace-to-join refuses** — a fifth refusal case that §31's
four-case table omits. Check §31 before you build: three of its four
cases are hers by this round's end, and this is a case the table does
not name. **If closing it would widen a gesture beyond parity with the
Mac's shipped behaviour, STOP AND REPORT** — widening is hers, parity is
not.

**6 — 🟠 B45-2: the `displaySlot` / `slots[i]` coupling**, out-of-range-
safe only by **caller accident** during the crystallization window. The
stability survey said to make it explicit *"if the reorder-takes work
touches this area"* — **PR8 reorder-takes is scheduled at batch 7**, so
the schedule is walking straight into it, and this round already touched
the same method for a different reason without addressing it. Make the
safety **structural rather than accidental**, and pin the shape a
reorder would produce. *(§18's NIT 8 already ruled `displaySlot` gets
the structural disarm; this is the other half of the same room.)*

**6b — 🟠 THE MAC HAS NO IDENTITY-PROJECTION AUDIT AT ALL** (Act 2's
sweep, `mobile-round-2.md` §53 finding 1 — **the most consequential item
that sweep found**). The DEBUG per-keystroke oracle that catches the one
corruption class both other oracles are blind to lives **only on the
phone**: `auditIdentityProjection` + the M15 Q2 separator check at
`MobileEditorViewModel.swift:1898–1920`, while
`grep -rn "auditIdentityProjection\|identityAuditFailures" App/Variorum/Variorum`
returns **ZERO hits**. The Mac has only `desyncRecoveryCount`, and it
stamps identity itself (`EditorViewModel.swift:1012, 1361`) with nothing
watching.

**Why this outranks its severity label:** §18's MAJOR 1 was *silent prose
overwrite with every total still agreeing*, and §20 **reproduced it
Mac-side** — `stored → ["Alpha", "Beta beta", "G"]`, her paragraph
written to the store as one character, through the ledger, with the
totals agreeing so nothing downstream noticed. The Mac has a **pin** for
that traced case and **no runtime oracle for the class**. And **13l opens
against this merged tree with a Fable cold review of exactly this Mac
code as its first act.**

**HOIST it, do not copy it** (MobileSoul §3, and it is the third hoist of
this round — the pattern is proven twice already). The audit is a pure
walk over the tiling plus a storage read at a computed offset; **that is
brain, not face.** Move it to `Shared/EditorBrain/` with both platforms'
consumers calling it, keep the phone's counter semantics byte-identical
(its pins read `identityAuditFailures` and must ride **unmodified** —
zero test edits is the parity proof), and give the Mac the same
Debug-only wiring. **Carry the empty-entry hole's fix with it** (§21
found the walk's `guard range.length > 0 else { continue }` skips an
EMPTY entry's separator entirely, so an empty block's boundary is
unaudited) — if that is already fixed phone-side, verify rather than
assume, and say which you found.

**Pin it red-on-old on the MAC** by reproducing §20's traced corruption
there and asserting the Mac oracle now fires. That is the whole point:
the phone already catches it, the Mac does not, and a hoist without a
Mac-side red proves nothing about the platform that lacked the oracle.

**6c — 🟠 A1-5: MERGE-THEN-EDIT LANDED AND ITS OWN INSTRUCTION WAS NEVER
EXECUTED** (§56). `MobileEditorViewModel.swift:1986-2000` says, verbatim:
*"the Mac's other cross-block compounds (merge-then-edit, visible-take)
are LATER rows on this phone (M22 for the first). **When merge-then-edit
lands, this line loses the partial-span case too and must be re-narrowed
again.**"* **M22 landed in batch 3 of this very round and the line is
unchanged** — superseded copy carrying its own unexecuted instruction.

Tracing the gate chain (`:1265-1302`), the four populations that now
reach *"This edit spans more than one block — edit inside one block for
now."* are: a touched block carrying a **fan** · a touched block
**locked** or a **gap** · a span reaching the **open tail** · a **seam
backspace** (item 5). **None is named**, and the sentence implies the
machinery is absent when three of the four have a specific cause the Mac
already states.

**FIX BY HOISTING, not by writing four new sentences:** the Mac's brain
for exactly this is `Variorum/Features/Editor/CrossBlockRefusal.swift`,
and it **stayed Mac-app-local while its two siblings were hoisted this
round** (`wholeBlockDeletion` at 1b, `CrossBlockEditPlanner` at 3). Move
it to `Shared/`, call it from the phone's else-arm, Mac suite riding
unmodified as the proof. **And carry item 3's fix into it** —
`diagnose`'s step 3 uses the same intersection test, so a zero-length
entry is invisible there too. **One more copy correction while you are
there:** the phone's `blocksNotAdjacent` sentence
(`MobileStructural.swift:891-894`) names *"a block that hasn't arrived
yet, or one that landed since you selected"* — **not the commonest cause,
an ordinary blank paragraph.**

**6d — A1-14: `BlockRangeIndex` now has TWO mutator protocols and no
stated rule about which is which.** The band header
(`:456-486`) reads as a whole-band law — *"THE MUTATORS REFUSE; THEY DO
NOT TRAP"* — while `transferTailPrefixToLastEntry` (`:522-528`),
`crystallize` (`:536-548`) and `range(ofEntryAt:)` (`:74-81`) still carry
preconditions. **Act 1 traced every call site and found all of them
currently guarded**, so this is a hazard, not a live bug — **but the
survivors are exactly the class this round proved fatal in Release, and
the header now reads as covering them.** State the split explicitly, or
make them fallible too. Your call; say which and why.

**7 — B45-3: the crash trace's SIX unowned items.** Read that record's
own sections; each is named there:
   - **E1** — the instrumented device experiment. **It is device work,
     not yours to run** (B45-4, her hardware, iOS 26.6). **Your job is
     to BUILD IT AND LEAVE IT RUNNABLE**: the instrumentation that logs
     each gate consult's `(range, replacementLength)` and each report's
     `(editedRange, delta)`, flagging any report whose OLD span extends
     past the last consult's `range.upperBound` — behind a flag that is
     inert in ordinary use. Say precisely how it is armed and read, in
     words a device session can follow without your context. **M1's own
     status is recorded "high confidence, NOT PROVEN", and this is what
     settles it.**
   - **E2** — the CI gate/report fixture.
   - **§8 path 8** — UIKit undo replaying a coalesced edit through the
     gaps between `removeAllActions()` calls. **Zero mentions anywhere
     in the round.** Trace it; if it is reachable it is a finding, if it
     is not, say why with the mechanism.
   - **§8 path 11** — the `supportsTextReplacement: false` fence,
     recorded expressly *"so the fence is not removed later without
     re-reading this"*. Verify the fence is still in place and carries a
     comment saying why.
   - **§9's Mac residual** — the `MarkdownActs` arm-then-hand-off sites,
     named once as *"the Mac's real residual"* and never revisited.
   - **M1's SUSPECTED status itself** — say what would move it, and what
     E1 will and will not settle.

   **Each of the six leaves your session either FIXED, or with a named
   owner** — a phase number or a master-plan project row, never a blank
   and never "a future session". Propose; the architect rules.

**8 — §44's MINORs 2, 4, 5 and NITs 6, 8**, each with a written
disposition: the `MobileStructural.swift:832` doc falsehood
(*"ONE `session.runner.run` transaction, so a throw means nothing
landed"* — `OperationsRunner.run` is an **actor hop, not a
transaction**, `deleteBlock` opens its own `database.write`, so the
compound is **N transactions** and the promise holds only via
`withCompound`'s **best-effort** unwind) · **the gap pin builds a gap
production cannot produce** (`indexWithGap` sets `variantID: nil` but
keeps a **non-zero length**; every real gap is length 0 — **and this is
exactly why finding 3 above was invisible from these pins**; the same
helper is in `MobileCrossBlockEditTests`) · the stranded-originals read
is unmeasured and **fails silently** (`(try? …) ?? []` turns any failure
— including a variable-count overflow in a two-stage recursive CTE bound
with one placeholder per deleted block — into the *reassuring* "nothing
was stranded" receipt) · the no-confirm guard covers only the delete
road, not merge-then-edit's · the second copy slip.

### Files you own — and nothing else
`App/Variorum/Shared/EditorBrain/` (all) ·
`Features/Write/MobileEditorViewModel.swift` · `MobileStructural.swift` ·
`MobileWriteView.swift` · `MobileMarkdownActs.swift` ·
`Variorum/Features/Editor/EditorSurfaceController.swift` ·
`Variorum/Features/Editor/EditorViewModel.swift` · tests:
`MobileEditRoutingTests.swift`, `MobileEditRoutingCrashTests.swift`,
`MobileCrossBlockEditTests.swift`, `MobileWholeBlockDeleteTests.swift`,
`MobileStructuralTests.swift`, `MobileEditorTests.swift`,
`VariorumTests/EditRoutingTests.swift`,
`VariorumTests/EditRoutingCrashTests.swift`,
`VariorumTests/BlockRangeIndexTests.swift`.
**`MobileBlockMenu.swift` is 4.5b's** and `MobileKeyboardBar.swift` is
4.5d's — stop and report if you need either.

### Environment
*[removed for publication]*
DerivedData `…/scratchpad/dd-45c` (mobile), `…/scratchpad/dd-45c-mac`
(Mac). **Yours alone**; by UDID, never `booted`.
**You touch `Shared/` and Mac code — M-B binds: core + Mac + both spines
+ mobile, all five reported.** The Mac suite standing at **1568/272
exact** is the hoist proof: **if it moves, something changed Mac
behaviour, and you say what.**
**P2/P3-class crash pins live in their own file by design** — they kill
the test process on a pre-fix tree, and a red-on-old verification run
must not take the suite's report down with it. Keep that separation.
Her device is **iOS 26.6**; this simulator is 26.2 — non-reproduction on
the UIKit input path is a **RUNTIME GAP**, never a clean bill.

---

## 4. BRIEF — SUB-BATCH 4.5d · THE KEYBOARD BAR'S GEOMETRY

**Read §0 above, then `mobile-round-2.md` §45's bar-family section**
(your findings), **§26** (the bar's measurement history and the dead
two-height mechanism), **§35** (the 20 pt structural floor and *why it
exists*), **§37/§38's R22/R25** (her one-row ruling, made with the
eleven-act cost in view, and her pre-ruling that the buttons are
tappable), and **M17** (the platform truth: an `inputAccessoryView`
cannot resize after presentation).

### Build

**1 — 🟠 The one-row strip OVERFLOWS a 320 pt phone.** It needs **338 pt
where 288 is offered** — iPhone SE, or any iPhone with **Display Zoom**
on — putting **~25 pt off each edge, with `×` and `⇤` effectively
unreachable.** This is FIX-5's original defect verbatim and it is a
**regression**: the two-row shape fit with 4 pt to spare. **The pin
cannot see it because it compares to a literal `375` while its own
toolbar is 320.**

**ACT 1 CORRECTED THE ROUND'S OWN FRAMING OF THIS (§56), and the
correction widens it:** `tightestBarWidth = 375` is right about
*hardware* — the reviewer verified that **SE 2/3, 12 mini and 13 mini are
all 375 pt on iOS 26**, so the round's "iPhone SE" framing was too narrow.
**320 pt is reached via DISPLAY ZOOM**, which makes a 375 pt SE *and* a
390/393 pt iPhone alike report 320. So this is not a rare-device edge —
**it is any iPhone whose owner turned on larger text-and-icons.** The
arithmetic: 11 acts × 28 + 10 × 2 = **328 pt** intrinsic; a 320 pt bar
offers 320 − 32 − 10 = **278 pt**.

**Her ruling is the shape, and it stands** — one row, eleven acts, and
she pre-ruled the tap targets acceptable at a quoted 31 pt (R25). **What
you are fixing is that the row must FIT the width it is given**, on
every width the app supports, not the one the pin assumed. Propose the
mechanism — scroll the strip, compress spacing, or scale with available
width — **with the tradeoff stated for each**, and note that her
standing preference is *text on screen outranks chrome polish* (R23) and
that she chose one row **partly to return ~20 pt of text to the page**.
**The architect rules the mechanism if it changes how it LOOKS**; if it
is purely a fit fix at her ruled shape, build it and report.

**2 — 🟠 The vertical geometry pins assert constants against
themselves** (`air >= air`), **so the recorded guarantee that "a future
iOS trips here and gets re-measured rather than silently re-broken"
DOES NOT EXIST.** This is §15's trap 1 for the **fifth** time in this
round, and it is the one that matters most here, because §26 and §35
both rest their conclusions on measured constants.

**Rebuild the pins against MEASURED geometry from the real surface** —
the frame dumps §26 and §35 describe are the technique — and **bound
them on BOTH sides** (the shipped air pin is bounded `> 0`, `<= 6`,
`== 4` precisely so that re-inflating trips it exactly as clipping
does; that is the pattern). **A width pin must read the toolbar's own
width, never a literal.** And add the 320 pt case explicitly: it is the
width the shipped defect lives at.

**3 — Report the floor's current truth.** §35 records a **20 pt
structural floor** (the resting glass cells run to 48 pt, the two-row
capsule's 88 pt cell centred on the fixed 48 pt content row reaches
68 pt, and one height must serve both states because of M17). **R22
retired the two-row strip.** So: **does the floor still exist at all?**
It was a consequence of the two-row capsule. If the one-row shape
dissolved it, say so — the constant's own doc comment records the floor
as a standing limit, and a limit that no longer binds is superseded
documentation, which §44's MINOR 6 class exists to catch. **Verify by
measurement, not by reading.**

### Files you own — and nothing else
`Features/Write/MobileKeyboardBar.swift` and its pins. **The bar's tests
currently live inside `MobileMarkdownTests.swift`, which 4.5c may also
need** — check with `git diff --name-only` at your start; **if 4.5c has
touched it, stop and report** rather than sharing the file. Prefer a new
dedicated `MobileKeyboardBarGeometryTests.swift` for your new geometry
pins, which removes the contention entirely.

### Environment
*[removed for publication]*
(and note it is a small-width device, which is useful to you) plus a
**320 pt-width configuration** for the defect itself; DerivedData
`…/scratchpad/dd-45d`. **Yours alone**; by UDID, never `booted`.
**`ImageRenderer` cannot capture this surface** (the parity inventory's
recorded warning) — use the real-surface frame-dump technique §26 used,
not a rendered snapshot.

---

## 4b. THE DEVICE QUEUE — SUB-BATCH 4.5-device (B45-4, widened by Act 2)

**Not a build session. A queue, run in ONE window when she offers her
phone** — and her standing instruction (§50 sweep finding 2) is that the
device-only queue runs in that window, **not just the install.** This
round already spent one such offer on two installs while two of these
sat runnable. **Her device is iOS 26.6; the newest simulator here is
26.2**, and every item below is here precisely because a simulator
cannot settle it.

| # | Item | What settles it |
|---|---|---|
| **E1** | **The crash trace's instrumented experiment** — *the only thing that settles where the stale verdict comes from.* **M1's own status is recorded "high confidence, NOT PROVEN."** | Log each gate consult's `(range, replacementLength)` and each report's `(editedRange, delta)`; flag any report whose OLD span extends past the last consult's `range.upperBound`. **4.5c builds the instrumentation and leaves it RUNNABLE**, with arming and reading written for a session that will not have 4.5c's context |
| **M16** | **Same-note text drag-move** — if a dragged selection covers whole paragraphs it may plan a BLOCK delete while the drop lands the text as content (I4). Unsettleable from the repo: no drag delegate is configured, so reachability is a **device fact** | §24.9's experiment: long-press-drag a two-paragraph selection within one note; observe whether the source blocks vanish and whether the moved text lands as blocks or as content |
| **D3** | **The destructive colour on a deletion door** (§46, §53 finding 2a) — `MobileNoteActions.swift:175` records that in a `layer.render` capture *system semantic* colours render as default label colour, so "Delete Note…" read black rather than red. Most likely a capture artifact, **but it is a colour a deletion door leans on (M-E)**, so it was flagged rather than assumed away | Look at it on the real screen |
| **D4** | **The quick note's PLATFORM half** (§53 finding 2b) — `MobileQuickNoteTests.swift:14–17`: the pins *"cannot reach that iOS really delivers `.background` before a swipe-kill, and that the `beginBackgroundTask` grant buys enough wall clock on real hardware."* **This is the device half of Q1/Q2/Q4's own promise** — 4.5a fixes the code and nothing verifies the platform contract the fix rests on | Type into the box, swipe-kill, relaunch: is the text there? Repeat with the device locking mid-round |
| **D5** | **`Shared/SignInFlow.swift`'s iOS `presentationAnchor` arm** (§53 finding 2c, PL-9's third judgment act) — *"compiles but has never run on a device"* | Exercise the delegated bridge-connect door once, if the door stays |

| **D6** | **Dictation into a MULTI-PARAGRAPH capture** (4.5a, §58) — iOS dictation replaces the whole field as it refines, which falsifies `hasPrefix`, so the box will hold at the boundary and refuse it. **4.5a's fix makes this SAFE** (the shipped code destroyed the tail in exactly this case) — but the interaction is untested on hardware, **and it is the same multi-paragraph case she is currently hand-avoiding** | Dictate into a box that already holds a pasted multi-paragraph capture; watch what the box does and what the note holds afterwards |
| **D7** | **The caret jumps to the end** on every held change — **inherited from the shipped clamp, not introduced by the fix.** Invisible in tests, obvious in the hand | Edit the first paragraph of a pasted capture and watch where the caret goes |
| **D8** | **A real cold FIRST launch, timed on her iPhone** (B45-1's unknown) — the simulator says **54.0 ms** for the full migration set, but simulator disk is host-SSD-fast and the device number has never been taken | Time a first launch after a fresh install |

| **D9** | **THE 23 pt STRIP AT DISPLAY ZOOM — the one user-visible change of 4.5d, never seen by a human** (§61 MAJOR 2). The 28 pt strip was photographed on device with taps verified; **23 × 38 pt has only frames-in-bounds in a plain window host**, and frame containment is not legibility. **Display Zoom RESTARTS THE DEVICE**, so it must ride the same window as an install | Settings → Display & Brightness → Display Zoom → Larger Text; open a note, tap **Aa**, look at the eleven acts and **tap each one** — especially `×` and `⇤` at the ends |

**R30 binds the install itself:** her words, *"i'll wait for my fresh
build til these batches are all done"* — so the phone keeps the
2026-08-21 23:49 build **with the three BLOCKERs live** until the round's
remaining batches land. **The queue above does not wait on that.** E1's
instrumentation needs a build to run on, so when a device window opens,
say plainly which items need a fresh install and which do not, and let
her choose.

---

## 4c. BRIEF — SUB-BATCH 4.5e · THE APP-LIFECYCLE FILES IN `Shared/` (wave 3, alone)

> ### ⚠️ THIS BRIEF IS SUPERSEDED IN SCOPE — read before dispatching it
>
> **Two rulings landed after it was written (2026-08-23), and both change
> what this sub-batch is:**
>
> **1 · ITS MAC AND `Shared/` WORK IS GONE — to the Mac phases.** Her
> ruling: *"I thought I asked for 4.5c's mac work to be added to what 13l
> is supposed to accomplish? so the mobile session shouldn't have mac /
> shared work to do when I return to it"*, under her principle *"do the
> mac phases in order so that the shared brain is 100% solid and
> stable."* **13l took the data-safety-shaped items (L-a…L-d); 13u took
> the editor-seam ones (its item 8).** **VERIFY WHAT THEY BUILT before
> planning anything below** — the itemisation here is the record of the
> FINDINGS, not your work list.
>
> **2 · 13u RULES THE CROSS-BLOCK SEMANTICS, AND IT RUNS FIRST.** Her 13u
> item 5 ruling (2026-08-21, on `main`) settles what these gestures DO
> for **both** platforms: cross-block edits **stop refusing**; the
> edge-join **merges** mid-paragraph and **not** at a paragraph break;
> and **the FANNED case is RULED OPEN** — a fanned *middle* block deletes
> whole to the tray, a fanned *edge* block's edit touches the chosen take
> only.
>
> **🔴 SO ONE INSTRUCTION BELOW IS NOW WRONG.** Where this brief says
> *"she fenced the fanned case off herself… the fanned case must keep
> refusing"* — **she has since ruled it open.** Fixing the fan fence's
> **SOURCE** (never authorize from a stale projection) is still right and
> still wanted; **hardening the fanned REFUSAL is not.** Compose to 13u's
> rule.
>
> **3 · "Write it into 13l's manifest" is stale wherever it appears
> here.** 13l will have CLOSED. New Mac-side work goes to the second
> manifest — the successor handoff's §6b and closeout obligation 13.
>
> **What still stands:** the pin-quality rules, the hygiene rules, the
> fence discipline, the review brief in §5, and every phone-local item.



**Born 2026-08-22** because three findings converge on two `Shared/`
files that no sub-batch owned — and because the architect's §1 brief
referred to `AppSession.swift` without listing it, which 4.5a correctly
refused to act on. **The record is `mobile-round-2.md` §58.**

**Read §0 above, then `mobile-round-2.md` §58 (your findings and the
rulings already made on them), §56 (Act 1, which found A1-15 and A1-21),
and §9's environment.** Also `notes/OverallModel.md` **§5 (P2: all DB I/O
off the main thread)** — item 1 is a P2 violation and you should read the
invariant in its own words.

### Build

**1 — 🟠 B45-1: `AppBootstrap.init` opens the store and runs the
migration set SYNCHRONOUSLY ON THE MAIN THREAD before first paint.**
`VariorumMobileApp.swift` constructs it as `@State`. **The shape is
already ruled** (§58, adopted from 4.5a's proposal):

> An `.opening` state; `init` sets it and starts the open; the file work
> runs on a detached task and hops back to MainActor for `install` plus
> the state write (**preserving the once-per-process `installed` flag**);
> `retry()` re-enters the same road; both app roots gain an `.opening`
> arm rendering a quiet launch view. **The "UI can touch a store that is
> not ready" window cannot open by construction** — `AppSession` only
> exists inside `.ready`, the same property `MobileStoreFailureView`
> already relies on. Read that view before designing; it is the
> precedent.

**MEASURED ALREADY — do not re-derive, but DO re-measure after:**
54.0 ms on a first launch (empty store, full migration set), 5.0 ms on an
ordinary reopen, **3.6 ms at the 100k proving ground** — i.e. **flat in
corpus size**, O(migrations) rather than O(corpus). 4.5a's
`MobileLaunchPathTests` (in `MobilePerfWalkTests.swift`) is the harness;
**report the after-numbers beside those three.** Note honestly what the
harness cannot time: `init` also calls `AppDatabase.install` →
`prepareDependencies`, a once-per-process door a test host cannot safely
re-enter.

**2 — 🟠 A1-21: `Shared/AppSession.postAutosaves` has NO removal path**
(no `removeValue` anywhere). Bounded for editors (notes opened), **but
the quick note adds one coordinator PER CAPTURE**, and
`flushEveryOpenPost()` iterates every one on every filing and every
background flush — so the cost of leaving the box grows with how much she
has captured this session.

**The shape 4.5a proposed, with the trap it already traced:**
`releaseAutosave(forPost:)` on `AppSession`, called from the quick note's
`reset()` — the box knows exactly when it is done, and it has already
flushed and savepointed by then. **The trap:** on the Mac,
`autosave(forPost:)` registers a `quitFinalize` closure at **mint** time,
so release-then-remint would register a **second** for the same post — a
duplicate `savepointOnLeaving`, which `closeAutoCommit` dedupes, so it is
noise rather than corruption, **but it must be deliberate rather than
discovered.** A mobile-only fix bypassing the session cache is available
and is **refused**: it contradicts A5-4's ruled *"existing shared drain"*.

**3 — A1-15: two comments in `AppSession.swift` state reasons that are
FALSE**, and behaviour is fine in both cases — which is the class that
makes the next reader wrong. `:89` says the phone registers structural
entries *"with no undo UI yet"* (**M20 shipped it at batch 4**).
`:240-245` says the quick note *"mints its note through the operations
layer, so there is no buffer to flush and no reason to grow one"* —
**inverted**: `MobileQuickNote.adopt` calls `session.autosave(forPost:)`,
which mints **and caches** a coordinator, and every post-mint keystroke
rides it. **It sits directly above the code item 2 is about**, so fix it
while you are there and make it say what item 2 makes true.

### Files you own — and nothing else
`App/Variorum/Shared/AppBootstrap.swift` ·
`App/Variorum/Shared/AppSession.swift` · the `.opening` arm in
**both** app roots (`VariorumMobile/VariorumMobileApp.swift` and the Mac's
root) · **PLUS, added 2026-08-22 (§59's MAJOR 2 / §62):**
`Variorum/Features/Shelf/QuickEntryBar.swift` and
`Variorum/Features/QuickNote/QuickNoteView.swift` — **the Mac's
quick-capture twins of Q2 and Q7**, which destroy her text on a refusal
(`entryText = ""` BEFORE the mint) and report a raw enum dump. **The
phone's just-shipped fix is your reference shape**; read
`MobileQuickNote.file()` and `MobileQuickNoteCopy.refusal` before
touching them, and route the copy through `OpsRefusalCopy.message(for:)`
rather than inventing a sentence · tests for both platforms.
**`VariorumMobileApp.swift` is unambiguously YOURS** — 4.5a's claim on it
is discharged (its work there is complete, comment-only, and landed).
That double-ownership was an architect brief error, caught by an
implementer; it is resolved here so wave 3 cannot inherit it.
**`MobilePerfWalkTests.swift` carries 4.5a's `MobileLaunchPathTests`** —
you extend it; confirm with `git diff --name-only` that no other session
is in it, and stop and report if one is.

### Environment
**You are ALONE in the tree in wave 3** — these two files are compiled
against by every target, which is exactly why. Simulator **iPhone 17 Pro,
*[removed for publication]*
`…/scratchpad/dd-45e` and `…/scratchpad/dd-45e-mac`.
**Every item here is a `Shared/` change, so M-B binds without exception:**
core + Mac + both spines + mobile, all five reported, **and every
Mac-side line goes into 13l's manifest** via your report. Before running
Mac suites check `pgrep -fl 'Variorum.app/Contents/MacOS'` — if her
real-store app is live, **never quit it, never kill it.**

---

## 5. THE COLD-REVIEW BRIEFS — written now, dispatched with each build (R28)

**R28, her ruling:** *a batch dispatch is BUILD → COLD REVIEW → FIX →
CONTINUE, as one unit, with no human in the middle.* The orchestrator
does not decide after a build reports whether to review it. **These
briefs exist before the builds do**, so no sub-batch can reach her
half-open.

**Each reviewer gets:** `notes/REVIEW_PROMPT.md` **VERBATIM** with
`{PHASE}` read as *Mobile Round 2, sub-batch 4.5x*, its standing
context, **the sub-batch's own diff as its target**, and **no framing
whatsoever about what was built** — that isolation is the whole
mechanism. It additionally gets the five mandatory blind-spot checks
below, which are defect CLASSES, not implementation narrative, and so
preserve the isolation exactly as a plan-time "Review foci" section
does.

**The five mandatory checks (every 4.5 reviewer, every round):**

1. **A fix claimed complete whose TWIN survives elsewhere** — the same
   shape in a sibling method, the other platform, the other door.
   Enumerate; do not sample.
2. **A pin asserting a stored value, or driving an API that BYPASSES the
   layer under test.** Ask of every new test: does its red depend on a
   state the product can produce, and did it drive the path it meant?
3. **A mechanism recorded from READING rather than RUNNING.** Any
   load-bearing claim must be locatable in code or a test you read. A
   claim you cannot locate proof of is itself a finding.
4. **Copy or comments describing SUPERSEDED behaviour.**
5. **The seams BETWEEN this sub-batch and the other three** — 4.5a/b/c/d
   ran in parallel over one tree; two changes each correct alone can be
   wrong together, and a shared brain's two platform consumers can now
   disagree.

**Findings land in `mobile-round-2.md` BEFORE any fix session sees
them** (repo-first). Fixes run in a **fresh** session with traced
mechanisms and revert-verified pins. Round 2 re-reviews with **another
fresh reviewer**; a new BLOCKER/MAJOR earns round 3; hard cap three.
**Every finding gets a written disposition** — including the dismissed
ones, with the reason.

---

## 6. THE EXIT CONDITION — 4.5 IS NOT DONE UNTIL THE DEDICATED STABILITY PASS HAS RUN

**It is not a list entry; it is the batch's exit condition** (handoff §3,
and §8's second commitment, which lived only in prose until 2026-08-22).

ONE fresh cold reviewer whose **only** brief is **the crash class and
the editor's range/identity math** — adversarial, tasked to find the
case the fix misses. **It reviews the FIX, not the feature.** Its target
is batch 1 + batch 1b + M22's shared-brain work **plus 4.5c's changes**
as one body: `Shared/EditorBrain/` (`BlockRangeIndex`,
`EditorEditRouting`, `CrossBlockEditPlanner`) and both platforms'
`storageDidEdit` consumers. **It OWNS M27** — *the first typed edit
after a DIVIDE is unroutable and takes `desyncRecovery`* (§46,
reproduced on the pre-batch tree, neither caused nor fixable in batch 4).

**It is discharged by nothing that resembles it.** Her ACT 1 pass is an
earlier read over batches 1–4. **B45-3** owns the crash trace's unowned
items as *build/experiment* work. Both look like this pass from a
distance; neither replaces it. *If you find yourself reasoning "we
already did a review like that" — that reasoning is how this round lost
five of them.*
