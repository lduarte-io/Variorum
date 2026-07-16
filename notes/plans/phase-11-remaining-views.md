# Phase 11 — Remaining views, export/import (execution plan)

> Authored 2026-07-12 at Phase 10's closeout per the front-loaded-planning rule,
> FROM `notes/plans/phase-11-brief.md` — the brief's author-ratified decisions
> (canvas_layout; version_of's two doors; the export shapes incl. bulk export;
> block names + the block-TOC) are **binding**; its 2026-07-09 additions are
> scope; its open interpretations are answered in §"Open interpretations,
> answered". **Staffing (CLAUDE.md model policy, author 2026-07-11): implementer
> FABLE · cold reviewer FABLE, same-model flow.** The standing Sync/ rider
> (+ Bridge/ prudence) is satisfied by the assignment; this phase's ONE
> engine-adjacent obligation is the migration-lockstep choreography (Step A1),
> which touches the registry/serializer/mirror-DDL exactly as SyncSpec §12
> prescribes.
>
> **Shape: the brief's subdivision recommendation is ADOPTED inside this plan**
> — Stage A (views) and Stage B (export/import + reference panel), strictly in
> order, each with its own verification gate. The coordinator may formalize
> 11a/11b master-plan rows at kickoff (the table "gains rows rather than
> rewriting history"); the plan works either way. One phase of this breadth
> invites a rushed tail — Stage B is never a footnote.
>
> **Kickoff notes (coordinator, 2026-07-12):** (1) **Coordinator seat redirected
> to FABLE by the author at kickoff** (her call, resolving the CLAUDE.md Opus
> assignment when asked: the phase's WORK was already moved to Fable on
> 2026-07-11 as the most interpretation-/UI-heavy remaining — the Opus
> coordinator seat was budget economy, not suitability, and she chose Fable
> when the tradeoff was put to her). Implementer/reviewer stay FABLE per the
> table; same-model flow — **the author confirmed Fable for ALL of Phase 11
> at the sitting, "just to be clear."** (2) The **kickoff-addendum HTML mockup
> spike is running in the coordinator's author-attended session** (2026-07-12,
> 9d-style; throwaway artifacts in `Spikes/Phase11Mockups/`); her choices will
> be recorded here when made — Step A3 stays blocked until then. **Spike round
> 1 feedback (author, same sitting — binding once the v2 mockup is approved):**
> ALL of the fan-out appearances ship, as a user SETTING (stack / carousel /
> margin-grid / spread — "different styles of use that are super defensible");
> A2 re-shaped as a centered TWO-UP discrete carousel under the in-flow chosen
> take (one-up on narrow windows; paging moves whole cards, never half-way);
> A3 re-shaped as a ~3-tall margin GRID overflowing into horizontally-scrolled
> columns, with the changing block HIGHLIGHTED in the document and a toggle to
> read it seamlessly (no formatting); B2's spread JOINS the same family as a
> fourth style ("the editing and showing can be the same") with equal
> mathematical column splits (user-set visible count) and the same discrete
> paging; EVERY style is an editing surface (the one live editor migrates on
> click; choosing stays an explicit ✓ = `chooseVariant`, I3); and whole-post
> side-by-side compositions must be BLOCK-ALIGNED columns — variant/fan rows
> vertically registered, lineage flowing through divides "like a color bar"
> (left block ↔ its divided descendants' span), which is how outline↔draft
> side-by-side falls out of `derived_from` for free. **Her mid-sitting
> clarification, verbatim intent:** the side-by-side family is exactly TWO
> compositions — **(A) 1–4 SEPARATE FULL-TEXT columns** (each column the whole
> post, differing at the fanned block; a block-start alignment LOCK toggle:
> locked = registered comparison rows, whitespace accepted — "lonely to read"
> acknowledged; unlocked = each column flows as its own whole variant of the
> post) and **(B) ONE article column whose fanned slot splits into a 1–4-wide
> equal-share pane space in place** (the rest of the article normal, full
> width). Carousel paging brings further takes into either composition; splits
> are always equal mathematical shares. Her B3 question (what is version_of /
> Mark as Versions for) answered at the sitting. **Spike round 2 (same
> sitting):** the A3 mark-toggle reading CONFIRMED; the Stack gains a quick
> expand/collapse; the Carousel gains an EXPLICIT beneath-count control (1–4,
> user-chosen for their screen width) plus a RESIZABLE main editor;
> composition (A) columns gain SAMENESS signals (a byte-identical row stays
> quiet; divergent cells tint; stable lineage-color as the same-ORIGIN signal,
> the 9d stable-color family) and per-column take selection (columns =
> view-local SELECTION PROFILES — the N-up form of swap-and-reread,
> session-only, I3-clean, ✓ = the explicit chooseVariant). **Duplicate-post-
> as-version APPROVED into Stage A scope** (one gesture: block copies +
> derived_from edges + version_of — the aligned view's automatic door).
> **OPEN, her uncertainty preserved verbatim ("i think we may have to
> reconsider that invariant. … I'm open to thoughts"):** whether cross-block
> take-coordination ("linked takes" / "posts have takes") needs DURABLE
> state — the coordinator offered three tiers, I8 untouched in all of them
> (session lens, free; SAVED lens as a small canvas_layout-class table — no
> invariant change, rendering truth/chosen pointers untouched; version-POST
> for full independence) plus a "diverge here" gesture (branch a take, the
> column adopts it) and promote-column-to-version-post. She has NOT decided.
> **Spike round 3 (same sitting):** **SAVED LENSES — her strong leaning,
> explicitly open to advice** ("if session lens is useful, it's a disservice
> to not allow it" — a lens/thread is days-long work and must survive
> app-close): a durable NAMED selection profile per post; coordinator concurs
> — a small canvas_layout-class view-state table riding the SAME A1 lockstep
> event (three additive changes in one choreography), with the semantic line
> held: **a lens is never rendering truth** (exports/bridge/book views read
> chosen pointers; ✓/adopt gestures are the only doors from lens to chosen —
> I3/I8 untouched). **Branch-all-fans APPROVED** (coordinator offered the
> lazier default: a fresh thread/lens starts as a transparent overlay and
> "diverge here" mints takes only where actually edited; eager branch-all
> stays an explicit command). **Two-posts-WITH-takes composition settled in
> the mock:** rows = block-level lineage correspondence; cells = slots whose
> fans bloom IN-CELL in the set fan style; quiet/tint compares displayed
> bytes; take-to-take kinship ACROSS posts deliberately NOT tracked (coarse,
> not forensic). Still open with her: saved-lens final confirm (+ synced vs
> local); the adopt-lens gesture; the duplicate/promote fan-copy defaults
> (recommendation: duplicate carries whole fans, promote materializes
> chosen-only per its lens).
> **Spike round 4 (2026-07-13):** adopt-this-lens APPROVED; SAVED LENSES
> CONFIRMED (synced, riding A1's lockstep event); lazy new-thread APPROVED;
> the teachable boundary RATIFIED in her words as the design's governing
> frame — **"a lens is the same structure with different choices; a version
> is a different structure; promote is the bridge"** ("this is exactly
> right"); cross-post take kinship confirmed NOT tracked. **Fan-copy
> ruling:** a version copy carries WHOLE fans AND the currently-viewed
> selection becomes the copy's chosen (the other options ride, kept open) —
> supersedes the coordinator's chosen-only-promote recommendation, one
> uniform rule. **Coordinator advice on her particulars (pending her go):**
> (1) UNIFY the two ops — promote(lens) ≡ duplicate-while-viewing: ONE
> operation, duplicateAsVersion(post, selection), where the selection
> parameter is whatever the view is looking through (main chosen text /
> a scratch column / a named lens); "Promote" is merely the button's label
> when that happens to be a lens. (2) A lens is SPARSE overrides over
> chosen — only divergences stored; un-overridden slots follow the post's
> chosen (the transparent new-thread lens = the empty lens; edits to
> un-overridden blocks show through every lens). (3) NO auto-minted named
> lenses: scratch column arrangements persist as VIEW MEMORY (automatic,
> local, scroll-position class — the view reopens as you left it), while
> NAMED lenses are deliberate (💾 + a name; synced canvas_layout-class
> tables `lens` + `lens_choice`, live-unique (lens_id, block_id), CAS
> variant pointer, dangling-variant falls through to chosen — the existing
> fallback class). (4) Promote/duplicate leaves the original post, its
> chosen pointers, and the lens untouched; lenses do NOT ride the copy
> (their (block, variant) references are the original's — the copy starts
> lens-clean with its selection as chosen).
> **Spike round 5 (2026-07-13):** the round-4 unification RETRACTED — she
> wanted the two ops DIFFERENT (the coordinator misread her; her
> four-columns-open case shows why she was right: "duplicate what I'm
> viewing" is ambiguous with N columns). Final shape: **duplicateAsVersion
> (post)** copies the post EXACTLY AS IT IS — its own chosen + whole fans,
> no lens/view involvement, unambiguous from anywhere; **promoteLens(lens)**
> materializes one lens — chosen := the lens's picks, fans ride (coordinator
> one-rule recommendation, pending her go), original + lens untouched, ⧉ is
> per-COLUMN. The ops differ in exactly one thing: where the copy's chosen
> comes from. **Vocabulary settled** (glossary in the sitting reply;
> governing sentence: "visible is what you're looking at; chosen is what
> the post is; a lens is a saved way of looking; a version is a different
> post"). Visible-not-chosen is real and editable — edits land in that
> take's working_text, durable and synced; rendering truth (chosen) moves
> only via ✓/adopt. **Named-lens edit model — coordinator recommendation
> (pending her go): LIVE autosave** (the canvas_layout arrangement
> precedent; no explicit re-save; a lens-bound column edits its lens, a
> main-text or scratch column touches no lens; "duplicate lens" covers
> riff-without-touching). View memory + named lenses both CONFIRMED. She
> authorized folding the sitting scope into the step plan explicitly and
> adding a sub-phase if needed — the coordinator will formalize 11a/11b
> master-plan rows at spike close.
> **Spike round 6 — CLOSED (2026-07-13, her go):** all three calls confirmed —
> the two operations as defined; fans ride Promote WITH a choose-at-promote
> option (her call: carry-all default, chosen-only offered at the gesture);
> live lens editing. Her final clarifying question (is the aligned view
> reliant on same block order?) answered at the sitting: kinship comes from
> lineage edges, never order — divides/merges/adds/deletes align via spans
> and blanks regardless of counts; a cross-version REORDER is the one case
> locked registration can't fully honor (anchor the opened post's order,
> mark moved kin; unlocked mode + lineage colors stay truthful under any
> order; the view is still offered, degrading honestly, never guessing).
> The MODES TUTORIAL added to scope mid-sitting (her instruction: an in-app
> walkthrough styled like the spike pages, live examples per mode). The
> consolidated BINDING record is the "## Kickoff spike record" section
> below; Steps A1/A2/A3/A4 amended, A10 added; master-plan rows 11a/11b
> formalized — THIS /run-phase invocation covers 11a (Stage A) only.
> **Post-kickoff authorizations (2026-07-13, the author):** (1) the A1
> schema DEPLOY is delegated to the coordinator ("go ahead and do the
> schema deploy when it is time") — mirror DDL via her PAT (the 9c
> precedent; untracked `.env.supabase.local`), then the Mac
> `/Applications` refresh at her next app-quit; the PHONE's one-time
> updated install remains hers (an Xcode-to-device step), and the A1
> version-check holds an un-updated client safely refused (visible,
> outbox intact, cursor unmoved) until it updates — the deploy is not
> complete, and new-schema writes must not begin, until BOTH devices
> carry the migrations. (2) #10/#11 sitting logistics, her "either way"
> resolved by the coordinator: a SELF-CONTAINED sitting document is
> prepared at the A9 stop regardless (the standing documentation bar —
> any fresh session can host the sitting from it), with this coordinator
> session hosting by default if still warm; answers recorded in her
> words in QUESTIONS.md + this plan either way. (3) *(superseded at spike
> close, author-authorized: master-plan rows 11a/11b WERE formalized —
> this run is 11a, hard stop at the Stage A gate.)* (4) The
> `/Applications` install was refreshed to the Phase 10 closeout build at
> kickoff (handoff step 1 done; author relaunch pending).
>
> **The A9 sitting (2026-07-13, hosted live in the warm coordinator
> session, demos in hand):** **#10 ANSWERED — auto-proceed on unique
> match** (the ceremony sheet appears only where some take doesn't match
> uniquely — exactly where a genuine per-take decision exists). **#11
> ANSWERED, three parts:** the PLAIN delete gesture on a fanned
> cross-block span = **visible-take delete** (remove exactly the selected
> text from the take being read + the neighbor's piece; fan, seam, and
> structure survive; never guesses — the two-paragraphs-not-joined
> deviation accepted on a badged block); **"Delete in every take"** as a
> deliberate named command (unique-match per take — the #10 discipline;
> APPLY to matching takes + REPORT the skipped, her call over
> all-or-nothing; one undo); **merge stays the explicit gesture** for
> when the seam should go, speaking about the fan. En-route
> clarifications: empty takes legal (`newBlankVariant` + ratified
> blank-take skip-rendering); "read without this block" = choose/lens a
> blank take (per-thread, non-destructive); a one-click "mute block"
> sugar noted as cheap-if-wanted, deliberately NOT built this phase.
> Full resolutions recorded in QUESTIONS #10/#11. The mirror DEPLOY
> continues to HOLD until the review ladder closes (coordinator judgment
> under her "when it is time" delegation).

## Kickoff message (for a fresh session)

> You are starting **Phase 11 of Variorum** — the full traversal set
> (side-by-side multi-variant editing, expand-all-fans, swap-and-reread, diff,
> book-scrub, outline↔draft, canvas, block-TOC + block names, full pool,
> unplaced-blocks, `version_of`) plus export/import and the reference panel.
> **First, verify Phase 10 is closed** (the master plan pointer says Phase 11
> and the Phase 10 closeout paragraph exists). **Second, confirm with the
> coordinator that the KICKOFF ADDENDUM ran**: the author-attended HTML mockup
> spike (2026-07-11 author decision — throwaway mockups of the fan-out
> appearances and the side-by-side view for her to CHOOSE between before you
> build them; informs, never binds). If it hasn't run, Step A3 is blocked on
> it — say so in your first report rather than designing those views on paper.
> Read, in order: `CLAUDE.md`; `notes/plans/phase-11-brief.md` IN FULL
> (ratified decisions binding — including the kickoff addendum block);
> this plan IN FULL; `notes/OverallModel.md`; `notes/AppSpec.md` §7 (the
> reference table; block DDL — `block.name` lands beside it), §9, §12, §14's
> deltas of 2026-07-07 (block-TOC), 2026-07-09 (both — the boundary-fluidity
> package and the elevated side-by-side), and **2026-07-12 (the spacing
> ruling: renderedText's join is now CONDITIONAL — export code inherits it,
> never re-implements it)**; `notes/SyncSpec.md` §3/§6/§7 and **§12 IN FULL**
> (Step A1 is the first live schema change under real two-device production
> sync — the lockstep rehearsal); `notes/TEXTKIT2_NOTES.md` §2/§3 (book-scrub
> and the TOC ride the Phase 6 memo's decisions; NO in-place folding in the
> live editor); `notes/QUESTIONS.md` items **10, 11** (OPEN — settled ONLY by
> asking the author at implementation time; her uncertainty is recorded
> deliberately — never add certainty she doesn't have) and 17 (Phase 10's
> PROVISIONALs — confirm at kickoff whether the checkpoint ratified them;
> the full pool builds on 17(c)); the Phase 10 plan's closeout (the read
> tier/focus-handoff machinery you will reuse; the spacing ruling's
> mechanism); `Sources/VariorumCore/Queries/` and the Phase 10 features under
> `App/Variorum/Variorum/Features/` (Read tier, BookView, Pool — the reuse
> surface). **Baselines — do not re-run at session start: core 562/62 · Mac
> app 311/55 · mobile 11/4** (the Phase 10 closeout's final counts). Remember
> the environment traps: piped xcodebuild masks exit codes; a live app
> instance or stale unsigned DerivedData product blocks the Mac test runner
> (NEVER kill the author's `/Applications/Variorum.app` — report and run
> targeted suites instead); SwiftUI `.task` doesn't fire under the test host
> (drive models by hand; representable lifecycles DO fire); nested run loops
> don't drain the main queue (interleave real awaits when pumping). The
> author DAILY-DRIVES on real auth + the live mirror: the A4 fence stays
> absolute, and Step A1's mirror DDL deploys ONLY through the author-assist
> gate (her paste or her PAT — the 9c precedent), never headless.

**Hard author gates in this phase (stop-and-report, coordinator relays):**
1. **QUESTIONS #10** (must the W always be a full ceremony?) — ask at the
   moment cross-fan bracketing's auto-proceed case is reachable (Step A9).
2. **QUESTIONS #11** (fanned cross-block edit semantics) — ask when the
   fanned case is reachable (Step A9). Where a live answer doesn't settle
   either, her suggested method is BOTH-WAYS TESTING VIA DISTINCT COMMANDS —
   build both, let her use both, decide from use.
3. **Step A1's deploy** (mirror DDL + lockstep) — author-assist, both devices
   updated before any new-schema writes (§12's choreography, to the letter).
4. The reference panel's file-access/TCC prompts (Stage B) — author-assist.

## Open interpretations, answered (ride the checkpoint ratify list)

1. **Reference drag-out lineage: gesture-style copy, NO edge — PROVISIONAL.**
   A reference is not a block, so `derived_from` is impossible without a new
   edge/table class (a schema-level product call — hers, never invented).
   The drag is pool-drag-STYLE (AppSpec §7's wording); the result is ordinary
   bulk text entry. QUESTIONS entry at implementation.
2. **Diff granularity: LINE-based over the two rendered texts** (display
   choice, nothing stored; the cheapest correct form — sentence chunking can
   layer on later). Whitespace-normalization toggle per §12.
3. **Swap-and-reread: view-local projection** (the leaning adopted): the swap
   never touches `chosen_variant_id`; an explicit "keep this take" gesture
   emits `chooseVariant` (I3 discipline — review focus 6 enforces).
4. **Canvas scope: pools first, blocks-as-cards** (the leaning adopted;
   extending to posts later is cheap — the table's shape doesn't change).
   PROVISIONAL.
5. **PDF: the attributed-string print/PDF path** over `renderedText`
   semantics; typographic polish is explicitly Phase 13's.

## Kickoff spike record (2026-07-12/13 — BINDING design input for Stage A)

The author-attended HTML mockup spike ran across six rounds (throwaway
artifacts: `Spikes/Phase11Mockups/`; the round-by-round record is in the
kickoff notes above). This section is the consolidated result — binding,
in her rulings.

**Vocabulary (the governing frame):** VISIBLE is what you're looking at;
CHOSEN is what the post is; a LENS is a saved way of looking; a VERSION is
a different post. Her boundary sentence, ratified: *"a lens is the same
structure with different choices; a version is a different structure;
promote is the bridge."* Visible-not-chosen takes are real, editable,
durable (ordinary `working_text`); rendering truth moves only via ✓/adopt.

1. **Fan-out styles are a user SETTING — all four ship** ("different styles
   of use that are super defensible"): **Stack** (with quick expand/
   collapse); **Carousel** (chosen take in-flow as the main option; an
   explicit 1–4 beneath-count control — never auto-only; discrete
   whole-card paging, never halfway; resizable main editor); **Margin
   grid** (~3 cards tall, overflows RIGHTWARD with horizontal scroll; the
   changing block HIGHLIGHTED in the text with a toggle for seamless
   zero-formatting reading; edit-in-place); **Slot split** (the fanned slot
   divides into a 1–4-wide equal mathematical split inside the one article
   column). Whichever style is set is what expand-all-fans opens
   document-wide. EVERY pane everywhere is an editing surface: the ONE live
   editor migrates on click (P3 unchanged); ✓ = `chooseVariant` (I3 —
   clicking/editing never re-points).
2. **Side-by-side has exactly TWO compositions:** (A) 1–4 separate
   FULL-TEXT columns — the whole post per column, differing at fanned
   blocks — with a block-start alignment LOCK toggle (locked = registered
   rows, honest whitespace; unlocked = each column flows as its own
   complete read); (B) ONE article column whose fanned slot splits 1–4 wide
   in place. Equal mathematical splits always; discrete paging in both.
3. **Columns are selection profiles; lenses make them durable.** A lens =
   SPARSE overrides over chosen — only divergences stored; un-overridden
   slots follow the post's chosen (the transparent new-thread lens is the
   EMPTY lens — the lazy default; takes mint only on divergence). Scratch
   columns persist via VIEW MEMORY (automatic, local, scroll-position
   class — the view reopens as you left it). NAMED lenses are deliberate
   (💾 + a name), synced, and LIVE-edited (no explicit re-save — a
   lens-bound column edits its lens; main-text/scratch columns touch no
   lens; "duplicate lens" covers riff-without-touching).
4. **Sameness signals, two independent channels:** stable lineage-COLOR
   marks same-origin (the 9d stable-color family); QUIET vs TINTED marks
   same-bytes-right-now (byte-identical row across columns = quiet;
   divergent cells tint; computed at read time, never stored).
5. **Gestures:** ✓ choose · ADOPT LENS (every pick → chosen, one compound) ·
   DIVERGE HERE (edit-as-this-thread mints a take; the column adopts it —
   visible, not chosen) · BRANCH-ALL-FANS (explicit compound command; the
   transparent lens is the default for new threads) · DUPLICATE AS VERSION
   (the post EXACTLY as it is — its chosen + whole fans; ignores columns
   and lenses; unambiguous from anywhere) · PROMOTE LENS (per-column ⧉ —
   new version-post with chosen := the lens's picks; fans ride by DEFAULT,
   chosen-only offered at the gesture; original and lens untouched; lenses
   never ride any copy). The two copy operations differ in exactly one
   thing: where the new post's chosen comes from.
6. **Aligned posts (versions & outline↔draft):** rows keyed by BLOCK-LEVEL
   lineage (`derived_from` closure), never by order — divides/merges/adds/
   deletes align via spans and blanks; a cross-version REORDER is the one
   case locked registration can't fully honor (anchor the opened post's
   order, mark moved kin; unlocked + lineage colors stay truthful under any
   order). Take-to-take kinship ACROSS posts is deliberately NOT tracked
   (coarse, not forensic). In-cell fan blooms follow the fan-style setting.
7. **Modes tutorial (her instruction, 2026-07-13):** an in-app walkthrough
   of the three modes — POLISH IN PLACE / THREAD ONE PIECE / FORK THE
   PIECE — styled like the spike's mockup pages (captioned sections, live
   examples per mode) over a seeded demo post. Functional at 11a; the
   pretty pass is Phase 13's. (Step A10.)
8. **Schema consequences (JOIN Step A1's one lockstep event):** `lens` +
   `lens_choice` — sparse overrides; live-unique `(lens_id, block_id)`;
   CAS variant pointer; a dangling lens variant falls through to chosen
   (the existing fallback class); cascades from lens/post/block/variant;
   own schema commit.
9. **New operations (JOIN Step A2):** `duplicateAsVersion`, `promoteLens`
   (+ carry-fans option), `adoptLens`, lens CRUD (`createLens` /
   `setLensChoice` / `clearLensChoice` / `renameLens` / `duplicateLens` /
   `deleteLens`), `branchAllFans`. Undo inverses per the structural-undo
   pattern where applicable.

## Ground rules

- **Every view is a traversal** (OverallModel §9): the moment side-by-side or
  the canvas wants data machinery beyond `canvas_layout`, surface it as a
  model finding — full-severity review item, never a quiet workaround.
- **Exports are one-way projections** on `renderedText` semantics — which,
  since 2026-07-12, means the CONDITIONAL join (`joinRenderedTexts`: `"\n\n"`
  unless the left block ends in a newline) and blank-take skipping. Export
  code CALLS the one join brain; it never re-implements it.
- Schema changes get their own commits BEFORE dependent code; the §12
  choreography order is recorded as it happens (mirror → every client → only
  then new-schema writes; disagreement = refusal to sync).
- Bounded observations everywhere (the Phase 10 probe-and-marker pattern for
  anything corpus-shaped); P3's one-live-editor rule holds in every new view
  (the side-by-side's ratified shape: the live editor MIGRATES between panes).
- The author's deliberately-open items stay open until SHE answers — record
  her words, not paraphrases that add certainty.

## Stage A — the views

### Step A0 — the offline-label fix (KnownIssues row re-owned from 10)
**Files:** `App/Variorum/Shared/SyncStatusViews.swift` + the status source in
`SyncSession`/scheduler surface (classification only — NO engine changes; if
classification demands engine surgery, stop and report per the rider).
**Work:** offline/unreachable (URLError network-down classes) presents as
"Waiting to sync (offline)" — pending/queued, never "SyncError"; real refusals
keep the error face. BOTH platforms (the row's letter).
**Tests:** classification pure-function tests (error → presented state);
the existing A3 offline-keeps-outbox behavior unchanged (no engine deltas).

### Step A1 — THE SCHEMA COMMITS + the lockstep rehearsal (`canvas_layout` + `block.name`)
**Work:** (i) migration `v1_5` — `canvas_layout` exactly per the brief's
sketch honoring every §6 convention (UUID TEXT PK, owner_id, ISO timestamps,
`deleted_at`, `sync_version`, live-unique `(container_id, block_id)`,
cascade-by-trigger from container AND block, outbox triggers) — own commit;
(ii) migration `v1_6` — nullable `block.name` (additive; plain metadata CAS;
no uniqueness, no repair rule) — own commit; (iii) registry + serializer +
`Server/supabase/` mirror DDL additions (+ the 04 RLS posture for the new
table: owner-gated like its peers — verify against the deployed 9c cutover,
don't assume); (iv) **the SyncSpec §12 version-check mechanism ships NOW**
(the spec's letter: it ships with the first post-sync migration that needs
it) — a server-readable schema marker checked at engine-session start,
mismatch ⇒ visible refusal, outbox intact; (v) repair rule: pure duplicate,
keep smaller id (SyncSpec §7 pattern); (vi) `setBlockName` +
`setCanvasPosition`/`removeCanvasPosition` operations; (vii) **the deploy is
an author-assist gate** — mirror first, then BOTH devices update, only then
any new-schema write; the choreography is recorded step-by-step in this
plan's closeout (review focus 1 audits it against §12, not the summary);
(viii) **spike addition (2026-07-13):** migration `v1_7` — the `lens` +
`lens_choice` tables (spike record item 8), own commit, JOINING THE SAME
lockstep event — one choreography, now FOUR additive changes; items
(iii)–(v) apply to them identically (registry, serializer, mirror DDL +
RLS posture, pure-duplicate repair on `(lens_id, block_id)`).
**Tests:** migration + trigger + serializer-completeness walks (the A6
pattern — the in-repo mirror-DDL coverage check must swallow the new
tables); repair tests with the outbox-row assertion; version-check refusal
test (behind ⇒ refuses, outbox intact, cursor unmoved); ops
state-transition tests; convergence scenarios over canvas AND lens rows
(move/move + choice/choice races = metadata CAS); a dangling lens variant
falls through to chosen at read time.

### Step A2 — `version_of` (the KnownIssues op) + two doors + the version/lens operations
**Work:** the minting operation (canonical `(min,max)` storage,
`origin_op='manual'`, undirected — AppSpec §7; refuse self-link and dupes at
the ops boundary) + undo inverse; door 1: select two posts in library/folder
→ "Mark as Versions"; door 2: the side-by-side view offers the link on
unlinked posts (lands with A3). **Spike additions (record items 5/9):**
`duplicateAsVersion(post)` — exact copy, chosen as-is + WHOLE fans, per-block
`derived_from` edges + `version_of` minted, lenses never ride;
`promoteLens(lens, carryFans: true default)` — chosen := the lens's
effective picks, chosen-only offered at the gesture, original + lens
untouched; `adoptLens(lens)` — one compound of `chooseVariant`s;
lens CRUD (`createLens`/`setLensChoice`/`clearLensChoice`/`renameLens`/
`duplicateLens`/`deleteLens`); `branchAllFans(post)` — one compound.
**Tests:** op state transitions (canonical order pinned both input orders);
both doors emit the SAME op; the Phase 5 dedupe repair still green; the two
copy ops pinned to differ in EXACTLY one thing (where the copy's chosen
comes from); adopt is atomic; compounds undo as one entry.

### Step A3 — the takes/lens view family (FIRST-CLASS; the spike record is BINDING)
**The kickoff spike RAN and CLOSED (2026-07-12/13)** — build items 1–6 of
the "## Kickoff spike record" section: the four fan-out styles as a SETTING;
the TWO side-by-side compositions (full-text columns with the block-start
lock; in-column slot split); view memory + named lenses (live-edited);
the sameness/lineage signals; the gesture faces (✓ / adopt / diverge-here /
branch-all / 💾 save lens / ⧉ promote / duplicate-as-version); the aligned
versions & outline↔draft views with in-cell fan blooms. Throughout: **every
pane rendered read-cheap, the ONE live editor migrating between panes on
click** (ratified — P3 unchanged; the Phase 10 focus-handoff machinery is
the reuse surface: seeds, teardown contract, read-tier panes).
Expand-all-fans: fans stay open once expanded + close-all (§12), opening in
the set style; the version_of door rides the two-post composition.
**Tests:** exactly-one-live-editor across a randomized pane walk (the Phase
10 pattern); pane handoff mid-dirty-buffer; take edits land in the RIGHT
variant (row-level); ✓/adopt are the ONLY writers of `chosen_variant_id`
from this family (I3 pin); lens round-trip (set choices, close, reopen —
named survives, scratch survives via view memory); sameness signal
correctness (quiet ⇔ byte-identical); alignment rows keyed by lineage incl.
a divide's span and an orphan's blank; fan expansion state session-only.

### Step A4 — diff (+ swap-and-reread ABSORBED by the lens machinery)
**Work:** diff over `Queries.diffPair` inputs (line-granularity, whitespace
toggle). Swap-and-reread needs no separate build: a scratch column IS the
swap (visible, not chosen), and ✓/adopt are the commit gestures — record
the absorption in the closeout so §12's view list stays accounted for.
**Tests:** diff pure-function tests; the I3 pin — viewing through any
lens/scratch NEVER writes `chosen_variant_id`; ✓/adopt write exactly it.

### Step A5 — book-scrub + outline↔draft
**Work:** book-scrub model-driven (the Phase 6 memo: the post list is the
scrubber's domain; landing via the hybrid jump; page = a post); outline-left/
draft-right over `derivedBlocks` (independent or tracked scroll; connector
polish stays deferred).
**Tests:** scrub landing accuracy (the memo's primitive, pinned at view
level); outline mapping matches the CTE exactly.

### Step A6 — block-TOC + `block.name` faces + block-management affordances
**Work:** the TOC view (one row per block: explicit name else first sentence
DERIVED AT READ TIME via BoundarySnapping — never stored; expand-to-read via
the read tier; one live editor on demand; collapse session-only; jump via the
hybrid primitive; NO in-place folding); naming (`setBlockName` face, in-TOC);
ordinals; block management: delete block (+ the tray's door — restore),
drag-to-reorder (in-TOC), move block to pool.
**Tests:** derived-first-sentence purity (nothing persisted — review focus 7
class); TOC ops emit exactly the Phase 2/3 ops; reorder emits fractional-
index moves; tray restore round-trip through the UI path.

### Step A7 — the canvas (pools first)
**Work:** sticky-notes board over `canvas_layout` (blocks-as-cards, drag =
`setCanvasPosition` metadata CAS; cards render via the read tier); layout
rows tombstone with their block/container (the A1 triggers).
**Tests:** view emits exactly the layout ops; a two-device position race
converges (CAS — either wins, never corruption); cards render gaps
tolerantly.

### Step A8 — the full pool
**Work:** block-tag filtering (the block-tagging faces DEFERRED FROM 10 land
here: apply/remove on blocks — `TagAssignmentSheet`'s block twin), pool-side
structural ops surface (legal since Phase 3), the canvas as the pool's
second face (A7), plus the Phase 10 minimal-pool PROVISIONALs as ratified at
the checkpoint (confirm #17 before building on the sidebar shape).
**Tests:** filter matches `everythingTagged` block semantics; block tag ops
row-level; structural ops in pools through the UI path.

### Step A9 — cross-fan bracketing (COMMITTED scope; the ask-her-live step)
**Work:** the boundary-fluidity package: the cross-block refusal becomes a
guided flow (confirm → adjust neighbor edges → compound divide/divide/merge
under ONE undo entry); single×single cross-block EDITS become merge-then-edit
compounds (a cross-seam delete just works — her ratified direction);
CutPropagation's unique-match auto-proceed prepared as a DEMO.
**THEN STOP at the two hard gates:** ask #10 (W-always-a-ceremony?) and #11
(fanned semantics) with the concrete demos in hand; implement her answers;
where she doesn't settle, build BOTH WAYS AS DISTINCT COMMANDS (her method)
and record that the decision moves to use-evidence.
**Tests:** per her answers — compounds atomic on partial failure (the
withCompound pattern); the soak extended over the new gestures; refusals
that remain still speak.

### Step A10 — the modes tutorial (spike addition, author instruction 2026-07-13)
**Work:** an in-app walkthrough of the three modes — POLISH IN PLACE /
THREAD ONE PIECE / FORK THE PIECE — styled like the spike's mockup pages
(captioned sections, live interactive examples per mode) over a SEEDED demo
post (the spike's example content may be reused; seeding never touches the
user's real posts — a dedicated, clearly-labeled, deletable demo post).
Functional at 11a; the pretty pass is Phase 13's.
**Tests:** seeding idempotent + isolated (never mutates existing user
rows); the tutorial's examples drive REAL ops on the demo post only;
deleting the demo leaves no orphans.

### Stage A verification gate
Full suites; the randomized gesture soak green over the new surface; sync
convergence spot suite incl. canvas rows, block names, AND lens rows
crossing the wire; P1/P3 spot checks (side-by-side pane cost, TOC at 100+
blocks — the TOC is the within-post-virtualization escape hatch's natural
face, measure it); TEXTKIT2 §5 ritual. **This gate ends the 11a run** —
Stage B is master-plan row 11b, its own `/run-phase` invocation.

## Stage B — export/import + reference panel

### Step B1 — export (the ratified shapes)
**Work:** `.md` export for posts, readings, AND single blocks; fan export =
one file with the labeled "Alternates for this block" sections (chosen take
in place; `take: "<label>"`, unlabeled numbered); post export's
include-variants option; **bulk export — the whole library as a folder of
plain `.md` in ONE gesture** (one file per post, dated/titled filenames;
readings as optional folder views — layout details this step's, the gesture
and totality ratified); basic PDF via the attributed-string path. All through
`joinRenderedTexts` semantics; save panels are author-visible moments.
**Tests:** shape pins per ratified form (fan sections, blank-take skip, the
2026-07-12 conditional join — spaced posts export their spacing); NO export
path writes rows (review focus 2 — pure projections); bulk export totality
(every live post lands exactly once).

### Step B2 — import (drop-in)
**Work:** drop `.md`/plain text on the library or a pool → new post via
`bulkSegments` (the pipeline exists; spacing preserved per the ruling); the
file is a one-way source, never edited in place.
**Tests:** round-trip sanity (export→import→export byte-stable modulo the
recorded edge-run drops); segmentation per effective default; source file
untouched (mtime/bytes).

### Step B3 — the reference panel
**Work:** per-post references beside the draft (AppSpec §7): Quick Look
generally, PDFKit for PDFs (page memory via `view_state`; text selection
drag-out = interpretation 1's gesture-style copy, PROVISIONAL), read-only
WKWebView or open-externally for URLs; add/remove/reorder + view-state ops
(exist since Phase 2). Security-scoped bookmarks are LOCAL-ONLY under sync
(never in payloads — the serializer already excludes; verify, don't assume);
TCC prompts are author-assist moments.
**Tests:** ops through the UI path; `file_bookmark` never serialized (the
existing exclusion pinned from the panel's path too); view-state round-trip.

### Step B4 — Stage B verification + phase closeout
Full suites; import/export round-trip; the closeout ritual (results, memo,
dispositions; master plan row(s) + pointer → 12; KnownIssues reconciliation —
incl. whether the export/import rows and the offline-label row close; the
author handoff; the Phase 12 plan authored from `phase-12-brief.md`).

## Explicitly out of scope
Typographic PDF (13); the variorum-edition bundle + E2EE (14); EPUB/
annotation/citation (permanently); within-post virtualization BUILD (12
assesses; the TOC only measures); any bridge/sync-engine change beyond A0's
presentation and A1's prescribed choreography (anything more: stop, report).

## Risks
- **Breadth** — the two-stage gate structure exists so Stage B is never a
  rushed footnote; the coordinator may hard-split at kickoff.
- **A1 is the lockstep rehearsal under LIVE production** — a mis-ordered
  deploy desyncs her real devices; the choreography is recorded as executed,
  and the version-check mechanism is the permanent guard it leaves behind.
- **The ask-her-live items** — building past #10/#11 without her answers is
  the forbidden move; the gates are in A9 by construction.
- **Sandbox/TCC** (B3) — author-assist, planned not improvised.

## Review foci (for the cold reviewer — the brief's seven, carried verbatim in intent)
1. canvas_layout sync-shaped end to end (triggers, registry, mirror, repair,
   lockstep FOLLOWED) — audit against SyncSpec §3/§6/§7/§12 directly.
2. Exports are pure projections; shapes match the ratified forms incl. the
   2026-07-12 conditional join.
3. version_of: canonical storage; both doors emit the same op; dedupe holds.
4. Import: one-way; segments per the effective default; source untouched.
5. Every view reads through Queries (new queries tested) — bespoke view-side
   data machinery is full-severity.
6. Swap-and-reread never mutates `chosen_variant_id` without the explicit
   commit gesture (I3).
7. Block-TOC: derivation read-time-only (persisted derivation = full
   severity); collapse unpersisted; `block.name` sync-shaped and rode the
   SAME lockstep event as canvas_layout (verify the order held for BOTH).
8. *(added at plan time)* The ask-her-live gates actually stopped: #10/#11
   answers are recorded in her words before the dependent code exists.
9. *(added at spike close)* **Lenses are never rendering truth:** exports,
   the bridge, the book view, and every other surface read chosen pointers
   only; ✓/adopt are the only lens→chosen doors; view memory is local;
   named lenses are synced, sparse, live-edited; the two copy operations
   differ in exactly one thing (where the copy's chosen comes from) and
   lenses never ride a copy.

## Closeout

### Stage A implementation record (2026-07-13, single Fable implementer session — Steps A0–A10; STOPPED at the two hard gates)

**Run shape:** all Stage A steps shipped in order, one commit per step
(schema changes as their own commits per convention), each step's suite
green before its commit; the FULL suites re-ran green at the end (counts
below). **The run stopped, as the plan requires, at the two hard gates:**
(1) Step A1's mirror deploy (author-assist — 05_phase11_lockstep.sql has
NOT run; the §12 choreography is written into the file's header and
recorded below); (2) Step A9's QUESTIONS #10/#11 (the ratified halves are
built and the demos are ready; NOTHING was built past the open questions).
The Stage A verification gate therefore ran as a PRE-gate (full suites +
convergence + the soak); it formally closes after her #10/#11 answers are
implemented.

**Commit-shape note for the reviewer:** within Step A1 the three schema
commits land migration+record+registry+mirror-DDL together (the v1_4
precedent — all four are DECLARATIONS of one schema change; the
registry-wide walks and RPC rework reconcile in the step's fourth commit),
so intermediate commits BUILD clean but the full suite is guaranteed green
at step end, per the tests-at-step-end convention. Every other step's
commit is suite-green standalone.

#### Step A0 — the offline label (KnownIssues row, re-owned from 10; author-approved)
`SyncScheduler.isOfflineError` — a pure classifier over URLError's
network-down codes (walks the NSError underlying chain, so wrapped
transport/auth-refresh failures classify); `Status.lastErrorIsOffline`;
the shared `SyncStatusRow` (BOTH platforms — one shared file) shows
"Waiting to sync (offline)" + pending count for the offline class; real
refusals keep the error face. NO engine changes — the A3 posture pins
re-ran green. `SyncOfflinePresentationTests` 5.

#### Step A1 — THE SCHEMA COMMITS + the lockstep machinery (deploy PENDING — the author gate)
- **v1_5 `canvas_layout`** (own commit): the brief's sketch, every §6
  convention — live-unique `(container_id, block_id)`, cascade triggers
  from BOTH parents (exact-stamp children), outbox capture via a new
  shared `createOutboxCaptureTriggers` helper (v1_core emits byte-identical
  SQL). Ops: `setCanvasPosition` (upsert, metadata CAS, owner-stamped,
  requires the block live-placed in the container) / `removeCanvasPosition`.
  `CanvasLayoutTests` 9.
- **v1_6 `block.name`** (own commit): additive nullable column; plain
  metadata CAS; `setBlockName` (whitespace → clearing; no-op writes
  nothing; no touch stamp/churn — a handle is not text work; rides the
  existing block outbox triggers, verified). `BlockNameTests` 6.
- **v1_7 `lens` + `lens_choice`** (own commit): the spike's SAVED LENSES —
  sparse overrides; live-unique `(lens_id, block_id)`; cascades
  container→lens→choice (one exact stamp, the cross-table chain) +
  block→choice; deliberately NO variant→choice cascade (a dangling pick
  FALLS THROUGH to chosen at read time — pinned). Lens CRUD ops
  (createLens/renameLens/duplicateLens/deleteLens/setLensChoice/
  clearLensChoice; setLensChoice mirrors chooseVariant's guards exactly).
  Read side: `Queries.lenses/lens/lensChoices/effectiveLensSelection` +
  `renderPost(throughLens:)` (nil = transparent). NOTHING here writes
  `chosen_variant_id` (I3 pinned in the same suite). `LensTests` 9.
- **The sync shaping** (fourth commit): mirror DDL
  `Server/supabase/05_phase11_lockstep.sql` — 04's RPC bodies VERBATIM
  with 16-table allowlists + owner_tables gaining canvas_layout and lens;
  per-table RLS/revokes for the new tables (04's schema-wide revoke
  predates them); `sync_meta` + `sync_schema_version()`
  (authenticated-only; 404/missing marker ⇒ version 1, the 9c-era
  deployment defined retroactively); **the marker insert is the file's
  LAST statement** (a partial deploy never advertises the new version).
  **The §12 version-check mechanism ships** (the spec's letter — with the
  first post-sync migration that needs it): `SyncSchema.lockstepVersion =
  2`; `SyncTransport.schemaVersion()` (hard requirement — wrappers
  forward, fakes declare, no vacuous default); `SupabaseTransport`
  implements it (404→1; ONE 401 refresh-retry); `SyncEngine.
  verifySchemaLockstep()` opens BOTH round halves — behind OR ahead
  refuses with a self-explaining `SyncError.schemaLockstepMismatch`
  (outbox byte-intact, cursor unmoved, heals with zero state surgery —
  pinned end to end incl. the status row and never-presented-as-offline).
  Repairs: canvas_layout + lens_choice join the pure-duplicate rule
  (outbox-row assertions); `deadParentStamp` knows the three children;
  lens joins the cascade-parent set; direction-1 victim enumeration
  covers container→canvas/lens(→choice), block→canvas/lens_choice.
  `AuthRLSDDLTests` REWORKED to pin the DEPLOYED COMPOSITION (04+05,
  last-body-wins; 04 stays byte-untouched deployed history) with THE
  DRIFT PIN: the deployed marker must equal `SyncSchema.lockstepVersion`.
  `SchemaLockstepTests` 3 · `SchemaVersionTransportTests` 4 ·
  `Phase11SyncConvergenceTests` 5 (drag-race CAS; duplicate repairs both
  tables; names/lenses across the wire; cross-device cascades —
  byte-identical dumps, empty outboxes).
- **THE DEPLOY GATE (open):** the §12 choreography — (1) 05 runs on the
  MIRROR first (safe for the still-deployed old clients: new tables serve
  zero rows; the reworked RPCs are behavior-identical on old tables; old
  clients carry no marker check); (2) BOTH devices update to a build with
  v1_5–v1_7 (a new client against the un-migrated mirror REFUSES visibly
  until then); (3) only then new-schema writes. **No production write has
  occurred; the author's live devices are untouched** (her /Applications
  build predates this phase). The deploy is the coordinator-relayed
  author-assist (her paste or PAT — the 9c precedent).

#### Step A2 — version_of + the copy operations
`markVersionOf`/`removeVersionOf` (canonical (min,max) pinned BOTH input
orders; origin 'manual'; no undo entry — the tags/locks trivially-
re-toggled class); `markPostsAsVersions` — the post-level door rides a
block edge anchored on the two posts' FIRST live blocks (**PROVISIONAL,
QUESTIONS #19** — I8 + the block-to-block edge schema make some anchor
necessary; `Queries.versionPeerPosts` matches ANY live version_of edge
between the posts' placed blocks). **The two copy ops, one shared machine
differing in EXACTLY where chosen comes from (pinned):**
`duplicateAsVersion` (own chosen + whole fans incl. archived statuses;
commits never copied; copies never born locked; parent trees remapped;
block names ride; positions verbatim; per-block derived_from + ONE
version_of anchor; tags/memberships/references/lenses do NOT ride;
sealed source legal) and `promoteLens(carryFans: true default)` (chosen
:= the lens's effective picks; chosen-only offered at the gesture —
round 6's call). `adoptLens` (one transaction; refuses under seal; undo
restores pre-image pointers as one compound); `branchAllFans` (fresh
lens picking a new take branched from what every slot shows; fan-END
positions — the resolveSyncConflict precedent, recorded; refuses under
seal; NO undo — branch-class rows + a deletable lens, rationale
recorded). Undo inverses: `revertMintedContainer` (tombstone the mint;
restoreContainer stays the recovery door) + `revertChosenPointers`.
Build-time calls recorded: duplicate copies title/entry_date VERBATIM
(exactly-as-it-is; a journal duplicate = a second same-day entry — the
documented hand-merge/pause doctrine applies); copy origin_op = 'manual'
(the §7 vocabulary respected, no sixth value invented); the copy starts
churn-clean with baseline = its rendered length. `VersionOperationsTests`
10. **Door 1** (library context menu: "Mark as Versions with…" submenu —
the pair-picking shape of "select two posts"; + "Duplicate as Version")
and **door 2** (the aligned view offers the link on unlinked posts) EMIT
THE SAME OP (pinned by construction — both call `markPostsAsVersions`).

#### Step A3 — the takes/lens view family (the spike record, items 1–6)
Core: `FanStyle` setting ('fan_style' in the SYNCED setting table —
document semantics like segmentation; **default 'stack', a recorded
build-time call**) + `Operations.setFanStyle` (UPDATE-then-INSERT, never
an upsert — an outer ON CONFLICT overrides trigger-body conflict
handling, which would break the outbox coalescing; found by test);
`Queries.takesProjection`/`observeTakes` (ONE post-bounded traversal);
`Queries.blockKinship` (nearest derived_from kin, ancestors preferred,
bounded). App (`Features/Takes/`): columns-as-selection-profiles
(main/scratch/lens); VIEW MEMORY (automatic, LOCAL, per-post — columns +
alignment lock; fan expansion DELIBERATELY excluded, session-only);
`Sameness` (quiet ⇔ byte-identical; divergent cells tint; computed at
read time) + stable lineage color (BlockTint's 9d family); `PostAlignment`
(rows keyed by LINEAGE never order — divide spans share a row; orphans
get blank rows after their neighbor; cross-version reorders MARK moved
kin, anchored on the opened post's order); `TakesViewModel` (buffer-
authoritative live panes over one AutosaveCoordinator; deferred
projections at settle; every gesture an ops call); `TakePaneView` (the
cell: content-sized TK2 read-cheap surface, canary armed, ONE live
editor migrating on click — P3 unchanged); `TakesBoardView` (composition
B: blooms in place per style — STACK w/ quick collapse; CAROUSEL w/ the
EXPLICIT 1–4 beneath-count + discrete whole-card paging; MARGIN GRID
~3-tall overflowing rightward w/ changing-block highlight + seamless
toggle; SLOT SPLIT equal shares; composition A: 1–4 full-text columns w/
the block-start alignment LOCK — locked registered rows, unlocked
independent flows; expand-all/close-all in the set style);
`AlignedPostsView` (the two-post aligned composition + version_of door
2 + in-cell blooms; take-to-take kinship across posts NOT tracked);
`PostDetailView` (Write/Takes/Compare/Outline/Blocks) in RootView.
Presentation notes recorded: in-cell blooms inside narrow cells degrade
carousel/slot-split paging to the shared paged row and margin-grid to
stack (geometry; Phase 13 revisits); the carousel's "resizable main
editor" rides content-sizing rather than a drag handle this phase
(functional-unstyled; Phase 13). Scratch-column ⧉ prompts save-as-lens
first (one extra deliberate click; no auto-minted lenses — the round-4
advice honored). `TakesBoardTests` 7 (the randomized pane walk — one
live editor, every edit lands in ITS take, chosen never moves; the
mid-dirty handoff; THE I3 PIN — ✓/adopt the only chosen writers; the
lens/scratch round-trip vs session-only expansion; sameness; alignment;
kinship over a real duplicate+divide) + `TakesProjectionTests` 2.

#### Step A4 — diff; swap-and-reread ABSORBED
`LineDiff` (pure LCS, line granularity — the answered interpretation 2)
+ the §12 whitespace toggle (comparison-only; displayed lines verbatim;
line structure — incl. the 2026-07-12 ruling's stored blank lines —
stays an honest difference, recorded). Doors: "Diff against chosen" per
take (diffPair semantics) and "Diff" on the aligned view over
`joinRenderedTexts` (the ONE join brain — the diffed text IS what
export/bridge emit). The view writes NOTHING. **Swap-and-reread is
deliberately not a separate build:** a scratch column IS the swap
(visible, not chosen; view-local per the answered interpretation 3) and
✓/adopt are the commit gestures — §12's list stays accounted for.
`DiffViewTests` 5.

#### Step A5 — book-scrub + outline↔draft
Book-scrub MODEL-DRIVEN (the Phase 6 memo): the post list is the
scrubber's domain — page = a post, uniform whatever the lengths; a scrub
bar maps the track fraction through the pure `scrubIndex` (clamped,
every page reachable — pinned) to an anchor scroll. **Reconciliation
recorded:** the memo's hybrid jump governs jumps WITHIN one TK2 document
(it remains the caret-reveal primitive after focus); the shipped book
view is a virtualized LazyVStack of per-post surfaces, so cross-post
landing is the model-driven anchor scroll — the memo's
never-live-geometry doctrine, with the stored-estimate door still
unbuilt. Outline↔draft (`Features/Outline/`): outline-left (compact rows
with →N counts) / draft-right; the mapping IS `Queries.derivedBlocks`
verbatim (pinned == the CTE over a real lineage world incl. a divide's
depth-2 span and a fresh block mapping nowhere); tracked or independent
scroll; connector polish stays deferred (§13). `ScrubAndOutlineTests` 3.

#### Step A6 — the block-TOC + names + management
Core: `Queries.blockTOC` + `Queries.tocHandle` (READ-TIME handle:
explicit name else the first sentence via BoundarySnapping — pure, never
stored; pinned incl. the structural no-second-column check) +
`observeBlockTOC`. App (`Features/TOC/`): one row per block (ordinal
n/count read-time; names bold; ⑂/lock marks); rows expand into the
read-cheap tier with exactly ONE live block on click (P3's split,
reused); collapse SESSION-ONLY (pinned); NO in-place folding —
jump-to-block re-seeds the WRITE editor's caret (the hybrid primitive
lands it there; TK2 §3 honored); in-TOC naming; ↑/↓ reorder = ONE
fractional-index write on the SAME placement row (pinned); delete + the
tray's restore door; move-to-pool. `BlockTOCTests` 5.

#### Steps A7 + A8 — the canvas (pools first) + the full pool
Canvas (`Features/Canvas/`; interpretation 4 PROVISIONAL — pools first):
blocks-as-cards over canvas_layout; a drag's END emits exactly ONE
`setCanvasPosition` (pinned; second drag CAS-updates the SAME row);
un-positioned cards stack at DERIVED positions (nothing persisted until
placed — pinned); Reset tombstones; a departed block's layout row is
INERT, remembered if it returns (pinned); core gains
`canvasLayouts/canvasProjection/observeCanvas`. `PoolDetailView`: Scraps
(the ordinary editor — the ratified Phase 10 shape; pools' structural-op
surface since Phase 3) | Canvas. Full pool: the block-tagging faces
deferred from 10 (`BlockTagAssignmentSheet` — one toggle = exactly one
applyTag/removeTag(toBlock:), tombstone never removal, pinned; core
gains `Queries.blockTags`); the pool tag FILTER pinned ==
`everythingTagged`'s block half (subtree semantics, asserted against the
query itself). `CanvasAndPoolTests` 4.

#### Step A9 — boundary fluidity: THE RATIFIED HALVES BUILT; #10/#11 STOPPED AT
Built (both author-ratified 2026-07-09): **(1) the guided cross-boundary
Make Block** — planner case `.makeBlockAcrossBlocks` (single×single
only; gaps/fans/locked-edges classify first; a fanned block refuses with
NEW copy naming the open question — `.fannedCrossBlockSpan`; extract
keeps `.crossBlockSpan`); the flow CONFIRMS first (an alert naming the
act; cancel touches no rows — pinned), then divide-first-edge /
divide-last-edge / merge-the-in-span-pieces as ONE `withCompound` undo
entry through the one structural door (full render — the mergeChain
precedent); snapped-off edges drop their block from the span; ONE undo
restores the original blocks byte-identically (pinned). **(2)
merge-then-edit** for single×single cross-block EDITS: the
`.crossesBlockBoundary` refusal now routes eligible spans into ONE
compound — merge the touched run, apply the exact intended edit to the
merged buffer (the mapped range's ends live in the verbatim-preserved
leading/trailing pieces, so the merge's join bytes die with the deleted
span — the surface reads exactly "the selection vanished", her
principle); the keystroke itself is refused so the storage never
half-applies (pinned end-to-end through the real NSTextInputClient
path); fanned/locked/gap/tail spans keep a SPEAKING refusal naming the
open call; undo restores both blocks with the edited merged mint TRAYED
(insurance doctrine — pinned). **(3) THE #10 DEMO, wired to NOTHING:**
`demoAutoProceedCutsAreComputableWhenEveryTakeMatchesUniquely` —
CutPropagation's unique-match condition mapping a span's BOTH edges into
every take (cuts inside a shared region) + the divideW it would
auto-mint, shown with the real op. Two Phase 9 planner pins updated with
dated comments (the supersession class Phase 10 established).
`BoundaryFluidityTests` 5. **STOPPED HERE at the two ask-her-live gates,
as required; the sitting then answered both, and the builds landed the
same session (next section).**

#### Step A9, second half — the #10/#11 SITTING RULINGS BUILT (2026-07-13; gate 2 closed)
The author answered both questions live (demos presented; her rulings in
QUESTIONS #10/#11's resolutions and the kickoff-notes sitting record).
Built exactly as ruled:
- **#10 — auto-proceed on unique match.** The guided cross-block Make
  Block's fanned edges no longer refuse: the planner plans the guided
  flow for ANY arity (`.fannedCrossBlockSpan` RETIRED — the refusal
  vocabulary shrinks; locked-edge checks now bind only single-variant
  divided edges, since W-divides COPY takes — the Phase 3 semantics); the
  EXECUTOR maps the edge's cut into every active take by CutPropagation
  (the ceremony's own seeding discipline). All unique ⇒ NO sheet: the
  fanned edge W-divides inside the one compound — the out-of-span half
  keeps its per-take fan, the in-span half joins the single-variant
  middle by merge's standing semantics; ONE undo restores byte-
  identically (pinned). ANY non-matching take ⇒ the W CEREMONY OPENS for
  that block, store untouched (pinned) — "the ceremony survives exactly
  where a genuine per-take decision exists." (Recorded shape: after the
  ceremony's confirm the author re-invokes Make Block — a two-act
  completion in the rare mixed case; a one-shot continuation is a
  possible refinement, deliberately not invented.)
- **#11a — VISIBLE-TAKE DELETE** (supersedes the shipped refusal as the
  fanned span's everyday behavior): the plain cross-block delete/edit
  removes exactly the selected text from each touched block's VISIBLE
  take (a typed replacement rides the first block — recorded reading);
  fan, seam, and block structure untouched — the ruled deviation: two
  blocks, NOT a join, the fan hangs on the seam; unseen takes NEVER
  change (pinned); one undo compound restores. Locked/gap/tail spans
  keep a speaking refusal (copy updated to name exactly those).
- **#11b — "Delete in Every Take"**, the deliberate NAMED command
  (editor context menu + Block menu; fire-and-speak): locates the span
  per take by UNIQUE match (`TakeSpanMatch` — one occurrence or nothing),
  APPLIES to matching takes and REPORTS the skipped ones visibly (her
  applied-and-reported call; locked takes skip with their reason); one
  transaction, one undo compound (pinned end to end incl. the report).
- **#11c — merge stays the explicit seam-removal gesture and SPEAKS on
  fanned blocks** ("N other takes stay with the released blocks in
  lineage — undo brings them back"), binary and chain alike.
- **NOT built, on the record (her call):** the "mute block" one-click
  sugar — choosing/lensing a blank take remains the manual path.
- **The supporting core op:** `Operations.editTakesAtomically` — ONE
  transaction; per-target `autosave` guards; DIRTY targets are
  insurance-committed first (the quiet-auto-commit doctrine — text
  removed from an unseen take stays one restore away beyond the
  session); ONE registered undo entry (`revertStructural`
  restoringTexts); COMPARE-AND-SET via `TakeEdit.expectedText`.
- **The session's one surprise — a REAL race the soak caught (red-on-old
  evidence: 102 soak issues on the pre-fix code, in the transcript):**
  the deferred keystroke compounds (merge-then-edit / visible-take)
  executed a main-actor turn after the refused keystroke, so later
  keystrokes could land first and the compound applied PLAN-TIME offsets
  over newer text. Closed at the OP boundary: every deferred compound is
  now a CAS against its plan-time texts — a moved buffer refuses the
  WHOLE compound, visibly ("nothing was altered; try it again"), never a
  clobber — and compounds chain through one awaitable
  `pendingCrossBlockTask` (teardown/tests await quiescence). Direct pin:
  `aCompoundPlannedAgainstAStaleBufferRefusesInsteadOfClobbering` (the
  interloper text survives whole). Recorded residual (the standing W
  drift-check class): the verify→act gap inside one serialized runner
  body remains open to a sync apply's ms-window; the CAS moves the whole
  race from silent clobber to visible refusal.
- **Superseded pins updated with dated comments:** the Phase 7 v1
  refuse/clamp pin (`crossBlockDestructiveEditsRefuse`) — which had been
  passing VACUOUSLY once the compound went async — split into its two
  enduring truths (`crossBlockKeystrokesNeverHalfApplyToTheStorage`;
  `editsIntoTheOpenTailStillRefuseAndSpeak`); the context-menu inventory
  gains the named command; the reachability sweep drops the retired
  refusal.
`BoundaryFluidityTests` 10.

#### THE FORMAL STAGE A VERIFICATION GATE (2026-07-13 — GREEN)
- **Core `swift test`: 618 green in 71 suites** (baseline 562/62).
- **Mac app: 349 green in 62 suites** (baseline 311/55) — including the
  randomized gesture soak over the CHANGED planner/compound paths
  (non-vacuous by its own earlier 102-issue failure) and the tint/badge/
  window smokes (TEXTKIT2 §5's executable items: canary silent, 10k-word
  jump/height stable, decorations live, boundary selections through the
  planner; macOS 26.4.1 — unchanged since the Phase 6 baseline, no spike
  re-run owed).
- **Mobile: 11 green in 4 suites** (baseline matched).
- Sync convergence spot suite incl. canvas + lens + block.name rows
  crossing the wire (`Phase11SyncConvergenceTests`): byte-identical
  dumps, empty outboxes.
- P1/P3 spot checks hold as recorded in the pre-gate section (the takes
  board's one post-bounded observation; one live editor across every new
  pane family — pinned; the TOC's row-cheap/expand-on-demand shape).
- **Still open: GATE 1** — the mirror deploy (05_phase11_lockstep.sql),
  HELD until the review ladder closes per the coordinator; the env-gated
  integration test remains expected-failing against the un-deployed
  mirror; no production write has occurred.

### Review round 1 — dispositions (2026-07-13; 1 MAJOR / 5 MINOR / 3 NIT — ALL AGREED, all fixed; the round-2 anchor)

**MAJOR (the restore/undo doors don't revive the three NEW cascade
children) — AGREED, fixed, RED-verified (6 pins red on the pre-fix
code).** Mechanism self-traced and confirmed: v1_5/v1_7's cascade triggers
stamp `canvas_layout`/`lens`/`lens_choice` with the parent's exact
`deleted_at`, and the SYNC side kept the exact-stamp discipline from A1
(Repairs.swift's own comment says why: "so restoreContainer/restoreBlock
still recognize it as a cascade victim") — but `restoreContainer` and the
shared `flipBlockCascadeTombstones` (restoreBlock + undo's
revertDeleteBlock) were never extended: a restored post lost its lenses
(days-long work, her round-3 rationale), a restored block silently lost
its picks and canvas position — AppSpec §9's letter and structural undo's
exact-pre-image contract both broken. **Fix:** `flipBlockCascadeTombstones`
gains the canvas_layout + lens_choice flips with the SAME live-parent
guards as the tag flip (a row under a dead container/lens stays dead);
`restoreContainer` revives the container's exact-stamp lenses BEFORE the
block loop (so each block's flip sees live lenses). **Pins (all red
pre-fix):** `LensRestoreTests` (restoreBlock revives the pick; UNDO
revives it too; restoreContainer revives lenses + choices; the negative —
a pick whose lens died independently stays dead) + `CanvasRestoreTests`
(both doors revive positions, byte-exact x/y).

**MINOR 2 (the quit door awaits only the focused editor — takes/TOC pane
text lost to ⌘Q) — AGREED, fixed, RED-verified by behavioral revert**
(registration commented ⇒ the typed text absent post-quit; the Phase 10
quit-door class, reintroduced by the new surfaces). **Fix:** AppSession
gains `QuitFinalizeRegistry` (Mac-side, beside the editorRouter);
TakesViewModel and BlockTOCViewModel register their coordinators' flushes
at init and unregister at teardown (BlockTOCView gains the missing
`.onDisappear` teardown); the delegate awaits the focused editor's
finalize AND `finalizeAll()` before replying. Pins:
`QuitFinalizeSurfacesTests` (a takes-pane and a TOC-pane edit inside the
debounce both survive the composed quit path; teardown unregisters).

**MINOR 3 (unbounded unplaced-blocks observation) — AGREED, fixed
(architectural; mechanism traced — the unplaced set is corpus-history-
shaped by construction since every merge/divide-W releases lineage blocks;
no pin owed, the Phase 10 MINOR-3 precedent).** `Queries.unplacedBlocks`
gains an optional `limit` (nil = the one-shot full fetch); RecoveryView
observes `window + 1` with the probe-and-marker parity of its two sibling
sections.

**MINOR 4 (copyPost's hard DELETE strands a phantom outbox entry; the ops
layer's only physical delete) — AGREED, fixed, RED-verified by behavioral
revert** (the reverted insert-then-delete left exactly 1 phantom row —
`sync_outbox` naming a block that doesn't exist, undrainable forever
because push's snapshot compactMap drops-without-clearing). **Fix:** the
variant set is computed FIRST and the block row minted only when it is
non-empty — the DELETE is gone; S2's letter holds (the ops layer performs
no physical deletes). Pin: `CopyPostPhantomOutboxTests` (a forced
SyncSpec-§5 gap slot copies as nothing; zero phantoms; no
inserted-then-deleted rows).

**MINOR 5 (the guided confirm executes plan-time cuts across the
human-scale alert window with no drift check) — AGREED, fixed,
RED-verified by behavioral revert** (the reverted code produced the exact
silent wrong-position split the reviewer predicted: "Rewritte" /
"n remotely…" — the stale offset landed in-bounds in the rewritten text).
**Fix:** the sibling compounds' CAS, as the finding offered:
`CrossBlockMakeState` snapshots the edge blocks' rendered variants+texts
at plan time; the confirm's compound opens with a no-op
`editTakesAtomically` verification of the DIVIDED edges (middles merge by
id — their text drift is harmless); a moved buffer refuses the whole
compound visibly. Pin: `aBufferMovedUnderTheOpenConfirmRefusesTheCompound`.

**MINOR 6 (two load-bearing comments state the pre-sitting world) —
AGREED, fixed (cleanliness; the traced mechanism is misdirection of the
fresh sessions that build their refusal-vocabulary model there; no pin).**
The `.makeBlockAcrossBlocks` case doc now states the any-arity guided flow
with the executor's auto-proceed/ceremony call; `planCrossBlockEdit`'s
eligibility comment now states the ANSWERED #11a routing.

**NIT 7 (removeVersionOf's inverted refusal) — AGREED, fixed:** new
`versionLinkNotFound` case thrown where the link does NOT exist; the
not-found path now pinned in `VersionOperationsTests`.

**NIT 8 (LCS table memory at multi-thousand-line scale) — AGREED,
recorded:** bounded by the compared inputs (not P1 as written, the
finding's own framing); the code comment now carries the Phase 12
scale-check note (two-row LCS / Myers bounds it if the hardening
benchmarks show it).

**NIT 9 (inline GRDB/SQL in view-model observation closures) — AGREED,
fixed (architectural — review focus 5's letter: home, not shape):** the
per-block active-fan fetch and the title SELECTs move to tested Queries
homes — `Queries.activeFans(blockIDs:)` (which `takesProjection` itself
now reads through: one brain, pinned equal) and
`Queries.containerTitle(id:)` (tolerant, pinned); AlignedPostsViewModel
and OutlineDraftViewModel compose exclusively Queries traversals.

**Post-round counts: core 626 green in 74 suites · Mac 352 green in 63
suites · mobile 11 green in 4 suites — all green** (pre-round: 618/71 ·
349/62 · 11/4; +8 core pins across 3 new suites, +3 Mac pins).

### Review round 2 — dispositions (2026-07-13; round 1's nine fixes ALL verified by the fresh reviewer; 1 NEW MAJOR / 3 MINOR / 2 NIT — ALL AGREED, all fixed; the round-3 anchor)

**MAJOR (the takes board's `liveBuffers` never clears —
`projectionCaughtUp` had ZERO callers; the display could go permanently
stale, then resumed typing clobbered newer store text with NO conflict
variant) — AGREED, fixed, RED-ON-CURRENT verified.** Mechanism confirmed
by my own trace AND by the pin failing before the fix: `paneEdited`
inserted entries; nothing ever removed them (the seam's own doc recorded
the unwired intent); `resolvedTake` and the blooms preferred the frozen
buffer forever, so an external edit — a phone edit landing via sync, an
engine repair, a sibling surface — never reached the display, Sameness
computed on stale bytes, and a resumed edit sent a stale-based full text
through autosave (an ordinary local write AFTER the remote landed cleanly
— S5 never fires; the stale-surface-clobber class). Broke the sitting's
governing vocabulary on the flagship surface. **Fix (the designed seam,
wired):** `adopt(_:)` — which only runs clean or at settle — now calls
`projectionCaughtUp` for every buffer with NO pending autosave record;
pending entries stay authoritative (the dirty half, separately pinned).
Accepted residual, recorded in the code: a stale pre-flush emission
racing settle can flicker one observation cycle before the post-commit
emission converges it. **Pins:**
`aSettledAdoptionDropsTheBufferAndShowsExternalEdits` (RED on current:
returned "local typing" where "remote edit landed" was truth) +
`aDirtyBufferStaysAuthoritativeUntilSettle` (the discipline's other half,
green both sides BY DESIGN — a guard pin, not a bug pin).

**MINOR 2 (restoreContainer still loses cascade-stamped canvas/lens_choice
rows whose block DEPARTED before the delete — a residual corner BESIDE
the round-1 fix; the in-code comment overclaimed) — AGREED, fixed,
RED-ON-CURRENT verified (both pins).** Traced: the container cascade
stamps ALL rows by container_id — including a departed block's inert row
(the A7-pinned remembered position; the write-time placement guard binds
at write, `moveBlock` later is legal) — but restore revived only through
the per-block loop, and a departed block is never in `blockIDs`. **Fix:**
`restoreContainer` adds direct exact-stamp flips after the block loop —
`canvas_layout` by container + `lens_choice` through the just-revived
lens chain — guarded on the BLOCK being live (revived here or living
elsewhere; independently-dead blocks keep their rows dead — the standing
guard shape); the overclaiming comment corrected. **Pins:**
`restoreContainerRevivesADepartedBlocksRememberedPosition` (the position
is byte-intact when the block returns) +
`restoreContainerRevivesAPickWhoseBlockDepartedThePost`.

**MINOR 3 (the guided confirm executes against possibly-shifted entry
INDICES — text CAS didn't cover index drift, and the misclassification
path skipped the CAS entirely) — AGREED, fixed, RED-ON-CURRENT verified.**
Traced: plan-time positional indices re-read after the human-scale alert;
a remote structural insert above re-addresses every position (mobile
capture mints blocks — the daily-drive reality); the
`startCut == firstLength` misclassification silently drops an edge AND
its CAS check. **Fix (the finding's one-guard shape):** the confirm
verifies IDENTITY — `entries[firstIndex].blockID == state.blockIDs.first`
and the last twin — and refuses visibly on mismatch ("the blocks moved
while the confirm was open"). **Pin:**
`anIndexShiftUnderTheOpenConfirmRefusesByIdentity` (RED on current: the
pre-fix confirm proceeded against the shifted world).

**MINOR 4 (production quit/teardown never awaits `pendingCrossBlockTask` —
the closeout's "teardown/tests await quiescence" held only for tests) —
AGREED, fixed, RED verified by behavioral revert** (the reverted guard
left the compound silently un-applied at quit: both pin expectations
failed). Traced: the triggering keystroke was REFUSED, so
`finalizeWork`'s dirty guards see nothing; ⌘Q could reply terminateNow
with the gesture unexecuted (bounded harm — the surface never showed the
deletion — but the quit-door class in gesture form, and a falsified
recorded guarantee). **Fix (the finding's two lines):** `finalizeWork`
guards on `pendingCrossBlockTask != nil` and its task awaits the pending
compound before the flush. **Pin:**
`quitTimeFinalizeLandsAScheduledCrossBlockCompound`.

**NIT 5 (the TOC pane has no live-buffer map — a sub-second post-blur
flicker window; charDelta from a possibly-stale projection) — AGREED,
RECORDED (the finding's offered alternative):** the flush is forced at
`makeLive`, so the window is one flush+observe cycle and self-healing;
the takes board carries the full discipline because its panes are the
flagship editing surface, the TOC's expand-to-edit is a convenience. The
acceptance is now written AT the mechanism (`makeLive`'s comment);
revisit with Phase 13's polish if it ever shows. The charDelta staleness
is cosmetic by design (churn approximate — SyncSpec §6's counter class).

**NIT 6 (two inline EXISTS probes left in the tutorial view file) —
AGREED, fixed:** `Queries.containerIsLive(id:includingArchived:)` is the
tested home (pinned, both flavors); the tutorial's seeding/reset checks
read through it.

**Post-round counts: core 628 green in 74 suites · Mac 356 green in 64
suites · mobile 11 green in 4 suites — all green** (pre-round: 626/74 ·
352/63 · 11/4).

### Review round 3 — dispositions (2026-07-13; 1 MINOR / 1 NIT, ZERO new BLOCKER/MAJOR — THE LADDER CLOSES at the hard cap; fixes landed POST-CAP per the ladder's rule, recorded for the author)

Round 3 independently verified every round-2 fix clean (buffer-convergence
premise re-checked at commit level; both restore flips' SQL re-read; all
three suites re-run green by the reviewer itself).

**MINOR (the confirm's boundary-vs-interior cut classification re-derived
from CONFIRM-TIME lengths — text drift crossing the cut length under the
open alert skipped both the CAS and the divide: the residual corner of
round-1 MINOR 5 + round-2 MINOR 3) — AGREED, fixed post-cap,
RED-ON-CURRENT verified.** Traced end to end and confirmed by the pin
failing pre-fix (the compound proceeded and silently EXCLUDED the first
block's selected span — the reviewer's exact outcome; the last-edge dual
would silently INCLUDE a remotely-rewritten block). **Fix (the finding's
one-guard shape, no new state):** `firstLength`/`lastLength` now derive
from the PLAN-TIME snapshots the state already carries — a drifted edge
always enters the interior branch, where the existing CAS refuses the
whole compound before any row changes, exactly as the prior guards were
built to do. **Pin:**
`aTextDriftCrossingTheCutLengthRefusesInsteadOfReclassifying` (RED on
current; green on the fix). Bounded-harm framing per the finding: one
undo restores, the window needs a remote edit crossing the cut length
during a human-scale alert.

**NIT (`pendingCrossBlockTask` assigned and chained but never cleared —
"pending" stopped meaning pending after the session's first compound; the
quit fast-path permanently disabled, harmlessly) — AGREED, fixed post-cap
(cleanliness; no observable misbehavior, no pin owed per the guard's
architectural clause).** `scheduleCrossBlockCompound`'s task body now
nils the handle after `body()` when a UUID token confirms it still owns
the slot (a chained schedule keeps its own).

**FINAL 11a counts after round 3: core 628 green in 74 suites · Mac 357
green in 64 suites · mobile 11 green in 4 suites — all green.** These are
the 11b baselines.

### 11a CLOSED (2026-07-13)

Stage A is complete: A0–A10 shipped, the two author gates passed (#10/#11
answered live and built; gate 1 — the mirror deploy — executes at the
coordinator's post-ladder gate), the review ladder ran all three rounds
and closed at the cap with zero HIGH findings after round 2. **Stage B
(export/import + the reference panel) is master-plan row 11b — its own
`/run-phase` invocation; this plan file's Stage B section + this closeout
are its anchors; no new plan document is owed (the front-loaded rule is
satisfied by this file), and Phase 12's plan is authored at 11B's
closeout, not now.**

#### Step A10 — the modes tutorial (her round-6 instruction)
`Features/Tutorial/ModesTutorialView`: POLISH IN PLACE / THREAD ONE
PIECE / FORK THE PIECE — captioned sections with LIVE examples over a
SEEDED demo post ("safe to delete" in its title; defaults-bookmarked id;
seeding idempotent + ISOLATED — pinned byte-level against a user row);
examples drive REAL ops on the demo only (branch/✓/adopt/
duplicateAsVersion — pinned); Reset deletes demo + tracked fork copies
and re-seeds (NO ORPHANS pinned, incl. the empty unplaced-blocks net);
her boundary sentence quoted verbatim. Functional; Phase 13 prettifies.
`ModesTutorialTests` 3. PLUS §12's **unplaced-blocks utility view** (the
brief's standing definition): a RecoveryView section listing
`Queries.unplacedBlocks` plainly, with a place-into-pool door
(`placeBlock`'s face).

#### PROVISIONALs and open items (the checkpoint's walk)
- **QUESTIONS #18** — the seal posture on the new metadata surfaces
  (block names REFUSE — the everything-under letter; canvas positions
  ALLOW; lens CRUD ALLOWS — viewing isn't authoring; ✓/adopt/take-minting
  still refuse under seal through their own guards). One guard line each
  to flip.
- **QUESTIONS #19** — the post-level version link's first-block anchor.
- Interpretation PROVISIONALs implemented as planned: reference drag-out
  (Stage B), diff = line-based, swap = view-local absorption, canvas =
  pools-first, PDF path (Stage B).
- **QUESTIONS #10/#11 — OPEN; the A9 gates.** Demos ready.
- Build-time calls recorded above (fan-style default 'stack'; duplicate's
  verbatim title/entry_date; 'manual' origin; branch-all fan-end
  positions; scratch-⧉ saves first; presentation degradations).

#### Pre-gate verification (the formal Stage A gate re-runs after the A9 answers)
- Core `swift test`: **618 green in 71 suites** (baseline 562/62).
- Mac app: **343 green in 62 suites** (baseline 311/55) — the randomized
  gesture soak (GestureSoakTests) green over the changed planner; the
  tint/badge/window smokes green (TEXTKIT2 §5's executable items ride
  these suites; macOS 26.4.1 unchanged — no spike re-run owed). Two
  environment notes: `-only-testing:` with a wrong suite name reports a
  vacuous SUCCESS on zero tests (bit this session once — always confirm
  the count line); the full run stays ~13 s.
- Mobile: **11 green in 4 suites** (baseline matched).
- Sync convergence incl. canvas + lens + block.name rows crossing the
  wire: `Phase11SyncConvergenceTests` (core) — byte-identical dumps,
  empty outboxes.
- P1/P3 spot checks: the takes board's standing observation is ONE
  post-bounded fetch; panes are content-sized read-cheap surfaces with
  ONE live editor (pinned); the TOC at 100+ blocks is row-cheap with
  text upgrading on expand (the within-post-virtualization face) —
  formal measurements at the gate re-run.

### The A1 lockstep deploy — EXECUTED (2026-07-13, coordinator, under the author's standing delegation)

The SyncSpec §12 choreography, as run:

1. **Mirror first:** `Server/supabase/05_phase11_lockstep.sql` executed
   verbatim on the production mirror via the author's PAT (Management API;
   HTTP 201). Verified in the same sitting: `sync_schema_version()` = 2;
   `canvas_layout` / `lens` / `lens_choice` present with ZERO rows; RLS
   enabled on all four new objects (incl. `sync_meta`); `block.name` column
   present. The env-gated integration test was deliberately NOT run — it
   writes rows and the mirror fronts the author's live corpus; end-to-end
   proof arrives with the updated devices' first real rounds.
2. **Mac client:** the post-ladder Release build (`8d82b5f`) installed to
   `/Applications/Variorum.app` with the app confirmed quit (never
   hot-swapped). Awaits her relaunch.
3. **Phone — PENDING, hers:** the one-time updated Release install (handoff
   checklist). Until it lands, the old phone build keeps syncing normally
   (no marker check; the new tables serve it zero rows). §12's letter
   ("every client updates before any new-schema write") therefore becomes
   the checklist's practical rule: **don't create lenses / canvas positions
   / block names until the phone is updated** — those are all deliberate
   gestures, so ordinary journaling and editing are unaffected in the
   window; the checkpoint report says this to her explicitly.

### Checkpoint ratification round (2026-07-13, the author via the coordinator)

- **QUESTIONS #18 RATIFIED AS SHIPPED, all three surfaces:** block names
  REFUSE under seal; canvas positions ALLOW; lens edits ALLOW (✓ / adopt /
  diverge-here keep refusing under seal through their own ops' guards).
- **QUESTIONS #19 RATIFIED AS SHIPPED (option (a))** after the label-vs-map
  tradeoff walk: `version_of` is the one coarse findability LABEL (anchored
  on the first-block pair — plumbing, not meaning); the per-block MAP is
  `derived_from` lineage, minted automatically wherever real history exists
  (copies/promotes/outline-derived drafts) and deliberately ABSENT between
  independently-written posts (invented correspondence = fake history).
  The re-mark-after-anchor-restructuring cost accepted; a post-level link
  table only if re-marking annoys in real use.
- Both entries marked ANSWERED in QUESTIONS.md. The checkpoint report was
  delivered in the coordinator session the same day; the deploy stands
  two-thirds complete (mirror v2 + Mac installed; the PHONE install is the
  author's one open action — no lens/canvas/name writes until it lands).
  THE PHASE IS CLOSED; Phase 11b awaits her kickoff.

### Stage B implementation record (2026-07-16, single Fable implementer session — Steps B1–B3 + the verification gate; the review ladder's anchor)

**Run shape:** B1 → B2 → B3 in order, one commit per step, each step's
suites green before its commit; the FULL three suites re-ran green at the
gate (counts below). **NO schema change** (the coordinator's scoping note
confirmed at the letter: the `reference` table and its operations have
existed since v1/Phase 2; nothing Stage B needed a new column — no §12
lockstep event, nothing gated on the author's pending phone install).
Baselines inherited from 11a: core 628/74 · Mac 357/64 · mobile 11/4.

#### Step B1 — export, the ratified shapes (commit `68b165b`)
- **Core `Queries/Export.swift`** — pure read-side projections, ALL through
  `joinRenderedTexts` (review focus 2's letter: `exportPost` without
  variants IS `renderedText` — the same call, pinned equal — so the
  2026-07-12 conditional join and blank-take skip are inherited, never
  re-implemented; stored spacing exports byte-exact).
  - `exportPost(includeVariants:)` — chosen takes in place; with variants,
    each fanned block's **"Alternates for this block" section follows the
    block IN PLACE** (build-time call: the literal "renders in place;
    alternates follow" reading — the single-block shape repeated, one
    brain; an appendix-at-end alternative was considered and rejected as
    needing invented block identifiers). Section markers, exact:
    `--- Alternates for this block ---` … `--- end alternates ---`;
    labeled takes as `take: "<label>"`, unlabeled numbered by 1-based
    ordinal among the block's alternates in fan order. Alternates = live
    ACTIVE takes minus the rendered one, **blank takes skipped** (the
    blank-take doctrine applied to the section — build-time call) and
    **archived takes excluded** (out of the fan; the Phase 14 variorum
    edition is the full-fidelity tier). A fanned block whose CHOSEN take
    is blank still emits its section under includeVariants (the takes are
    the author's work; the blank chosen skips as ever) — build-time call.
  - `exportBlock` — the read-time rule block-scoped (live placement's
    chosen else live default; an unplaced lineage block renders its
    default — pinned via a merge-released block); fanned → the same
    section; dead/missing → empty (tolerant read).
  - `exportReading` — ONE document: `# <name>`; posts under `## <title>`
    (title else entry_date else "Untitled"); when the reading groups by a
    tag root, section headings `## <sectionPath>` (nil-section posts under
    `## Ungrouped`) with posts dropping to `###` — build-time call on the
    heading levels; pieces joined through the one join brain; missing
    reading → empty.
  - `bulkExportManifest(includeReadings:)` — the ONE-gesture totality as
    pure data (`ExportFile` = relative path + contents; the app face only
    writes): every live post exactly once, filenames
    `<date> <sanitized title>.md` (entry_date else the created day; date
    alone when untitled — journal-friendly), **deterministic id-prefix-8
    collision suffix** (case-insensitive tracking — APFS default);
    **archived posts INCLUDED under `Archived/`** (QUESTIONS #22b — the
    no-lock-in totality + the 9b archived-stays-projected doctrine;
    tombstoned posts do NOT export — the SQLite file stays the lossless
    archive); readings as the optional folder view (`Readings/<name>.md`,
    the reading projection — a VIEW over the same posts, never a second
    copy); bodies are the PLAIN projection ("folder of plain .md" — no
    variants in bulk). `sanitizedFilename` public (the app's default
    save-panel names derive from the same rule).
- **App `Features/Export/`** — `PDFExporter` (QUESTIONS #21: the pure
  attributed-string → CTFramesetter → CGPDFContext path; US Letter, 1-in
  margins, system fonts — functional-unstyled, Phase 13 owns typography;
  bold title line on post PDFs; ≥1 page always, pagination terminates by
  construction); `ExportWriter` (manifest → files, intermediate dirs,
  atomic writes); `ExportModel` (projections read off-main via the reader
  pool; write-where-pointed; report/error surfaced); `ExportPanels`
  (NSSavePanel/NSOpenPanel — thin, author-visible moments).
- **Doors:** library/journal post context menu → Export ▸ Markdown… /
  Markdown with Takes… / PDF…; reading context menu → Export Markdown… /
  Export PDF…; File menu (CommandGroup after `.importExport`) → **Export
  Library…** (folder chooser → bulk) and **Export Block as Markdown…**
  (the caret block; block export is .md-only — a one-block PDF earns
  nothing, recorded). Reports land in the sidebar status line / editor
  status / an alert when no editor is focused.
- **Tests:** `ExportProjectionTests` 11 (shape pins incl. exact fan
  sections both labeled and numbered; the == renderedText pin; stored
  spacing byte-exact; blank-chosen section; unplaced-block default;
  grouped + ungrouped reading shapes; bulk totality/layout/collisions;
  sanitizer; **NO export path writes rows** — row counts + sync_version
  sum + empty outbox after every export path). Mac `ExportFacesTests` 5
  (PDF is a real document carrying the text; long bodies paginate >1
  page, empty = 1; bulk writer creates subfolders + exact contents;
  ExportModel delivers core bytes unchanged and writes where pointed).

#### Step B2 — import, drop-in (commit `3ebf942`)
- **Core `Operations+Import.swift`** — TWO doors, one pipeline
  (`SegmentationRules.bulkSegments` — the same class as paste/drop/
  capture, so the 2026-07-12 spacing ruling rides for free), each ONE
  transaction:
  - `importPost(title:text:)` — the library door: a NEW post, segmented
    by the global `default_segmentation` (a fresh post has no override);
    shares `insertPost` with `createPost` (made internal — one mint
    shape). Undo: `revertMintedContainer`, label "Import" (the copy-op
    pattern; `restoreContainer` stays the recovery door — pinned
    round-trip).
  - `importBlocks(into:text:)` — the pool door: scraps appended at the
    end of the EXISTING container per ITS effective segmentation
    (override else setting else paragraph — the containerHeader chain);
    sealed refuses (`ensureUnlocked`). Deliberately door-agnostic: any
    live unsealed container is accepted at the ops boundary (the UI
    decides which doors exist) — recorded. Undo:
    `revertImportedBlocks` — exactly the minted blocks tombstoned,
    `last_container_id` stamped (tray-reachable — pinned).
  - Whitespace-only text refuses (`OperationError.emptyImport`, new
    case) — nothing minted (pinned). Mints stamp touch + churn per the
    ratified `newBlock` rule (one `registerTextChange` per minted block —
    byte-identical semantics to N `newBlock` calls).
  - **Round-trip pins:** import→export reproduces dropped bytes
    (`"Alpha.\n\nBeta.\n\n\nGamma."` exact); export→import→export
    byte-STABLE, with the recorded moduli — edge runs (leading/trailing
    blank lines) drop; a single newline between paragraphs promotes to
    the `"\n\n"` join on FIRST export (no stored trailing content) and is
    stable thereafter. Sentence-mode global default honored (pinned).
- **App `Features/Import/`** — `ImportModel`: `handleDrop` (file URLs +
  plain text via NSItemProvider), `importFiles` (extension allowlist
  md/markdown/txt/text — anything else skips VISIBLY; UTF-8 with lossy
  fallback; title = filename sans extension; per-file skip reporting
  never fails the whole drop; reads under the drag's security scope),
  `importText`. **The dropped file is a ONE-WAY source: the model only
  ever READS the URL** — pinned by bytes+mtime-unchanged (review focus
  4). Doors: the sidebar List is the LIBRARY drop target; the pool's
  rows/empty-hint/button carry DEEPER pool targets (deepest target wins —
  drop ON the pool lands as scraps: QUESTIONS #22a, the letter's "new
  post" read as the library case); File menu **Import Files…** (the
  drop's keyboard-reachable twin, same operation — build-time call).
- **Tests:** `ImportOperationTests` 8 (segmentation per global +
  per-container defaults incl. one_block; spacing round-trips; empty
  refuses both doors with zero mints; sealed refuses; touch stamped;
  both undo shapes). Mac `ImportFacesTests` 4 (file→post with source
  untouched — bytes + mtime; multi-file + non-text visible skip;
  text→pool scraps; empty drop reports, zero mints).

#### Step B3 — the reference panel (commit `e55ca03`)
- **Core** — `Queries.references` (live rows by `(position, id)`) +
  `AppDatabase.observeReferences`; NO new operations (add/remove/
  reorder/view-state shipped Phase 2 — verified, reused).
  **The `file_bookmark` exclusion RE-PINNED from the panel's own write
  path** (`ReferencePanelQueryTests`): a reference created exactly as the
  panel creates it (real bookmark bytes) reaches the outbox but its
  `SyncRow` payload carries NO `file_bookmark` key while the local row
  keeps the bytes — the plan's "verify, don't assume", verified.
- **App `Features/References/`** — `ReferencesViewModel` (every gesture
  one Phase 2 op; URL adds scheme-normalized https + host-named; file
  adds mint a security-scoped bookmark at the author's open panel, with
  a plain-bookmark fallback where scoping is unavailable; reorder = one
  fractional move against the sibling anchor; `ReferenceViewState` —
  extensible JSON page memory, unknown keys tolerated);
  `ReferencePanel` in `PostDetailView`'s inspector (toggle beside the
  mode picker; session UI state): **PDFKit** pane for PDFs (page memory
  restored at load + persisted on `PDFViewPageChanged`; **selected text
  drags OUT through the editor's existing drop path — gesture-style bulk
  copy, NO lineage edge: PROVISIONAL, QUESTIONS #20**), **Quick Look**
  for other files, **read-only WKWebView** + "Open in Browser" for URLs;
  security scopes held per preview and released at panel teardown;
  stale/unresolvable bookmarks degrade to a visible "can't be found"
  state. EPUB/annotation/citation untouched (permanently out of scope).
- **Tests:** core `ReferencePanelQueryTests` 3 (listing order/liveness/
  scoping; the serializer pin; view-state round-trip through the op).
  Mac `ReferencePanelTests` 5 (view-state JSON incl. tolerant + unknown
  keys; URL normalization + refusal; bookmark mint→resolve round-trip on
  a real temp file; remove/reorder through the UI path with tombstone
  asserted; page memory persistence). The REAL-file/TCC moments (save
  panels, a real PDF's grant + drag-out feel) are author-assist — the
  handoff checklist carries them.

#### Stage B verification gate (2026-07-16 — GREEN)
- **Core `swift test`: 650 green in 77 suites** (11a baseline 628/74).
- **Mac app: 371 green in 67 suites** (baseline 357/64) — full suite,
  count line confirmed non-vacuous.
- **Mobile: 11 green in 4 suites** (baseline matched; Stage B is
  Mac-only surface + core, mobile untouched by design).
- Import/export round-trip pinned in core (byte-stability + moduli).
- No engine, bridge, or schema files touched beyond `Queries/` additions
  and the two `Operations` files named above (the Sync/ rider never
  engaged; `Bridge/` untouched — the bridge's projection already called
  `joinRenderedTexts` and still does).
- PROVISIONALs awaiting the checkpoint walk: QUESTIONS #20 (drag-out
  lineage), #21 (PDF path), #22 (pool-drop destination; archived posts
  in bulk export under `Archived/`).

### Stage B review round 1 — dispositions (2026-07-16; 1 BLOCKER / 2 MAJOR / 1 MINOR / 3 NIT + a clean bill on export purity, the conditional join, import one-way-ness, and the bookmark exclusion — ALL EIGHT AGREED, all fixed-or-filed; the round-2 anchor)

**BLOCKER (every save-panel export door dead in the sandboxed install —
`ENABLE_USER_SELECTED_FILES = readonly`, and Stage B added the app's
first-ever user-selected writes) — AGREED, fixed, RED-verified by run
(commit `7e7948f`).** Mechanism self-verified: both app configs carried
`readonly` (pbxproj 618/651); the documented powerbox rule refuses
NSSavePanel display entirely without read-write, `ExportPanels.saveFile`
maps any non-`.OK` to nil, and every caller treats nil as user-cancel —
all six save doors silent no-ops, and bulk export's folder grant was
read-only so `ExportWriter` writes denied. The Mac tests wrote only to
`temporaryDirectory` (container-internal) and never crossed the powerbox
— the 9c-finding-3 class (a capability's first use is where its missing
entitlement surfaces), and the fix is the established Phase 7/8/9c
target-defect class (the 9c network setting sits two lines above in the
same blocks). **Fix:** `readwrite` in both configs. **Pin, RED state
confirmed by run on the pre-fix settings:** `EntitlementsTests.
userSelectedFilesAreReadWrite` reads the test host's REAL signed
entitlements via `SecTaskCopyValueForEntitlement` — failed on `readonly`
(transcripted), green after. No signing identity/provisioning surface
(synthesized entitlement, automatic local signing).

**MAJOR 1 (bookmark persistence unpinned — no `bookmarks.app-scope`
entitlement; the plain fallback documented-dead across relaunch and
silent) — AGREED, fixed, both pins verified (commits `7e7948f` +
`a5e514e`).** (i) `Variorum.entitlements` created (outside the
synchronized group, beside the xcodeproj) declaring
`com.apple.security.files.bookmarks.app-scope`, wired via
`CODE_SIGN_ENTITLEMENTS` in both configs — the established target-defect
class; nothing touched signing identity/provisioning. **The merge
verification the coordinator required — `codesign -d --entitlements` on
the RELEASE build:** `app-sandbox` ✓ · `files.bookmarks.app-scope` ✓ ·
`files.user-selected.read-write` ✓ · `network.client` (the 9c
entitlement, survived) ✓ · `get-task-allow` (local dev automatic
signing, expected) — the file MERGES with the synthesized ENABLE_*
settings, replaces nothing. Pin `appScopedBookmarksAreDeclaredAndThe
SandboxHolds` (RED on the pre-fix settings by run — transcripted) also
guards the merge: sandbox + network must stay present. (ii) Bookmarks
now mint `[.withSecurityScope, .securityScopeAllowOnlyReadAccess]` —
**read-only scope, the coordinator-approved build-time call:** a
reference is a §7 VIEWING AID, never written; page memory lives in
`view_state` rows, never the file. Consequence recorded: if a future
phase ever wants to annotate/write reference files, the mint option is
the line to revisit (a product-call moment anyway). (iii) The
plain-bookmark fallback is **visibly degraded** (the reference adds; the
panel says "added without cross-launch access… re-add it if so" — a
plain bookmark grants zero sandbox access after relaunch, documented,
so silence was a delayed silent failure), via an injectable mint seam.
**Pin RED-verified by behavioral revert** (`anUnscopedMintIsVisibly
Degraded`: visibility line disabled ⇒ `lastError` nil ⇒ FAILED;
restored ⇒ green). (iv) The handoff's real-file walk gains an explicit
RELAUNCH step (re-open a PDF reference after quitting — the cross-launch
grant proven on a real user file).

**MAJOR 2 (`resolveFileURL` ran I/O + scope claims + observed-state
mutation inside a View body; claims accrued unboundedly with no
per-selection release; the comment claimed a release path that didn't
exist) — AGREED, fixed, RED-verified by behavioral revert (commit
`a5e514e`).** All three halves self-traced as plain code facts (my own
code and my own overclaiming comment). **Fix (the finding's shape):**
resolution + claiming moved to the panel's `.task(id: selection)` →
`preparePreview` (release-previous → resolve → claim-once → failure
recorded as `PreparedPreview` state, never a mutation during view
update); `ReferencePreview` is now a PURE renderer; outstanding claims
bounded by ONE preview by construction; `claimAccess` is claim-once per
URL; the `accessedURLs` comment corrected to describe the real
lifecycle. **Pins, RED states confirmed by behavioral revert (both
reverts run and transcripted):** `preparingTheSameReferenceTwiceClaims
Once` — unconditional-claim revert read count 3 (the pre-fix
per-render accrual), green restored; `movingTheSelectionReleasesThe
PreviousClaim` — no-release revert read count 2 with the stale claim
retained, green restored. The failure-loop half stands as the reviewer
framed it (plausible, not empirically confirmed) — moot under the fix:
nothing resolves in body anymore.

**MINOR (bulk export silently excludes every pool scrap; no pool export
door exists) — AGREED, filed as directed, NO behavior change.** The
shipped manifest matches the ratified letter ("every live post exactly
once"), but the reviewer is right that this bundle's own #22b reasoning
(no-lock-in totality surfaced archived posts) was not applied to pool
scraps, which are equally her work. Per the coordinator's adjudication:
QUESTIONS **#22 gains sub-item (c)** with the finding's two shapes
verbatim ("`Pools/<title>.md` in the manifest, or an explicit recorded
exclusion — one manifest addition + one test either way") — a product
call for the checkpoint walk, deliberately not defaulted.

**NIT 1 (QUESTIONS #16 stranded under the new 11b header) — AGREED,
fixed (docs):** #16 moved into numeric position under its own "Phase
9c (2026-07-10)" section between #15 and #17; the 11b walk list now
scopes cleanly to #20–#22.

**NIT 2 (block export's literal "Block.md" default) — AGREED, fixed:**
the default now derives from the block's read-time HANDLE — the A6
`Queries.tocHandle` (explicit name else first sentence; one brain,
already pinned) through `sanitizedFilename` via
`ExportModel.blockExportFileName` (pinned:
`blockExportFileNameDerivesFromTheHandle`); the door fetches the handle
through `Queries.blockTOC` (no inline SQL — the 11a review-focus-5
discipline).

**NIT 3 (bulk export wrote N files synchronously on the MainActor) —
AGREED, fixed (traced-mechanism cleanliness; no pin owed per the
architectural clause).** The trace, as required: `ExportModel` is
`@MainActor` and the target defaults to MainActor isolation, so
`ExportWriter.write`'s `createDirectory` + `Data.write(options:
.atomic)` loop — N synchronous filesystem calls — executed on the main
thread inside `writeBulkExport`, hitching the run loop for the write's
duration on a large library (the projection half was already off-main
via the reader pool — P2 clean; the I/O half wasn't). **Fix:**
`ExportWriter.write` is `nonisolated` and the gesture awaits it
`Task.detached` — the MainActor never runs file I/O.

**NIT 4 (a multi-file drop registered one undo entry per file) —
AGREED, fixed, pin RED on current confirmed by run (pin written FIRST):**
`aMultiFileDropUnwindsWithOneUndo` failed on the pre-fix code exactly as
predicted (one undo left 2 of 3 posts live; a second "Import" entry
remained — transcripted), green after. **Fix:** `importFiles` reads all
files first, then registers the whole batch under ONE
`UndoStack.withCompound(label: "Import")` inside one runner call, with
per-file failures caught INSIDE the compound body (one bad file never
unwinds its siblings; skip reporting preserved). `importText` unchanged
(one gesture, one entry already).
***CORRECTION (round 2, MINOR):* this disposition (and commit
`8b79d10`'s message, which cannot be rewritten) OVERCLAIMED** — the fix
batched `importFiles(urls)`, the array path only the File-menu door
uses; the actual DROP door (`handleDrop`) still spawned one task per
provider, so a real Finder multi-file drop remained N gestures. The
round-2 MINOR below closed the door itself; this entry's claim is true
only as of that fix.

**Post-round counts (full suites, count lines confirmed): core 650
green in 77 suites · Mac app 378 green in 68 suites · mobile 11 green
in 4 suites** (pre-round: 650/77 · 371/67 · 11/4 — +7 Mac pins across
1 new suite: EntitlementsTests 2; ReferencePanelTests +3;
ImportFacesTests +1; ExportFacesTests +1).

### Stage B review round 2 — dispositions (2026-07-16, fresh reviewer; 1 MINOR / 5 NIT, ZERO new BLOCKER/MAJOR — THE LADDER CLOSES at round 2; all round-1 fixes independently verified green by run)

**MINOR (the round-1 NIT 4 fix didn't cover the door the finding named:
`handleDrop` still made an N-file Finder drop N gestures — N compounds,
N overwritten reports — and the round-1 disposition overclaimed) —
AGREED, fixed, pin RED-ON-CURRENT confirmed by run (pin written FIRST,
driving the DROP DOOR itself).** Mechanism self-traced: both drop
targets route through `handleDrop`; its per-provider `loadItem`
completions each spawned `Task { importFiles([url]) }` — the compound
and the aggregated report only exist per `importFiles` CALL, and my
round-1 pin drove the batched-array path that only the File-menu door
uses (the wrong door). **Fix:** `handleDrop` COLLECTS every provider
load first (checked continuations awaited inside ONE task created in
the caller's context — task-locals ride, which also cured an incidental
escaped-dependency artifact the red run surfaced), then calls
`importFiles(allURLs)` once. **Pin:**
`aMultiProviderDropRegistersOneCompoundAndOneReport` — ≥2 real
`public.file-url` NSItemProviders (the pool drag provider's own
registration shape) through `handleDrop`, quiescence awaited; RED on
the pre-fix code by run, all three predicted failures transcripted
(report "Imported 1 post."; one undo left 2 of 3 posts; a second
"Import" entry remained); green after. **The round-1 NIT 4 disposition
is CORRECTED in place above** (the commit-message overclaim in
`8b79d10` noted there — history not rewritten).

**NIT (export errors rendered gray, `exportStatus` never cleared) —
AGREED, fixed:** the sidebar's export outcome rides two fields —
`exportError` joins the RED overlay branch beside the other models'
errors; `exportStatus` carries reports only; both clear when the next
export gesture starts.

**NIT (N synchronous `Data(contentsOf:)` reads on the MainActor in
`importFiles`) — AGREED, fixed (the round-1 NIT 3 class; architectural
clause, trace stated):** the model is MainActor-isolated, so the read
loop — extension filter, scoped access, full-file reads — executed on
the main thread per drop and would hitch the run loop on a large file;
the loop moved to a `nonisolated static readFiles` awaited via
`Task.detached`, ops unchanged.

**NIT (the ratified "readings as OPTIONAL folder views" has no
user-reachable option) — AGREED, recorded (the coordinator's
adjudication: no UI invented):** `bulkExportManifest(includeReadings:)`
is built and pinned both ways; the one face calls the default
(always-on). **Recorded as the build-time call for the checkpoint walk,
both options named:** (a) always-on as shipped (readings are cheap
one-file views over the same posts; the folder is self-explanatory), or
(b) an accessory checkbox on the folder chooser — a product-surface
choice, hers. Comment at the call site carries the record.

**NIT (a multi-select Add File batch let a later clean add erase an
earlier file's degraded-mint warning — last-writer-wins inside one
gesture against MAJOR 1's never-silent guarantee) — AGREED, fixed, pin
RED-verified by behavioral revert:** `addFiles(_:)` is the batch door
(the panel's multi-select calls it once); per-file failures and
degraded notes ACCUMULATE and land as one message. Pin
`aBatchAddKeepsEveryDegradedNote` (mixed batch: file 1 degraded, file 2
clean — the warning must survive); the accumulation reverted ⇒ the pin
failed (warning erased, transcripted), restored ⇒ green.

**NIT (`describeImportError` spoke only for `emptyImport`; a sealed
destination skipped as a raw enum dump) — AGREED, fixed:** the seal
case now reads "the destination is sealed — unseal it first"
(fire-and-speak); everything else keeps the diagnosable raw description.

**Post-round counts (full suites, count lines confirmed): core 650
green in 77 suites · Mac app 380 green in 68 suites · mobile 11 green
in 4 suites** (pre-round: 650/77 · 378/68 · 11/4 — +2 Mac pins:
ImportFacesTests +1, ReferencePanelTests +1). **The ladder closes at
round 2 with zero new HIGH findings.**

### 11b CLOSED — PHASE 11 CLOSED (2026-07-16)

**Stage B is complete: B1–B3 shipped, the review ladder ran two rounds
and CLOSED at round 2** (round 1: 1 BLOCKER / 2 MAJOR / 1 MINOR / 3 NIT
— all agreed, all fixed with red-verified pins; round 2: 1 MINOR /
5 NIT, ZERO new BLOCKER/MAJOR — the ladder rule's clean close; every
disposition above, every bug-class fix red-verified by run or
behavioral revert). **Final Stage B verification state — the Phase 12
baselines: core `swift test` 650 green in 77 suites · Mac app 380 green
in 68 suites · mobile 11 green in 4 suites.** The import/export
round-trip pins hold (import→export byte-exact; export→import→export
byte-stable with the recorded moduli); export purity, the conditional
join, import one-way-ness, and the bookmark exclusion were each
independently re-verified by both reviewers.

The round-1 BLOCKER deserves its one-line moral for future phases: a
capability's FIRST use (here: the app's first user-selected writes and
first app-scoped bookmarks) is where its missing entitlement surfaces,
and container-internal tests cannot see it — the 9c-finding-3 class,
now guarded permanently by `EntitlementsTests` reading the signed
host's real entitlement set.

**PROVISIONALs for the checkpoint walk (QUESTIONS #20–#22 + build-time
calls):**
- **#20** — reference drag-out = gesture-style copy, NO lineage edge.
- **#21** — the PDF path (attributed-string → CTFramesetter).
- **#22a** — a pool drop lands as scraps in that pool.
- **#22b** — bulk export includes archived posts under `Archived/`.
- **#22c** — pool scraps in bulk export: manifest inclusion vs recorded
  exclusion (OPEN product call — the round-1 MINOR).
- Build-time calls recorded in the Stage B sections above: inline
  alternates placement + the section marker text; reading heading
  levels; bulk filename scheme + id-suffix collisions;
  block-export-.md-only; the File-menu import twin; `importBlocks`
  door-agnosticism; **read-only bookmark scope at mint**
  (coordinator-approved); **includeReadings ALWAYS-ON at the bulk face**
  (round 2 — the accessory-checkbox alternative named, hers).

**Deploy state unchanged by 11b** (no schema change): the mirror stays
at lockstep v2; the PHONE's one-time updated install remains the
author's open action from 11a — no lens/canvas/name writes until it
lands. The author handoff (`notes/handoffs/phase-11b-handoff.md`)
carries the real-file/TCC walk INCLUDING the quit-and-relaunch
reference reopen (the cross-launch bookmark proof on a real user file).

Phase 12's execution plan is authored from `phase-12-brief.md` at this
closeout (`notes/plans/phase-12-hardening.md`); the master plan's row
11b is done and the pointer moves to Phase 12.

### Checkpoint ratification round (2026-07-16, the author via the coordinator)

- **QUESTIONS #22c ANSWERED — INCLUDE POOLS in bulk export** (her pick
  of the round-1 reviewer's first shape), **BUILT at the checkpoint**
  per the 11a A9 precedent (her ruling built the same session, kept
  surgical): `bulkExportManifest` gains one `Pools/<sanitized title>.md`
  per live pool — scraps rendered in the pool's own listing order
  (`Queries.pools`, the one listing brain) through the same
  `joinRenderedTexts` semantics (a pool is a container; no bespoke
  shape); collision handling and totality reasoning identical to posts
  (untitled → "Untitled"; id-suffix on case-insensitive collision;
  tombstoned pools absent). Pools ride TOTALITY, not the
  `includeReadings` toggle. **Pins:** the totality pin extended (every
  live pool exactly once; the deleted pool nowhere) + the new
  `poolExportsRenderScrapsInPoolOrderWithCollisionHandling` (the Pools/
  shape incl. stored spacing and disambiguation). NO other behavior
  changed.
- **QUESTIONS #20 RATIFIED AS SHIPPED** — reference drag-out is a
  gesture-style copy, NO lineage edge (provenance would be a schema
  event, hers if ever wanted).
- **QUESTIONS #21 RATIFIED AS SHIPPED** — the attributed-string →
  CTFramesetter PDF path; Phase 13 owns typography.
- **QUESTIONS #22a RATIFIED AS SHIPPED** — a pool drop lands as scraps
  in that pool.
- **QUESTIONS #22b RATIFIED AS SHIPPED** — bulk export includes archived
  posts under `Archived/`; deleted posts never export.
- **Build-time calls RATIFIED:** includeReadings ALWAYS-ON at the bulk
  face (she was offered the accessory checkbox and ratified always-on);
  READ-ONLY bookmark scope at mint; the block export filename derived
  from the read-time handle. The remaining recorded calls (alternates
  placement/markers, reading heading levels, bulk filename scheme,
  block-export-.md-only, the File-menu import twin, `importBlocks`
  door-agnosticism) stand unobjected with the bundle.
- All three QUESTIONS entries marked ANSWERED. **Post-ratification
  counts: core 651 green in 77 suites · Mac 380 green in 68 suites ·
  mobile 11 green in 4 suites.** THE PHASE REMAINS CLOSED; these counts
  supersede the closeout's as the Phase 12 baselines.
