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
`BoundaryFluidityTests` 5. **STOPPED HERE: QUESTIONS #10 (must the W
always be a ceremony?) and #11 (fanned cross-block semantics) are OPEN —
ask-her-live, demos ready; her both-ways-testing method stands where a
live answer doesn't settle. NOTHING was built past them.**

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
