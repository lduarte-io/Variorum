# 18l — Navigation feel (FIRST HALF) — AUTHOR HANDOFF (2026-09-26)

*Self-contained: a fresh session can answer your questions about 18l from this file plus the run
record (`notes/plans/phase-18l-navigation-feel.md`). 18l split at your R-18l-3 ruling, confirmed
at your check-in: this half closed U0 · U0b · U0c · U-VIS · U1; **18l-b** (U2 · U3 · U4 + the B5
trace) runs under a fresh orchestrator on your paste of the kickoff you were handed in chat.*

## ✅ YOUR CHECKLIST (in order)

1. **Send the 18l-b kickoff** (the message the orchestrator gave you in chat) into a fresh
   session — the word was given with this handoff's push. Nothing else gates it.
2. **Open Variorum freely** — the install was refreshed at this closeout (binary `c09f81be` → **`c05400e8`**, Release from `1c720578`; safety copy `Backups/safety-copies/18l-refresh-20260927T010212Z`, 6 files byte-verified; codesign OK, both keychain access groups present). **It's safe to open Variorum now.**. All four of your reported bugs are fixed in it: the Index click lands
   where you click; the last line's descenders draw whole; removing a newline no longer eats the
   page's top air; opening a note shows the START (first open each session) and an in-session
   re-open comes back exactly where you left.
3. **Ratify or overturn, one line each** (`notes/QUESTIONS.md`):
   - **#149** — the 13g surface-rule carve-out (R-18l-5): formatted read tiers may seed a caret
     through the pinned click translation (as built), vs. switching those tiers to the
     dimmed-marker face.
   - **#150** — two refinements of your note-open ruling: (a) a first open seeds NO remembered
     fact (the literal reading failed in use — one ⌘1 brought the blank END back; measured,
     pinned); (b) a re-open restores the page without revealing an off-page caret.
   - **#151** — U1's judgment call: note Read shipped the WATCH (authority + signpost +
     watchdog) without the charter's placeholder rows — the placeholder half was built and
     measured WORSE (59-pt cold miss + a 1 s jump). Real-story landings: 72/72 settled, 0 hops;
     the ladder's MAJOR (a click into the just-landed block moved the page 5 pt) fixed —
     your acts now END a landing, verified in the orchestrator's own hands.
4. **One taste call (no rush):** the read tier and the live pane wrap slightly differently, so a
   clicked block shifts a little as it goes live (your caret still lands right — S3). Share the
   tiers' metrics, or keep them distinct? (KnownIssues row, Design & UI review owner.)
5. **Confirm your sitting rulings as standing:** R-18l-1 (note-open) · R-18l-2 (facts) ·
   R-18l-3 (the split — fired) · R-18l-5 (the carve-out). R-18l-4 (the overnight mandate) is
   discharged. The U-VIS design note is ratified-by-build unless you object to its shape.
6. *(Resolved at your check-in: the Finder consent prompt — you clicked Don't Allow.)*

## What shipped (one line per unit)

| Unit | Result |
|---|---|
| U0 | Index click FIXED (pre-existing — the tap carried no place; off-screen replica + pure `sourceOffset`); descender clip FIXED (the width door + the settle net; the ~85-pt row closed free); sweep S1–S9 with per-finding ATTRIBUTION; ladder 0/0/2/2 + sanity PASS |
| U0b | Write top-air collapse FIXED (`ReadingAnchor` — the restore now carries WHERE the line sat); B1–B3 pre-existing, B4 our-commit; ladder 0/0/2/2 + sanity PASS |
| U0c | Note-open built to YOUR rule: START on first open per session, exact-page restore in-session, deep links untouched; all pre-existing mechanisms; ladder PASS in one round (0/0/0/3 NIT) |
| U-VIS | Your testing ask is REAL: `Tools/VisualWalk/` — 11 scenarios × 2 voices, geometry assertions, opt-in (`VARIORUM_VISUAL_WALK=1 Tools/VisualWalk/visual-walk.sh`); proved it can red (incl. on your own −24 pt bug); caught + measured B5; ladder two rounds (the MAJOR was the harness activating before guarding — fixed everywhere incl. WalkKit) |
| U1 | Note Read (both faces) now lands through the ONE authority — watched, corrected, signposted (`landing` lines in Console at last); honest baseline: the §1.2 stutter did NOT reproduce on real prose, so the placeholder half was rejected on measurement (#151) |

## Attribution (your kickoff question, answered)

Every bug you reported was **pre-existing** — September's fixes EXPOSED them (the Index only
became editable in the fall), they did not cause them. The one confirmed macOS-27 regression was
the jump-landing bug 18k already fixed; the OS's four measured behavior shifts are recorded in
`TEXTKIT2_NOTES.md` §3. The full evidence: each unit's ATTRIBUTION cells in the run record.

## What 18l-b owes (the fresh orchestrator's scope; the kickoff carries it)

U2 (Takes' landing half onto the authority; restore half BYTE-preserved per your R-Q20/R-Q21;
may-take: the born-live pane's persisted-END residue) · U3 (PanePublisher frame-sync/state-
deferred — YOUR gate: walk the boards, revert on any felt regression; + the macOS-27
`layoutViewport()` exam of `PaneSurface`'s render restore; + the ~1,989-warning measurement) ·
U4 (the one-liners) · the **B5 trace** (KnownIssues row 88 — deterministic Study recipe in the
harness; re-owned there at this split).

## The finals *(PENDING at draft; the closeout commit fills them)*

Ladders: U0 R1 0/0/2/2 + sanity PASS · U0b R1 0/0/2/2 + sanity PASS · U0c R1 PASS (0/0/0/3) ·
U-VIS R1 0/1/8/9 + R2 0/0/3/8, closed at two rounds · U1 R1 0/1/3/2 all confirmed + fixed red-first inside the ReadEditPane boundary · R2 all VERIFIED-FIXED + 0/0/0/5 NIT dispositioned — closed at two rounds; the orchestrator re-walked the MAJOR's gesture by hand (`end=handedover top=0`). Suites at each unit's
close all green (the run record's LIVE STATUS tables carry exact counts; core 1729/181 at U0;
closing Mac runs 341/59 · 694/87 · 989/146 · 210/37 per unit). Install: `c05400e8` from `1c720578` (safety copy + codesign above).. MOBILE PARITY: `notes/MobileSoul.md` PL-38 — the phone's note-open owes R-18l-1's twin; its long-note Read inherits U1's watched-lazy shape, never the Index's manifest.

## Machinery this half minted (yours to keep using)

`Tools/VisualWalk/` (the standing visual harness; run it after every macOS update — tree
unchanged + red = the OS moved, your attribution question answered by construction) ·
`Tools/WalkKit/guard.sh` + `click.sh`/`keys.sh` (the per-step walk guard, durable) · the
hardened ENVIRONMENT TRAPS (per-step HID checks; system-dialog rules; consent dialogs are
yours alone).
