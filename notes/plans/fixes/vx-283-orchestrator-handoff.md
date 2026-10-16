# VX-283 — orchestrator handoff (drafted early, 2026-10-15 ~02:00, per SessionResiliencyProtocol addendum 7)

**Use this only if the orchestrator session `vx-283` has died or must cut over.** Verify, never trust: read the run
record's LIVE STATUS and `git log` first. The run record `notes/plans/fixes/vx-283-sidebar-library-polish.md` is the
truth; this file is the map.

## Paste-ready kickoff for a successor orchestrator

> You are the successor orchestrator for VX-283 (Run: Sidebar & Library polish), architect shape, Opus. The author
> is ASLEEP under her overnight mandate (quoted verbatim at the top of the run record): rule provisionally, leave her a
> morning handoff, and whichever of VX-283/VX-336 merges last cuts the release and publishes it. Worktree
> `~/dev/variorum-vx-283`, branch `vx-283-sidebar-library-polish`. Read CLAUDE.md, the run record IN FULL (its LIVE
> STATUS first), `notes/plans/fixes/vx-283-orchestrator-handoff.md` (this file), and the memory file
> `vx-283-run-state.md`. The stage is coordinated by the session **oct13coordinator** (REQUEST → READY → GO → RELEASE;
> relay every release the MOMENT it happens). Cast: `opus-implementer` at xhigh (one active at a time), screenshot
> walkers = a fresh general-purpose agent with model opus at xhigh after every unit (her rule), cold reviews =
> `fable-reviewer` at xhigh (her word), cross-model flow. No commit trailers, ever. Continue from the record's LIVE
> STATUS.

## State at drafting (verify each)

- **U1 (VX-285/286/287/289):** built + walked; the fix legs U1b → U1c → U1d (her memo rulings: follow only on her next
  act; the fade reshaped, cap 0.8). U1d's stage window GREEN (434/96; R-I/R-J red as named). **U1d's re-walk was
  running** at drafting (claim `vx283-u1d-walk`, expiring 02:46). If its record says HOLD on every row, U1 closes.
- **U3 (VX-121/175/20/245 + VX-359):** proven by its closing window (R-ALL red as named); its walk held W1/W3/W4/W5;
  **W2 (VX-175) failed** → the ruling P-U3-5 (the wrap reads stable widths only) is recorded; **U3b NOT yet built** —
  a fresh implementer, then a short test window + a re-walk of W2.
- **U2 (VX-288 + the chip):** an implementer was building at drafting; READY FOR STAGE expected.
- **Tickets born:** VX-344 (Open list multi-select, Parked), VX-359 (the separator, in U3), VX-360 (the shell's
  same-frame navigation race, Backlog/Medium — product, outside this run).

## What remains, in order

1. U1d's re-walk verdict → close U1 (or a narrow fix if a row fails — her two rulings stand).
2. U3b (P-U3-5) → its window → W2 re-walk → close U3.
3. U2's window → its walk → close U2.
4. **The ladder:** a fresh `fable-reviewer` at xhigh, `notes/REVIEW_PROMPT.md` verbatim, over the whole run's diff
   (`git diff origin/main...HEAD`); findings repo-first; the Opus implementer applies confirmed fixes; ≤3 rounds.
5. **Closeout** (CLAUDE.md's ritual + the new filed-ticket triage rule): merge `origin/main` into the branch first
   (VX-336 will have merged); the Mac run over every suite exercising a changed source file; AppSpec §12 contract
   lines (the Open list's height, Close Note ⇧⌘W and Close All, the follow rule, the edge fade, the toast placement,
   the controls row's wrap, the dark heading) + an §14 entry (roll the oldest per the ~5-efforts rule); QUESTIONS
   bundle (every P-… provisional, at the merge moment); the master plan's in-flight row retired + a closeout
   paragraph; tickets closed; MOBILE PARITY: "nothing mobile-visible" (the Open list and the Library controls are
   Mac-only — confirm); the handoff `notes/handoffs/vx-283-handoff.md` (her checklist at top: every provisional to
   overturn, what to try in the 0.9.8 build); PR `VX-283: …` merged as a merge commit via the coordinator.
6. **Release (her mandate):** if VX-283 merges after VX-336 (which cuts 0.9.7), cut **0.9.8**: bump MARKETING_VERSION;
   notes written by us (one line per bullet; her review waived — her word); the coordinator's rule card (main frozen
   from the bump to the stamp; move `~/dev/variorum/default.profraw` to /tmp; the MCP-link gate — the page is live,
   200); `Tools/Release/release.sh` at a zero-instance window; DMG first, appcast second (memory: Variorum release
   publishing); serialize site deploys with vx-336; then the /Applications refresh under the full rule card (A1 copy
   of her real store + key files first, the SAME version+build as the website, nothing launched).
