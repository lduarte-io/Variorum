# Batch 9 — THE ⋯ VOCABULARY + TEXT SELECTION (brief; written 2026-08-31 by the Fable orchestrator)

**Her list, verbatim (2026-08-23, `notes/author-reports/2026-08-23-device-walk-and-product-asks.md`):**

> *"structural undo should be added to the ... menu (and structural redo
> needs to be an option as well). i want it easy to access. I also think
> that take history should move into the three ... menu on each take
> rather than the main three dot menu. i also don't think takes needs to
> be an option on the three dot menu, it's already the middle bar. i also
> only see merge with previous rather than a multi merge option? or do we
> need to add multi merge on mobile still? or a select and then merge?
> idk, let's think about that three dots menu a little more."*

> *"right now it is genuinely hard to copy and paste text because the
> copying and dragging up and down doesn't work correctly, holding it
> down makes you scroll upwards, the exact opposite. so that needs to be
> fixed."* (`mobile-round-2.md` §67, routed to batch 9)

**⚠️ HER PHONE RUNS THE STALE 2026-08-21 BUILD (R30).** Her asks describe
a tree that predates batch 4's M20 and everything since — so deliverable 1
is VERIFY-FIRST: some of her list may already be built and simply never
seen by her. A verified already-built item is recorded as such (a
dismissal with evidence is a good outcome), never rebuilt.

**Read in full, yourself, before building:** `CLAUDE.md` ·
`notes/MobileSoul.md` §2–§5 · `mobile-round-2.md` §67–§68 + the batch map
banner · `notes/plans/mobile-batch-6b-record.md` (the tray landed on the
same menus you touch) · the code: `MobileBlockMenu.swift` (the block ⋯ —
its row set and `includeTakes` split), `MobileNoteActions.swift` (the
note ⋯ — the structural Undo/Redo doors, `topLabel`/`topRedoLabel`),
`MobileTakesBrowser.swift` + `MobileTakesBrowserView.swift` (the per-take
⋯ that already exists: label · lock/unlock · archive · delete),
`MobileBlockHistory.swift` + `MobileBlockHistorySheetView.swift`,
`MobileKeyboardBar.swift` (the ⋯'s host; `includeTakes: true` caller),
`MobileEditMenuSeam.swift` (`includeTakes: false` caller), and — for
deliverable 5's trace — `MobileEditorTextView.swift` and whatever the
trace demands.

## Deliverables

1. **VERIFY-FIRST INVENTORY (record it):** the current row sets of the
   note ⋯, the block ⋯ (both `includeTakes` arms), and the per-take ⋯,
   each mapped against her four asks. Structural Undo/Redo already live
   in the note ⋯ with live `topLabel`/`topRedoLabel` (M20, batch 4) —
   verify they render and act, verify "easy to access" honestly (how many
   taps from the editor), and record that her ask predates the build she
   is running.
2. **"Takes…" LEAVES the block ⋯** — her letter: *"it's already the
   middle bar."* Remove the `includeTakes: true` row (and then the
   parameter if nothing else uses the split — read both callers first).
   The middle bar remains the takes door; drive it in a pin so removing
   the ⋯ row cannot orphan the capability (P-2: the door that stays must
   really act).
3. **Take history moves to the per-take ⋯** — each take card's existing ⋯
   gains a `History…` row opening the SAME Block History sheet
   (`MobileBlockHistory`) — focused/scrolled to that take's savepoint run
   if the sheet's existing expansion machinery reaches it cheaply (it
   expands the focused take today; read it first). The main block ⋯'s
   `Block History…` row is REMOVED (her "move", honored as written).
   Verify nothing is orphaned: every Block History region (savepoints ·
   archived · deleted · came-from) must remain reachable through the
   per-take door + 6b's tray segments — state the road per region in the
   record. PROVISIONAL: the removal and the per-take word both go to her
   bundle.
4. **THE MERGE-VOCABULARY PROPOSAL — PROPOSE-ONLY, NOTHING BUILT.** Her
   question verbatim above. Write a short proposal section in your record
   for her sitting bundle: what exists today (Merge with Previous; the C5
   carry-all fanned default; the Mac's 13e ⌘-click merge-selection
   precedent), what batch 7 will add (PR20 block multi-select — the
   natural select-then-merge road), and 2–3 shaped options with a
   recommendation. NOTHING is built from this deliverable.
5. **🟠 THE TEXT-SELECTION DEFECT — TRACE THE MECHANISM FIRST.** Her
   report verbatim above (selection drag; auto-scroll runs the WRONG
   direction). Reproduce it (simulator long-press selection drag toward
   an edge; if the simulator cannot reproduce it, say so and trace by
   reading), trace the concrete mechanism (which scroll adjustment fires,
   who owns it — UITextView's own selection auto-scroll vs the app's
   keyboard-avoidance / contentInset / scroll code), and fix it
   PHONE-LOCAL with a red-on-old where the mechanism is pinnable — an
   un-pinnable gesture fix is labelled honestly with what WAS measured.
   **It is phone input-handling until proven otherwise: STOP AND REPORT
   if the trace leads into `App/Variorum/Shared/EditorBrain/` or any
   fenced file — do not fix it there.**
6. **THE commitNow RIDER (carried):** if any surface you touch gains its
   own Commit button, that door takes the `MobileWriteLatch` the same
   day. Not otherwise your scope.

## Pins & discipline

Real mounted surfaces driven through `accessibilityActivate()`; menu rows
via their `UIMenu` actions where drivable (a SwiftUI `Menu`'s rows are
not — say which you drove). Red-on-old by behavioural revert with output
quoted, naming what was reverted, production or fixture, every time.
Removals get ABSENCE pins over populated surfaces (never vacuous).
PROVISIONALs recorded in `notes/plans/mobile-batch-9-record.md`, written
as you go; claims written before final verification are marked PENDING.
STOP AND REPORT any deliverable needing `Sources/`,
`App/Variorum/Shared/`, `App/Variorum/Variorum/`, or `EditorBrain/`.

## Environment (binding)

As every batch: own fresh named simulator (iPhone 17 family, newest iOS
26 runtime; every 16-series sim is iOS 18.3 = invalid), arm
`ApplicationAccessibilityEnabled` and read it back `1`, private
`-derivedDataPath` under your session scratchpad, simulator deleted at
the end; full mobile suite at the end from `App/Variorum/`, exact final
line quoted (baseline: **661/98 green with 2 known issues** — the 6b
unit's close, recorded in `mobile-batch-6b-cold-review.md`'s UNIT CLOSED
section).
`MobilePerfWalkTests.typingAtTheViewportHoldsThePerKeystrokeBudgetAt100k`
is the known load-flaky pin — isolated re-run + report both if it reds.
Never sweep `Package.resolved`; never touch the real store; never quit
the live Mac app; no Release builds, installs, or pushes;
pathspec-limited commits with the standing trailer. R28: your cold review
dispatches from your report.
