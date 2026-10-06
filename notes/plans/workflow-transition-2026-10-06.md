# The workflow transition — Linear, VX, parallel sessions, PRs, the stage (2026-10-06)

**Status: RULED 2026-10-06 (the author, this session) — building the same day.** This file is the
binding record of the transition and its runbook; CLAUDE.md's "Tracker & parallel work" section
carries the live rules. The transition commits land directly on `main` at her "go ahead and do all
of that work" — the bootstrap exception; everything after bootstrap follows the PR rule it installs.

---

## 1. Her rulings (2026-10-06)

1. **Tracker: Linear** (the proposal's Plan A), free tier first — *"i can buy the 10 dollar plan if
   *[removed for publication]*
   declined for now — *"i'd like to start with the UI polish"*; bug-title privacy accepted
   (*"i'm not that worried about bug name privacy and the ui is a plus"*).
2. **Prefix: VX.** VR retires (it was two days old — minted 2026-10-05 at the librarywalkpolish
   sitting, riding GitHub issue numbers). Her word at kickoff: *"I also don't like VR for naming
   anymore — maybe VX? I like the V prefix and even the two letter prefix."*
3. **Branches & PRs**: every build effort on a ticket-named branch, merged by PR; **merge commits
   only, never squash or rebase-merge** (canon cites commit SHAs; squashing would orphan them).
   `main` gets require-PR protection with her admin bypass.
4. **Standing fixes**: new fixes are VX tickets; **the open letters are RE-MINTED as VX tickets —
   "no more letters !! I'm tired of letters."** The lettered-ledger era is closed; the 17/19 ledger
   files become archives of their run records (their CLOSED entries' records stay exactly where
   they are; nothing moves).
5. **KnownIssuesAndTechDebt.md is absorbed into tickets** (the file becomes a stub after the mint
   pass; rich row prose rides into the ticket verbatim, with links back to any plan files it names).
6. **GitHub Issues: migrate, validate, then DELETE** — *"just delete"* — with the full JSON export
   committed first as the permanent archive.
7. **Small-fix records** (her delegation — *"what do you think? my instinct is that PR alone might
   be sufficient"* — the orchestrator's call, recorded here): a small fix's record is its **commit
   message + PR** — the commit message states the traced mechanism and the pin (red-on-old,
   revert-verified), so the hallucination-guard evidence lives in git history, which is in-repo and
   offline-readable. Any fix that runs a review ladder, or whose diff touches `Sync/`, custody/
   keychain, or the editor seam, still lands a repo record file: `notes/plans/fixes/vx-NNN-<slug>.md`.
8. **The master plan accommodates several simultaneous working sessions and merges** (her rider) —
   the "Current phase" pointer becomes the IN-FLIGHT table; see §6.
9. `notes/AppSpec 2.md` (a stray July 6 Finder-duplicate of the pre-split AppSpec) deleted at her word.
10. Organization delegated: *"you are the organizer I just tell you what needs to be done."*

## 2. The one rule (the needle)

**Linear holds status, sequence, and numbering; the repo holds truth, rulings, and records.**
A ticket body is a pointer plus a one-liner, never a spec. Any ruling born in a ticket thread lands
in canon at the merge, exactly as a sitting's would. Nothing about the canon system changes:
AppSpec, OverallModel, CoreDescription, SyncSpec, plan files, archives, QUESTIONS.md are untouched.

## 3. The artifact map

| Artifact | Fate |
|---|---|
| AppSpec / OverallModel / CoreDescription / SyncSpec / archives / QUESTIONS.md | Unchanged — canon. |
| `notes/plans/phase-*.md` plan files | Unchanged — the spec + record per effort; the Linear project points at the plan file. |
| `notes/DetailedPlanForPhases.md` | Keeps the phase table, the closeout paragraphs, ONE current-order table; "Current phase" → the IN-FLIGHT table. Superseded-order tables stop accreting — ordering lives on the board. |
| `notes/FuturePhases.md` | Unchanged (canon rows); far-off efforts may get Backlog projects pointing at it. |
| Standing-fixes ledgers (17, 19) | Archives of their run records. No new letters. Open letters re-minted as VX tickets (census §8). |
| `notes/KnownIssuesAndTechDebt.md` | Rows → tickets at the mint pass; then the file is a stub pointing at the board + snapshot. |
| `notes/TICKETS.md` | NEW — generated snapshot of open VX tickets (`Tools/vx sync`), refreshed at bout starts; never hand-edited. |
| GitHub Issues | Exported to JSON (committed), then deleted after the validation window. Future GitHub numbers accrue to PRs only (burned numbers never return — GitHub shares one counter and never reuses). |

## 4. The Linear shape

- One workspace; **team key VX** (issues number VX-1, VX-2, … — independent of GitHub's counter).
- **Project = a phase/effort** ("13o — Search"); description = one paragraph + the plan-file pointer.
  Initiatives optional later (e.g. "Road to 🚀").
- **Issue = the work item**: one umbrella ticket per phase (names the branch/PR), children per
  acceptance unit where useful; bugs/debt/polish minted freely — filing a bug no longer owes a
  ledger letter or an immediate owner.
- **States** (adapt Linear's defaults): Triage · Backlog · **Parked** (with reason — the old
  "deferred with owner" discipline) · **Needs Lillian** (the adjudication queue, visible across all
  parallel efforts) · Ready · In Progress · In Review (the ladder) · Done · Canceled.
- **Labels**: bug · debt · polish · feature · exploration · mobile.
- **Issue template "Standing fix"** carrying the binding checklist: traced concrete mechanism →
  red-on-old pin → verified by revert → cold review (Opus; Fable for `Sync/`/custody/editor-seam;
  author may waive) → disposition landed.
- **GitHub integration**: branch-name format the bare `vx-123-slug` style; PR auto-link via branch
  name or "Fixes VX-123"; auto-move In Progress on PR open, Done on merge.

## 5. The stage — who owns the machine (`Tools/stage`)

An exclusive lock for everything that touches the screen or a store on the Pro: GUI walks/cliclick,
launching the Debug app, UI-driving test runs, dev-store resets/reseeds, and the `/Applications`
Release refresh (which keeps its zero-instance window besides). Headless `swift build`/`swift test`
never needs it. The lock lives at `~/.variorum/stage.d/` — outside every worktree, shared by all
sessions on the machine; claims carry who/reason/expiry and EXPIRE (a dead session can't wedge the
Mac); stealing a live claim is the author's word only. `stage status · claim · renew · release · log`.
**The Air never runs suites, walks, or flashing locally — it has no stage.** It ssh'es to the Pro
and claims this one (`ssh <pro> '~/dev/variorum/Tools/stage claim …'`), per her kickoff words: the
Air is "never possessed by test suites." Sessions may also coordinate by direct message (the local
session roster); the lock file is the arbiter, messages the courtesy channel.

## 6. Parallel sessions

- **One worktree per effort**, the mobile precedent: `~/dev/variorum-13o`, `~/dev/variorum-13x`, …
  (`~/dev/variorum` stays `main` — integration + her daily canon edits).
- **Kickoff declares the effort's surfaces** and checks overlap against the other in-flight rows.
- **At most ONE `Sync/`-or-custody-touching effort at a time** (the Fable rider unchanged).
- **Closeouts serialize**: two efforts never close at once; first-ready merges first, the next
  rebases onto it. The shared ledgers (master plan, TICKETS.md, QUESTIONS.md, AppSpec §14's delta
  line) are touched only at merge moments, on latest main, by the merging session.
- The master plan's IN-FLIGHT table is the roster (one row per effort: ticket · branch · worktree ·
  machine · state); Linear carries day-to-day status.

## 7. The migration runbook

**Phase 0 — her hands (GUI/accounts):**
- [ ] Linear workspace + team with key **VX**; add the states/labels of §4 (or leave to Fable via MCP).
- [ ] Install Linear's GitHub app on `lduarte-io/Variorum`; set branch format to the bare
      `vx-123-slug` style; enable the PR automations (In Progress on open, Done on merge).
- [ ] Linear MCP for Claude Code, user scope:
      `claude mcp add --scope user --transport http linear-server https://mcp.linear.app/mcp`
      then `/mcp` in a session → authenticate (browser OAuth).
- [ ] A Linear **personal API key** (for `Tools/vx sync`) stored in the login Keychain:
      `security add-generic-password -s variorum-linear -a "$USER" -w` (prompts; paste the key).
- [ ] `gh auth login -h github.com` (the current token is invalid).
- [ ] GitHub branch protection on `main`: require a pull request before merging; keep her admin bypass.

**Phase 1 — the mint pass — ✔ RAN 2026-10-06 (the API-key road; 59 open tickets, 15 projects):**
- [x] Projects + FLAGSHIPS: **13o = VX-5** (`vx-5-13o-search`) · **13x = VX-6**
      (`vx-6-13x-library-portability`) · **13s = VX-7** (`vx-7-13s-voice-onboarding`) — worktrees
      `~/dev/variorum-13o` / `~/dev/variorum-13x` created; all three branches pushed.
- [x] THE FULL FUTURE ROADMAP minted as backlog projects with flagships (her ask — "the delight
      path, the mcp path"): 12 Hardening = VX-22 · 13h = VX-23 · 13m = VX-24 · 13n MCP = VX-25 ·
      13q Delight = VX-26 · 13t = VX-27 · 13w = VX-28 · 16 Images = VX-29 · 18a = VX-30 ·
      18b = VX-31 · Mobile = VX-32 · v1 release readiness = VX-33.
- [x] Open letters re-minted (19h → VX-8 · 17r → VX-9 · 17s → VX-10 · 17w → VX-11 · 17x → VX-12 ·
      17z → VX-13 · 17j → VX-14); succession notes at both ledgers' heads.
- [x] Open VR items re-minted (VR-120/121/123/124 → VX-15/16/17/18 Parked post-release;
      VR-125/126/127 → VX-19/20/21 Todo + Pre-launch); `notes/plans/vr-to-vx-map.md` written.
- [x] KnownIssues ABSORBED: the file FROZEN at `notes/KnownIssuesArchive-2026-10-06.md` (tickets
      cite rows by line number; freeze note appended so lines stay stable), stub in its place;
      rows → VX-34…57 (project-12 FAMILY tickets by the rows' own family names; per-row tickets
      where individually schedulable; the two flagged mobile rows VX-55/56 stand alone) +
      VX-58…63 (Parked singles: ex-18n, accessibility, EPUB, grammar, more export, Apple Notes
      import). The dedupe held: row 108 IS VX-16, rows 44/96/104 ARE VX-9/11/12.
- [x] `notes/TICKETS.md` generated (59 open); the In-flight table carries the three ready rows.
- Label note: the polish class wears Linear's existing **Improvement** label (no separate Polish
  label); Debt · Exploration · Mobile · Pre-launch minted new beside Bug/Feature/Improvement.
- Her paid-plan note (2026-10-06): she bought the Linear subscription pre-emptively — the
  250-issue free cap is MOOT; archive-to-stay-under-cap guidance is void.

**Phase 2 — validation:** ~1–2 weeks of real use across the parallel efforts; her word closes it.

**Phase 3 — GitHub cleanup (only after her validation word):**
- [ ] Export ALL issues (open + closed, with comments) to
      `notes/source/github-issues-export-2026-10.json`; commit.
- [ ] Delete every GitHub issue (`gh issue delete <n> --yes` loop; permanent). Burned numbers never
      return; from here every new GitHub number is a PR.

## 8. The open-item census (to re-mint; verified 2026-10-06)

**Open letters:** 19h (the broadcast-driven test-host shell class — its GitHub index is VR-112) ·
17r (stamp faces' midnight rollover) · 17s (the drop-out returner's rescue) · 17w (VisualWalk
hardening) · 17x (structural undo/redo's false receipt — undo-core design) · 17z (the
duplicate/version-of marking EXPLORATION — options for her, zero build before her ruling) ·
17j (PARKED — the "open your library without Variorum" recipe; ticket born Parked).
*(17k is a pointer to 18a, not its own ticket; 17e/17y and all 19 letters a–g are CLOSED.)*

**Open VR items:** VR-112 (=19h) · VR-120 (book reorder returns properly) · VR-121 (Book Panel drag
feel; = the KnownIssues row) · VR-123 (Library scroll smoothness residual) · VR-124 (the drag's
delectable moment) · VR-125 (Timeline's books-honesty bug — hoped pre-launch) · VR-126 (the dark
heading band — hoped pre-launch) · VR-127 (Book Panel grips under a derived sort — pre-launch,
the Wednesday polish family). The GitHub export reconciles anything this census missed.

**VR → VX map:** lands in `notes/plans/vr-to-vx-map.md` at the mint pass.

## 9. Naming & pointer conventions (the "what number is that epic?" contract — settled 2026-10-06)

- **The grouping is a Linear PROJECT** — Linear's native epic-equivalent; when she says "epic,"
  sessions hear "Linear project." Projects have names, not numbers, so:
- **Every effort gets ONE FLAGSHIP TICKET** — the project's first issue, titled the effort's name.
  The flagship's number IS the effort's number; it names the branch (`vx-NNN-slug`) and the PR
  (`VX-NNN: …`); its description carries the plan-file path. Child tickets per acceptance unit /
  bug hang beside it in the same project.
- **Plan files:** existing phase files keep their names (`phase-13o-*.md` — the phase vocabulary
  is canon); NEW post-phase efforts name theirs `notes/plans/vx-NNN-<slug>.md`. Fix records:
  `notes/plans/fixes/vx-NNN-<slug>.md` (§1 item 7).
- **Two-way pointers, always:** the plan file's header carries `Ticket: VX-NNN · Project: <name> ·
  Branch: vx-NNN-<slug>`; the ticket's description carries the plan-file path. The repo stays the
  one source of truth; Linear is the pointer system over it.
- **Answering "I'm ready to tackle the MCP connection epic — what number is that? what are we
  doing?":** look in `notes/TICKETS.md` (or Linear) for the project, read its flagship ticket's
  number, open the plan file its description names. Every session can answer this offline from
  the snapshot + the plan file.
- **THE ORPHAN-POINTER SWEEP (her ratification 2026-10-06 — "we'll make sure that any linear
  ticket that doesn't have a plan-file path gets found and added"):** she generally goes through
  Fable for issues and plans, so orphans should be rare; any ticket minted without a repo pointer
  (a phone-minted one, a quick note in the UI) gets its pointer added at the next triage — the
  session that notices owns the fix, and a bout-start `vx sync` read is the natural notice point.

## 10. What deliberately does NOT change

The cast and ladder rules, the review prompt, sizing guidance, the resiliency protocol, the
author-only list, canon discipline, the §12 lockstep rule, the memory-repo rhythm, the two-Mac
pull-at-start rule (which now also refreshes the snapshot: `Tools/vx sync`, best-effort), and the
hard rule that reading preflight is never delegated.
