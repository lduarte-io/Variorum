# VM-78 — Fixes to what's there: your handoff

**STATUS: OPEN — re-fitted on 2026-11-19, after the badge fix was taken out and main was merged into the branch.**
Still ahead: a short test window for the fixes re-applied after the merge, the fourth review round, and the final
gate (the whole phone test suite, the Mac tests over the shared code this run changed, and a walk through the
changed screens on the simulator). Every **PENDING(…)** slot below is filled at the merge; nothing marked PENDING
has happened yet.

*How to read this file:* **VM-NNN** and **VX-NNN** are tickets on the board. A **test window** is a test run on the
shared Mac, granted by the stage coordinator. The **review** is the cold code review, one fresh reviewer per
round. The record behind everything here is `notes/plans/fixes/vm-78-fixes-to-whats-there.md` — its FOR A LATER
READER section is the short version, and its Closeout section has the detail.

---

## Your checklist

- [ ] **The snap-back in the phone editor (VM-24) — you decided: its own run after wave 1.** Nothing is needed
  from you now. The stage coordinator launches that run once all four wave-1 mobile runs have merged. It starts
  with one session on your phone — your hands — counting how often the snap-back happens, before the fix and
  again after. (The next section.)
- [ ] **The stray takes badges on long notes (VM-17) — you decided: take it out, its own run.** The fix built for
  it did not hold up in its test window, so it was backed out of this run. It becomes one run with the callout
  and comment-mark finding (VM-239) and the takes marks' cost (VM-179). **That run is yours to launch, after
  wave 1:** `/architect-phase vm-17 vm-239 vm-179` — its kickoff is `notes/plans/vm-17-chrome-geometry.md`.
- [ ] **Two provisional calls** (QUESTIONS PENDING(the QUESTIONS number, at the merge)), each built the way the
  spec leans and waiting for your word:
  1. **An archived gathering in the phone's "add to a book" list.** Archived books there now say "(archived)". As
     built, an archived gathering says it too ("Quotes (archived) (by tagging)"). The Mac's chip leaves gatherings
     unmarked. Should both platforms mark it, or neither?
  2. **"Diverge" on a gathering's row** in a note's list of books. The phone no longer offers it there, because a
     gathering always refuses it. The Mac still offers it and then refuses with a sentence. No words of yours were
     found for either choice. Should the Mac follow the phone, the phone go back, or the two stay different on
     purpose?
- [ ] **The wording pass** — every line this run drafted, old beside new, is in the record's Closeout under "For her
  wording pass": the pocket guide's divide lesson, the "getting around" lesson's two sentences, the new-book
  sheet's three gathering lines, the sealed book's Reopen sentence on the phone ("This book is sealed, so it can't
  be reopened here." — does "here" read wrongly when the phone has no Unseal yet?), and whether the phone keeps a
  line at all after collecting a note into a gathering.
- [ ] **Two canon lines I changed, for your eyes** — the section of that name below.
- [ ] **The tickets filed** — the list at the bottom.
- [ ] PENDING(the single wave-1 phone install — only if this run is the last of the four mobile runs to merge: the
  device build from merged main, and a paste-ready kickoff a fresh session can run with you, per
  `notes/plans/vm-44/plans/vm-45-install-runbook.md`).

## The first decision: the snap-back in the phone editor (VM-24)

**What the trace found.** The phone's long-failing caret test was not a test setup problem. It shows a real
behaviour in how the phone editor decides which block an edit belongs to. Some ways of putting text in reach the
editor without it being told first: accepting an autocorrection or a prediction, dictating, committing text from
the candidate bar, and sometimes even an ordinary typed letter, when the keyboard slips a change of its own in
first. For those, the editor works out the block from TextKit's own report of what changed. TextKit sometimes
stretches that report past the end of the paragraph. When it does, the editor reads the change as crossing into
the next block, refuses it, and redraws the note from what is saved.

**What you would see.** The character or word you just put in snaps back to what was there before, with a flicker
as the note redraws. Your saved text is never at risk: nothing wrong is written, and anything you typed before it
is saved first. How often this happens on your phone has not been measured — the simulator cannot produce real
autocorrect, predictions or dictation. It looks like the same thing as an older watch item about the note
flickering (VX-68).

**You decided.** You picked "Own run after wave 1 (Recommended)", and told the stage coordinator: "I chose the own
run after wave 1 option that vm-78 proposed. i want you to message them about this to lock the plan down, but
basically i want you to open a new session in tmux once wave 1 is done and merged, and tell it to architect-phase
that issue, reporting to you for stage details. just kick that off when wave1 is done for me."

**What happens next.** This run builds no fix for it. The caret test stays failing on main, on purpose and in plain
sight — it is the proof the fix has to turn green, and it is not hidden as a known issue. Once all four wave-1
mobile runs have merged, the stage coordinator opens a new session that runs `/architect-phase vm-24`, reporting to
the coordinator for stage details. Its kickoff is written: `notes/plans/vm-24-unwarned-edit-routing.md`.

**What needs your hands, at that run's start.** One session on your phone with the editor's edit trace turned on:
typing with autocorrect on, accepting predictions, dictating, using the spelling menu and pasting, so the run counts
how often an edit arrives unannounced and how often a snap-back follows. That count is the "before"; the same
session after the fix is the "after". Putting a build on your phone for it is your hands too (the install runbook
is `notes/plans/vm-44/plans/vm-45-install-runbook.md`).

## The second decision: the stray takes badges on long notes (VM-17)

**What was found.** On a long note with many blocks that have takes, scrolling down could leave a takes badge
standing beside the wrong paragraph — one stood about 1,260 points from its own block — or a little above its own
line, and some blocks with takes showed no badge on their line at all. Nothing piled up at the top of the note,
which is what the ticket had suspected. The trace found two causes: a badge kept a position measured before the
screen had laid out the text above it, and a badge coming on screen was measured a moment before the screen placed
its line. A small measurement then found the moment in each screen update when that line's position is final.

**What the first fix did, and what its test window showed.** The fix drew the takes marks only for text on screen
and measured them again at that moment. In its test window steady scrolling went clean — no stray badge at all —
but jumping straight to a block from the block list left that block's badge missing, four far jumps did not land
on their block, and seven other takes tests failed. So the fix was not proved.

**You decided.** Asked whether to keep working it inside this run or take it out, you picked "Take it out, own run
(Recommended)". The fix was backed out (two plain revert commits, one for the fix and one for its tests). The
badge test and the measurement tests left the branch in named commits, so main carries no new failing test from
this run; they stay in the branch's history for the new run to restore. The takes badges on the phone are
therefore exactly as main had them before this run.

**The callout and comment-mark finding (VM-239).** The third review pointed out that callout colours, their glyphs
and comment marks are placed by the same old rule the badges had. The same test window measured them: they stray
the same way on a long note. VM-239 was filed for it (High), and it joins the new run.

**The new run.** VM-17, VM-239 and VM-179 (the cost of the takes marks on a long note), designed once for all of
them. It is yours to launch, after wave 1: `/architect-phase vm-17 vm-239 vm-179`. The kickoff,
`notes/plans/vm-17-chrome-geometry.md`, carries everything measured here and the first fix's exact shortfall, and
tells that run not to assume the first fix's shape was right.

## What changed on the phone, in plain words

Eight fixes ship, each shown failing on the old code and passing on the new one in a test window before the
merge. Where the wings run (VM-55) had changed the same screens, each was re-applied on top of its work at the
merge.

1. **Undo no longer pretends (VM-16, with VM-20).** If an undo found nothing to do — because the change had
   already been reversed some other way — the phone used to say "Undid: X" and offer a Redo that would have
   re-applied a different change; after the wings run it said nothing and still kept that wrong Redo behind the
   scenes. Now it says the Mac's sentence on the phone's one message line ("Nothing to undo — X was already undone
   or changed since.") and keeps no way back. The same for redo. The undo warning also says "It is committed
   first", the Mac's word, where it said "It is saved first".
2. **A restore keeps what it replaces (VM-43).** Restoring an older commit on the phone now keeps one quiet commit
   of the words it is about to replace, as the Mac does — your ruling at the November 10 sitting.
3. **The pocket guide's divide lesson tells the truth (VM-3).** It taught that other takes are copied onto both
   halves; the phone keeps them on the top block. The lesson is rewritten (a draft for your pass).
4. **The date chip follows the date (VM-84).** On a note with a title, changing its date left the chip showing the
   old day until something else changed. Now it updates at once.
5. **The Trash no longer flashes "empty" (VM-33).** Opening a Trash with things in it showed "Nothing in the Trash."
   for a moment first. The test proved this was real; now nothing shows until the list has loaded, in whichever
   wing the Trash is showing.
6. **Book Details asks first, tells the truth and shows only doors that work (VM-81).** Finishing a book dismisses
   everything waiting at its Arrivals; the phone now asks — "Finish "‹name›"?" with "N waiting at Arrivals will be
   dismissed." — only when something is waiting, exactly as the Mac does. (The "Open Arrivals first" button you
   asked to keep needs the phone's Arrivals screen, which comes with VM-175.) Its caption says the Mac's "Finished
   means the table of contents is done — the writing inside can still change." instead of "freezes its notes".
   Finish is no longer drawn on a gathering, which always refused it. A starred archived book, which opened to an
   empty sheet, now shows the book marked archived with an Unarchive button. Deleting a gathering from Book
   Details now says "Gathering moved to the Trash", as the shelf does. (Reopen on a sealed book now speaks a
   sentence — since the merge it comes through the wings run's own wording table, which says the same.)
7. **The shelf sorts properly, with one star, and says "gathering" (VM-83).** "Zebra" sorted before "apple" and
   "Book 10" before "Book 2"; now it is a–z, numbers in order, starred books first — the Mac's rule. Choosing a
   different order waits for the phone's Bookcase in wave 3, as you said. "Pin to Shelf Top" is gone: it was the
   star under another name. The shelf, the delete button, its confirmation and its message, the note's book list,
   the new-book sheet and the Trash say "gathering" where they said "smart book" or "book". A few spots are left
   for the tickets that own those screens (the record lists them).
8. **The collect message tells the truth, and archived books are marked (VM-21).** Collecting a note into a
   gathering by starring it said nothing about the star, and on an archived gathering it claimed the gathering
   shows the note. It now says the Mac's words on the message line: "Starred — the gathering shows it now." or
   "…once it's unarchived." Archived books in the "add to a book" list say "(archived)".

Also: **a test that left the keyboard focus behind now lets go of it (VM-19).** It was suspected of upsetting the
editor in later tests; that did not happen on this toolchain, so the fix stands as tidiness in the tests.

## Two canon lines I changed, for your eyes

**1. The insured restore is no longer marked provisional** (your ruling, QUESTIONS #274 addendum 2: "P-849-1
RATIFIED + the phone wired (the insured restore stands; the phone's one-argument insurance is VM-43)" — and VM-43
wired it). Three places, the same change in each: "PROVISIONAL" dropped, "on both platforms" added.
- `notes/AppSpec.md` §9, the quiet auto-commits list. Old: "…passed true by the flush-first restore doors —
  PROVISIONAL, QUESTIONS #274)". New: "…passed true by the flush-first restore doors on both platforms — QUESTIONS
  #274)".
- `notes/AppSpec.md` §9, `restoreCommit`. Old: "the restore doors flush pending typing first and pass it true
  (PROVISIONAL, QUESTIONS #274; VX-849)". New: "the restore doors on both platforms flush pending typing first and
  pass it true (QUESTIONS #274; VX-849)".
- `notes/OverallModel.md` §3. Old: "…the restore doors flushing pending typing first — PROVISIONAL, QUESTIONS
  #274)". New: "…the restore doors on both platforms flushing pending typing first — QUESTIONS #274)".

**2. Two measured facts about TextKit on the phone, added to `notes/TEXTKIT2_NOTES.md` §3.** Old: §3 had no entry
for iOS 26.2. New: one block, "iOS 26.2 measured findings (VM-78 …)", stating each fact with what was measured and
no more:
- "The iOS fixing finding above reaches the REPORT an unarmed replace is routed by, and whether it widens is not
  stable." — the snap-back's cause, with the exact ranges seen; VM-24's run owns the fix.
- "A FORCED mid-document read is a frame TextKit later moves; inside the same layout pass, after the text view's
  own layout, an UNFORCED read is already placed — a measurement, not a recipe." — the badge measurement, and
  that the first fix built on it still failed on the jump road; VM-17's run owns the rule.

## The evidence, in a few lines

- **Before the merge:** every one of the eight fixes and every review fix was shown failing on the old code and
  passing on the new one, in test windows on the simulator — batch B (68 tests), batch A (84 tests, plus the Mac's
  110 tests over the words moved into shared code), the first review's fixes (75 tests), and two short follow-ups
  (4 tests and 11 tests). The editor window's eleven runs showed the caret test failing exactly as traced, the
  badge test failing on the old code (the badge problem is real), and the keyboard-focus test failing on its old
  version and passing on the fix.
- **The badge fix's window:** the fix failed (above); the callout and comment-mark measurement failed too, which
  is VM-239.
- **After the merge:** the phone and the Mac both build for testing on the merged code, and a check confirms the
  takes badge files are exactly main's and no measurement test is left in the tree.
- **The re-applied fixes, proved again on the merged code:** against main's versions of the undo and Trash files,
  exactly the six tests that should fail did fail (44 tests ran), and on the branch they pass; then this run's
  tests and the wings run's over the same screens — 283 tests — all passed.
- PENDING(gate 1: the whole phone test suite on the merged code — its result, with the caret test as the one
  expected failure).
- PENDING(gate 2: the Mac tests over the shared code this run changed — its result).
- PENDING(gate 3: the simulator walk through each changed screen — each screen's outcome and its capture).

## The review, in plain words

A fresh reviewer read the run three times. The first round found two major points — the run could not be called
reviewed until the editor work was read, and the badge test as first written could not see the problem it was
meant to catch — plus small fixes, all applied and proved. The second round found nothing major. The third round
read the editor findings and found one major point: the callout colours and comment marks share the badges' old
rule (now VM-239). It also corrected how far the snap-back reaches — an ordinary typed letter can be caught by it
too — and that correction is in the section on VM-24. The same round set the shape of the badge fix, which was
built exactly and then failed its window. A fourth round is owed; with the badge fix gone, it reads the back-out,
the merge and the undo fix re-applied. PENDING(ladder round 4: its outcome).

## What a later reader would otherwise trip on

- **The caret test is failing on purpose.** `MobileMarkdownCaretTests.aReplaceThroughTheInputRoadAtARescuePointKeepsTheSurfaceInStep`
  stays red on main after this merge, by your decision, until VM-24's own run fixes the editor. It is not wrapped
  as a known issue and must not be.
- **The badge tests are in history, not in the tree.** The badge test, the callout-and-comment measurement and the
  timing measurement were removed in named commits before the gate; the VM-17 kickoff says how to bring each back.
- **"A plain revert commit" became two.** The option you picked said one; the back-out reverted the fix and its
  tests in one commit each.
- **Two fixes met work main already had.** The wings run had already made Book Details speak sentences for a
  sealed book's Reopen and for a raced Unarchive, word for word as this run's tests expect, so this run's own
  version of that was removed at the merge and main's stands. And the wings run's undo door still had the quiet
  press problem, so VM-16 was needed exactly and was re-applied on its message line.
- **The verification checkout.** The orchestrator ran most test windows from a separate throwaway copy of the
  branch (`~/dev/variorum-vm-78-pins`, with its own build folder) so an implementer could keep the worktree. It is
  removed at closeout with the worktree.
- **Some test result files are missing or cannot be opened.** Batch B's failing run kept no result file; the
  failing runs of the first review's fixes and of the VoiceOver-hint fix, and both runs of the badge fix's window,
  could not be opened. The kept logs, under `App/Variorum/DerivedData/logs/` in the worktree, are the evidence,
  and they agree with the record.
- **This run's parity row is PL-77** in `notes/MobileSoul.md` (it was drafted as 75; the search run and the wings
  run took 75 and 76 first).
- **VM-20 and VM-19 were already closed** as duplicates when the plan was minted; their work is done here under
  VM-16 and VM-24.
- **The orchestrator did not change hands.** The session's context was compacted once at a clean point, at your
  word; `notes/plans/vm-78-orchestrator-handoff.md` was written in case a successor was wanted and served as the
  same session's map.

## The phone install

PENDING(the single wave-1 phone install — only if this run is the last of the four mobile runs to merge: the
device build from merged main is prepared, and a paste-ready kickoff for a fresh session to help you install it is
at the path written here). Your ruling, from the night: "the phone step is the single wave-1 install after all four
runs have merged. I'll do the hands part hands on in the morning."

## Canon size

PENDING(the canon-size line: `Tools/canon-size`'s report at the merge).

## Tickets

VM-24 and VM-17 stay open as the tickets for their own runs; VM-179 joins VM-17's run. For the tickets still to
be filed at the merge, the state shown is the one proposed; the merging session sets it.

Tickets filed:
- [ ] VM-239 (High, Bug, Todo): callout colours, their glyphs and comment marks stand away from their own blocks on a long note; joins VM-17's run.
- [ ] PENDING(id) (Low, Bug, Todo): the Archive room may show "Nothing archived." before its list loads (the Trash's old flash).
- [ ] PENDING(id) (Low, Bug, Todo): a book's contents may show "No notes in this book yet." before its list loads.
- [ ] PENDING(id, or a line on VM-218) (Low, Bug, Todo): Book Details' name row hides the book's name from VoiceOver.
- [ ] PENDING(id, or a line on VM-156) (Low, Bug, Todo): pressing Unarchive twice quickly in Book Details shows a refusal under the book the first press unarchived.
- [ ] PENDING(id) (Low, Debt, Backlog): a core comment still describes the shelf's retired pin order.
- [ ] PENDING(id, only if your answer to call 2 is that neither platform offers it) (Low, Bug, Backlog): the Mac's book chip offers Diverge on a gathering's row, then refuses.
