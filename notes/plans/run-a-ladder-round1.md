# RUN A — LADDER ROUND 1 (cold review, Fable; 2026-09-21)

**Reviewer:** `fable-reviewer`, zero implementation context, `notes/REVIEW_PROMPT.md` verbatim.
**Diff under review:** `50e581fa..HEAD` (batches A1 · A2 · A3 — 17b, 17l items 1–4/6–7, 17n, 17m).
**Anchor:** `notes/plans/run-a-custody-text-loss.md` (ledger rows 1–16, three batch records,
three adjudications) + `notes/plans/phase-17-standing-fixes.md` §§17b/17l/17m/17n.

**Written incrementally per `notes/SessionResiliencyProtocol.md` — findings land here as they
are traced; the round's final list is the FINDINGS section when the STATUS line below says
COMPLETE.**

**STATUS: COMPLETE — round 1's findings are final.** Production diff read whole (core + app +
tests + notes); all 16 ledger rows checked against their pins and the code; run by my own hands:
the FULL core suite (**1639 tests in 177 suites — ALL GREEN**, matching the record) and the two
new core suites in isolation (`ContentReplacementRedoTests` + `PromotePicksArchivedPickTests`,
8/2 green). Zero commit trailers across the run's 57 commits (grep-verified). Findings: **1
MAJOR · 1 MINOR · 2 NIT**; six suspicions traced to NOT-findings and recorded below.

---

## FINDINGS (severity-ranked)

### [MAJOR] · App/Variorum/Shared/AppSession.swift:717–721 (`QuickNotePark.park`) + App/Variorum/Variorum/VariorumAppDelegate.swift:84/93/118 · The 1b rider's "a second consecutive ⌘Q always proceeds" is FALSE whenever the pad is OPEN — every ⌘Q re-parks and re-arms the one-shot, so a store that keeps refusing declines the quit indefinitely

**What's wrong.** The recorded ruling (run plan, ROW 7 RULING binding 4: *"a second consecutive
⌘Q always proceeds"*; QUESTIONS #137(c), the author-facing text: *"Press ⌘Q again and it quits,
whatever the store is doing — you can never be trapped by a store that will not take it"*) is
violated on exactly the road the pin describes as covered.

**The mechanism, traced end to end.** With the pad OPEN and the store refusing:
1. ⌘Q #1 → `applicationShouldTerminate` → registry non-empty (the pad's quit token is
   registered) → `Task { … await registry.finalizeAll() … }` → the pad's closure runs
   `pad.finalizeAtQuit()` = `take()` (QuickNoteView.swift:137, :159).
2. `take()`'s `.refused` arm calls `session.quickNotePark.park(text:…)`
   (QuickNoteView.swift:216), and `park()` sets `held` **and unconditionally
   `declineSpent = false`** (AppSession.swift:720).
3. `reply(toApplicationShouldTerminate: !declineQuitIfACaptureStands())` →
   `declineQuitOnce()` → held ≠ nil, declineSpent == false → **declined** (spent = true). Correct.
4. ⌘Q #2 → the SAME path: `finalizeAll()` runs again → `take()` refused again → `park()` again →
   **`declineSpent` reset to false** → `declineQuitOnce()` returns true again → **declined
   again**. And again, on every subsequent ⌘Q, for as long as the store refuses.

The one-shot only ever works on the pad-CLOSED road (registry empty → the early
`.terminateNow` arm consults the park without re-running `take()`, so the spent flag survives
to the second press). Her escape with the pad open is undiscoverable: close the pad first
(which parks and re-arms once more), then press ⌘Q twice.

**Why the pins missed it.** `QuickNoteParkTests.aRefusedCaptureAtQuitDeclinesOnceAndThenProceeds`
(and the delegate half, `theQuitDoorsOwnDecisionDeclinesOnceAndSpeaks`) call `finalizeAtQuit()`
ONCE and then `declineQuitOnce()` twice back-to-back — they never re-run the quit road's
`finalizeAll()` between the two presses, which is what the real second ⌘Q does. The pins prove
the one-shot primitive; the integrated door defeats it.

**Red-on-current pin (the fix's red-on-old).** Stage the real second press:
`finalizeAtQuit()` → `declineQuitOnce()` (true) → `finalizeAtQuit()` again (the second ⌘Q's
`finalizeAll`) → expect `declineQuitOnce()` == **false** per binding 4. On the shipped code it
returns true.

**Proposed fix (narrowest honest one, matching the ruling's letter).** `park()` re-arms the
one-shot only when a refusal is ARISING — i.e. reset `declineSpent = false` only when `held`
was nil at park time (a resolution — `.filed`/`.nothingToFile` — already clears it via
`clear()`, so "a refusal resolved and later re-arising re-arms" is preserved byte-exactly).
Re-parking over a standing capture keeps the spent flag, so the second ⌘Q proceeds with the
capture still parked in memory until the process exits (the ruled memory-only cost).

**Severity call.** MAJOR, not BLOCKER: no data loss (the failure direction is over-protective),
no I/P/S invariant touched, and an escape road exists — but it contradicts the recorded ruling's
letter AND the sentence already written to the author's ratify list (#137(c)), which must not
ship false.

### [MINOR] · App/Variorum/VariorumMobile/Features/Write/MobileCommentsSheetView.swift:110–124 (`submitDraft`) · The stated "only the submitted text is cleared" discipline is not what the code does — keystrokes during the write leave the LANDED text in the field, so the next Add re-posts it

**The mechanism.** The new code clears the field only when `self.draftField.text == text`
(byte-equal to the submitted snapshot). If she types during the write's flight, the guard fails
and NOTHING is cleared — the field then holds `submitted + tail` although `submitted` already
landed as a comment row. The next Add posts `submitted + tail` → the store holds two comments
sharing the same leading paragraph. The pad this comment cites as the adopted shape
(`QuickNotePad.take`, QuickNoteView.swift:196–199) strips exactly the submitted prefix and keeps
the tail; the doc comment here (*"only the submitted text is cleared — the pad's discipline"*)
claims that behavior while the code implements clear-all-or-nothing.

**Pinnable.** Delay the write via the controller's seam, type a tail mid-flight, land it: field
should read the tail alone; the shipped code leaves `submitted + tail`. Red on current.

**Proposed fix.** On a landed submit, if the field still has `text` as a strict prefix, remove
that prefix (keep the tail + hide/show placeholder accordingly); else leave it alone. Or —
cheaper and honest — fix the comment to say what the code does and accept the corner (the
conservative direction never loses text; the double-post needs her to press Add again on a field
she can see). Either resolution is acceptable; the comment and the code must stop disagreeing.

### [NIT] · Sources/VariorumCore/Operations/Operations+NoteVersions.swift:288 + Operations+Container.swift:411 · `clearRedoFuture()` runs outside the write transaction — a caller composing these ops inside a larger transaction would clear the future even on a later rollback

**The mechanism (traced, but currently unreachable).** Both calls sit after
`try database.write { … }` returns, so a refusal inside the op leaves the future intact —
correct today, since every caller invokes these ops stand-alone. But unlike `register` (which
also runs post-write in the same pattern), a FUTURE compound that calls `restoreNoteVersion` /
`deleteContainer` as a leg and then throws would have cleared the future for a write that rolled
back. No production caller does this today (checked every `deleteContainer` call site:
VersionActs:71, NoteDeletion:180, SnippetsSurface:363, TutorialSeeder:241/244 — all standalone),
so no red-on-old pin exists — recorded as a hazard note, not a defect. The existing
registration machinery has the same property (the run plan's own R1-10 precedent records the
class), so this is at most a comment's worth of work.

### [NIT] · App/Variorum/Shared/AppSession.swift:718 (`QuickNotePark.park`) · The whitespace guard is dead code

`take()` only reaches `.refused` after `QuickNoteMint.mints(capture.text)` passed, so
`park(text:…)` is never called with whitespace-only text; the
`guard !text.trimmingCharacters…isEmpty else { return }` can't fire from the one call site. If
it ever DID fire it would silently violate binding 1's "a refused capture is parked" — a guard
that protects nothing but could someday eat a capture is better deleted or turned into an
assertion. No pin possible (unreachable); cleanliness only.

---

## FINDINGS THAT DID NOT SURVIVE THEIR OWN TRACE (recorded so round 2 doesn't re-derive them)

- **`AppleRelinkModel.confirm` re-checks neither posture nor `followPending` at the act** —
  traced through every staging I could construct: a Castle entered elsewhere mid-consent is
  refused by the server's key proof (this device's custody then holds a stale master —
  `aWriteTheServersProofRefusesLeavesTheVaultsRevisionWhereItWas` is exactly this arm); a
  Replace-All-Keys completed on THIS device mid-consent leaves custody holding the new master, and
  re-landing it under the re-read key is the heal's correct act; entering Castle from THIS window
  is fenced by the open sheet. No reachable wrong-write world found; the consented-id guard covers
  the key axis. Not a finding.
- **`applyPendingIfClean` restoring the STALE deferred value could clobber a newer pending
  projection** — the pending value is only ever a MARKER; every application path re-reads fresh
  from the store before applying, so restoring the older photograph changes nothing but the retry.
  Not a finding.
- **The seeder latch's static state** — `SampleLibrarySeeder` is `@MainActor`; the check-then-insert
  has no suspension between test and mutation; waiters are always resumed by the holder's `defer`;
  the latch key is (session, book) so parallel test worlds never serialize. Not a finding.
- **`followAsksNothing` refactor** — byte-equivalent to the old model-side predicate
  (`isConnectVariant` = `.connectLibrary`, `isAlwaysAskVariant` = `.alwaysAskRetiredWord`,
  `isChangeNoticeVariant` = `notice.isChangeNotice`; verified against `50e581fa`'s
  PostureFollowModel:63–74). Not a finding.
- **Root-presenter start** — `PostureSwitchSheet` runs `.task { await model.start() }` itself
  (ProtectionPane.swift:1334), so the notice-bar presenter starts the ceremony exactly as the
  pane's does. Not a finding.
- **`ensure` marking on tombstone-decline also silences the LAUNCH seeder on that device** —
  that is the desired direction (the deletion honored at launch too), not a hole; the
  cross-device launch remainder is the new KnownIssues row (owner 17e, #138(f)) and is correctly
  out of scope here.

## THE FINAL CALLS (cross-model flow; the implementer's responses at `f6d7b960`) + THE FIX PASS

**1 · MAJOR (the 1b one-shot re-armed by every ⌘Q) — CONFIRMED; implementer AGREES.** Fixed at
`bfdd3bd6`: `QuickNotePark.park` re-arms `declineSpent` only when parking into an EMPTY park (a
refusal ARISING); a re-park over a standing capture keeps the spent flag and still ASSIGNS
`held` (the implementer's note — the newest words win). `clear()` resets the flag, so binding
4's "resolved then re-arising re-arms" holds byte-exactly, and #137(c)'s sentence is now true
on the pad-open road. Pin: `QuickNoteParkTests.theSecondQuitsOwnReRefusalDoesNotReArmTheDecline`
— the integrated second press (finalize → decline → finalize again → decline must read false),
plus the re-park-assigns arm, the capture-stays-parked arm, and the resolution-re-arms arm.
Green with the fix: QuickNoteParkTests **6/6**.

**REVERT R-L1 ANNOUNCED (from the committed `bfdd3bd6`):** put the unconditional
`declineSpent = false` back in `park()` (the pre-fix body) in the working tree and run
`QuickNoteParkTests` — expected: the new pin RED at its second-decline expectation (the decline
reads true again), the five shipped pins GREEN (they never re-ran the quit road, which is
exactly how the defect shipped). Restore by `git checkout --` from the repo root; result
recorded below when written.

**2 · MINOR (the comments sheet's clear discipline) — SPLIT: the behaviour change is DISMISSED
AS WRONG; the comment fix is CONFIRMED.** I re-checked the implementer's falsification at both
sites myself: `QuickNotePad.take` (QuickNoteView.swift:199 — `if text == submitted { text = ""
… }`) is the SAME all-or-nothing gate, and the family's original records the rule deliberately
(`QuickEntryBar.swift:113–121`: *"clearing them wholesale would lose them for the sake of
tidiness. She sees them still there, and a second ⏎ makes them a second note."*). My finding's
premise — that the pad strips the submitted prefix — was wrong (I conflated it with
`MobileQuickNote`'s frozen-prefix machinery, which is a different mechanism on a different
surface). The double-post corner is therefore the capture family's RECORDED consequence, not an
oversight; prefix-stripping the comment door alone would fork it from the three capture doors
(the forked-brains class), and changing the family's rule is the author's call, not a ladder
fix. What remains true is that the sheet's doc comment claims a prefix discipline no door has —
fixed to the bar's own recorded rule (comment-only, no pin owed).

**3 · NIT (clearRedoFuture outside the transaction) — CONFIRMED as a comment-class hazard note;
implementer AGREES.** One sentence at each call site naming the R1-10 class (a compound leg's
clear survives its body's rollback — recorded, accepted, no caller composes it today). No pin
(nothing red-on-old exists).

**4 · NIT (the dead whitespace guard) — CONFIRMED; implementer AGREES.** The silent early-out
replaced with a loud debug assertion + unconditional park: the one call site fires only after
`QuickNoteMint.mints` passed, and the only thing the silent return could ever do is eat a
refused capture (binding 1 inverted). No pin (the arm is unreachable from production code).

*(Fix-pass suite lines land at the bottom of this section when the pass closes.)*

## CLEAN BILL — load-bearing things specifically checked and found solid

1. **Core suite, my own hands:** `swift test` → **1639 tests in 177 suites, ALL GREEN** — the
   record's claim exactly. The two new core suites isolated: 8 tests in 2 suites, green.
2. **P5 (`promotePicks`)** — the fix traced through all four livePick × carryFans arms plus the
   dangling-chosen corner: I10-at-birth is impossible through the pick leg on every arm, the copy
   carries exactly what the column showed, `sourceChosenID`'s duplicate semantics are preserved,
   and the pins drive the archived-pick world both ways (chosen-only and carry-fans) plus the
   live-pick and unknown-pick guards.
3. **P6 (`clearRedoFuture`)** — AppSpec §9's rule applied at exactly the two recovery-door acts;
   every production `deleteContainer` call site checked (VersionActs:71, NoteDeletion:180,
   SnippetsSurface:363, TutorialSeeder:241/244) — all are genuine new structural acts and none
   sits inside an undo-inverse or redo-reapply closure, so undo↔redo ping-pong is untouched; the
   clear runs post-write so a refusal changes nothing; the guard pin proves the undo history is
   untouched; both rewritten pins (`RedoStackTests` / `SmartConversionTests`) had genuinely staged
   their state via the now-outlawed behavior and correctly moved to below-ops tombstones; the
   undo-side residue is measured, pinned as documented behaviour, and owned (17e, #136(b)).
4. **P7 (flush-first branches)** — all six doors verified riding `AppSession.runCopying`
   (branchTake, branchTakeRevealed both hosts, branchIntoColumn, addWriteColumn,
   replaceColumnWithNewWrite, writeNewTakesEverywhere); the sweep table's SAFE verdicts
   spot-checked (`newBlankVariant` mints `''`; `mintCaretTake` always flushed; the phone's
   `branchDisplayed` already flushed; WriteTakesPanel's growth door calls `model.branchTake`);
   `flushExistingAutosave` flushes the existing coordinator and never mints one (13l R2-1 kept);
   the negative half is its own pin.
5. **P4 (comments draft)** — clear-only-on-landed with the edit target surviving; the
   latch-turned-away arm returns false with no refusal spoken; the pins drive the real UIKit
   door (mounted sheet, key window, a real seal). The one corner that remains is the MINOR above.
6. **P14 (quick-note read failure)** — identity owned first, the thrown read distinguished from
   the empty result through the endorsed defaulted seam, the double-mint killed at
   `armMintClock`'s own guard, and the `.saved` + `handoffHold` hold matching the in-file A1-19
   precedent; the ordinary road guarded by its own pin.
7. **P36** — the marker restore matches its two sibling guards; restoring the stale value is
   safe because every application path re-reads fresh before applying.
8. **Row 7 (the park, minus the MAJOR)** — refused-captures-only with the guard pin; restore
   clears in the same breath (no ghost, idempotent); `.filed`/`.nothingToFile` clear; the close
   road's false sentence replaced with one that is true; parked from `submitted`, never `text`.
9. **Row 8 (seeder latch + the decision that outlives the tombstone)** — the latch is
   `@MainActor`-isolated with no suspension between check and insert, keyed (session, book),
   waiters always resumed by the holder's `defer`, the deciding re-discovery INSIDE the latch;
   the purge-consult substitution's premise verified myself at
   `Server/supabase/10_phase13j_purge.sql` (the ledger is ids-only by design — the entry's named
   consult is unbuildable without a disclosure regression); the mark's write leaf injected in
   every test world that reaches the roads (grep across both test targets); the launch-seeder
   residual correctly recorded, not fixed, with owner 17e and her options at #138(f).
10. **Row 9 (drill escrow leg)** — the override touches only the throwaway store-id's item; the
    real-scope inertness pin (corner 47) stands beside it; the her-Mac negative honestly framed
    as corroboration (a flagless `security` search cannot see a synchronizable item) with
    `migrated2a = 1` as the strong answer.
11. **Row 10 (her four wordings)** — all four landed as constants with pins on BOTH platforms;
    the ledger-46 order pinned as an order; `followAsksNothing` is byte-equivalent to the old
    model predicate (checked against `50e581fa`'s PostureFollowModel:63–74); the Chapter 7 pin
    reads the shipped resource itself.
12. **Row 11 (root presenter)** — two presenters, one model, host decided once at `openSwitch`;
    `PostureSwitchSheet` runs `.task { await model.start() }` itself so the root-hosted ceremony
    starts exactly as the pane-hosted one; the phone binds `activeSwitch` directly and is
    untouched by the host machinery; the count cannot go negative.
13. **Row 12 (*(0 of 0)*)** — the gate is `total > 0` (first window), never done==0; the
    one-brain refactor byte-preserves all four sheets' arms (minting/picking-up kept as the
    parameter); the grep pin bans a fifth copy.
14. **Row 13** — NIT-N8's face re-verified with the PANE mounted at 13u4's 720×552 and read two
    honest ways; `WordsCeremony.regenerated` set only after a generate that succeeded; the tail
    rides only the instance `wording` (the post-screens failure set) with the typed-words guard.
15. **Row 14 (the floor)** — `passphraseFloor` named once; the call-site sweep run myself
    (`setPassphrase`/`setLocalPassphrase`/`validated` across Shared + both apps): every SETTING
    door floors, and the two deliberate negatives (the unlock primitive; the migration's
    confirm re-wrap) are pinned as negatives.
16. **Row 15 (phrase transit)** — `VaultTie.make`'s arms traced; `unreadableReason` set only in
    `.newerFormat`; `PhraseOffer.take` refuses before the mint with nothing on the store or key
    file; the passphrase door already refused on `.couldNotCheck` before the phrase half; arms
    1–2 green-either-side as the row's own verification criterion, arm 3 red-on-old.
17. **Row 16 (the re-link door)** — reads and never mints (R1 discriminated exactly that);
    the consented-id guard at the act (R2 discriminated exactly that); all five refusal arms
    leave the vault's revision unmoved, pinned over the REAL `EncryptionSession` + RPC emulation
    enforcing proof, CAS and whole-row replace; `relandAppleHeldCopy` read myself — CAS on the
    fetched revision + `KeyProof.wireToken(master:)`, no mint anywhere; the posture/follow races
    at confirm time are backstopped by the server's key proof (traced; recorded in the
    not-findings list); the pane's render gate matches P-2; `KeyActPassphrase` is a verbatim
    hoist (old `verifyPassphrase` compared line-by-line) and the ceremony's wording is
    preserved through its own `lastError`; keeping the `healAppleHeldCopy` name with two callers
    is CONCURRED with (the doc is widened, authorization lives at the callers, and a rename
    churns four shipped pins for a word — the adjudication's invitation considered, declined).
18. **Fences** — zero `Sources/VariorumCore/Sync/` lines in the combined diff (the core diff is
    Operations+Container/NoteVersions/Versions + UndoStack only); zero schema, marker 8; nothing
    tracks word-level change, nothing copies text across entities outside the deliberate copy
    ops, and no new road scales with corpus size (the latch's re-discovery is one indexed read
    per seed act).
19. **Records** — QUESTIONS #136–#139 present and accurate to the code (with the one exception
    the MAJOR names in #137(c)); the two new KnownIssues rows carry owners (17e); the PL-37
    parity row; the FAQ + book edits match their batch records; `run-a-screens/` gitignored;
    test-count arithmetic consistent across all three batches (core +8/+2, Mac +14/+3 → +10/0 →
    +8/+1, mobile +6/+2 → +3/0 → 0); **zero commit trailers** across the run's 57 commits.
