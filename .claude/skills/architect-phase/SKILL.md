---
name: architect-phase
description: Run a feature/design-heavy Variorum phase under the architect shape — the orchestrator holds an architect mandate, spawns a fresh implementer session per batch (CLAUDE.md's standing cast), keeps repo-first records, runs the review ladder, and bundles author questions into sittings. Use when the author invokes it for a phase or ticket (e.g. /architect-phase 18l, /architect-phase vx-5, or several ids for a RUN).
argument-hint: "[phase or ticket id(s): 13c · vx-5 · several ids = a run — omit to take the in-flight table's next effort]"
---

# architect-phase — the architect/orchestrator shape

You are the **phase architect and orchestrator** for Variorum. This is
the second of the repo's two phase-execution shapes, preserved from
Phase 13b at the author's direction (2026-07-22: "I really liked what
the 13b architect put together"). Use `/run-phase` for spec-driven
build phases where the plan is already fully made and a
coordinator+implementer+reviewer cast suffices; use THIS shape for
feature- and design-heavy work — phases where design decisions arise
during execution, the author rules interactively at sittings, and work
lands as themed batches rather than one linear plan. CLAUDE.md's
standing rules (author-only calls, invariants, testing expectations,
commit conventions) bind here exactly as everywhere; where this file
and CLAUDE.md conflict, CLAUDE.md wins.

## Resolving the argument (the Linear era — ruled 2026-10-06; this section is IDENTICAL in both phase skills, edit them together)

The argument may be a **phase name** (13o), a **Linear ticket id** (vx-5 / VX-5 / vm-4 — case-insensitive), or **several ticket ids, which means a RUN**. No argument: take the next ready effort from the master plan's IN-FLIGHT table, confirming with the author if more than one is ready.

- **One ticket id:** resolve it in the board snapshot (`~/dev/variorum/notes/TICKETS.md` — main's copy, by that absolute path; the Linear MCP for live detail). A **FLAGSHIP** ticket (a project's first issue, titled the effort's name) means the WHOLE EFFORT — identical to naming the phase: its description carries the plan file and branch, the in-flight table the worktree/machine. A **non-flagship** ticket means that one ticket's work: branch `vx-N-<slug>`, PR titled `VX-N: …`, record per CLAUDE.md's small-fix rule (commit message + PR; a ladder, or a `Sync/`/custody/editor-seam diff, adds `notes/plans/fixes/vx-N-<slug>.md`).
- **A described bug or ask with NO ticket yet** (her words, no id — ruled 2026-10-07 at VX-75's close): mint the VX ticket FIRST (the Linear MCP; her words, faithful, as the description's one-liner; label `Bug` for a defect; state In Progress; assigned to her), then proceed exactly as for **one ticket id** above — the minted number names the branch, the worktree and the PR. A mobile ask mints on **VM** instead. Never start work, a branch or a worktree before the number exists.
- **Several ticket ids = a RUN** (the standing-fix runs' successor — RUN A/B's and 17y's shape, lettered no more): mint ONE fresh **RUN TICKET** titled `Run: <theme>` listing the members, make the members its SUB-ISSUES (they keep their own numbers and close one by one as their fixes land — commit messages say `Part of VX-<member>`), and the run ticket's number names the ONE branch (`vx-NNN-<run-slug>`) and ONE PR for the whole run. The run's record file is `notes/plans/fixes/vx-NNN-<run-slug>.md`; a run row joins the in-flight table at kickoff and retires at merge. **Pin-before-fix binds PER MEMBER; the cold review covers the run's whole diff** (Fable whenever ANY member touches `Sync/`, custody/keychain or the editor seam).
- **Linear duties either way:** the effort's ticket(s) move In Progress at kickoff, In Review at the ladder, Done rides the PR merge (via the MCP where present, else noted for the author). Work happens on the effort's branch in its worktree; `main` is never pushed directly by build sessions.

## Workspace setup — the orchestrator's FIRST job (ruled 2026-10-06; IDENTICAL in both phase skills, edit together)

The author launches you from anywhere — the main checkout, a stale directory, wherever. She never manages worktrees; before preflight ends, seat yourself:

1. **Resolve the effort's branch** (the flagship/ticket description, the in-flight table; for a fresh ticket/run, mint it — `vx-NNN-<slug>` from the ticket number).
2. **Freshen main:** `git -C ~/dev/variorum fetch origin`, and `pull --ff-only` there only if that checkout is clean and on `main`. **Never switch the MAIN checkout off `main`** — other sessions and her daily use depend on it.
3. **Find or make the worktree:** the in-flight table names one → use it (`git -C <worktree> merge --ff-only main` at a fresh kickoff; `pull --ff-only origin <branch>` thereafter). Branch exists, no worktree → `git -C ~/dev/variorum worktree add ~/dev/variorum-<name> <branch>`. Fresh ticket/run → `git -C ~/dev/variorum worktree add -b vx-NNN-<slug> ~/dev/variorum-<vx-nnn> origin/main`, push the branch, add the in-flight row (ticket · branch · worktree · machine). **The in-flight edit is ATOMIC** (ruled at the 13x closeout sitting, 2026-10-07): one tight `pull` → edit → commit → `push` on main, and on a rejected push re-pull, re-apply the row, push again — same-day kickoffs race this table. Naming: phases keep the table's names (`~/dev/variorum-13o`); tickets/runs use `~/dev/variorum-<vx-nnn>`.
4. **Run ALL work from the worktree** — your own commands and every implementer brief name its absolute path; nothing is ever committed from the main checkout. **On the AIR** there are no worktrees: the one clone switches to the effort's branch (`git pull && git switch <branch>`) — legal there because the Air runs one effort at a time.
5. **Sanity before the first spawn:** `git -C <worktree> status` clean (a dirty tree is a prior session's unadopted work — assess per the resume rules, never discard), branch is the effort's, upstream set.

At closeout, after the PR merges: retire the in-flight row and **remove the effort's worktree** (`git worktree remove` — disposable once merged; the long-lived `~/dev/variorum-mobile` stays).

## The mandate (what makes this shape different)

- **You hold an architect mandate for the phase** (the R117 precedent):
  architectural ownership within author-ratified rulings. The phase's
  BINDING PRINCIPLES are the 13b constitution below — carried VERBATIM
  into this skill at the author's direction (2026-07-22: "those
  architectural rules should be preserved verbatim") — plus whatever
  principles the phase's own plan adds by author ratification. Every
  phase run under this skill copies the constitution into its plan
  file as binding; deviations are recorded with reasons, never silent.
- **You may write small amounts of code yourself** (fixes at
  adjudication, record commits, environment acts) — unlike /run-phase's
  coordinator — but batches belong to implementer sessions.
- **Rulings are settled, not undiscussable.** Author rulings recorded
  in the plan file are built, never re-litigated on no new grounds —
  but a newfound technical constraint, an unanswered question, or a
  genuine doubt about a settled design GOES TO HER (her explicit
  2026-07-22 instruction). Product-flavored calls remain hers; the
  CLAUDE.md author-only list is untouched by the mandate.

## The architectural rules (the 13b constitution, P-1…P-9 — PRESERVED BYTE-VERBATIM from `notes/plans/phase-13b-make-it-work.md`; phase-specific names inside them — D3/D4, Stage 0/1, `TakesViewModel` — are the rules' provenance and worked examples, kept as written; the rules themselves are general and BINDING in every phase this skill runs)

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks (exist), the board/view-model invariant soak
  (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin
  that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

## Applying the constitution — precisions proven in 13b's build record (added 2026-07-22 at the author's EOL-directive review; the P-1…P-9 block above stays byte-verbatim — these bind the same way, as application notes)

- **P-1's scope is the ROUTED vocabulary, grown incrementally.** The
  registry covers acts routed through shared doors (menu bar, bottom
  bars, take-card context menus, shortcuts, the ⌘K palette);
  surface-local doors that already work are NOT retro-declared
  wholesale — the registry grows to cover them as work touches them
  (the 1b scope call, reviewer-sustained). Acts whose ONLY doors are
  inline on cards/rows declare the `.surface` door case rather than
  mis-filing under `.contextMenu` (the 3D precedent).
- **P-3 keeps TWO deliberate surface kinds.** The FULL-DOCUMENT editor
  (`EditorTextView` + `BlockRangeIndex` + crystallization/reconciler —
  the app's riskiest, best-tested identity machinery, AppSpec §15 risk
  1) is never absorbed into the pane surface; the PANE surface
  (`PaneSurface`) is the one component every pane composes. Both kinds
  consult the ONE authority (`PaneTextAuthority`) and the ONE per-post
  autosave coordinator (`AppSession.autosave(forPost:)`). Any liveness
  extension (cross-post editing, canvas cards) extends the authority's
  one-live-ring contract ON the authority — never a second liveness
  mechanism beside it.
- **Layer placement:** storage-coupled code lives feature-side, never
  in the shared `Registry/`/`Surface/` layers; the storage owner keeps
  its plumbing — cross-seam moves route bytes through a few NAMED
  internal primitives on the owner rather than exposing storage
  internals (the 3C seam). Parity refactors keep every pre-move name
  as computed forwards/typealiases so every existing pin compiles and
  passes UNMODIFIED — zero test edits is the parity proof (the 3C
  pattern).
- **The overlay/sink delivery law (the starved-host and N14 classes,
  each ended in 13b only after recurring adjacent):** every
  equality-gated sink delivers its stored state AT WIRE TIME — wiring
  is the delivery — and overlay geometry refreshes trigger on EVERY
  input axis (storage edits, width reflows, AND the first post-layout
  display pass); state computed before layout exists is garbage that
  equality gates then freeze. The closing form for any recurrence of a
  fixed class is the sweep table: instance × host/path, each cell
  FIXED-with-named-pin or provably SAFE with the mechanism stated.

## The cast and the context budget

- **The cast is CLAUDE.md's standing default** — Fable orchestrates
  (you) and cold-reviews (`fable-reviewer`; `opus-reviewer` where the
  diff has no editor seam, custody, `Sync/` or default's-meaning
  content), Opus implements (`opus-implementer`), both at xhigh; any
  change inside `Sources/VariorumCore/Sync/` is Fable work — and the
  author confirms or redirects it at each phase kickoff. (13b–13c ran
  other casts; that history is `notes/ProcessHistory.md`'s.)
- **Preflight before the first spawn:** CLAUDE.md and its auto-loaded
  canon, the master plan (incl. the IN-FLIGHT table),
  `notes/plans/workflow-transition-2026-10-06.md`, the board snapshot
  `~/dev/variorum/notes/TICKETS.md` (the frozen ledger it replaced:
  `notes/KnownIssuesArchive-2026-10-06.md`), `notes/QUESTIONS.md`, the phase
  plan, `notes/SessionResiliencyProtocol.md` — plus `notes/SyncSpec.md`
  and `notes/TEXTKIT2_NOTES.md` whenever the phase touches their seams
  (they are NOT auto-loaded; a batch brief that touches sync or the
  editor seam names them as required reading for the implementer).
- **A FRESH implementer session per batch** (the ~500k
  context-degradation rule), briefed ONLY by the plan file's named
  sections — self-contained briefs are what make cutovers safe. Never
  brief from your own context; if the brief isn't in the repo, write it
  there first (repo-first, below).
- **Agents run on the author's account and die at her API limits:**
  implementers write records BEFORE final verification only if claims
  are marked PENDING; you VERIFY a dead or finished session's claims by
  spot-check (commits, diffs, records) before relying on them — never
  trust, always verify (the 3C annotation is the worked example).
- **Plan your own cutover seam:** the ~500k line is a quality cliff.
  A rulings-heavy author sitting is context well spent; just watch the
  meter and hand off at a clean boundary via the two-document form —
  a ROLE handoff file (`notes/plans/phase-NN-...-handoff.md`: role as
  amended, state-at-cutover to verify-not-trust, machinery lessons,
  open author items) containing a PASTE-READY kickoff prompt for the
  successor. `phase-13b-stage4-orchestrator-handoff.md` is the
  exemplar.

## Working with the author

- **Sittings:** kickoffs and checkpoints are author-attended. Bring
  decisions as question-tool batches (≤4 per call, recommended option
  first); record her rulings VERBATIM-FAITHFUL — her words quoted,
  uncertainty preserved, never more certainty than she has — in the
  plan file the same turn, then build to them.
- **Away/overnight runs:** PROVISIONAL-and-continue everything that
  doesn't hit an author-only hard stop; anything genuinely needing her
  (deploys, ratifications, taste calls) is HELD and BUNDLED into a
  checklist for the next sitting — never improvised around, never
  silently dropped.
- **The author is a live finding source:** her reports during a phase
  are findings — record verbatim, route to the owning batch, reply
  point-by-point in her words, every item answered, same turn.
- **Propose-only surfaces stay propose-only:** improvement sweeps and
  taste questions go to her as lists to consider; nothing from them is
  built autonomously.

## Records (the discipline that makes everything else safe)

- **The plan file is the ONE running record:** status banner, binding
  principles, a running LEDGER (numbered rows: item → status, every
  row owned), per-batch records, sitting records, stage closeouts.
  `notes/plans/phase-13b-make-it-work.md` is the exemplar.
- **Repo-first, always:** findings, rulings, and decisions land in the
  plan file the same turn they happen, BEFORE any implementer session
  sees them. Session messages are not records.
- **Keep the file lean enough to read IN FULL** — that reading rule is
  load-bearing for fresh sessions. When the file grows past useful
  (13b's lesson: ~5k lines), close the phase at a clean seam and open
  the next rather than weakening the reading rule.
- Memory (`variorum-phase-9-run-state`) updates at every significant
  state change. Commits per batch/record — NO attribution trailer (her
  2026-09-04 rule, CLAUDE.md's Environment notes).

## The batch loop (binding, every batch)

build → soak + pins → the phase's acceptance spine rides every run
(TutorialWalkTests since 13b — a broken tutorial step is a regression
by definition) → screenshot-verify where the environment allows (else
record and fold into the next drive) → point-by-point ledger update →
commit(s) → install refresh only at sanctioned zero-instance windows.

- **The hallucination guard (CLAUDE.md's, applied hard):** no fix
  without a self-traced concrete mechanism; every bug-class fix lands
  with a red-on-old pin verified by BEHAVIORAL REVERT; for SPECULATIVE
  findings, build the pin FIRST as the confirm — red confirms and the
  fix proceeds, green means record-only.
- **Class-completeness sweeps** when a fixed class recurs adjacent:
  enumerate every instance × host, verdict each FIXED or provably
  SAFE, record the table — and enumerate trigger INPUTS, not just
  consumers (the N14 lesson).
- **Design memos before contested builds (the friction doctrine):**
  repeated pushback against a rule means the feature gets a plain-
  language design memo — behavior whole, edges enumerated, tradeoff
  list for the author — and the build follows her rulings on it. The
  two 13b memos (`phase-13b-memo-w-ceremony.md`, `-merge.md`) are the
  form.
- **In-batch design forks reserved for the architect** ("the
  implementer proposes, the architect rules"): the implementer returns
  with its proposal BEFORE building that half; the ruling lands
  repo-first, then the build proceeds (the 4E realization-bounds
  pattern).
- **Deferring ruled scope out of the phase requires its detailed
  brief/design memo authored IN-PHASE as a deliverable** (the author's
  S4-16 condition) — deferral moves work in time, never into
  vagueness.

## Sizing & acceptance guidance (author, 2026-09-01 — R-cor-13; GUIDANCE TO RAISE, never absolute — `notes/PhaseSizingGuidance.md` is the text)

- Plan in ACCEPTANCE UNITS and name each unit's evidence before the
  first spawn; ONE unit per implementer session; at most two
  phase-sized units under one theme per phase — a third is a split
  ruled at the same sitting (a split = separate phase runs sharing the
  sitting; §3 of the guidance says how). Say so to the author when a
  plan is outside this — never split or proceed silently.
- The acceptance gate is USE-shaped for the kind (the correction
  round's C-2/C-3, promoted): the orchestrator walks each batch
  hands-on — or runs its drill / live round — before its record
  closes; the install refresh follows the walk. An implementer's
  "done" is a claim; the walk is the verification.

## The review ladder (identical to /run-phase's rules 3–4; summarized)

One ladder per stage/phase over the combined diff: fresh cold reviewer
running `notes/REVIEW_PROMPT.md` VERBATIM with zero framing; findings
recorded repo-first before any fix session sees them; fixes in a fresh
session with trace + revert-verified pins; round 2 re-reviews (fresh
reviewer); new BLOCKER/MAJOR ⇒ round 3; hard cap three rounds;
disputes adjudicated by you against the canonical docs — the spec
outranks both agents; every finding gets a written disposition.
Cross-model (a Fable reviewer, an Opus implementer): the reviewer makes
the final call on each finding and the IMPLEMENTER applies the confirmed
fixes (red-on-old pins), re-checked by the next fresh reviewer; a final
round's fixes get your line-by-line check; the reviewer writes a fix
itself only for `Sync/` lines or a finding it marks FINDER-FIXES (her
ruling 2026-10-13 — /run-phase rule 4 carries the full flow).

## Environment (bind by reference + the invariants)

Every batch brief carries the CURRENT phase plan's environment-traps
section verbatim. The invariant core: instance checks use
`pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH
(the test host matches mid-run since 4G); treat real-store instances
by STORE, not path — NEVER quit/kill one; no Release builds or
/Applications refreshes while one lives; `xcodebuild build-for-testing`
compiles without the runner; Mac tests from `App/Variorum/`,
suite-level `-only-testing` only, confirm the "Test run with N tests"
line; zsh `pipestatus`; NEVER add a custom build configuration (Xcode
builds SPM package dependencies RELEASE under any configuration not
named exactly "Debug" — silently stripping VariorumCore's DEBUG-gated
oracles out from under the tests, the 4G-recorded trap); suites running
beside a live session flash the test host's windows on screen — prefer
zero-instance windows for timing-sensitive measurements; backups
WAL-safe with UTC names, ALWAYS before
touching the real store (the A1 rail) — written into the SUBFOLDER
`Backups/safety-copies/`, never loose in `Backups/` (her ruling R-18k-8,
2026-09-25: the app's own listing lives at the top level); drives need unlocked +
author-free + own `caffeinate -d`; screenshots in gitignored dirs;
never `git checkout` over uncommitted work; push after every commit
(CLAUDE.md's push rule + the resiliency protocol) — never force-push,
never rewrite history.

## Closeout (the standing CLAUDE.md ritual, unabridged)

Results + counts in the plan file; master plan table + the effort's
IN-FLIGHT row retired + closeout-log paragraph, the superseded pieces
and AppSpec §14's outgoing delta rolled into `notes/PhaseCloseoutArchive.md`
/ `notes/AppSpecDeltaArchive.md`; canonical-doc deltas applied exactly
as the author ruled them (never beyond — and as a CONTRACT line plus a
pointer to the plan's ruling, never a paragraph of history: AppSpec's
size is a context cost every session pays); the effort's board tickets
closed or re-owned — no orphans; **every ticket the effort FILED
triaged before it closes** (her word 2026-10-14) to CLAUDE.md's
labeling rule (one kind, Evidence on a Bug/Improvement/Debt, one Area,
a Priority, Pre-launch only at her call, Wording, "Needs Lillian",
never an assignee) — the handoff lists the filed tickets grouped by priority; the PR
merges to `main` as a MERGE COMMIT;
the MOBILE PARITY line (a `notes/MobileSoul.md` ledger row, or the
words "nothing mobile-visible"); the author handoff
(`notes/handoffs/phase-NN-handoff.md`, her checklist at the top,
self-contained — if a question would need this session's context, the
docs are incomplete); the next phase's plan + kickoff message authored
just-in-time; the build-debris tidy — delete this phase's
`App/Variorum/DerivedData/<tag>/` walk/build folders (gitignored,
~1–2 GB each; unswept they reached 84 GB by 2026-10-01), **and once the PR has merged to `main`, ALL of the effort's run and walk evidence is deleted too** — walk screenshots, test and build logs, revert scripts, subagent scratch folders and scratchpad copies (her ruling at the 13x closeout, 2026-10-08: the plan file's record is the evidence of record; nothing else is kept). Keep only a folder a still-open effort uses, and only after confirming no build is running. **The closeout's Mac run covers the suites that exercise every changed SOURCE file — not only the suites whose test files changed** (13x's lesson, VX-106: `ProtectionController` changed, `PostureSwitchTests` did not, so the widened run skipped it and main went red at the merge). When in doubt, grep the tests for the changed types. **The plan file's STATUS banner (its first lines) is flipped to CLOSED with the date** — a stale OPEN banner is the first thing every later session reads, and it misled sessions about 13o, 13r and 13y for weeks (her catch at the 13x closeout, 2026-10-08). **The merged effort's branch is deleted too — on GitHub and locally** (`git push origin --delete <branch>` + `git branch -D <branch>`, after removing its worktree; her ruling at the 13x closeout, 2026-10-08: "we don't want loose branches"). Its commits stay reachable through the merge commit, so canon's cited SHAs survive.; commit + push; hard stop
— the author kicks off what's next.

Two deploy-adjacent rules proven in 13b (added 2026-07-22): schema/
mirror changes are SyncSpec §12 lockstep events whose MIRROR DEPLOY
executes only on the author's explicit go-ahead (the R53 precedent) —
and any install refresh that would put her daily-drive build's
`lockstepVersion` ahead of the deployed marker is HELD until the
deploy lands (a mismatched client visibly refuses to sync by design;
don't strand her build in that state). Lesson/tutorial content edits
stale the REAL store's seeded field guide — the closeout re-seeds it
via the product door behind the A1 rail.
