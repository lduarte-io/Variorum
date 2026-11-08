# The last wave before open-sourcing — the plan (VX-894's sitting, 2026-11-08)

**The frame, hers:** this is the final batch of code before the project switches whole to the
open-source flip. Every member earns its seat by (a) the public repo needing it or (b) being cheap,
already ruled, and making the frozen app better. *[removed for publication]*
*[removed for publication]*
One release closes the wave (the runway rule), then the code pause.

**Her two open calls at kickoff:** (1) Run S and Run P in PARALLEL worktrees or sequential;
(2) the crash-trace member — confirm it is the VX-661 + VX-855 family (one trace, both sightings).
Plus Run S's standing ask: Fable or Opus implements (vx-544's record leans Fable — custody).

---

## Run S — vx-849 · the sync lane ("Run: the typed-over rescue and the offline unlock retry")

Members, in her ruled order: **VX-683** first (the sync-pull-into-debounce overwrite; design RULED
R-683-1…4 — option C: the flush-first `beforeRound` hook + the guarded autosave rescue; the memo is
`notes/plans/fixes/vx-683-sync-into-debounce.md`), then **VX-544** (the offline typed-unlock retry;
design D-544 carried whole in `notes/plans/fixes/vx-544-offline-typed-unlock.md`, kickoff message
inside it; the `beforeRound` hook is built ONCE and serves both), then **VX-664** (the fold — the
general outside-change pane class behind VX-440's W-1).

- Branch `vx-849-…`, its own worktree; holds the ONE Sync/-custody slot, stage per nov5's queue.
- **Fable cold-reviews, mandatory** (Sync/ + custody + the editor seam via VX-664/the autosave guard);
  implementer = HER CALL at kickoff. Preflight adds: SyncSpec WHOLE, CastleRules WHOLE,
  `notes/sync-postmortem-fragments.md`, TEXTKIT2_NOTES (the pane adoption seam).
- Evidence: convergence tests for every sync change (unreviewed otherwise), the planted-road pins,
  VX-544's custody DRILL (the two-Mac steps 8–9 — HER HANDS, bundle the ask).

## Run P — "Run: the last polish" (ticket minted at kickoff; members become sub-issues)

Batched by surface, all ruled or Confirmed:
1. **Search:** VX-895 (the facet header doesn't follow the pick — trace, don't assume).
2. **Icons & badges:** VX-900 (the icon twins standardized — dimmed when the server's off) ·
   VX-905 (badges switch → Settings ▸ MCP) · VX-896 (masthead one-line threshold).
3. **Trail & menus:** VX-902 (heading drops "From ‹client›") · VX-903 (the dial moves up — the
   VX-281 geometry trap is IN the ticket) · VX-904 (collapsible client groups) · VX-901 (Index ⋯).
4. **The wire:** VX-775 (error to her, truth to the client — RULED) · VX-891 (hidden-vs-missing
   asymmetry — the fence's byte-identical promise).
5. **Wording sweep + small bugs:** VX-897 (em-dashes → commas, both lines) · VX-898 ("the take
   now" on lineage members) · VX-909 (the sync-pause duplicate) · VX-889 (Make a Gathering wing).
6. **The crash trace (pending her confirm):** VX-661 + VX-855 as ONE family trace (exit/teardown
   class) — outcome is a traced mechanism or a documented defer, not necessarily a fix.
- Standard cast: Fable orchestrates and cold-reviews; Opus implements; `opus-reviewer` eligible for
  batches 2/3/5 (no seam); Fable reviews batch 4 (the door's meaning) and batch 1 if the trace
  touches the listing seam. No Sync/ anywhere — runs free of the slot.

## Run G — "Run: open-source gating" (after Run S releases the slot)

1. **VX-751 — the security re-verify:** the 13y quota numbers re-checked against today's world;
   EVERY RPC door added since 13y proven quota'd or deliberately exempt with the reason written
   into the record; plus the no-open-finding-ships-as-roadmap pass over Castle/sync/MCP tickets.
2. **VX-752 — the outsider build road:** cold-clone `swift build` + Mac app build proven on a
   signing-free path; build docs; the three GRDB-fork rows (fork README, immutable tag, audit
   sweep of the fork); README stance / CONTRIBUTING + auto-close / SECURITY.md / the VX-nnn
   pointer line / the maintenance-model sentence.
3. **VX-893 + VX-892:** fix the cheap belt or an explicit defer-with-reason, each written down.
- Fable reviews (Server/ + custody-adjacent). Touches `Server/` → takes the slot after Run S.

## The parallel OSS track (no code wave needed; state as of this sitting)

- **VX-748 machine arm DOUBLE-GREEN** (gitleaks: 9 findings, 0 secrets, all classified public-by-
  design; trufflehog: 0/0 over 72,827 chunks). Re-run both at flip time. The PAT file never
  touched history. Two rows for her bless: the Fragments/Suite publishable keys in history.
- **VX-750:** license AGPL-3.0 CONFIRMED (file lands at the flip) · *[removed for publication]* ·
  trademark DEFERRED, not a gate. Remaining: the per-dependency license table.
- **After the wave (the full-focus phase):** VX-754 (eyes-on sweep; *[removed for publication]*) → VX-749 (filter-repo rehearsal; publish as a FRESH repo) →
  the day-one writing (LICENSE · the short post · the README-of-the-record, VX-753's slice).
- **Whenever:** VX-747 (the open format — her word: post-flip is fine) · VX-755 (the beyond-repo
  verdicts; her Air prompt-record read-through) · the tour posts and video (trail the flip).

## Kickoff messages (paste-ready)

- Run S: `/run-phase vx-849` — or `/architect-phase vx-849` if she wants sittings; the memo and
  D-544 carry the designs, so run-phase suffices. Name the implementer in the same breath.
- Run P: `/run-phase vx-895 vx-889 vx-900 vx-901 vx-902 vx-903 vx-904 vx-905 vx-775 vx-891
  vx-896 vx-897 vx-898 vx-909` (+ `vx-661 vx-855` on her confirm) — the skill mints the run ticket.
- Run G: `/run-phase vx-751 vx-752 vx-893 vx-892`, after Run S merges.
