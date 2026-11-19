# VM-78 — Fixes to what's there: your handoff

**STATUS: DRAFT.** It was written before batch C's stage window, the last review round, the merge and the final
test gate. Every **PENDING(…)** slot is filled before the merge; nothing marked PENDING has happened yet.

The record behind everything here is `notes/plans/fixes/vm-78-fixes-to-whats-there.md` — its FOR A LATER READER
section is the short version, and its Closeout section has the detail.

---

## Your checklist

- [ ] **Two provisional calls** (QUESTIONS PENDING(number)), each built the way the spec leans and waiting for your
  word:
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
- [ ] **The tickets filed** — the list at the bottom.
- [ ] PENDING(anything batch C's window holds for you — for example a cause found in the editor itself, which this
  run reports rather than fixes).
- [ ] PENDING(the single wave-1 phone install, only if this run is the last of the four mobile runs to merge: the
  device build from merged main and a paste-ready kickoff for a fresh session at PENDING(where)).

## What changed on the phone, in plain words

1. **Undo no longer offers to redo the wrong thing (VM-16).** If an undo found nothing to do — because the change
   had already been reversed some other way — the phone still said "Undid: X" and offered a Redo that would have
   re-applied a different change. Now it says the Mac's sentence ("Nothing to undo — X was already undone or
   changed since.") and offers nothing. The same for redo. PENDING: the wings run (vm-55) merges first and changes
   how every phone screen shows its messages, so this fix is re-applied on top of that, and its tests are shown
   failing on the old door and passing on the new one again.
2. **The undo warning says "committed" (VM-20).** It said "It is saved first"; it now says the Mac's "It is
   committed first".
3. **A restore keeps what it replaces (VM-43).** Restoring an older commit on the phone now keeps one quiet commit
   of the words it is about to replace, as the Mac does — your ruling at the November 10 sitting.
4. **The pocket guide's divide lesson tells the truth (VM-3).** It taught that other takes are copied onto both
   halves; the phone keeps them on the top block. The lesson is rewritten (a draft for your pass).
5. **The date chip follows the date (VM-84).** On a note with a title, changing its date left the chip showing the
   old day until something else changed. Now it updates at once.
6. **The Trash no longer flashes "empty" (VM-33).** Opening a Trash with things in it showed "Nothing in the Trash."
   for a moment first. The test proved this was real; now nothing shows until the list has loaded.
7. **Finish asks first (VM-81).** Finishing a book dismisses everything waiting at its Arrivals. The phone now asks
   — "Finish "‹name›"?" with "N waiting at Arrivals will be dismissed." — only when something is waiting, exactly as
   the Mac does. The "Open Arrivals first" button you asked to keep is not built yet; it needs the phone's Arrivals
   screen, which comes with VM-175.
8. **Book Details tells the truth and shows only doors that work (VM-81).** Its caption said a finished book
   "freezes its notes"; it now says the Mac's "Finished means the table of contents is done — the writing inside can
   still change." Finish is no longer drawn on a gathering (it always refused). Reopen on a sealed book now says a
   sentence instead of raw error text. "Diverge" is no longer offered on a gathering's row (your call 2 above).
9. **A starred archived book has a way out (VM-81).** Opening it from Starred showed an empty sheet. Now the sheet
   shows the book, marked archived, with an Unarchive button.
10. **The shelf sorts properly, with one star (VM-83).** "Zebra" sorted before "apple" and "Book 10" before "Book
    2". Now it is a–z, numbers in order, starred books first — the Mac's rule. Choosing a different order waits for
    the phone's Bookcase in wave 3, as you said. "Pin to Shelf Top" is gone: it was the star under another name.
11. **A gathering is called a gathering (VM-83).** The shelf, the delete button, its confirmation and its message,
    the note's book list, the new-book sheet and the Trash said "smart book" or "book"; they now say "gathering". A
    few spots are left for the tickets that own those screens (the record lists them).
12. **The collect message tells the truth (VM-21).** Collecting a note into a gathering by starring it said
    nothing about the star, and on an archived gathering it claimed the gathering shows the note. It now says the
    Mac's words: "Starred — the gathering shows it now." or "…once it's unarchived."
13. **Batch C, the test-side work (VM-24 with VM-19, and VM-17).** PENDING(window 3): whether the long-standing
    failing caret test was a test setup problem or something in the editor; whether a stale keyboard focus left by
    another test was the cause; and whether takes badges can stand in the wrong place on a long note.

## The evidence, in a few lines

- Every fix so far was shown failing on the old code and passing on the new one, in five stage windows on the
  simulator: batch B (68 tests), batch A (84 tests, plus the Mac's 110 tests over the words moved into shared code),
  the first review's fixes (75 tests), and two short follow-ups (4 tests and 11 tests).
- PENDING: batch C's window; the whole phone test target and the Mac tests on the merged tree; the walk through each
  changed screen on the simulator.

## The review, in plain words

A fresh reviewer read the whole run twice. The first round found two major points — the run could not be called
reviewed until batch C's results were read, and the badge test as first written could not see the problem it was
meant to catch — plus small fixes, all applied and proved. The second round found nothing major. A third round is
owed because batch C's results are new work: PENDING(its outcome).

## What a later reader would otherwise trip on

- **The verification checkout.** The orchestrator ran the stage windows from a separate throwaway copy of the
  branch (`~/dev/variorum-vm-78-pins`, with its own build folder) so an implementer could keep the worktree. It is
  removed at closeout with the worktree.
- **Some test result files are missing or cannot be opened.** Batch B's failing run kept no result file, and the
  failing runs of the round-1 fixes and of the VoiceOver-hint fix were stopped before Xcode finished writing theirs.
  The kept logs, under `App/Variorum/DerivedData/logs/` in the worktree, are the evidence, and they agree with the
  record.
- **The wings run's message line.** vm-55 moves every phone message onto one shared line and rewrites the undo
  door's tests. When this branch takes main behind it, VM-16 is re-applied on that line, and Book Details' refusal
  function meets VM-62's change at the same spot.
- **Batch C's diagnostic tests must be gone before any whole-target run.** They deliberately leave a stale keyboard
  focus and flip the global voice; in a full run they could make other tests fail. They leave in a named commit
  before the gate.
- **VM-20 and VM-19 were already closed** as duplicates when the plan was minted; their work is done here under
  VM-16 and VM-24.

## Tickets filed:

- [ ] to mint on VM (Low, Bug, PENDING(state)): The Archive room may show "Nothing archived." before its list loads (the Trash's old flash).
- [ ] to mint on VM (Low, Bug, PENDING(state)): A book's contents may show "No notes in this book yet." before its list loads.
- [ ] to mint on VM, or a line on VM-218 (Low, Bug, PENDING(state)): Book Details' name row hides the book's name from VoiceOver.
- [ ] to mint on VX (Low, Debt, PENDING(state)): A core comment still describes the shelf's retired pin order.
- [ ] to mint on VX, only if your answer to call 2 is that neither platform offers it (Low, Bug, PENDING(state)): The Mac's book chip offers Diverge on a gathering's row, then refuses.
- [ ] PENDING(window 3): any ticket batch C's window produces.
