# 13u3 LADDER — ROUND 2 (fable-reviewer, cold, 2026-09-19)

**Scope:** a REAL re-review of round 1's fixes and what they touched — the six fix commits
`262ef925` (R1-2) · `ede79958` (R1-3) · `5cceee24` (R1-4) · `d42a3440` (R1-5+R1-6) · `43f420b4`
(R1-1) · `df32bf06` (S-1…S-4), each read as its full `git show` diff and then traced in the
CURRENT tree, against the phase's whole diff (`98696c81..HEAD`) wherever a fix's blast radius
reaches. **Anchor:** `notes/plans/13u3-ladder-round1.md` (findings, dispositions, "Handed to
round 2") + `notes/plans/13u3-ladder-round1-responses.md` (the implementer's responses and
sanity pass S-1…S-4 with their dispositions). Prompt: `notes/REVIEW_PROMPT.md` verbatim.

**Range note, recorded for the record's honesty:** the brief's range `56f133e8^..2f998bf4`
contains only four commits (the five R1 fix commits predate `56f133e8`); the NAMED commit list
is authoritative and each named commit was reviewed whole. Verified independently: from
`262ef925^` to HEAD exactly SIX commits touch anything outside `notes/` — the six named ones.
No production change hides in the notes commits.

**Read in this session:** every hunk of the six diffs; the current
`EditorViewModel.swift` (storageDidEdit whole, updateCaretContext whole, the settle-hop
machinery, refreshDecorations whole, operationMessage whole, the ask/file doors);
`EditorView.swift` (the storage delegate + the sibling re-measure observer);
`Operations+Variant.swift` (renameCommitPoint + setTakeLabel); `BlockHistoryPane.swift` (model
+ rename door + regions); `TakesViewModel.swift` / `CanvasViewModel.swift` /
`CompareBoardView.swift` (each ask door + each filer's error road); `OpsRefusalCopy.swift`;
`CaptureTextView.swift` (updateNSView + takeFocus); `QuickEntryBar.swift` / `QuickNoteView.swift`
(the chip closures); `EditorSurfaceController.swift` (the `displayed:` doc + the drift-check
dispatch); the four fix-pin suites whole; the harness's `replace` (verified: the REAL
`insertText` path, so the R1-1 pin genuinely drives shouldChange → storage edit →
didProcessEditing).

**Targeted verification runs (no full suite at review start, per the standing rule):**
- core `swift test --filter SavepointNameTests` — **12/12 green** (the R1-2 red-on-old cell
  among them).
- Mac `xcodebuild -only-testing` over the four fix-pin suites — **23 tests / 4 suites, all
  green**: EditorDecorTransactionTests (2) · SavepointSealedDoorTests (6, the S-2 pair
  included) · SavepointRenameDoorTests (5) · TakeCardDoorTests (10).

**STATUS: COMPLETE — findings, the implementer's responses adjudicated, and the reviewer's fix
pass (dispositions + finals at the end of this file). ROUND 2 IS CLOSED; NO ROUND 3 OWED.**

---

## FINDINGS (severity-ranked)

### R2-1 · [MINOR] · `EditorViewModel.swift:3090–3093` (the R1-3 Write guard) vs `:4024` (`operationMessage`) · the Write door's seal refusal speaks a DIFFERENT sentence than the Write filer's — the fix's own "the two moments cannot disagree" comment, and the round-1 disposition's "each speaking the exact `lockedPost` sentence the post-⏎ road speaks", are both false at exactly one of the four doors

**Mechanism, traced:** the R1-3 guard at `askSavepointName` (`:3090`) speaks
`OpsRefusalCopy.message(for: .lockedPost)` = **"This note is sealed — unseal it to change
takes or choices."** (`OpsRefusalCopy.swift:339–340`). Write's post-⏎ road — `fileSavepoint` →
`commitCaret` → catch → `showOperationError` (`:4015`) → the surface's OWN local table
`operationMessage` — speaks **"This note is sealed — unlock it first."** (`:4024`). So on a
sealed note in Write: ⌘S at the door says one sentence; the same refusal reached through the
filer (a seal landing under the open field — the stale-`header` race the fail-open design
deliberately leaves to the filer — or any shipped pin that drives `commitCaret` directly) says
another. That is the exact "one door, two answers" grain R1-2 was raised for, reintroduced by
R1-3's own fix at one of its four doors.

Two aggravations, both factual:
1. **The pre-D shipped behavior was the OTHER sentence.** R1-3's disposition bills the fix as
   "restoring the pre-D keypress refusal" — pre-D, ⌘S on a sealed note ran `commitCaret` → the
   op threw → `operationMessage` → *"unlock it first."* The fix restored the TIMING but changed
   the WORDS she has seen at that keypress since the seal existed.
2. **The `OpsRefusalCopy` register is wrong for this gesture:** "unseal it to change takes or
   choices" answers a takes/choices door; the gesture refused here is a COMMIT.

**Why the three boards are clean and Write alone is not** (verified per surface, door AND
filer): Takes/Lenses' filer errors route `run` → `setRefusal(Self.message(for:))` →
`OpsRefusalCopy` (`TakesViewModel.swift:2523–2531, 2551–2553`); Canvas' filer catch is
`OpsRefusalCopy.message(for: error)` (`CanvasViewModel.swift:757`); Compare's likewise
(`CompareBoardView.swift:821`). On those three, door and filer genuinely speak one sentence.
Write is the ONE surface whose filer has its own local table (`operationMessage`, whose own
`blockNotFound` case documents the two-switch duplication hazard and shares a constant for
exactly this reason), and the R1-3 guard reached past it to the registry.

**Why the shipped pin missed it:** `SavepointSealedDoorTests.writesDoorRefusesASealedNote…`
asserts the door's message equals `OpsRefusalCopy`'s sentence — it pins the door to the
REGISTRY, not to the SURFACE's filer, so the divergence is invisible to it by construction.

**Fix:** the Write door speaks its own surface's sentence — `refuse(operationMessage(
OperationError.lockedPost(id: postID)))` (same class, one line) — and the Write cell asserts
the CONTRACT instead of a constant: drive the door AND the filer under one seal and
`#expect` the two spoken sentences are EQUAL. **Red-on-old pin:** that equality cell fails on
the current tree (the two strings differ) and passes after. Nothing lands wrongly today — both
sentences are honest refusals of the same class — hence MINOR, not MAJOR.

### R2-2 · [NIT] · `EditorViewModel.swift:3443–3444` · the depth counter's "one writer" is documented but not compiler-enforced

`enterStorageEditTransaction()` / `exitStorageEditTransaction()` are **internal**, while their
doc comment says "The one writer (`storageDidEdit`'s entry/exit), named so no second site ever
mutates the depth ad hoc." The only caller is `storageDidEdit`, in the same file — `private`
compiles (Swift file-scope private) and turns the doc's claim into a compiler fact; today any
App-module code could bump the depth and silently suppress the indicator refresh (or, worse,
un-suppress it mid-transaction via a stray `exit`). No pin owed (cleanliness — no reachable
wrong state today, verified by grep: zero callers outside the definition + `storageDidEdit`).

---

## THE HANDED ITEMS — round 2's dispositions

1. **R1-1's fix — VERIFIED SOUND at the editor seam** (the xhigh area; re-traced whole, not
   taken from the records). `enterStorageEditTransaction()` + `defer` open `storageDidEdit`'s
   body and cover all six exits (the suppress return, four `desyncRecovery` returns, `.refuse`,
   plus the normal end); the method is non-async and non-throwing, so nothing strands the
   depth. The indicator arm (`:3372–3383`) is the ONLY `refreshDecorations` reach inside the
   transaction — re-enumerated on the CURRENT tree: the eleven call sites are appearance/pointer
   `didSet`s (`:216`, `:225`), observation adopters (`:542`, `:547` — async deliveries),
   block-selection acts (`:3019`, `:3026`, `:3035` — clicks), the gated arm (`:3381`), the
   settle hop's `defer` (`:3505`), `pushDecorationsToSink` (`:3582`), and none of the
   `refreshBadges` callers (adoptEcho `:833`, settle `:3491`, restore-jump `:3923`, plus
   view/controller sites) runs inside `processEditing`. What still runs in-transaction is
   geometry-free: `refreshGestureAvailability` is a planner walk over selection + index
   (`:2784–2807`), the caret walk is offset arithmetic, the U-20 caret report is bookkeeping.
   The oracle sits exactly at the forcing boundary (after `needsFrames`, before `offsetAt`'s
   `textLayoutFragment(for:)`; `fragmentFrame` enumerates `options: []`, non-forcing).
   Non-starvation re-traced: generation bump at `:1186` precedes the suppress guard; the settle
   hop's gate + `refreshBadges`' unconditional `defer`; `caretBlockID` inside `BlockDecor.State`
   so the equality gate passes the change; the post-edit selection-change call is the belt.
2. **S-1/S-3 — VERIFIED.** The witness counts at the deferral branch itself and cell 1 asserts
   `== 1` beside the oracle's `== 0` (the hollow world is now red-and-loud); cell 2 holds the
   plain-caret road at witness 0 with the synchronous refresh delivering. The depth-counter form
   is behaviour-identical today and closes the re-entrant-`defer` hole by construction. The pin
   drives the REAL pipeline (`h.replace` = `insertText(_:replacementRange:)`). Both cells green
   here. (The one residue is R2-2's visibility NIT.)
3. **R1-3's widen — VERIFIED at all four doors, door AND filer** (the round-1 record verified
   the guards' FACTS; this round verified the SENTENCES, which is where R2-1 fell out). Facts
   re-confirmed: Write `header?.locked` (the bar's own disable fact; nil-header fails open to
   the filer, consistent with S-4's doctrine); Takes/Lenses `projection.sealed` (exactly
   `isPaneLive`'s frozen term minus `structuralInFlight` — correct: the filer does not refuse
   for in-flight structure); Canvas `sealed` (its own container's header); Compare
   `face(for: pane.context)` with both pane-key sites carrying `context: postID`, the S-4
   fail-open stated at the guard, and the filer's `pane.context.isEmpty ? anchorPostID :`
   fallback noted as the one legacy-empty-context shape — covered by fail-open + the filer's
   own refusal. The S-2 discriminating pair holds the peer-vs-anchor judgment per direction and
   was measured red both ways against the rejected board-fact variant (round 1's announced
   measurement; both cells green here).
4. **R1-2 — VERIFIED.** Guard order now `setTakeLabel`'s letter (the op doc's "to the letter"
   true again); the Bool answer consumed at the ONE production caller (`BlockHistoryModel
   .rename`, whole-repo grep: no mobile caller — `App/Variorum` + `Shared` + core only); the
   no-op still writes nothing (`aNoOpRenameWritesNothingAtAll` green in this session's core
   run); outbox capture untouched by the reorder.
5. **R1-2's recorded residual (the PANE's rename door still OPENS its field under a sealed
   note) — RULED: recorded, not fixed this round; a row candidate, named for the closeout.**
   The reasoning, in full so the call is auditable: (a) it is NOT a regression — the pane is a
   new UNIT D door with no shipped instant-refusal shape behind it, where R1-3's four doors
   regressed a shipped keypress refusal; (b) the pane's grammar is UNIFORM under a seal —
   Restore, Unarchive and Put back all refuse only AFTER the click, worded, so gating the
   rename field alone would make the pane internally inconsistent rather than consistent;
   (c) the model has NO seal fact to read — `BlockHistoryModel` holds `Queries.BlockHistory`
   (variant/commit_point observation) and never the container header, so the gate needs a
   query/observation extension or host plumbing across two hosts, a face-design change (Block
   History gaining seal awareness as a whole), not a three-line guard; (d) the ⏎ refusal is now
   correct and IDENTICAL on the changed and unchanged roads (the R1-2 fix's point). If the
   author wants the offer gated, it is a 17-entry / 13u4-sized item: "Block History renders and
   gates on the note's seal (all four act doors, not just rename)" — the closeout should carry
   it as a row with that owner, per the KnownIssues discipline.
6. **R1-4 — VERIFIED.** Both cases worded; the route confirmed (`TrayRefusalCopy` special-cases
   `lockedPost` only, then delegates); the copy's named road is REAL (`BlockHistoryPane` Region
   3 — deleted takes, 30-day clock, Put back), so the sentence promises nothing the app does
   not do; the generic `variantNotFound` wording reads correctly at its other reachable faces.
7. **R1-5 — VERIFIED ACCURATE against the code:** `refreshMergeSheetIfDrifted` dispatches BOTH
   preset roads (the `if !state.isRun` fence retired at UNIT G), so "run on every preset
   confirm" is exactly true, and the new comment names the plain road's actual protection
   without overclaiming.
8. **R1-6 — VERIFIED as built (stays a decision, no pin, per both sides' framing).**
   `QuickEntryBar` bumps its EXISTING counted `@State` (the multiple-asker design's own shape);
   `QuickNoteView`'s new `@State focusRequest = 1` reproduces open-time focus byte-for-byte;
   `updateNSView` assigns `lastFocusRequest` BEFORE `takeFocus()` (no desync/refire); the
   `firstResponder !== view` guard is correct for an NSTextView (no field editor in play) and
   closes the resign/become cycle the caution named.
9. **The two standing reds — NOT re-adjudicated (no new evidence; my targeted runs cannot reach
   them):** row 58's environment red and row 49's load-flake arm stand with round 1's recorded
   adjudications (1-red-2-green isolated).
10. **Process discipline — VERIFIED:** zero `Sync/`, zero `Persistence/`, zero schema, zero
    migrations, zero `Server/` across the six commits (file lists, not records); marker 8
    untouched; no `Co-Authored-By`/`Claude-Session` trailers on any of the seven commits from
    `262ef925` to HEAD; both behavioural reverts and both wrong-variant measurements were
    announced in the findings file BEFORE they ran, with restores re-verified; suite arithmetic
    internally consistent (2889/482 + 8 cells in 2 new suites = 2897/484; + the 2 Compare cells
    = 2899/484, exactly as recorded).

---

## CLEAN BILL (load-bearing things this round specifically checked and found solid)

1. The R1-1 transaction flag's coverage, the oracle's placement at the true forcing boundary,
   and the complete re-enumeration of every `refreshDecorations`/`refreshBadges` reach on the
   current tree — no second in-transaction road exists.
2. The deferral's delivery legs, each read in current code rather than trusted from the sanity
   pass: the pre-guard generation bump, the settle-hop gate, `refreshBadges`' `defer` above its
   bail, `caretBlockID` in the equality-gated state, and the selection-change belt.
3. The four seal guards' FACTS (per-surface, the right one each time) and the three boards'
   door-filer sentence unity; the S-4 fail-open stated where it lives; Compare's empty-context
   legacy shape covered.
4. `renameCommitPoint`'s restored guard order against `setTakeLabel` line by line; the did-write
   answer's single consumer; no mobile caller; I5 untouched (the name family cannot reach
   `commit_point.text`).
5. The four fix-pin suites re-run green in this session (23/23), core SavepointNameTests 12/12,
   and the R1-1 pin's drive verified to be the real delegate pipeline, not a model-poke.
6. The fix range's integrity: exactly six production-touching commits, all reviewed; the notes
   commits carry no code.

## VERDICT

**Counts: 0 BLOCKER · 0 MAJOR · 1 MINOR (R2-1) · 1 NIT (R2-2).** Under the standing ladder
rules **NO ROUND 3 IS OWED** — round 2 surfaced no NEW BLOCKER/MAJOR. The two findings enter
the cross-model flow (to the implementer verbatim; responses back to this reviewer; confirmed
fixes implemented reviewer-side — R2-1 with its equality red-on-old pin, R2-2 pin-free), and
their fixes ride this round without opening another.

---

## FIX PASS (this reviewer, 2026-09-19 — the implementer's ROUND 2 RESPONSES adjudicated; both
findings AGREED, `notes/plans/13u3-ladder-round1-responses.md` §"ROUND 2 RESPONSES", commit
`f43a0061`)

**Every fact the responses added was verified in code before ruling** (the guard binds both
ways): the two gesture-worded sibling doors read at their lines (`shouldChangeText:992`
"unlock it to edit." · `poolDrop:2949` "unlock it to add to it."), the duplicated no-caret
literal at `:3083`/`:3110` with its three shipped test assertions, and R2-2's five-uses count
(whole-module grep — definitions, the one call pair, two same-file flag reads, zero test
callers).

### R2-1 — CONFIRMED; THE FORK RULED: shape (A), the implementer's recommendation adopted with
all three cautions honored (commit `6d4433a1`)

The responses' two new facts changed the finding's FRAME without changing its answer: door ==
filer is NOT a Write-wide rule (two shipped doors are gesture-worded, rightly — their doors
consume the gesture outright, so the door is those gestures' only worded refusal), but THIS
door's gesture has TWO refusal moments — the guard, or the filer under the stale-header race
the fail-open design deliberately leaves — and one gesture must not speak two sentences on
header freshness. Shape (A) restores the exact pre-D words at that keypress and keeps the race
pair honest; the guard's comment now says precisely why this door differs from its two siblings
(caution: the next reader must not "fix" it toward the `:2949` grammar).

- **The fix:** `refuse(operationMessage(OperationError.lockedPost(id: postID)))` — the
  surface's own filer sentence, *"This note is sealed — unlock it first."*
- **Red-on-old, measured pin-first:** `writesDoorAndFilerSpeakOneSealSentence` (the
  equality-form contract — drive the door AND the filer under one seal, `#expect` the two
  sentences equal) — **1 issue on the pre-fix tree, both sentences verbatim in the failure**:
  `(atTheDoor → "This note is sealed — unseal it to change takes or choices.") == (atTheFiler
  → "This note is sealed — unlock it first.")`. Green with the fix.
- **Caution 1 honored:** the pin's doc is SCOPED to this door — it names the two shipped
  gesture-worded siblings as deliberately outside the contract, so no reader widens it into a
  surface-wide law or deletes it as one.
- **Caution 2 honored:** the pin's doc states the future cost — gesture-wording this door later
  means changing `operationMessage`'s shared `lockedPost` case with it, or redding the cell
  honestly.
- **Caution 3 honored:** ONLY the Write cell's expectation changed (to the surface sentence,
  with the reason in place); the other three `SavepointSealedDoorTests` cells keep the registry
  compare their own surfaces' filers genuinely speak.
- **The offered adjacent TAKEN** (same commit): the no-caret sentence hoisted to ONE literal
  (`Self.noCaretToCommit`) consumed by the door and the filer — the same finding class one
  guard up, byte-identical string, the three shipped assertions of it ride unchanged. No pin
  (structural; no behaviour moved).

### R2-2 — CONFIRMED + FIXED (commit `034cdd73`)

`enterStorageEditTransaction` / `exitStorageEditTransaction` AND the computed
`inStorageEditTransaction` are now `private` (file-scoped) — the "one writer" doc is a compiler
fact. The doc names both hazards with the responses' sharper one first (a stray `exit` drives
the depth negative and un-suppresses mid-transaction — R1-1's hole reopened in the one state it
closes). **The completion note's call, taken:** the getter carries the same fence — the risk
lives in the writes, but no out-of-file reader exists and a future one should reopen visibility
deliberately, not find it lying open. No pin (the compile is the enforcement).

### FIX-PASS FINALS

- `SavepointNamingTests.swift`'s SIX suites — **25 cells green** across two targeted runs
  (sealed-door 7 including the new equality pin · rename-door 5 · takes-door 1 ·
  commit-door/face/ask 12).
- `EditorDecorTransactionTests` — **2/2 green** after the visibility change (the pins read the
  DEBUG counters, never the flag — untouched by the fence).
- **The full Mac suite was NOT re-run, deliberately, and here is the judgment stated:** this
  pass's diff is one refusal string at one door, a byte-identical literal hoist, and access
  narrowing with zero out-of-file users — the two `xcodebuild test` runs COMPILED the whole app
  target (a stray reference to the now-private members would be a build error, and there was
  none), the greps swept every shipped assertion of both affected strings (the only pin
  asserting the Write door's sealed sentence is the cell this pass updated; the three no-caret
  assertions compare a byte-identical string; `TutorialWalkTests:2059`'s registry-sentence pin
  is a Takes-board door, untouched), and zero `Sources/` files changed, so core and mobile are
  not owed runs. Round 1's finals (core 1604/174 · Mac 2899/484 with the two recorded reds ·
  mobile 626/106 w/4 known) stand as the phase's suite baseline, +1 Mac cell from this pass.
- Fences: zero `Sync/`, zero `Persistence/`, zero schema, zero migrations, zero `Server/`;
  marker 8; no trailers on either fix commit; every commit pushed as it landed.

**The fix commits, in order:** `6d4433a1` (R2-1: the surface-sentence guard + the scoped
equality pin measured red first + the Write cell's expectation + the literal hoist) →
`034cdd73` (R2-2: the private fence, flag included). 

**ROUND 2 IS CLOSED. NO ROUND 3 IS OWED** — round 2 raised no NEW BLOCKER/MAJOR (1 MINOR ·
1 NIT, both now fixed with the MINOR's red-on-old measured). Standing for the closeout, carried
from this round: the R1-2 pane residual's named row candidate (Block History gaining seal
awareness — a 17-entry/13u4-sized face change, disposition item 5 above), and round 1's open
closeout obligations (the MOBILE PARITY rows · the re-seed list · the SyncSpec §6 annotation).
