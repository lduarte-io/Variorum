# VM-17 · VM-239 · VM-179 — The phone's chrome geometry on long notes

**STATUS: NOT STARTED. Kickoff written 2026-11-19 at VM-78's hand-over. This run starts after wave 1 of the mobile
catch-up has merged to `main`; the author kicks it off. Shape: `/architect-phase vm-17 vm-239 vm-179` (a RUN: its
orchestrator mints the run ticket and seats the three as sub-issues; VM-179 sits under its wave-4 umbrella until
then).**

**HELD (her word, 2026-11-24): this run does not launch until the phone editor design (VM-271's standalone design
session) is settled.** "make a note that I will not launch a run on the stray badges until after the editor redesign -
the board should say so." The board carries it as VM-17's blocked-by relation to VM-271; no run or rider sweep picks
these tickets up meanwhile.

This file is a kickoff and a set of pointers. It is NOT a design: the rule's shape is the architect's work.

## Kickoff message

> You are starting the run over **VM-17** (fan badges stand astray while scrolling a long fanned note), **VM-239**
> (callout washes, callout glyphs and comment marks stand astray the same way) and **VM-179** (the takes marks lay
> out only the fanned blocks on screen), under the architect shape, on `main` as it stands after wave 1.
>
> **Her decision that made this run (2026-11-19).** VM-78 built a fix for VM-17 and it failed its stage window.
> Asked whether to keep working it inside VM-78 or take it out, she chose — a dialog pick — "Take it out, own run
> (Recommended)": the unproven fix is backed out of VM-78, and VM-17, the callout and comment finding and wave 4's
> VM-179 become one run after wave 1 with that night's evidence as its starting point, so the rule is designed
> once for badges, markers, callouts and comment marks.
>
> **What is known (each line is measured unless it says "by reading"):**
> 1. On a long note with many fanned blocks, stepping the page leaves stray fan badges in view: one stood 1,260 pt
>    from its own block; several sat exactly 74 pt off their own line. There is no pile at the first block.
> 2. Two mechanisms. (A) An off-screen overlay keeps a frame resolved by a FORCED mid-document layout
>    (`firstLineGeometry`, `.ensuresLayout`), which TextKit later corrects. (B) An overlay coming on screen is read
>    by the chrome's tick BEFORE TextKit lays out the viewport in that same layout pass.
> 3. The settle measurement: at the first subview laid out after the text view's own layout, inside the same
>    pass, an UNFORCED read of a fan's first line already equals its settled position (118 of 118 reads; the ideal
>    layout in all 28 on-screen ones), while the chrome's badge was off in 49 until it read again.
> 4. Callout washes, callout glyphs and comment marks share the rule (`Write/MobileBlockDecor.swift`, the same
>    forced helpers) and stray the same way: over one stepped scroll of the same note, 225 wash, 51 glyph and 122
>    comment-mark readings stood astray.
> 5. The cost of the takes chrome's whole-note pass, cold: 1.81 ms with 22 fans against 0.11 ms with none at 150
>    blocks; 6.02 ms with 86 fans against 0.31 ms at 600 blocks (VM-179's number).
>
> **The first attempt, and exactly where it fell short** (the shape a cold reviewer called from the settle
> measurement: geometry scoped to TextKit's viewport, views created only when placed and hidden when their block
> leaves it, one geometry walk for every scope, and a second geometry walk inside the same layout pass from a
> zero-size anchor subview). In its window: **the scrolling road went clean** (astray 35 → 0, misses 0), but
> **on the jump road** (`jumpToBlock`, the block-list tap) the target fan stood on screen with NO badge (17
> cases) and four far jumps did not land their target; and seven existing takes tests went red, six of them
> because the badge or marker view was never created in the test host (consistent with a windowless host having
> no viewport or no layout pass — NOT established). One more observation from that window, unexplained: a new
> guard asserting that an empty fanned LAST block wears a drawn badge was red on the OLD chrome too.
>
> **Read first, in this order:**
> 1. `CLAUDE.md` and its loaded canon; `notes/TEXTKIT2_NOTES.md` in full (§3's VX-246 facts are the Mac's twin of
>    this); `notes/MobileSoul.md` §1–5; `notes/SurfaceContracts.md`, The note.
> 2. `notes/plans/fixes/vm-78-fixes-to-whats-there.md` — its **FOR A LATER READER** section, then WHOLE (this run
>    reopens the finding): BATCH C's "WINDOW (3) — RESULTS" for VM-17, and BATCH D entire (the brief, the trace of
>    mechanisms A and B, the settle measurement, "The build — LIVE STATUS", "THE WINDOW AND HER RULING").
>    `notes/plans/fixes/vm-78-ladder-round3.md`: R3-F1, R3-F2 and the "Final calls" section's "VM-17's fix shape"
>    (the called shape, point by point) and the fair-pin list for the decor reading.
> 3. The Mac's fix for the same class: `notes/plans/fixes/vx-246-mcp-door-fixes-ai-docs.md`, U4 and U4b.
> 4. `notes/plans/fixes/vm-64-timing-and-lags.md` — VM-64 changed `MobileEditorViewModel.swift` (where
>    `jumpToBlock` lives) in wave 1.
>
> **The pins and the first attempt are in git history, not in the tree** (they were removed before VM-78's gate so
> `main` carries no new red test). On branch `vm-78-fixes-to-whats-there`'s history, reachable from `main` after
> its merge:
> - the probe `MobileFanBadgePlacementProbeTests.swift` — VM-17's pin; red on today's chrome (readings (i), (i′),
>   (ii)); restore it with `git checkout 15add793d -- <its path>` (its last edition, the header brought up to date
>   by R3-N3; the test body M5 and M5b ran is the same from `78179b765` on — the parent of VM-78's removal commit
>   holds it too, with `16c75a5bf`'s header);
> - the decor reading `MobileDecorPlacementReadingTests.swift` — VM-239's pin (`211221f6b`, `75984c0e6`);
> - the settle measurement `MobileFanBadgeSettleMeasureTests.swift` (`35ce90848`; one known bug in its
>   display-link fallback, and its second mount is void — both written up in BATCH D);
> - the first attempt itself: pins `15add793d`, fix `f869f8667`.
> VM-78's back-out commits name each of these.
>
> **What this run must NOT assume:**
> - That the first attempt's shape is right and merely unfinished. It was called from one measurement, built
>   exactly, and failed in a way neither its reviewer nor its builder predicted. Design the rule for all four
>   overlay kinds and all three roads (scroll, jump, edit) before building any.
> - That the seven red takes tests were only a harness matter. Establish it: what viewport does a windowless test
>   surface have, and does a layout pass ever run there?
> - That the jump road is the chrome's alone. `jumpToBlock` forces its own read and scrolls to an estimate; with
>   nothing else forcing layout, far jumps missed. That code is in the view model — the editor seam.
> - That the comment mark can borrow the badge's read. It sits at a block's LAST line.
>
> **Evidence a stage window must show before this run closes:** the probe and the decor reading green on both the
> scroll and the jump roads; the existing takes and decor suites green; a simulator walk of a long fanned,
> commented, called-out note scrolled top to bottom and jumped through from the block list; VM-179's cost before
> and after. This is the editor-seam class: a Fable cold review reads every round.
>
> **Stage:** report to the stage coordinator of your window for every `xcodebuild test`, simulator boot and walk.

## Pointers

- Tickets: VM-17 (re-owned out of VM-78's umbrella, Confirmed), VM-239 (minted 2026-11-19), VM-179 (wave 4,
  umbrella VM-176, until this run's kickoff seats it). Each carries a comment with her decision.
- Later tickets this touches: VM-188 (wave 5 — the visible badge and the foot pill redraw the badge's face);
  VM-218 (the VoiceOver pass — whether an off-screen fan should expose a badge).
- Evidence kept only on the Pro (local, gitignored) until VM-78's worktree is removed: the windows' logs and
  result bundles. What matters from them is written into the VM-78 record.
