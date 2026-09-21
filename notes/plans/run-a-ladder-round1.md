# RUN A — LADDER ROUND 1 (cold review, Fable; 2026-09-21)

**Reviewer:** `fable-reviewer`, zero implementation context, `notes/REVIEW_PROMPT.md` verbatim.
**Diff under review:** `50e581fa..HEAD` (batches A1 · A2 · A3 — 17b, 17l items 1–4/6–7, 17n, 17m).
**Anchor:** `notes/plans/run-a-custody-text-loss.md` (ledger rows 1–16, three batch records,
three adjudications) + `notes/plans/phase-17-standing-fixes.md` §§17b/17l/17m/17n.

**Written incrementally per `notes/SessionResiliencyProtocol.md` — findings land here as they
are traced; the round's final list is the FINDINGS section when the STATUS line below says
COMPLETE.**

**STATUS: IN PROGRESS — production diff read whole; findings below are traced and final unless
marked; targeted-suite verification and the remaining test-file reads still running.**

---

## FINDINGS (severity-ranked)

### [MAJOR] · App/Variorum/Shared/AppSession.swift:132–136 (`QuickNotePark.park`) + App/Variorum/Variorum/VariorumAppDelegate.swift:80–92 · The 1b rider's "a second consecutive ⌘Q always proceeds" is FALSE whenever the pad is OPEN — every ⌘Q re-parks and re-arms the one-shot, so a store that keeps refusing declines the quit indefinitely

**What's wrong.** The recorded ruling (run plan, ROW 7 RULING binding 4: *"a second consecutive
⌘Q always proceeds"*; QUESTIONS #137(c), the author-facing text: *"Press ⌘Q again and it quits,
whatever the store is doing — you can never be trapped by a store that will not take it"*) is
violated on exactly the road the pin describes as covered.

**The mechanism, traced end to end.** With the pad OPEN and the store refusing:
1. ⌘Q #1 → `applicationShouldTerminate` → registry non-empty (the pad's quit token is
   registered) → `Task { … await registry.finalizeAll() … }` → the pad's closure runs
   `pad.finalizeAtQuit()` = `take()` (QuickNoteView.swift:137, :159).
2. `take()`'s `.refused` arm calls `session.quickNotePark.park(text:…)`
   (QuickNoteView.swift:~208), and `park()` sets `held` **and unconditionally
   `declineSpent = false`** (AppSession.swift:135).
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

### [NIT] · App/Variorum/Shared/AppSession.swift:133 (`QuickNotePark.park`) · The whitespace guard is dead code

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

## CLEAN BILL — checked and found solid

*(final list in the round's closing report)*
