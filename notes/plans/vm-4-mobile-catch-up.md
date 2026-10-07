# VM-4 — The mobile catch-up READING & PLAN

**Ticket: VM-4 (flagship, team VM) · Project: Mobile — the catch-up & launch · Worktree: `~/dev/variorum-mobile` (branch `mobile`)**

---

## KICKOFF MESSAGE (the author launches in `~/dev/variorum-mobile`)

You are the **mobile catch-up planner**. Mobile has been paused since ~2026-08-30 while the Mac
ran 13u → 13i → 13r → 0.9.2 (now LIVE, friends beta open). Your duty is a THOROUGH catch-up
plan and the Linear organization to carry it — **you build nothing**; you read, reconcile,
structure the board, and bundle every question into ONE sitting for her ratification. Hard stop
at the plan + sitting bundle.

**A branch fact before anything: `mobile` predates the 2026-10-06 workflow transition.** Read
every transition-era doc from MAIN's checkout by absolute path (`~/dev/variorum/notes/…`) — and
do NOT merge main into `mobile`: how main's two months of changes reach the mobile branch is
exactly the branch-shape question below, hers to rule first.

**PREFLIGHT (never delegated), in this order:**
1. Your project memory (auto-loads — the VM workflow + cast ruling) ·
   `~/dev/variorum/CLAUDE.md` ("Tracker & parallel work" especially) ·
   `~/dev/variorum/notes/plans/workflow-transition-2026-10-06.md` (the whole system).
2. The standing mobile entry point: `notes/plans/mobile-round-2-orchestrator-handoff.md`
   (HANDBACK CHECKLIST first) · `notes/MobileSoul.md` (the parity ledger) ·
   `notes/plans/mobile-app-plan.md` (incl. the v1 gate sitting — mobile is a COMPLETE app,
   her ruling).
3. What happened while mobile slept: the master plan's closeout log (13u1→13r paragraphs) +
   `notes/AppSpecDeltaArchive.md` + AppSpec §14's recent entries — the 13i family (wings,
   Bookcase, gatherings, Owned/Finished/Sealed, the daily Journal) and the 18-era editor-seam
   hoists are the big parity surfaces born since.
4. The board: `~/dev/variorum/notes/TICKETS.md` — VM-1 (hand-ins bundle), VM-2 (keystroke
   fence, data-shaped), VM-3 (tutorial copy, her flagged beta risk); plus every Mobile-labeled
   VX ticket and the frozen archive rows they cite.

**THE DELIVERABLES (all repo-first, then the sitting):**
1. **The branch-shape PROPOSAL** (deliberately left to you): (a) keep long-lived `mobile` with
   `vm-N-slug` ticket branches off it and periodic mobile→main merges, or (b) rebuild onto
   main-based worktrees. Weigh: two months of main drift, the shared-core hoists already on
   main, the PR rule, the resiliency protocol. Recommend one; she rules.
2. **The catch-up plan**: reconcile the handoff's owed reviews and batches-through-10 against
   today's tree (some owed work may have been discharged by the Mac's hoists — verify, never
   assume); fold in VM-1/2/3 and the parity ledger's open rows; sequence into batches sized per
   `notes/PhaseSizingGuidance.md`; name what is data-shaped or beta-visible (VM-2, VM-3) as
   pull-forward candidates for her.
3. **The Linear organization**: projects (epics) within team VM with a FLAGSHIP each, tickets
   per batch/row with two-way pointers (plan-file path in every ticket; `Ticket · Project ·
   Branch` in every plan-file header), states honest (Parked carries reasons; her calls to
   Needs Lillian). The conventions are the transition record §9; runs use the RUN-ticket
   pattern; mobile epics never mint in VX.
4. **The sitting bundle**: branch shape, pull-forwards, sequencing, anything the reading found
   ambiguous — one organized list, her rulings, then the plan finalizes and VM-4 moves to
   reflect it.

**Rules that bind:** the stage (`~/dev/variorum/Tools/stage`) for ANY simulator/device/suite
run — though a reading should need none; CLAUDE.md's author-only list; repo-first records (this
file is your record — keep a LIVE STATUS section from your first commit, per the resiliency
protocol); commits on `mobile` push to `origin/mobile` as ever until the branch-shape ruling
says otherwise.

---

## HER RULINGS AT THE PLAN'S DELIVERY (2026-10-06 evening — verbatim-faithful; these govern)

1. **The branch shape is RATIFIED (b):** *"go ahead and do the final mobile -> main merge and
   retire the long lived branch and verify that everything is still working."* VM-5 is GO.
2. **THE CAST:** *"Fable will orchestrate but use Opus 5.5 for implementation - Fable cold review
   where you want / need."* — Fable orchestrates (and resolves the merge as integration work, the
   merging-session rule; stated to her in the report, redirectable); Opus 5.5 implements build
   units and fix waves; Fable cold reviews at the orchestrator's judgment (the resolution diff,
   the stability pass and the whole-round pass all get one — the seam is in them).
3. **Pull-forwards: ONLY VM-10 post-merge** — *"let's only do VM-10 post merge - not sure what
   that one even is."* VM-2 and VM-3 stay in Backlog for a later run.
4. **VM-10 WIDENS — her new report, the bug that "most drives me insane … a constant issue":**
   *"when i make a new line, it scrolls so i only see empty page and it fights me when I try to
   scroll back up. showing empty space should be allowed if you scroll there but it shouldn't be
   forced. not sure if that bug is fixed on mobile but I don't think it is - the whitespace at the
   end issue was a problem that the core work was going to fix and did in fact fix."*
   So VM-10 is the phone Write page's whole SCROLL AUTHORITY, three arms: (a) the ARRIVAL shows
   none of the text (PL-22's ruled shape — reveal minimally, per-note session memory, the room
   stays); (b) a NEW LINE forces a scroll onto the empty room; (c) the scroll-back FIGHT —
   something re-scrolls against her gesture. **Her product rule, verbatim and binding: empty space
   may be SHOWN if you scroll there; it is never FORCED.** Pin-before-fix per arm; the trace run,
   not read.
5. **The QUESTIONS renumber: ordered** (*"also, fix the questions numbering"*) — rides the merge.
6. **Memory: collapse is ratified in direction** (*"collapsing the mobile and variorum core repos
   like this - memory, branches, etc. I'm very open to"*), with her design question answered in
   the report: ONE memory STORE (the main repo — it is what auto-loads in every worktree and
   syncs across both Macs), DISTINCT FILES where platform content genuinely diverges (two memory
   notes on one topic — one phone, one core — exactly as she floated: "that might be fine").
   The seeded `…-variorum-mobile/memory/` dir retires to a pointer stub.
7. **The phases: ratified as planned** (*"I'm fine with your plans on the phases"*). **The merge
   install: she is ready** (*"I'll be ready for the merge install as well"*).

## LIVE STATUS (the resiliency protocol's record — newest first)

- **2026-10-06/07 — THE PLANNING SESSION RAN TO ITS HARD STOP.** Preflight COMPLETE in the
  kickoff's order (VM memory + main's CLAUDE.md + the transition record · the standing mobile
  entry point with the handback results §9–§12 · the parity ledger PL-17…PL-47 on main ·
  the master plan's in-flight table + closeout state · TICKETS.md + sizing guidance · the VM
  tickets · git reconciliation with measured numbers). THE PLAN below authored; the VM board
  structured (projects + flagships + tickets, §4's map); the mobile branch's CLAUDE.md
  instruction-overflow FIXED (the lean auto-load set — her instruction at kickoff); the sitting
  bundle delivered in the session report. **State: HARD STOP — awaiting her sitting.**
  Nothing was built; nothing merged; no simulator touched (no stage claim needed or taken).

---

## §1. WHERE MOBILE STANDS — the reconciliation (measured 2026-10-06, re-derive before relying)

1. **The round paused at batch 10** (2026-09-01, her word): mobile suite **727/103**, the batch-10
   tree installed to her iPhone 17 Pro that night. Everything after that on this branch is records
   + the §12.2 hand-in. The seat-2 handoff (`mobile-round-2-fable-seat-2-handoff.md`) governs the
   old resume road; **this plan supersedes its sequencing** (the workflow changed under it).
2. **Divergence, measured:** `mobile` is **68 ahead / 3,579 behind** `origin/main`; merge-base
   `43a35ef8` (2026-08-30). Mobile's 68 commits touch **42 code files, ALL under
   `App/Variorum/VariorumMobile/` + tests** (+6,295/−625) — **zero `Shared/`, zero `Sources/`,
   zero schema: the fence held all round.**
3. **Main moved five lockstep events ahead:** 13u1→13u4, two use-report rounds, RUN A/B,
   13y (marker 8→9), 13i a–e (markers 9→10→11→12, schema v1_18…v1_21: wings/shelves/gatherings/
   Owned/Finished/Sealed/book-archive), 13r (THE FRIENDS BETA IS LIVE — 0.9.0–0.9.2 on
   stargazing.tech), 17y + librarywalkpolish. `SyncSchema.lockstepVersion`: **main = 12, this
   branch = 7.** **A build of this branch REFUSES TO SYNC today** — the branch cannot produce an
   installable daily-driver build without absorbing main first. In flight beside us: 13o (VX-5),
   13x (VX-6 — holds the Sync/custody slot), 13s (VX-7, the Air).
4. **Her phone runs MAIN-built installs since 2026-10-01** (the 13i-a window; marker-12 build at
   the 13i-e window 2026-10-03, proven syncing at her 2026-10-04 walk). **Consequence, stated
   plainly: the round-2 features she had on her phone through September — the Trash two-rooms +
   Versions face, the Library kind-filters, the per-note tray, the ⋯ vocabulary, the fan's hands
   (reorder/take→block/copy-all), block multi-select, the starred page, the shelf↔library swipe
   band, New Note/New Chapter in a book — are NOT on her phone right now.** They exist only on
   this branch. The merge is not bookkeeping; it puts her features back.
5. **Main edited the phone target itself while mobile slept** (13u1 carried the phone's cross-block
   consumers onto `Shared/EditorBrain/CrossBlockCompound`; 18m rebuilt the conductor band +
   `MobileRefusalRoads`; 13u2 fixed the space-eater with mobile pins; 17y removed the phone's
   Jekyll seed; 13i-e swapped the daily Journal's Delete→Archive doors; 19b migrated mobile test
   sites). **The both-sides conflict surface is exactly 15 files** — the Shell family
   (`MobileLibraryView/ViewModel`, `MobileQuickNote`, `MobileShelfFaces/View`, `MobileShellView`,
   `MobileStars`, `MobileStarterJournal`, `VariorumMobileApp`), the Write family
   (`MobileEditorViewModel` ⚠ the hairiest, `MobileBlockMenu`, `MobileNoteClipboard`,
   `MobileStructural`, `MobileUndoDoor`), and `MobileTutorialSeeder`. Expect SEMANTIC conflicts
   beyond textual ones: mobile's 4.5c-phone liveness arms and main's 18m conductor band rewired
   the same roads.
6. **What 13u settled (the old blockers are UNBLOCKED):** the handback checklist's U-1…U-5 and U-7
   are ALL FLIPPED on main (PL-23 quotes them); cross-block semantics are ONE shared brain with
   the phone's consumers carried in-phase; **R-13u-4 ruled the capture model for both platforms
   (⏎ files · ⇧⏎ paragraph · many-paragraph box · `importPost` bulk hand-off)** — so batch 4.6's
   wait is over and it is reborn as the capture-face unit (PL-27, the lost-prose fix). The
   `planVisibleTakeEdit` fence's tripwire reading stands: a diff there implements 13u's rule or it
   is a finding.
7. **What main did NOT do (still owed, exactly as #94 deferred):** the `FindReplaceGate`,
   `TakeClipboard`, and `ThemeStore` hoists (grep-verified absent from `Shared/`+`Sources/` on
   main 2026-10-06). `applyTypedPath` IS hoisted (`Shared/TypedTagPath.swift`);
   `Queries.exportMapped` lives in core (verify `public` at the merge).
8. **Two notes-file hazards at the merge, found now so nobody meets them cold:**
   (a) **QUESTIONS.md numbering COLLIDES** — this branch's Mobile Round 2 section minted #84–#94
   (Two rooms, the filters, the hoist deferral…) while main independently minted a DIFFERENT
   #84–#94 (pre-13u bundle, postures, the bridge retirement, typed-return edges) and now sits at
   #179+. The merge RENUMBERS mobile's entries into main's sequence (status marks preserved;
   cross-references in the mobile records updated or glossed) — never a textual union.
   (b) `mobile-round-2-orchestrator-handoff.md` and `notes/MobileSoul.md` are both-sides-edited —
   resolve as deliberate unions (main's handback flips + ledger rows PL-17…47 AND mobile's §12.2 +
   status flips both kept).
9. **The bridge is GONE** (retired on main 2026-09-04, tag `archive/fragments-bridge-2026-09-04`;
   PL-9 dissolved; main's #89 carries a MERGE NOTE for this seat: take main's deletions). Batch 8's
   bridge-door items are MOOT; this branch still carries every bridge file until the merge.

## §2. THE BRANCH-SHAPE PROPOSAL (deliverable 1 — hers to rule)

**RECOMMENDED: (b) — one final, careful `mobile` → `main` merge, then RETIRE the long-lived
branch; all future VM work runs on main-based ticket worktrees exactly like VX.**

The kickoff's four weighings, answered:

- **Two months of main drift:** 3,579 commits including FIVE §12 lockstep events. The branch
  cannot ship to her phone at all (marker 7 refuses the marker-12 mirror), so option (a)'s
  "cheapness" is an illusion — every future install REQUIRES absorbing main anyway, and a
  long-lived branch pays that conflict tax repeatedly instead of once.
- **The shared-core hoists already on main:** the phone's brains now live in `Shared/`
  (`CrossBlockCompound`, `TypedTagPath`, `PlainPaste`, `NoteCardFace`, `BlockHistoryFace`,
  `CaptureMicrosyntax`, the refusal table…). MobileSoul §3's parity-is-inheritance architecture
  now assumes ONE tree; a second long-lived tree is a standing fork of every brain.
- **The PR rule:** merge-commits-to-main from ticket-named branches. A permanent `mobile` branch
  means recurring giant unreviewable PRs with no ticket name; per-effort `vm-N-slug` branches give
  small, cold-reviewable PRs — the system working as designed.
- **The resiliency protocol (+ the two-Mac rule, the skills, the stage):** main-based worktrees
  inherit the current CLAUDE.md, the transition-era phase skills (ticket resolution + workspace
  setup), `Tools/stage` and `Tools/vx`. This branch predates all of them.

**Option (a) kept honest:** it defers the 15-file conflict session and keeps `mobile`'s history
linear. But it cannot install, it forks every shared brain going forward, and periodic
mobile→main merges reproduce exactly this reconciliation forever. Rejected on the measurements.

**Mechanics when ratified (the merge is Phase 1 below, its own flagship):**
1. Mint the merge flagship (VM-5); cut `vm-5-the-catch-up-merge` from `origin/main` in worktree
   `~/dev/variorum-vm-5`; `git merge mobile` — ONE merge commit preserving all 68 SHAs (canon
   cites them). Resolve the 15 both-sides code files + the notes unions + the QUESTIONS renumber
   (§1.8). The Library-filter row reconciles onto 13i-b's core filter mechanics (one brain, the
   round's phone face kept).
2. Post-resolution verification: handback U-rows re-greped on the merged tree; the five fences
   (zero schema, zero `Sync/` from mobile's side, no build config, `planVisibleTakeEdit` zero
   invented semantics); FULL suites — core + the whole Mac target + the mobile union + both
   spines. **The Mac suite riding near-unmodified is the proof the merge moved addresses, not Mac
   behavior** (the hoist-proof pattern in reverse; main-side mobile pins may move honestly).
3. **A Fable cold review of the RESOLUTION diff is mandatory** (the editor seam is in it — the
   standing rider). Cast proposal, hers to redirect: Fable orchestrates AND implements the
   resolution (seam judgment); Opus is wrong for this one.
4. PR **`VM-5: the catch-up merge (mobile → main)`**, merge commit; **closeouts serialize** — the
   PR lands between VX closeouts on latest main, coordinated via the in-flight table (a VM row
   joins it at kickoff).
5. After the merge: tag `archive/mobile-2026-10` at `mobile`'s tip (pushed; history never
   deleted), retire the branch, REMOVE the `~/dev/variorum-mobile` worktree. Release install to
   her phone at a window — **her batch 5–10 features return, now at marker 12.**
6. From then on, VM = VX in shape: the three sizes verbatim, `vm-N-slug` branches,
   `~/dev/variorum-vm-N` worktrees from `origin/main`, removed at closeout.

## §3. THE WORKING RULES FOR VM SESSIONS (the simulator problem, answered — deliverable 1's rider)

- **The stage (`~/dev/variorum/Tools/stage`) claims EVERY `xcodebuild test`, simulator runs
  included** — CoreSimulator state is machine-global; the 2026-08-30/31 evidence is decisive (two
  agents on one simulator read each other's installed bundles; a clean + uninstall did not survive
  a concurrent install). Headless `swift build`/`swift test` stays free and parallel.
- **One simulator per live session, by UDID, never `booted`;** arm
  `com.apple.Accessibility ApplicationAccessibilityEnabled = 1` on it first (sixteen real pins
  phantom-fail otherwise); **one `-derivedDataPath` per session;** pathspec-limited commits
  (`git commit -- <paths>`) wherever two sessions could share a tree.
- **Runtime inventory TODAY (Xcode 27): iOS 26.2 and 27.0 simulators exist;** deployment target is
  iOS 26 — re-derive valid devices per session (the old iPhone-16-series/18.3 trap generalizes:
  *[removed for publication]*
  unlocked at install moments; `devicectl` is the proven road.
- **Accepted cost, named:** VM simulator suites serialize with VX Mac-app suites behind the ONE
  stage. That is the ruled single-arbiter shape; it surfaces to her only if it becomes the real
  bottleneck.
- **TestFlight remains the eventual distribution road** (Stage E); until then `devicectl` installs
  at windows, phone unlocked.

## §4. THE CATCH-UP PLAN (deliverable 2 — scope reconciled against today's tree, sequenced, sized per `notes/PhaseSizingGuidance.md`)

**Phase 0 — this session:** the plan, the board, the CLAUDE.md overflow fix. DONE at the hard stop.

**Phase 1 — THE MERGE & ROUND-2 CLOSE** *(project "Mobile — the merge & round-2 close"; flagship
VM-5; TWO phase-sized units + her window; Fable cast proposed)*:
- **Unit 1 — the merge** (§2 mechanics; its own ladder).
- **Unit 2 — the round-2 close, run honestly against the merged tree:** the **dedicated stability
  pass** (owns M27; it reviews the FINAL seam — the post-merge timing seat 2 itself proposed) →
  the **whole-round pass** (`46ffa0c..`the merge — closeout obligation ZERO) → the thirteen
  closeout obligations executed against the new world (1 is complete-as-of-13l by its amendment;
  13 is a dissolved tripwire; the QUESTIONS renumber from §1.8 lands here; the parity-ledger marks;
  the author handoff) → the #94 reconciliation (TakeClipboard rides the copy-all face, Phase 5;
  ThemeStore folds into the palette ticket; FindReplaceGate rides the find face; `exportMapped`
  `public` check) → **Mobile Round 2 CLOSES as a round.** Everything left becomes tickets.
- **Her window:** the Release install (features return) + the device queue (§4's standing row).

**Phase 2 — PULL-FORWARD SINGLES** *(her word; natural as ONE run right after the merge)*:
**VM-2** the structural-flight keystroke fence (data-shaped — a mid-flight keystroke duplicates
store text) · **VM-3** the tutorial's retired-divide lesson rewrite (her flagged beta risk; PL-23's
row-64 lesson) · **VM-10** the Write-page arrival (PL-22/§12.2 — ruled shape: reveal minimally,
per-note session memory, the room stays; "drives me insane" daily).

**Phase 3 — THE ROUND-2 REMAINDER** *(a RUN over small tickets when she says go)*:
**VM-11** batch 8 REVISED (cadence/pruning settings rows PL-11(f) · document settings PR17 · M14's
unmeasured half, measure-only; the bridge items DROPPED — retired 2026-09-04) · **VM-12** the
leftover-backlog batch (ONE nesting-aware editability authority — both stranded-`isEditable`
variants · the sync-road silent keyboard-drop MECHANISM (the voice is hers) · the batch-5/6a
MINOR/NIT backlog · R24 "info" · 4.5e verification) · **VM-1**'s bundle rows fold here and into
Phase 5 where they belong (each named in the tickets).

**Phase 4 — THE 13i FAMILY FACES** *(project; flagship VM-6; the biggest accrual — PL-42…47 +
PL-45's letter; SPLIT per the sizing rule, ONE design sitting rules all of it)*:
- 4a the Bookcase-as-LIST + the wing switcher + per-wing Archived/Trash + move/copy doors + the
  union star's words (Pin → Star/Unstar);
- 4b gatherings: the Arrivals faces + the rule editor (`RuleEditing` is core) + the Pool tuck +
  the starred-gathering seed occasion + bind/spawn doors;
- 4c membership & ownership: the choice sheet (copy in / move in) + Book Settings' Collecting
  sentences + the state doors (Finish/Seal/Own) + the outflow chooser + two-choice delete +
  Duplicate + the badge family + the two sealed-book "Reopen" sentences fixed;
- 4d the archived-BOOKS group (Open · Unarchive — her 2026-10-04 walk met exactly this hole and
  mistook it for a sync bug) + archive doors on ordinary books + "(archived)" marks + the
  comes-back receipt + the Welcome-arrangement call + the pocket guide's furniture-fold FACTS
  entry (PL-46);
- the Book Panel's phone shape = the design sitting's item.

**Phase 5 — EDITOR & CAPTURE FACES** *(project; flagship VM-7)*: the **R-13u-4 capture face**
(⏎ files · ⇧⏎ paragraph · the many-paragraph box · the text-preserving refusal — PL-27, the
lost-prose fix, the set's highest value) · the cross-block RECEIPT + the device gesture-matrix
walk (PL-23) · the empty-block Return CHAIN (PL-31) · the paste-plain edit-menu door (PL-24a) ·
capture microsyntax's two lines (PL-32) · named commits' field + rename door (PL-28) · **the
synced PALETTE adoption** (the four-parameter `resolve`; folds the ThemeStore hoist; PL-22/18g) ·
the stamps/sort/day-search family (18h's twin) · the `receipt_style` face call (hers) · the seam
carves over 18m's declared arms (row 51; VM-1) · the title-room look (PL-24b) · `NoteCardFace`
snippet adoption, cap ~30 (PL-26) · the note-open rule twin + watched Read landing (PL-38) · the
PL-19 set (mode order · ONE current block · the scrolled-open door · the `#` tag door · recovery
stamps + Block History calm grammar) · the divide three-preset sheet + keep-on-top display check
(PL-21) · copy-all-takes (`TakeClipboard` hoist; PL-10c) + the COPY ALL word-screen doors (PL-41).

**Phase 6 — PROTECTION & RECOVERY FACES** *(project; flagship VM-8)*: the "How Protection Works"
explainer + the sheet's live-checklist lead + the unchosen-state indicator + the T1 verify
(PL-18) · the sample-library restore door (PL-17) · the PL-13 residue, SHRUNK by PL-20 (the
sync-status slot partly shipped at 13r; the backup offer NOT owed on the phone by design; the
plaintext export door waits for a document-picker road) · the Apple re-link door — **her #139(f)
call first** · note-level multi-select (design call).

**Phase 7 — BETA READINESS → THE MOBILE LAUNCH** *(project; flagship VM-9)*: the Dynamic Type +
VoiceOver audit (the chrome font does not scale — recorded pre-existing, app-wide) · TestFlight ·
the crash-report opt-in face (PL-47's candidate; MetricKit is API-shared) · the What's New call
(hers — the App Store has its own surface) · App Store presence (the iOS name reservation rides
her 13r tail). Her polish bar gates the launch; "other bugs and items" she logs land in VM Triage
and slot here or earlier at her word.

**Standing — THE DEVICE QUEUE** *(VM-13, Needs Lillian; one window, post-merge install)*: the
selection-defect experiment (one minute, collapses four candidates — `mobile-batch-9-record.md`
§4.5) · the Face ID walk (PL-15) · the 100k Sherlock perf + memory leg (the fixture arrives with
the merge) · M16 drag-move · D9 Display-Zoom strip · the emoji-sheet keyboard overlap · the swipe
band's real pan · the landing-law pin's device walk (PL-24c).

**Explicitly NOT re-decided here:** 13o's search face (the engine lands in core at VX-5; the phone
face becomes a ledger row then) · 13s's phone copy re-voicing (that phase's) · anything the 13i
sitting record already ruled.

## §5. HELD FOR HER — the sitting bundle (mirrored in the session report)

1. The branch shape (§2) — ratify (b), or redirect.
2. The merge cast (Fable resolves + Fable reviews) and its slot between VX closeouts.
3. Phase-2 pull-forwards: VM-2, VM-3, VM-10 — which, and whether they ride the merge run.
4. The sequencing of Phases 3–7 (the board's project order; anything she wants pulled).
5. Standing calls the round already held: the merge-vocabulary proposal (batch 9's (A)+(B)) · the
   assign-to-chapter door's placement (batch 10) · `receipt_style` on the phone (quiet slot vs
   keeps toasting) · #139(f) the re-link door · the What's New call · the PROVISIONAL bundle
   (mobile #84–#94's unratified rows, renumbered at the merge).
6. Workflow hiccups raised (§6) — the VM memory consolidation wants her OK.

## §6. WORKFLOW ISSUES RAISED (the kickoff's standing instruction)

1. **The seeded VM memory does not auto-load.** This worktree's session auto-loaded the MAIN
   project memory (`…/-<home>-dev-variorum/memory/`), not the seeded
   `…-variorum-mobile/memory/` — the harness keys worktrees to the parent repo (the VX-5
   orchestrator's memory lives in the main repo's memory too). PROPOSAL: fold the two seeded VM
   files into the main memory repo (done this session as `vm-workflow` content inside the main
   repo's memory, pointer added) and retire the separate dir at her word — one memory, already
   git-synced across both Macs.
2. **The kickoff file lives on two branches** until the merge (main's verbatim copy; this branch's
   copy carries the plan). Resolved at the merge to this copy. Future VM plan files are born once,
   on the effort's own branch.
3. **VM-4's Linear description carried a stale branch name** (`vx-32-mobile-catch-up`, pre-split)
   — fixed at this session's board pass.
4. **MobileSoul's ledger numbering has a duplicate: two PL-25 rows on main** (13u3's comments
   panel · 17u's glyph rain). Cosmetic; renumber at the merge's ledger pass.
5. **The stage serializes VM simulator suites with VX Mac suites** (§3) — accepted cost, named so
   it isn't rediscovered as a surprise.
6. **The old-era skills/tools on this branch** (`.claude/skills`, no `Tools/stage`) — dissolve with
   the branch at the merge; until then VM sessions use main's tools by absolute path.
