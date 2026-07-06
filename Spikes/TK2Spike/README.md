# TK2Spike — Phase 6 throwaway spike (DO NOT IMPORT)

**Status: throwaway evidence, kept in-repo per the Phase 6 plan.** This package is a
standalone SPM executable that measures TextKit 2 viewport/height/scroll/typing facts
on Tahoe against the 26 SDK. It is **never** a dependency of `VariorumCore` or the app
target, and nothing in it is production code — the quality bar was measurement rigor,
not polish. The findings and the decision memo live in
`notes/plans/phase-06-tk2-spike.md`; the per-point-release caveat in
`notes/TEXTKIT2_NOTES.md` §5 applies to every number it produced.

Run: `swift run` from this directory (opens a small window, drives scenarios
programmatically, prints a results table, exits). Optional args select scenarios:
`load fallback height scrub typing ensure scale`. Env `TK2SPIKE_STRICT=1` turns the
fallback canary's loud log into a hard `assertionFailure`.

`swift run TK2Spike manual` is the author's feel pass: the 50k-word corpus in a
live window that stays open (canary armed, loud) — type at start/middle/end,
scroll hard, drag-resize, jump around with the scroller. Close the window to quit.

The definitive automated run for the Phase 6 memo is archived at
`results-2026-07-06-macos26.4.1.log` in this directory.
