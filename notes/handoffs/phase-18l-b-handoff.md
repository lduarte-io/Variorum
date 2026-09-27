# 18l-b — Navigation feel, SECOND HALF — AUTHOR HANDOFF (2026-09-27)

*Self-contained: a fresh session can answer your questions about 18l-b from this file plus the run
record (`notes/plans/phase-18l-b-navigation-feel.md`). This half closed U2 · U3 · U4 · U-B5 —
the whole remainder R-18l-3 split off, B5 included. **18m is next at your paste** (your
2026-09-27 resequence: the editor-conductor hoist runs before 18o so mobile work can resume);
the kickoff prompt is at the bottom of this file, verbatim.*

## ✅ YOUR CHECKLIST (in order)

1. **Send the 18m kickoff** (the last section of this file) into a fresh session. Nothing else
   gates it — the word was given with this handoff's push.
2. **Open Variorum freely** — the install was refreshed at this closeout (the refresh commit
   carries the hashes; A1 safety copy under `Backups/safety-copies/`). What's new in your hands:
   Takes tells the Console what its landings did (`landing surface=TakesArticle …`), the "Open
   Takes mode" door can no longer silently fail to navigate, a Read/paged/note-box click into the
   Index puts the caret at the block's START instead of the blank line, and **B5 is dead** — ⏎
   after ⌘↓ on a freshly re-rendered note no longer slides the page.
3. **Ratify or overturn, one line each** (`notes/QUESTIONS.md`):
   - **#152 — the warning-family fork.** Your ratified PanePublisher shape was built, measured
     (it removes ALL ~2,400 `Modifying state during view update` warnings), and REVERTED at your
     own gate: it made the Takes board's mount flash a collapsed article for 50–83 ms (5/5 on
     frame video, 0/5 without). Nothing you see changed. Pick: (a) accept and document ·
     (b) defer only the make/update writes (unbuilt, plausibly keeps both) · (c) re-attempt with
     the visible slot answered. If you rule the flash "not felt": `git revert b60e5d6d` restores
     the shape whole.
   - **#153 — where a landing into the book Index puts the caret.** Built: (a) the block's START
     (the blank-line artifact is dead). The ladder found a cleaner (a′): "START, except the block
     you were last in lands at your remembered caret" — one line to swap.
   - **#149 · #150 · #151** — the 18l first-half trio, still open, unchanged.
4. **Confirm the U3 felt-gate close** — the revert is your sentence's letter; my walk closed it
   provisionally. If the app's boards feel right to you, nothing to do; it stands.
5. **Standing-rulings confirms carried from 18l:** R-18l-1 (note-open) · R-18l-2 · R-18l-3 (the
   split — both halves now closed) · R-18l-5 (the carve-out), plus the S3 taste call (the tier
   metrics) — all unchanged from the 18l handoff.

## What shipped (one line per unit)

| Unit | Result |
|---|---|
| U2 | Takes' landing half on the ONE authority (aim kind: top · minimal-reveal · viewport-fraction); restore half byte-preserved (your R-Q20/R-Q21); the bloom-race stall found at MY walk, traced PRE-EXISTING by run, fixed red-first; every landing ending now files — nothing dies silently; ladder 0/0/3/4 clean |
| U3 | **REVERTED at your gate — a valid close.** The shape works (all warnings gone) but costs a visible mount flash; your fork is #152. Ships: the macOS-27 `layoutViewport()` exam of the pane restore — PROVABLY SAFE, tripwire pinned — and the B5 harness fixture fix; ladder 0/0/1/3 |
| U4 | The Outline ends its landing with itself (no more phantom Console lines); the Index landing's caret at the START (#153); the flow's story heights are ONE brain; ladder two rounds clean |
| U-B5 | **B5 traced and fixed.** TextKit re-bases a floating island under an unmoved clip when a forcing read (your editing ring's walk, via TextKit's own selection fix) lays out the new paragraph; the fix keeps the untouched reading line exactly; your gesture no longer moves the page — walked in my hands, 14/14 |

## The finals

Ladders: U2 R1 0/0/3/4 + sanity 681/101 · U3 R1 0/0/1/3 + sanity 75/9 · U4 R1 0/0/2/1 + R2
0/0/0/3 · U-B5 R1 0/0/1/2 + sanity 56/9 — all closed, zero disputes anywhere, no cap reached.
Closing sets per unit: 681/101 · 1114/191 · 1287/221 (+ iOS BUILD SUCCEEDED) · 1019/154, all
green. The harness baseline: **16 seeded scenarios, XFAIL 4 = the S3 taste call only** (B5's
XFAIL retired with its fix). KnownIssues: row 88 CLOSED; rows 85 (sharpened) · 95–98 + two new
owner-12 rows all owned. Canon: ZERO AppSpec deltas (every product call is PROVISIONAL in your
bundle); TEXTKIT2_NOTES §3 gained two measurement records. MOBILE PARITY: nothing mobile-visible.

## Machinery this half minted (yours to keep using)

Three new standing harness scenarios (`takes-landing` · `book-landings` · `b5-more-roads`) —
every landing surface now has a tripwire with proven teeth; the U-B5 instrument + rig kept in
`App/Variorum/DerivedData/18lb-ub5/` for the two owner-12 successor rows; the built-and-reverted
PanePublisher shape recoverable exactly (`e113dd56` + `8a93eb24`).

## THE 18m KICKOFF (paste into a fresh session, verbatim from the chat word)

```
/architect-phase 18m

You are the FRESH Fable orchestrator for 18m — the editor-conductor hoist, the post-13u health
rounds' KICKOFF 3, run now at my word so the mobile catch-up can resume on its spine. The
ratified charter is notes/plans/post-13u-health-rounds.md KICKOFF 3 (author-ratified 2026-09-22)
— its unit text is the binding scope, read it in full before anything: U1 the routing cascade as
ONE pure function over a declared platform capability set (order as data; zero behavior change
per platform is the bar — a differing route is a finding, not a fix) · U2 crystallization, the
storage primitives and the identity audit hoisted on the 3C pattern · U3 one refusal table
(platform door-names stay local; the converged sealed-note sentence is PROVISIONAL, copy is mine,
QUESTIONS row) · optional U4 the tutorial-seeder scaffolding, take-or-leave at your sizing call.
Open your own record file at notes/plans/phase-18m-editor-conductor-hoist.md.

Preflight, read in full before any spawn (reading is never delegated): CLAUDE.md + its
auto-loaded canon · the charter's KICKOFF 3 with its own read-first list (the health review §3
and §2.1 leaks 1–2 · MobileSoul §3/§4.4 · both conductors side by side — the review's §3 table
maps the bands · everything in App/Variorum/Shared/EditorBrain/) · notes/KnownIssuesAndTechDebt.md
whole — rows 28 (the conductor-band fork is yours to discharge; update its enumeration in the
same commit as each hoist), 51/53 (the phone's missing seam carves: 18m makes them buildable and
NEVER builds them), 70 (the EditorViewModel decomposition rows, owned 18m), 74 (the phone's
autosave-registry leak — the touch rule may take it at the unit that touches the phone's editor
model; decide and record either way) · the 18l AND 18l-b records
(notes/plans/phase-18l-navigation-feel.md, notes/plans/phase-18l-b-navigation-feel.md) — the
editor seam moved under the charter at both (ReadingAnchor, the note-open arm, the settle net,
MarkdownRendering.sourceOffset, LandingAim + the Takes watch, the U-B5 keeper on the differential
road): the conductor you hoist is the one in TODAY's tree, never the review's snapshot ·
notes/TEXTKIT2_NOTES.md in full · notes/QUESTIONS.md · notes/SessionResiliencyProtocol.md ·
notes/DetailedPlanForPhases.md (the pointer + row 18) · notes/MobileSoul.md.

Fences, restated because they bind every unit: zero Sync/ lines (a fix that wants it is
STOP-and-report); the 3C proof is the bar on BOTH platforms — every existing routing/gesture pin
rides UNMODIFIED, Mac and mobile, and the FULL mobile suite is part of every unit's finals, not
just the Mac's; the phone's seam carves and its tutorial CONTENT (row 51) stay the mobile
catch-up's — scaffolding only in U4.

Cast (my standing ruling): opus-implementer per unit, one at a time, strictly sequential; FABLE
cold reviewer on EVERY unit — this is editor-seam surgery by definition; cross-model flow as
always. The visual harness (VARIORUM_VISUAL_WALK=1 Tools/VisualWalk/visual-walk.sh) is a standing
instrument — run the seeded suite as regression cover after each unit. Standing rules bind:
pin-before-fix with behavioral reverts; one unit per implementer session; commit+push per piece,
NO trailers; PROVISIONAL-and-continue with author-only calls as hard stops; each unit closes on
your own hands-on walk plus the full mobile suite green; the closeout ritual per CLAUDE.md,
including the install refresh at a zero-instance window behind the A1 rail. The MOBILE PARITY
line at close is load-bearing this time: state exactly what the catch-up can now build on (the
shared route function's declared-arm seam) and what it still owes (row 53's carves, the
refusal-copy faces, row 51's lesson rewrite) — the mobile catch-up resumes NEXT at my word from
notes/plans/mobile-round-2-orchestrator-handoff.md (the HANDBACK CHECKLIST first), and your
author handoff says in one line what 18m changed under it.
```
