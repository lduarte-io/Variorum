# VM-24 — An unwarned edit whose report TextKit widens snaps back on the phone

**STATUS: NOT STARTED. Kickoff written 2026-11-19 at VM-78's hand-over. This run starts only after all four
wave-1 mobile runs (VM-47, VM-55, VM-64, VM-78) have merged to `main`; the stage coordinator of that window
launches it. Shape: `/architect-phase vm-24`. Ticket: VM-24 (team VM, project "Mobile — the catch-up & launch").**

This file is a kickoff and a set of pointers. It is NOT a design: the fix's shape is the architect's work, with
her rulings where product behavior is touched.

## Kickoff message

> You are starting **VM-24** as its own run, under the architect shape, on `main` as it stands after wave 1 of
> the mobile catch-up has merged.
>
> **Her decision that made this run (2026-11-19).** Asked where VM-24's fix should be built, she chose — a dialog
> pick — "Own run after wave 1 (Recommended)": VM-24 becomes its own short run on merged main as soon as all
> four mobile runs have merged, before wave 2; **it starts with one session on her phone counting how often
> unwarned edits and snap-backs occur, so the fix has before-and-after numbers.** Her words to the stage
> coordinator the same morning, verbatim: "I chose the own run after wave 1 option that vm-78 proposed. i want
> you to message them about this to lock the plan down, but basically i want you to open a new session in tmux
> once wave 1 is done and merged, and tell it to architect-phase that issue, reporting to you for stage details.
> just kick that off when wave1 is done for me."
>
> **The mechanism, traced by VM-78 in a stage window on 2026-11-19 (three lines):**
> 1. An edit can reach the phone editor's `storageDidEdit` UNARMED — without the edit gate having been consulted
>    for it, or with its arming already spent: autocorrect, predictive replacement, dictation and marked-text
>    commits by the code's own account, and sometimes an ordinary typed character that lands behind a keyboard
>    transaction of its own (a device capture shows exactly that).
> 2. An unarmed edit is routed by `fallbackVerdict` from the storage's own report of what changed.
> 3. When TextKit's attribute fixing widens that report inside `processEditing` so that it reaches past the
>    block's terminator, `fallbackVerdict` refuses what was a plain in-block edit, and `desyncRecovery` re-renders
>    the surface from the store: the character or word just entered snaps back, with a flicker. Stored text is
>    never at risk (the refused route returns before the autosave).
>
> **Where it lives:** `App/Variorum/VariorumMobile/Features/Write/MobileEditorViewModel.swift` (`storageDidEdit`,
> `fallbackVerdict`, `desyncRecovery`, the gate and its arming), `App/Variorum/Shared/EditorBrain/EditorEditRouting.swift`
> (`ArmedEdit.describes`, shared with the Mac), `App/Variorum/VariorumMobile/Features/Write/MobileEditorTextView.swift`
> (the input roads). This is the editor seam: a Fable cold review reads every round, and `notes/TEXTKIT2_NOTES.md`
> is read before any line is touched.
>
> **The pin, standing red on main:**
> `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`
> (`App/Variorum/VariorumMobileTests/MobileMarkdownCaretTests.swift`) — red for two of its three cases, the
> replacements "hi" and "hello there", at the expectation `model.desyncRecoveryCount == 0`; the third case,
> "Hello", is green. It is red alone, red in company, and has been since 2026-10-25 with no product change. It is
> NOT wrapped as a known issue and must not be: it goes green by the fix, and only by the fix. (A test-side wait
> that makes it green by avoiding the condition was considered and refused.)
>
> **Read first, in this order:**
> 1. `CLAUDE.md` and its loaded canon; `notes/TEXTKIT2_NOTES.md` in full; `notes/MobileSoul.md` §1–5.
> 2. `notes/plans/fixes/vm-78-fixes-to-whats-there.md` — its **FOR A LATER READER** section, then, WHOLE (this
>    run is reopening that finding): BATCH C's "WINDOW (3) — RESULTS" and "VM-24 — the mechanism, its reach, and
>    the options" (the reach table, what Apple's documentation does and does not say, the three fix options and
>    what only a device can tell), and "The orchestrator's live state" → the decisions on window (3).
>    `notes/plans/fixes/vm-78-ladder-round3.md`, finding R3-F5 and its final call (the reach correction: a typed
>    character can land unarmed; arming the visible roads cannot cover an arming spent before its edit lands,
>    while routing from the pre-fixing range does not depend on the arming).
> 3. **`notes/plans/fixes/vm-64-timing-and-lags.md` (and `vm-64-midpoint-review.md`) — BEFORE designing
>    anything.** VM-64 merged a flight fence into the same file: it changes how an unwarned edit is handled while
>    a divide, merge or extract is landing (`Domain/StructuralFlightFence.swift`, `MobileStructural.swift`,
>    `MobileEditorViewModel.swift`), and its record says its batch 2 traced the SAME widened-report mechanism for a
>    bare `insertText` (four state-dependent pins in its first fence cycle). Its later batches (the open/close
>    road, the leaving savepoint) also changed `MobileEditorViewModel.swift`.
> 4. `notes/plans/mobile-round-2-crash-trace.md` (the device capture, E1 #50–#52) and VX-68 (the gate-less
>    insertion watch row — it looks like this same mechanism; decide whether this run closes it).
>
> **What this run must NOT assume:**
> - That the code is as VM-78's trace saw it. By the time this run starts, VM-64's fence and its batches 6 and 7,
>   VM-55's message seam (`report(line:)`) and VM-78's date-chip mirror have all merged into
>   `MobileEditorViewModel.swift`. Re-read the routing on `main` and RE-RUN the pin alone before believing any
>   line number in the trace.
> - That the fence and this fix are independent. Both decide what happens to an unwarned edit; the fix is
>   designed against the fence as it landed, and the fence's pins are part of this run's gate.
> - That the simulator can answer the reach question. It cannot produce real autocorrect, predictions or
>   dictation; which system roads arrive unarmed, and how often their reports are widened, is a DEVICE fact.
> - That the trace instruments are in the tree. They were removed before VM-78's gate; commits `a570d3960` and
>   `fec0e478b` on VM-78's branch history carry them (`MobileCaretReplaceTraceTests.swift`, three suite types) and
>   can be restored for this run's own windows — run alone by type, never in a whole-target run.
>
> **The first acceptance unit is the measurement, and it needs her:** one session on her phone, the E1 edit
> trace armed, typing with autocorrect on, accepting predictions, dictating, using the spelling menu and
> pasting — counting gate-less edits and desync recoveries per road. That number is the "before"; the same
> session after the fix is the "after". Installing a build on her phone is her hands (the install runbook:
> `notes/plans/vm-44/plans/vm-45-install-runbook.md`); ask, do not work around it.
>
> **The fix options VM-78's write-up left for the architect (none is chosen):** route an unarmed report from the
> pre-fixing range (`willProcessEditing`), which does not depend on the arming; a fallback that accepts a
> widened report when the character change lies inside one block; arming the programmatic roads (which cannot
> cover a spent arming). The Mac shares `Shared/EditorBrain`; say for each option what the Mac inherits.
>
> **Stage:** report to the stage coordinator of your window for every `xcodebuild test`, simulator boot and
> device install (REQUEST, READY, GO, RELEASE).

## Pointers

- Ticket: VM-24 (re-owned out of VM-78's umbrella on 2026-11-19; Todo; Bug · Confirmed · Editor · High). Its
  comment of 2026-11-19 carries the mechanism and her decision.
- VM-19 (carried by VM-24 until then) is done in VM-78: its teardown pin is proved; the desync it described did
  not reproduce on this toolchain.
- Evidence kept only on the Pro (local, gitignored) until VM-78's worktree is removed: the trace window's logs
  and result bundles. What matters from them is written into the VM-78 record.
