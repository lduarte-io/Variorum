# VM-5 — the catch-up merge & round-2 close · AUTHOR HANDOFF

## Your checklist (top, as always)

- [x] **THE INSTALL IS DONE — your phone already carries the merged build** (installed over
      wifi 2026-10-07, early hours; `devicectl` returned success). Everything you lost at the
      2026-10-01 main-built install is back — the Trash two-rooms + Versions, the Library kind
      filters, the per-note tray, the ⋯ vocabulary, the fan's hands, block multi-select, the
      starred page, the shelf↔library swipe band, New Note/New Chapter in a book — now at
      marker 12 with all of main's two months beside them. Just open it.
- [x] **VM-10 IS DONE AND ON YOUR PHONE TOO** (PR #132, second wifi install, clean). The
      "drives me insane" bug's real cause was UIKit's own caret reveal padding the line by the
      typewriter room — now: opening a note restores where you left it (caret included), ⏎
      reveals one line instead of a page of empty room, and nothing programmatic scrolls while
      your finger is on the page. Your rule is the law in the code: empty space shows only when
      YOU scroll there. (The "opens at the top" arrival half turned out HOLLOW — the text-less
      page was always the reveal; recorded honestly.)
- [ ] **Ratify #200(a–c)** (the VM-10 PROVISIONALs): (a) the 0.6 s your-gesture window — with
      its consequence addendum read (it can swallow a typed-caret reveal or a find-next scroll
      for ≤0.6 s after a pan; the reviewer's optional tightening — typing voids the window — is
      one word away); (b) the caret rides the place memory; (c) the memory lives on the shell
      router, session-only.
- [ ] **The device queue when you have a window** (VM-13, one trip): the selection-defect
      experiment (one minute), the Face ID walk, the 100k Sherlock perf leg, M16, D9, the emoji
      overlap, the swipe band's real pan.
- [ ] **VM-2 priority call:** the structural-flight keystroke fence is now MEASURED store
      corruption (a settle-window keystroke visibly undoes a divide; the merge twin silently
      loses prose — the stability pass's probe is on the ticket). You held it out of VM-5;
      does the measurement change its slot?
- [ ] **Ratify bundle:** QUESTIONS **#159's addendum** (the wave brought in two Mac seal
      sentences under your ruled direction — one word ratifies or reverts) · the renumbered
      mobile QUESTIONS **#189–#199** (the unruled ones: #192 Block History's one-take sentence ·
      #194 batch-5 PROVISIONALs · #195 the architecture review's MINORs to slot) · the wave's
      PROVISIONAL copy (the bookless empty line "No bookless notes — every note is in a book." ·
      the quick note's "unlock it to keep writing") — all 13s-revoicable · the VM board's
      Needs Lillian rows (VM-4's sitting leftovers, VM-13).
- [ ] **One-command cleanup when convenient:** the old mobile worktree —
      `git -C ~/dev/variorum worktree remove ~/dev/variorum-mobile && git -C ~/dev/variorum branch -D mobile`
      (this session's own floor, so it could not saw it off; `origin/mobile` and the tag are
      already handled at the close).

## MERGED: PR #131 (`750eafde`) + VM-10 PR #132 (`ae7c3bb3`) · the ritual ran · `origin/mobile` retired behind `archive/mobile-2026-10` · BOTH builds installed to your phone overnight

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
- mobile suite FINAL: **808/126 GREEN** (4 standing knowns; +6 pins from the whole-round wave)
- Mac FINAL: the FULL suite ran — **3,972/654, zero merge-caused reds** (two known load-flakes
  green isolated; one PRE-EXISTING main red reproduced on main's own tip → **VX-77**)
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
