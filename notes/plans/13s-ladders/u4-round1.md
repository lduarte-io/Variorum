# U4 ladder — ROUND 1 (cold review, Opus, 2026-10-08)

**Target:** UNIT U4 (the savepoint→commit app-surface sweep, VX-103), EXACTLY the seven commits
`0f4055fb · b67e59c8 · 4a18ce00 · 96ac35ee · 705e98f2 · 8a2fb53a · 3ee9d349` on
`vx-7-13s-voice-onboarding` (worktree `~/dev/variorum-13s`). The interleaved commits in the range
(`fc9974db`, `eea127a7` — the tour fix; U1b's) were excluded hunk by hunk.
**Prompt:** `notes/REVIEW_PROMPT.md` verbatim. **Anchor:** the plan file's R-13s-31/32/34 (her
verbatim words), the U4 BRIEF, the U4 RECORD (grep table, PROVISIONALs P-U4-1..5, self-assessment,
stage commands, red-on-old recipes), R-VX83-9/10 + P-VX83-C7 in `notes/plans/fixes/vx-83-search-followup.md`,
the triage drafts' vocabulary (`13s-guide-triage/00-overview.md`, `chapter-03-takes.md`). No "Review
foci" section exists; the brief's high-stakes checks were treated as foci and each is answered below.
**Scope check (asked first):** the diff touches no editor seam (`CommitBar.swift` hunks are `.help`
strings only — no `EditorTextView`/`BlockRangeIndex`/`PaneSurface`), no custody/keychain code, nothing
under `Sources/VariorumCore/Sync/` or `Persistence/`, and no default's meaning (the cadence pane's
strings moved; `SavepointCadence`'s values and the `savepoint_cadence` read are untouched). Opus scope
holds — no re-spawn as `fable-reviewer` needed.
**My evidence seat:** headless only, in an ISOLATED copy (`git archive 3ee9d349` of the package into
my scratchpad — the shared tree carries U1b's in-flight `Sync/` edits, so I neither built nor
swapped files there). Everything below marked "traced" or "ran" was done at this seat.

## Findings

(In progress — written incrementally.)
