# Phase Sizing & Acceptance Guidance (+ how a split runs, + the 17-entry review rule)

**Status: GUIDANCE TO RAISE, never an absolute rule** — the author's clause (2026-09-01, the Act 10
correction round's sitting, R-cor-13): *"I'd put them in as guidance to raise as an issue if this is
being violated rather than as an absolute rule though."* A plan or session that finds itself outside
this guidance SAYS SO to her rather than silently proceeding or silently splitting. CLAUDE.md carries
the four-line summary; this file is what a session reads when in doubt. The binding record of the
rulings is `notes/plans/act10-correction-round.md` §1 (R-cor-12 · R-cor-13 · R-cor-14).

## 1. The unit: an ACCEPTANCE UNIT

The smallest thing whose done-ness is verified on its own by evidence OF ITS KIND:

| kind | one unit is | its acceptance evidence |
|---|---|---|
| UI | one screen / mode / board / panel | hands-on USE of the running dev-store build, both voices (and both appearances once dark mode exists), captured |
| sync / protocol | one §12 lockstep event, or one repair rule | the convergence suites for its shape + one live two-device round on the real mirror |
| custody / crypto | one road — a posture switch, a door, a recovery leg | the DRILL for that road (a fresh store or machine, the leg exercised end to end; 13p's migration drill and 13l's restore drill are the form) |
| operations / domain | one op family | the state-transition suite + a headless soak |

"Phase-sized" = a new mode/view/board, an app-wide token pass, a lockstep event, a posture model.

## 2. The four lines (CLAUDE.md's summary, expanded)

1. **ONE acceptance unit per implementer session.** The rule that would have stopped the pre-13u
   round's wave 2c (five surfaces in one session). A session that finds a second unit in its way
   hands off with a record; it never "also does" it.
2. **A phase names its units and their evidence at plan time and holds at most TWO phase-sized units
   under ONE theme.** A third is a split. ONE design sitting may rule several split phases (13u's
   shared sitting; 13i's), so a split costs an implementer session and a ladder — never a sitting.
   The ladder per phase is the part worth paying for: a cold review over ten thousand lines cannot see.
3. **A batch closes only on its kind's use-shaped evidence; a pin or a mount smoke alone never
   closes it.** The orchestrator walks each batch hands-on (or runs its drill / live round) before the
   record closes — an implementer's "done" is a claim, the walk is the verification (the correction
   round's founding orchestrator found two MAJORs that way after honest "done"s).
4. **The install refresh follows the walk or the drill, never precedes it.**

## 3. How a SPLIT phase runs (her question, 2026-09-01: "run architect for 13i-a, etc.?")

A split is **separate phase runs sharing one design sitting** — not one long phase with ordered
batches (that was 13b, whose plan file grew to ~5k lines and had to be closed early). Concretely for
13i: ONE author-attended sitting rules a–e and its record lives in the brief
(`notes/plans/phase-13i-smart-book-identity-brief.md`); then `/architect-phase 13i-a` runs with its
own just-in-time plan file, ladder, closeout and install refresh; then 13i-b; and so on. Each
letter's kickoff is short because the sitting already ruled; each letter's plan file stays readable
in full (the reading rule). The ONE schema/lockstep event is designed at the sitting and deployed
with the first letter that needs it (13i-a); later letters ride it.

## 4. The sanity check against the run history (her ask; by units named in each row's deliverables)

| phase | units (phase-sized) | verdict under this guidance | note |
|---|---|---|---|
| 11a | ~8 (fan-out styles · lenses + versions · aligned views · diff · scrub · TOC · canvas + lockstep · pool) | would be FLAGGED | substrate era: functional, unstyled, tests as the gate |
| 13b Stage 4 | two ceremonies · Compare rebuilt · the canvas package · the paged book + progress bar · restoreReading · a migration | FLAGGED | closed early at her EOL directive — the 5k-line plan file was the symptom |
| 13c | the friction batch · the uniform-page book view · the N38 conversion · Compare related-only · the book-order lens | borderline | — |
| 13d · 13g · 13k | bounded rows / one theme | PASS | — |
| 13e | A13–A21 + W26 | borderline | the overnight run |
| 13f | side-by-side windows · tabs · starred · the quick note · the string sweep | FLAGGED | — |
| 13j | the purge lockstep · the Trash · the recovery surfaces · the divide/merge default flips · the restoration doors | FLAGGED | the live 42702 incident was its one visible cost |
| 13l | backups + drill · insurance export + sanity check | PASS | two units |
| 13p | the spike · the substrate · custody/modes/recovery · copy + the phone's faces | AT THE LINE | three units, one theme, sequential batches, drills as the gate — ran clean; pre-13x repeats the shape |
| 14c | the multi-tenant rebuild · the entitlement · two-user suites · the deletion doors | FLAGGED | — |
| the pre-13u round | ~8 (four 17 entries · a review · Sherlock · Act 0 ×2 · the custody batch · Act 10 ×4 waves) | FLAGGED HARD | the Act 10 correction round is its bill |

**Reading (hers, confirmed by the table):** the flagged phases are where the fix rounds came from
(13b → 13c's friction batch; the pre-13u round → the correction round), while the substrate-era
phases passed on a different bar — the sizing "worked" while the acceptance was tests; the bar is
added now because the product is maturing and the acceptance is use.

## 5. The 17-entry review rule (R-cor-14, her ruling 2026-09-01, verbatim-faithful)

A 17 entry MAY run as one session (no orchestrator) under the standing-fixes discipline — **but an
OPUS cold review is ALWAYS mandatory, and a FABLE cold review whenever the diff touches `Sync/`,
custody/keychain code, or the editor seam** (`BlockRangeIndex` / `EditorTextView` /
`PaneTextAuthority`). Her stated practice, recorded so sessions plan for it: she will mostly still
run 17 entries a couple at a time as an ad-hoc phase under a **Fable orchestrator** — her words:
*"letting Opus run things on its own leads to an absolute mess - Opus is bad at keeping files caught
up with what's happened and lacks the discipline and thoroughness to be an architect or even keep
track of its own work."* Implement with Fable on key items; Opus implementers only under a Fable
orchestrator.
