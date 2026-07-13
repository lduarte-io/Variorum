# Phase 11a handoff — Remaining views I: views & the lens/version family (closed 2026-07-13)

*Self-contained checkpoint document (the standing rule: if a question about
this phase can only be answered by the original session, the docs have
failed — everything an author walk needs is here or linked). The full
record — spike decisions, step-by-step implementation notes, all fifteen
review findings with dispositions — lives in
`notes/plans/phase-11-remaining-views.md` (Kickoff spike record + Stage A
closeout sections).*

## Your checklist (in order)

1. **The deploy sequence — three parts, in this order (SyncSpec §12:
   mirror first, then BOTH devices, before any new-schema write).**
   - *(coordinator's, imminent)* The mirror deploy: `Server/supabase/
     05_phase11_lockstep.sql` via your PAT — three new tables
     (`canvas_layout`, `lens`, `lens_choice`), `block.name`, the reworked
     16-table RPCs, and the NEW `sync_meta` version marker +
     `sync_schema_version()` RPC (§12's version-check mechanism, shipping
     with this migration exactly as the spec assigned).
   - *(coordinator's)* The Mac refresh: Release build →
     `/Applications/Variorum.app`. **Your part: quit and relaunch** when
     told it's in place (never hot-swapped under your session).
   - *(YOURS — one-time)* **Install the updated phone app as a RELEASE
     build:** plug in + trust the iPhone, then in Xcode: scheme
     `VariorumMobile` → Product → Scheme → Edit Scheme → Run → Build
     Configuration → **Release** → run to your device once. (Same reason
     as Phase 8: a debug build from the home screen opens the fenced dev
     store where sync is deliberately off.)
   - **What you'll see in between, by design:** any updated client
     checked against an un-deployed mirror (or your phone still on the
     old build after the mirror updates) **visibly refuses to sync** —
     "schema lockstep mismatch," outbox intact, cursor unmoved. That's
     §12 working, not a bug; it clears the moment all three parts are
     done. Offline itself now reads as *waiting/queued*, never
     "SyncError" (the A0 fix — the label you flagged at the 9c sitting).
2. **Open the modes tutorial first** (sidebar → "How the modes work").
   It's the round-6 artifact you asked for: POLISH IN PLACE / THREAD ONE
   PIECE / FORK THE PIECE, with live examples over a seeded demo post
   ("safe to delete" is in its title; Reset re-seeds it; deleting it
   orphans nothing — pinned). It's also the fastest tour of what shipped.
3. **The ratify walk — QUESTIONS #18 and #19 (both OPEN), plus the
   build-time calls:**
   - **#18 — what does the seal refuse among the NEW metadata surfaces?**
     PROVISIONAL calls shipped: **block names REFUSE** under seal (a
     block is *under* the post — though the retitle parallel argues the
     other way and is recorded); **canvas positions ALLOW** (a card's x/y
     arranges a view, touches no content/order/chosen/commit); **lens
     CRUD ALLOWS** (a lens is "a saved way of looking"; ✓/adopt and
     take-minting still refuse under seal through their own ops'
     guards). Each is one guard line to flip if you rule otherwise.
   - **#19 — the post-level version link's anchor.** "Mark as Versions"
     rides ONE `version_of` edge between the two posts' FIRST live
     blocks (I8: posts are edges-only; the edge table is block-to-block).
     Consequence to know: divide/release the anchor block itself and the
     posts read unlinked — re-mark to relink (coarse, not forensic).
     Copies made by *Duplicate as Version* / *Promote lens* also carry
     per-block `derived_from` edges, so they stay peer-linked through
     restructuring in practice. Alternatives (per-pair edges; a
     post-level column) are recorded in QUESTIONS #19.
   - **Build-time calls** (recorded in the plan's closeout): fan-out
     style default is **'stack'** (a synced setting — document
     semantics, like segmentation); *Duplicate as Version* copies title +
     entry_date **verbatim** (a journal duplicate = a second same-day
     entry — your existing hand-merge/pause doctrine applies); copy
     lineage uses the existing `'manual'` origin (no sixth vocabulary
     value invented); *Branch all takes* places new takes at fan END;
     the scratch column's ⧉ saves-first; oversized fans degrade
     presentation gracefully (carousel count, grid overflow) rather than
     refusing.
4. **Three record-only corners** (recorded, deliberate, nothing owed):
   - *Takes board, one-cycle stale echo:* an external edit landing at the
     exact settle instant can flicker one observation cycle before the
     next emission converges it (the round-2 MAJOR's accepted residual —
     the convergence itself is fixed and pinned).
   - *TOC expand-to-edit flicker:* a sub-second post-blur window
     (forced flush + one observe cycle, self-healing); the takes board
     carries the full buffer discipline because it's the flagship
     editing surface, the TOC's editing is a convenience. Acceptance
     written at the mechanism; Phase 13 revisits if it ever shows.
   - *Guided confirm's rarity class:* a remote edit racing the open
     confirm sheet now always **refuses visibly** instead of proceeding
     against a shifted world (three guard layers: identity, plan-time
     lengths, text CAS — the round-2/3 fixes). The class needs a remote
     structural/text change during a human-scale alert; one undo
     restores anything a confirmed compound did.
5. **Carried over from Phase 10, still yours:**
   - **The spacing-ruling shakedown** (QUESTIONS #12 was your ruling):
     paste multi-paragraph text with blank lines; type
     paragraph–Enter–Enter–pause–paragraph; confirm gaps persist across
     pause and quit, and export/bridge carry them.
   - **The app-sections design conversation** you asked for at the 9c
     sitting (what the app's final sections ARE — the Journal section is
     still the minimal dated home). Deliberately open; bring opinions.
6. **Phase 11b, when you're ready — you kick it off.** Stage B of the
   same plan: **export** (`.md` + basic PDF; posts, readings, single
   blocks, fan "Alternates" sections, bulk whole-library — the no-lock-in
   principle), **markdown/text drop-in import**, and the **reference
   panel** (Quick Look / PDFKit with drag-selection-into-draft /
   read-only WKWebView). Its own `/run-phase` invocation; anchors are the
   plan file's Stage B section + the 11a closeout (no new plan document
   is owed; Phase 12's plan is authored at 11b's closeout). B3's
   file-access (TCC) prompts will need you at the machine.

## What shipped (why it's shaped this way)

Everything below renders the store through the Phase 4/10 query layer —
no view invented semantics. Functional and unstyled; Phase 13 makes it
beautiful.

- **The takes/lens view family** (`Features/Takes/` — the six-round
  kickoff spike's decisions, built as ratified): post modes **Write /
  Takes / Compare / Outline / Blocks**. Takes blooms fans in place per
  your chosen style — **stack · carousel (explicit 1–4 count, whole-card
  paging) · margin grid (~3-tall, rightward overflow, changing-block
  highlight) · slot split** — one style at a time, a synced setting.
  Compare is composition A: 1–4 full-text columns as selection profiles
  (main / scratch / lens) with the block-start alignment lock. Panes are
  content-sized read-cheap TK2 surfaces; **ONE live editor migrates on
  click** (P3 unchanged — the rule you ratified for side-by-side).
  Sameness tints only where bytes differ; lineage colors ride 9d's
  stable tint family.
- **SAVED LENSES** (v1_7 `lens` + `lens_choice`): sparse per-block
  overrides over chosen — *"a lens is the same structure with different
  choices; a version is a different structure; promote is the bridge."*
  A lens is **never rendering truth** (the I3 pin rides a randomized
  pane walk): the ordinary editor, book view, export, and the bridge all
  render CHOSEN. The only lens→chosen doors are ✓ (adopt one slot) and
  **Adopt lens** (one transaction, one undo compound). **Promote lens**
  mints a real version post from the lens's picks; **Duplicate as
  Version** forks as-is; both run one shared copy machine, pinned to
  differ only in where chosen comes from. **Branch all takes** gives a
  fresh lens picking new takes branched from what every slot shows.
- **`version_of` gets its operation + both doors** (the KnownIssues row
  resolved): library context menu "Mark as Versions with…" and the
  aligned two-post view's link offer — both emit the same op (canonical
  min/max storage per §7). The **aligned view** keys rows by LINEAGE,
  never order: divide spans share a row, orphans get blank rows beside
  their neighbor, cross-version reorders mark moved kin.
- **Diff** (line-based, whitespace-normalization toggle) between any two
  takes/columns; **swap-and-reread** is absorbed by scratch columns
  (recorded interpretation: a scratch column IS a swapped reading).
- **Book-scrub**: model-driven (the Phase 6 decision honored — the post
  list is the scrubber's domain; page = a post), landing via the bounded
  hybrid jump. **Outline↔draft** over `derivedBlocks` verbatim.
- **The block-TOC** (v1_6 `block.name`): one row per block — the name
  where set, else the first sentence derived at read time (never
  stored); expand-to-read, edit on demand; session-only collapse; naming,
  reorder, delete-to-tray, move-to-pool live on the rows. In-place text
  folding stays ruled out (TEXTKIT2 §3).
- **The canvas** (v1_5 `canvas_layout`, pools-first): drag scraps
  spatially; positions are synced metadata (live-unique per
  (container, block), CAS — exactly the 2026-07-06 design). Plus the
  **full pool experience** (block-tag faces, `everythingTagged` filter)
  and §12's **unplaced-blocks safety net** (a RecoveryView section with
  a place-into-pool door).
- **The boundary-fluidity package (A9)** — the ratified halves first
  (guided cross-block Make Block with a confirm; merge-then-edit so a
  cross-seam delete just works), then **your two live rulings built the
  same session**: **#10** — the W ceremony auto-proceeds when the span
  matches uniquely in every take (the sheet appears exactly when a real
  per-take decision exists); **#11** — visible-take delete is the
  everyday gesture on fanned spans; **Delete in Every Take** is the named
  command that applies to matching takes and REPORTS skips; merge
  **speaks** on fanned blocks before proceeding. The mute-block sugar was
  deliberately NOT built (your call).
- **The §12 lockstep mechanism itself** (the spec's assignment to this
  exact migration): server `sync_meta` marker + `sync_schema_version()`
  RPC; client `SyncSchema.lockstepVersion = 2`; every engine round
  verifies before touching data and refuses visibly on mismatch — outbox
  intact, cursor unmoved, pinned by test.
- **A0**: offline/unreachable now presents as waiting/queued in the
  status row on both platforms (presentation-only classification — the
  engine's keep-the-outbox behavior was already correct).

## The review ladder, in brief

Three rounds, fresh cold reviewer each, closed at the hard cap; all
fifteen findings AGREED, every bug-class fix red-verified (pre-fix-red
pins or behavioral reverts); full dispositions in the plan's three round
sections.

- **Round 1 (1 MAJOR / 5 MINOR / 3 NIT):** the MAJOR — restore/undo
  doors didn't revive the new tables' cascade children (a restored post
  lost its canvas positions and lens picks) — fixed with six pre-fix-red
  pins. Also: the quit door now finalizes the new surfaces; the unplaced
  observation is bounded; a phantom outbox DELETE removed; the guided
  confirm gained its text CAS.
- **Round 2 (1 NEW MAJOR / 3 MINOR / 2 NIT):** the MAJOR — the takes
  board's live buffers never converged to external edits (a phone edit
  couldn't reach an open pane's display) — the designed seam wired:
  settle-time adoption drops clean buffers, dirty ones stay
  authoritative. Also: departed-block restore corner; the confirm's
  identity guard; quit awaits a pending cross-block compound.
- **Round 3 (1 MINOR / 1 NIT, ZERO new HIGH — the ladder closes):** the
  MINOR — the confirm's cut classification re-derived from confirm-time
  lengths — fixed post-cap with plan-time snapshots (drift now always
  hits the CAS refusal); the NIT — the pending-compound handle now
  clears.

## Counts, baselines, deferred

- **Final: core 628 green in 74 suites · Mac app 357 green in 64 suites
  · mobile 11 green in 4 suites — the 11b baselines** (were 562/62 ·
  311/55 · 11/4).
- **KnownIssues:** offline-label, `version_of`, and
  `canvas_layout`+lockstep rows resolved and removed; export, import,
  and reference-panel rows re-owned to **11b**; nothing new added.
- **TEXTKIT2 §5:** macOS 26.4.1 unchanged since the Phase 6 baseline —
  no spike re-run owed; canary armed on every read-cheap pane, silent
  throughout.
- **QUESTIONS:** #18/#19 OPEN for your walk (above); #10/#11 marked
  ANSWERED with your sitting rulings.
