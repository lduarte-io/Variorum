# RUN A — LADDER ROUND 2 (cold re-review, Fable; 2026-09-21)

**Reviewer:** `fable-reviewer`, fresh session, zero implementation context, `notes/REVIEW_PROMPT.md`
verbatim. **Anchor:** `notes/plans/run-a-ladder-round1.md` (round 1's findings, final calls, fix
records, dispositions). **Diff under review:** round 1's fix pass (`bfdd3bd6..HEAD`, five fix
commits) re-derived at the code, the surfaces those fixes sit in, and anything else in the run's
combined diff (`50e581fa..HEAD`) this pass surfaces.

**Written incrementally per `notes/SessionResiliencyProtocol.md`; the round's final list is the
FINDINGS section when the STATUS line below says COMPLETE.**

**STATUS: IN PROGRESS.**

## Verification log (what has been re-derived so far)

- **The MAJOR's fix (`bfdd3bd6`) re-derived at the code:** `QuickNotePark.park`
  (AppSession.swift:717–739) re-arms `declineSpent` only when `held == nil`; traced the integrated
  pad-open road end-to-end (⌘Q #1: finalizeAll → take() refused → park into EMPTY park → re-arm →
  decline; ⌘Q #2: re-park over a STANDING capture keeps the spent flag → `declineQuitOnce()` false →
  quit proceeds), the pad-closed road (early `.terminateNow` arm, no re-park, one-shot survives),
  the resolution re-arm (`clear()` at `.filed`/`.nothingToFile`/`restore()` resets the flag, and a
  fresh park into the emptied park arms it), and the decline-then-close-then-⌘Q road (the re-park at
  close keeps the spent flag → the next ⌘Q proceeds — round 1's "undiscoverable escape" note is
  indeed closed by the same line). The new pin (iii-c) is the genuine integrated second press
  (finalize → decline → finalize again → decline must read false) plus the re-park-assigns,
  capture-stays-parked and resolution-re-arms arms.
- **The MINOR's comment fix (`2e3b0276`):** the doc comment now states the all-or-nothing gate the
  code implements (`self.draftField.text == text`); the dismissal's premise re-checked at both cited
  sites (QuickNoteView.swift:199 is the same `text == submitted` gate).
- **NIT-1 (`385ed8c4`):** both hazard sentences verified TRUE at their code — `clearRedoFuture()`
  sits after `database.write` returns at Operations+Container.swift:415 and
  Operations+NoteVersions.swift:293; a refusal inside either write never reaches the clear.
- **NIT-2 (`662237d3`):** the silent early-out replaced by a debug assertion + unconditional park;
  the one production call site (take()'s `.refused` arm, after `mints()` passed) verified as the
  only `park(` caller.

*(Findings and clean bill land below as they are traced.)*
