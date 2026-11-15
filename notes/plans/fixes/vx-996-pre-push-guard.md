# VX-996 — the pre-push guard (record)

**STATUS: ladder round 1 fixes IN PROGRESS** — branch `vx-996-pre-push-guard`, PR #4, worktree `~/dev/variorum-vx-996`.
Not merged; not activated in any real clone.

## FOR A LATER READER

*(Written at round 1's fixes; kept current. PENDING marks what is not yet verified.)*

PENDING — filled when the round-1 fixes close.

---

## LIVE STATUS

| Piece | State | Commit |
|---|---|---|
| first build: pin (stub), scanner, CLAUDE.md line, docstring | DONE — red 17 FAILED / 14 held on the stub; 31/31 on the scanner | `3e728e581` `7900952ff` `a21eac1f8` `034019b79` |
| round 1 (cold review, Opus) | IN — 5 MAJOR, 3 MINOR, 5 NIT; `vx-996-ladder-round1.md` beside this file | (this commit) |
| round-1 pins (new `Tools/test-githooks` cases, red on the tip) | NOT STARTED | — |
| F1 · F2 · F3 · F4 · F5 · F6 · N1–N5 fixes | NOT STARTED | — |
| F7 (binaries) — the author's call, behaviour left | NOT STARTED (wording) | — |
| record + PR description | IN PROGRESS | — |

## Round 1 — findings and dispositions

The findings are `notes/plans/fixes/vx-996-ladder-round1.md` (verbatim, the reviewer's). The orchestrator's dispositions,
as arbiter (2026-11-15):

- **F1 · F2 · F3 · F4 · F6 — FIX NOW**, each with a red-on-old `Tools/test-githooks` case first.
- **F5 — RULED by the author today:** commits must not carry her personal email; the repo-local commit email is already
  the GitHub noreply address on both Macs; a rewrite of the existing commits is settled separately. KEEP the identity
  entry, drop "provisional", make its refusal say exactly what to run, judge only outgoing commits.
- **F7 — the author's call:** behaviour left as built (binary blobs unscanned); "policy" wording removed from the test;
  logged below as an open question.
- **F8 — this record**, the reviewer's file committed beside it.
- **N1 · N3 — fix. N4 · N5 — fix if small, else correct the docstrings. N2 — tighten the example's shapes, add the
  missing vx-988 classes (shapes only).**
