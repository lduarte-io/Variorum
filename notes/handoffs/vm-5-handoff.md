# VM-5 — the catch-up merge & round-2 close · AUTHOR HANDOFF

## Your checklist (top, as always)

- [ ] **Unlock your phone at the install moment** — the Release install lands batches 5–10 +
      everything main shipped since, at marker 12 (the features you lost at the 2026-10-01
      main-built install come back: the Trash two-rooms + Versions, the Library kind filters,
      the per-note tray, the ⋯ vocabulary, the fan's hands, block multi-select, the starred
      page, the shelf↔library swipe band, New Note/New Chapter in a book).
- [ ] **VM-10 lands right after** (your only pull-forward): the Write page's scroll authority —
      the arrival, the new-line forced scroll, and the scroll-back fight, under your rule
      *"showing empty space should be allowed if you scroll there but it shouldn't be forced."*
- [ ] **The device queue when you have a window** (VM-13, one trip): the selection-defect
      experiment (one minute), the Face ID walk, the 100k Sherlock perf leg, M16, D9, the emoji
      overlap, the swipe band's real pan.
- [ ] **Ratify bundle:** the renumbered mobile QUESTIONS **#189–#199** (the unruled ones:
      #192 Block History's one-take sentence · #194 batch-5 PROVISIONALs · #195 the architecture
      review's MINORs to slot) + the VM board's Needs Lillian rows (VM-4's sitting leftovers,
      VM-13).

## What happened (one paragraph)

Mobile Round 2 came home: the `mobile` branch's 68 commits (batches 5–10, 4.5c-phone, the
filters, Two rooms + Versions, the ⋯ vocabulary, the fan's hands, navigation) merged onto the
marker-12 tree as ONE merge commit, conflicts resolved semantically (the 13i book/gathering
vocabulary, the 18h sort words, the first-write seeding design superseding the old B1 wait, the
union listing + main's empty state composed). The whole diff vs main sits inside
`App/Variorum/VariorumMobile/**` + notes — zero `Sync/`, zero `Shared/`, zero Mac-target, zero
schema (grep-verified), so Mac/core behavior is main's tip by construction. The QUESTIONS
numbering collision is fixed (mobile's #84–#94 → #189–#199, mapping table in place; main's own
stale next-free marker corrected). The round-2 closeout obligations are dispositioned in
`notes/plans/fixes/vm-5-the-catch-up-merge.md`; the long-lived `mobile` branch RETIRES at the close choreography (the tag
`archive/mobile-2026-10` is cut there, then the branch and its worktree go); all future VM work runs on main-based `vm-N` worktrees exactly like
VX.

## Verification (filled at close)

- core: 2204/247 + 40/6 GREEN (baseline-exact)
- mobile suite: 802/126 GREEN post-wave (4 standing known issues); the FINAL number re-run at
  the close
- Mac: the merge itself reaches zero Mac lines (construction argument upheld by round 1); the
  stability WAVE then fixed the shared brain + one Mac consumer, so the Mac verification widened
  — targeted editor-brain suites 268/24 + 91/14 GREEN; the FULL Mac suite runs before the PR
- THE LADDER CLOSED: round 1 (resolution) 0B/0M/3m/2n all fixed · round 2 (stability) M27
  DISSOLVED measured, MAJOR 2 fixed with red pins on BOTH platforms (the Mac twin hole was real),
  VM-2 re-measured and HELD per her ruling · round 3 (cap) 0B/0M/0m, 2 NITs recorded. The
  whole-round pass (obligation ZERO) ran last — its record:
  `notes/plans/fixes/vm-5-whole-round-pass.md`

## Where everything lives

The plan + rulings: `notes/plans/vm-4-mobile-catch-up.md` · the ladder + obligations:
`notes/plans/fixes/vm-5-the-catch-up-merge.md` · the board: team VM (VM-4 umbrella; VM-5 this
effort; VM-6…9 the phase flagships; VM-10 the scroll authority; VM-13 your device queue) · the
parity ledger: `notes/MobileSoul.md` §6 (PL-14 CLOSED, PL-3 DELIVERED at this merge).
