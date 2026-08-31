# Batch 4.5c-PHONE — the phone-local half (brief; written 2026-08-31 by the Fable orchestrator)

**What this is:** the phone-local residue of sub-batch 4.5c. The original
4.5c brief (`mobile-round-2-batch-4.5-briefs.md` §3) is SUPERSEDED IN
SCOPE by its own banner — its Mac and `Shared/` work went to 13l (landed,
handback-verified) and 13u (pending; the fence holds). **This batch is
ONLY the five phone-local items below plus one recorded deferral.**
Everything the old brief says about `Shared/EditorBrain/`, the fan
fence's source, the O(N²) twin, the gap fence's Mac face, the empty-block
plan, `CrossBlockRefusal`, and the identity-audit hoist is **13u's — do
not touch any of it** (reading is fine).

**⚠️ Line references below are FINDING-TIME (2026-08-22/23) and the tree
has moved — re-locate every site by symbol before editing; if a symbol is
gone or the mechanism no longer holds, VERIFY and record the finding as
stale with evidence rather than forcing a fix.**

**Read in full, yourself, before building:** `CLAUDE.md` ·
`notes/MobileSoul.md` §2–§5 · `mobile-round-2.md` §63 (the routed-out
table this batch executes: "Routed out" rows 1–4), §45's batch-3 section
(the B45-2 finding's family), §18 NIT 8 (`displaySlot`'s structural
disarm — the other half of B45-2's room), §31 (the four-case refusal
table — context for the deferral), §67 (13u item 5's semantics ruling —
why the deferral is right) · the 4.5c brief's supersession banner
(`mobile-round-2-batch-4.5-briefs.md` §3, the ⚠ block only) · the code:
`MobileEditorViewModel.swift` (the `displaySlot`/`slots` room + the
refusal one-liner), `MobileLivenessAuthority.swift`,
`MobileShellView.swift`, `MobileWriteView.swift`, `MobileLenses.swift`
(the Rename Lens confirm), `MobileCrossBlockEditTests.swift` (the stale
comment), `Shared/RecoveryCopy.swift`'s `DeletionRefusal` (READ-only —
fenced; you call it, never edit it).

## Deliverables, in order

1. **B45-2 — the `displaySlot` / `slots[i]` coupling becomes
   STRUCTURALLY safe** (finding-time site `MobileEditorViewModel.swift:1146`).
   Today an out-of-range read during the crystallization window is
   avoided only by caller accident; batch 7's reorder-takes (PR8) walks
   straight into this room next. Make the safety structural (bounds-check
   at the read, or re-derive the slot from identity rather than index —
   trace the room first and pick the minimal correct shape; §18 NIT 8
   already ruled `displaySlot` gets the structural disarm), and **pin the
   shape a REORDER would produce** — the exact stale-index pattern
   batch 7 will create — red-on-old against the accidental-safety code.
2. **The live editor over a tombstone — the REAL fix, at the liveness
   seam.** Deleting a note from the Library leaves the OTHER tab stack's
   editor live over the tombstoned note (§63: the §49-filed `onDeleted`
   fix reaches nothing — the stale editor is not in that stack). Fix
   where liveness is decided: the authority/host refuses or relinquishes
   the pen for a tombstoned note (`MobileLivenessAuthority` /
   `MobileShellView` / `MobileWriteView` — trace which seam owns it).
   Respect the A2 token discipline (entry + post-suspension guards —
   `MobileLivenessTests` is the harness precedent). Red-on-old: delete
   the note from the Library while its editor is live in the note stack;
   the editor must stop accepting keystrokes into the tombstone (drive
   through the real gate, `typeEdit`-style, not the view model's number).
3. **`MobileLenses` "Rename Lens" (finding-time :419) — SETTLE OR
   RECORD.** The candidate sixth confirm-reads-its-subject-back site
   (§63): a computed binding over `@State` read synchronously inside the
   action; the probe showed the handler runs before the write-back on the
   reachable road, but a genuine tap could not be driven, so it is NOT
   PROVEN immune. Either settle it with a real driven tap (the 6c/6b
   confirm harness — `presenting:`-style or the alert-action driver —
   may now reach it where the earlier probe could not), or convert the
   site to the `presenting:` shape the 4.5b BLOCKER class ruled (which
   moots the question), or record it unsettled with the new evidence.
   Pick ONE, say why.
4. **One-liner:** `MobileEditorViewModel.deleteNoteRefusal`
   (finding-time :958) → `DeletionRefusal.words(_:act:)` — the shared
   deletion vocabulary, ending the last `String(describing:)` fallback in
   that method's family (A1-18's 4.5c share). Pin: the refusal speaks the
   shared sentence.
5. **One-liner:** the stale test comment at
   `MobileCrossBlockEditTests.swift` (finding-time :598) asserting
   *"there is no undo door on this phone yet"* — false since M20
   (batch 4). Correct the comment; zero behaviour change.
6. **THE DEFERRAL, RECORDED (build nothing):** the A7/#34 seam carves —
   backspace-to-join at a block seam — stay UNWIRED on the phone, BY
   THIS RULING: 13u item 5 rules the cross-block gesture semantics for
   both platforms (her fence: *"the phone does not invent its own
   answer"*), and wiring a join gesture now would either harden a refusal
   13u opens or invent semantics. Write the deferral into your record's
   own section (one paragraph: what stays unwired, why, and that the
   post-13u-merge session inherits a DECISION, not a discovery — the #94
   pattern). This is a RECORD deliverable.

## Pins & discipline

Real mounted surfaces via `accessibilityActivate()` where a door is
driven; the editor items drive the REAL gate (the delegate road —
`UITextView.deleteBackward()`/`replace(_:withText:)` bypass it, §5.1's
trap). Red-on-old by behavioural revert, output QUOTED, naming
production or fixture every time; restore reverts from a pre-revert copy,
never `git checkout --` on a file this batch edits. A pin whose red needs
a state the product cannot produce is hollow — say so. PROVISIONALs and
PENDING claims in `notes/plans/mobile-batch-45c-phone-record.md`, written
as you go. STOP AND REPORT any item that seems to need `Sources/`,
`App/Variorum/Shared/`, `App/Variorum/Variorum/`, or `EditorBrain/` —
item 2 especially: if the liveness fix wants a fenced file, stop there
and report the trace.

**The planVisibleTakeEdit tripwire (standing):** after your work, `git
diff -- '*.swift' | grep planVisibleTakeEdit` must be ZERO Swift hits —
and if any item's trace runs through that method, STOP AND REPORT (13u
owns its neighbourhood).

## Environment (binding)

Own fresh named simulator (iPhone 17 family, newest iOS 26 runtime —
16-series sims are iOS 18.3, INVALID), `ApplicationAccessibilityEnabled`
armed and read back `1`, private `-derivedDataPath` under your session
scratchpad, simulator DELETED at the end. Full mobile suite at the end
from `App/Variorum/`; QUOTE the exact final line (baseline: **667/99 green with
2 known issues** — batch 9's unit close, recorded in
`mobile-batch-9-cold-review.md`'s UNIT CLOSED section). The load-flaky perf pin
(`MobilePerfWalkTests.typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k`)
reds → isolated re-run, report both. A runner restart mid-suite has been
observed twice under load — re-run and report both, never silently.
Never sweep `Package.resolved`; never touch the real store; never quit
the live Mac app; no Release builds, installs, or pushes;
pathspec-limited commits with the standing trailer. R28: your cold
review dispatches from your report.
