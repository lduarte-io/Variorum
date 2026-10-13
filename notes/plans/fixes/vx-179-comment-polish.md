# VX-179 — the comment area pristine pass

**STATUS: OPEN — kickoff 2026-10-12 (evening).** Ticket **VX-179** · branch `vx-179-comment-polish` ·
worktree `~/dev/variorum-vx-179` · PR `VX-179: …` (merge commit, per the standing rule). Shape:
`/architect-phase` on one ticket — Fable orchestrates + cold-reviews (`fable-reviewer` over the whole
diff; the run touches ONE `Sync/` line, written by the orchestrator itself under a full SyncSpec read),
`opus-implementer` builds, strictly sequential, fresh session per unit.

**Tonight's operational facts (hers, mid-kickoff):** the Pro's stage is HELD by the jadeite release
session — **every stage need (any `xcodebuild test`, walks, the closeout `/Applications` refresh) routes
through the `oct12coordinator` session**, never a direct `Tools/stage` claim; no commits touch the MAIN
checkout until the release reports (the bout-start board snapshot + the in-flight row land THEN — both
are open duties below). Headless `swift build`/`swift test` in this worktree runs freely.

## Her ask (2026-10-12, verbatim)

1. *"the comment pane's cursor to start typing in is misaligned and I feel like it doesn't actually
   look that good"* (the screenshot: the Comments sheet over Write, caret left of and taller than the
   "Write a comment…" placeholder).
2. *"I also feel like it's weird that comments at the side don't show as much as they could show given
   the length of a block - sometimes a block is several paragraphs but the comment is always just one
   line. it would be helpful if they were easier to read while on the side / had a scroll inside the
   comments. it could be handled well when there are multiple comments too."*
3. *"I'm also wondering why when a comment is deleted you can go into deleted comments and not even
   true delete it from there - seems a bit weird."*
4. *"In general I feel like we just need to make sure that the comment area is actually pristine +
   nice UI / UX."*

## Her kickoff rulings (2026-10-12, the kickoff sitting — all three recommended options taken)

- **R-VX179-1 — STACKED ENTRIES in the gutter card.** A block's card holds each comment as its own
  entry — stamp-ordered, thin separators — never the joined `"  ·  "` string; when the entries
  overflow the card's room, you scroll INSIDE the card.
- **R-VX179-2 — the card may grow to THE BLOCK'S OWN HEIGHT** (plus a small pad), still bounded by the
  13u3 rhythm (`roomBelow` — two cards never abut); a one-line block keeps a small card; scroll-inside
  covers overflow. The 96 pt cap retires.
- **R-VX179-3 — TRUE DELETE, CONFIRM EACH TIME.** "Delete forever…" beside Restore in the panel's
  deleted fold, asking once per press — the Delete Now posture (13j round 10: permanent acts always
  confirm). The mechanism is the Delete Now road: a `purge_intent` (the 13j §4f bend to S2); the row
  leaves the deleted listing immediately (the fence) and the janitor removes it everywhere at the
  horizon. Confirm copy is sentence case (her no-shouty-caps rule).

## What is true today (traced at kickoff — the mechanisms, with file:line)

- **The panel** (`App/Variorum/Variorum/Features/Editor/CommentsPanel.swift`): 13u3 UNIT A2's one
  writing surface. The add area is `PanelTextArea` — a SwiftUI `TextEditor` with a hand-overlaid
  placeholder at assumed insets `topInset 8 / leadingInset 5` (`PanelTextArea.placeholderLabel`,
  ~line 929). Those constants are a GUESS about `TextEditor`'s internal geometry ("the same numbers
  QuickNoteView's placeholder overlay has used since it shipped") — exactly the class that drifts per
  macOS release, and on macOS 27 the caret visibly sits left of and taller than the placeholder.
  Presented as a `.sheet` from `EditorView.swift:222` and `TakesBottomBar.swift:309`, and a `.popover`
  from `TakesShared.swift:754`.
- **The gutter card** (`Features/Editor/BlockDecor.swift`): `renderComments` (~line 864) joins ALL of
  a block's comments into ONE string (`"  ·  "`), hands it to `CommentCardView` — a single
  `NSTextField` with `maximumNumberOfLines = 4`, truncating tail (~line 1225). Card height:
  `leftCardRect` (~line 486) caps `ideal = min(blockHeight + 24, 96)` — 96 pt however tall the block.
  The 13u3 laws that MUST survive: the one law (no decoration ever moves the prose column —
  `ProseGutter.swift`'s header), the R-13u3-3 stack (glyph above face), the rhythm (`roomBelow`,
  cards never abut), card width ≤ 210 stopping at the 28 pt handle lane, badge/inline-strip grammar
  unchanged, read-tier cards click-through when `onClick == nil` (`hitTest`, ~line 1265), the
  ~0.04 ms decoration budget, overlays never rendering attributes (TEXTKIT2 §3).
- **Deleted comments**: `deletedBlockComments` (`Sources/VariorumCore/Queries/CommentQueries.swift:19`)
  lists per-block tombstones; the panel's deleted fold offers Restore only. The purge machinery:
  `Operations.purgeableTables` (`Operations+Purge.swift:15`) = container/reading/block/variant/
  commit_point — no `block_comment`; `PurgeFamily.deleteOrder` ALREADY carries `block_comment` and
  `expand`'s default arm (the row itself) is exactly right for a childless comment; the SERVER's
  allowed/owner/purge arrays ALREADY carry `block_comment` everywhere (`10_phase13j_purge.sql` —
  verified at kickoff: zero server work, zero lockstep, marker 13 untouched); the janitor's staleness
  net `tombstonedKinds` (`Sync/PurgeJanitor.swift:449`) does NOT know `block_comment` — without it a
  comment restored between intent and sweep would be purged LIVE. That one line is the orchestrator's
  (Fable, SyncSpec read in full 2026-10-12).

## The design (three units, strictly sequential, one implementer session each)

### U1 — TRUE DELETE (core + the panel door) — evidence: state-transition pins red-on-old, headless
1. `Operations.purgeableTables` gains `"block_comment"`; `validatePurgeable` gains the case: requires
   the comment TOMBSTONED (`purgeTargetNotDeleted` otherwise); missing row with any intent standing →
   skip (already purged); missing with none → `commentNotFound`. The standing `requestPurge` door is
   the op — no new operation.
2. `restoreBlockComment` gains the B1 belt: `voidPurgeIntents(db, table: "block_comment", rowID:)`
   inside its transaction (the 13j ladder-B pattern — a restore voids the stale intent).
3. `Queries.deletedBlockComments` gains the purge FENCE: exclude rows named by ANY `purge_intent`
   (live or tombstoned — "purged stays purged"; copy the standing `NOT EXISTS` arm, e.g.
   `Trash.swift:205`). Verify no other comment reader needs the arm (live readers can't see
   tombstoned rows by definition; sweep and say so in the record).
4. The panel: "Delete forever…" beside Restore on each deleted row, confirm-each-time
   (R-VX179-3; `.confirmationDialog` or alert in the panel's own idiom), classed receipt on land
   ("Comment deleted forever." — wording the implementer's, sentence case), refusals through the
   standing `perform` seam. The fold's count shrinks as the fence hides the row.
5. Pins (core, `swift test` headless): purge refuses a LIVE comment; a tombstoned comment's intent
   hides it from `deletedBlockComments` (red-on-old); restore voids the intent (red-on-old);
   requestPurge dedup/idempotence for the comment kind. Panel-side pins (app target) are written but
   their RUN is stage-gated — mark PENDING and leave them to the verification pass.
6. **Off-limits: `Sources/VariorumCore/Sync/` — already handled.** The orchestrator lands
   `tombstonedKinds` + its two-client convergence pin BEFORE this unit spawns (see LEDGER row 2).

### U2 — THE GUTTER CARDS (R-VX179-1/2) — evidence: geometry pins + the walk (stage-gated)
1. `leftCardRect`: the 96 pt cap retires — ideal = the block's height + the small pad, still
   `roomBelow`-bounded and `cardMinHeight`-floored. Geometry pins updated + a red-on-old cell (a tall
   block's card height follows the block on new, clamps at 96 on old).
2. `CommentCardView` re-forms for STACKED ENTRIES: one entry per comment (wrapping text, no 4-line
   truncation), thin separators, stamp order (the panel's order — `(created_at, id)`); content taller
   than the card scrolls INSIDE the card. Mechanism constraints: pooled views (the ~0.04 ms budget);
   scroll must not steal the page's wheel when the card has nothing to scroll; the read tier's
   click-through (`onClick == nil` ⇒ `hitTest` nil) keeps working — a read-tier card that cannot
   scroll shows what fits (strictly better than the old 4 lines; recorded consequence, not a defect).
   The tooltip keeps the full text. `CommentBrief` may grow a stamp field if the entry needs it.
3. Untouched by design: the one law (prose never moves), the R-13u3-3 stack, badge + inline-strip
   grammar, card width/lane numbers, `commentGutterFaces`' decision shape (height inputs may grow).
4. The voice idiom: Terminal's `// ` prefix per entry vs once per card — implementer proposes at
   build time in the record; the walk decides taste.

### U3 — THE PANEL PRISTINE PASS (her items 1 + 4) — evidence: the walk (stage-gated) + any
   mechanism pins that fall out
1. TRACE FIRST (the hallucination guard): measure where the add area's caret actually sits vs the
   placeholder overlay, and why the caret is tall (typing attributes vs the applied font?). The fix
   is MECHANISM-level, not a nudged constant: either derive the placeholder's position from the
   editor's real text geometry, or replace `PanelTextArea`'s `TextEditor` with an AppKit-backed text
   view whose insets/typingAttributes are OURS so caret and placeholder coincide by construction. If
   the fix is a rewrite of `PanelTextArea`, return with the proposal BEFORE building (the
   implementer-proposes-architect-rules fork). Check `QuickNoteView`'s placeholder overlay for the
   same drift (the constants claim shared provenance) — if it drifts too, fix the shared mechanism
   and close with a sweep table (instance × host), per the constitution's closing form.
2. The pristine pass, within existing tokens and idioms (`VoiceControls` vocabulary, both voices,
   both appearances): the add area's empty state (the sheet today is a large void with a bare
   placeholder), header/footer rhythm, the deleted fold's look, row spacing/stamp line typography.
   No new settings, no new doors, no semantics changes — §2 D's contract (add area owns the leftover
   space, click-anywhere, ⌘⏎/⎋/⏎ grammar) is untouched. Taste numbers PROVISIONAL, chosen against
   the real surface on the walk.
3. U1's "Delete forever…" row joins the pass (one visual language for the fold).

## Sizing & cast
Three ticket-sized units under one theme (not phase-sized; within guidance). U1 first — fully
headless-verifiable tonight; U2/U3 build now, verify when the stage frees (via `oct12coordinator`).
One ladder after all units over the whole run diff: `fable-reviewer` (the run carries a `Sync/` line
and decoration-overlay work beside the editor; Fable's judgment is the safe default), round 2
re-reviews fixes, cap three. Pin-before-fix binds per fix class; every bug-class fix red-on-old,
verified by revert.

## Environment traps (this run's own)
- The stage is the release session's → `oct12coordinator` for EVERY stage act; no `xcodebuild test`,
  no walks, no app launches, no `/Applications` touch from this run until granted.
- No commits in `~/dev/variorum` (main) until the release reports; ALL work commits in THIS worktree
  on `vx-179-comment-polish`, pushed after every commit (the resiliency protocol binds).
- Instance checks before anything screen-adjacent: `pgrep -fl 'Variorum.app/Contents/MacOS'`,
  discriminate by PATH; the author's real-store app is NEVER touched.
- `swift build` / `swift test` (core) run freely here. Keep heavy `xcodebuild build` invocations to
  what a unit actually needs while the release archive runs.
- Never add a custom build configuration; Mac tests (when granted) from `App/Variorum/` with
  suite-level `-only-testing`; zsh `pipestatus`; Swift Testing counts skipped tests (read `skipped:`).
- Screenshots in gitignored dirs; `default.profraw` in the main checkout is pre-existing debris —
  leave it.

## The binding principles (the 13b constitution, P-1…P-9 — copied per the architect-phase skill; the
application notes in `.claude/skills/architect-phase/SKILL.md` bind with it)

- **P-1 — One capability registry.** Every user-facing act is declared exactly once: verb, scope
  (block/take/post/book), per-mode availability rule, its doors (menu / context / bar / shortcut /
  palette), and its refusal copy. Surfaces render their doors FROM the registry; gating is data,
  never per-view if-statements. A registry-walk test asserts every declared door exists and every
  rendered door is declared.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act — including any mode-switch
  choreography, done visibly for the user — or delivers the operations layer's real refusal. A door
  that can never act in its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface component that every pane
  composes; "what text does this pane show, and is it live" is answered by ONE pure, unit-tested
  authority (`PaneTextAuthority`); views never re-derive it. Exactly one live pane; the live pane is
  buffer-authoritative; read panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** No listener derives business state or
  availability from a broadcast; no flow's correctness depends on broadcast ordering. Cross-feature
  flows route through composition.
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule marks an
  under-architected feature. The response is never another patch: write the feature's DESIGN MEMO,
  get the author's rulings on the product-flavored edges, then build to the memo.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial flow is the contract for
  every happy path; any change that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive harness. Red-on-old stays
  absolute: no bug-class fix without a pin that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind the rebuilt layer exactly
  as the substrate (invalidation ∝ realized rows; one live editor; virtualized long views).
  Overlays, never rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`.
  `Theme/VoiceControls.swift` is THE chrome vocabulary. Complexity lives in the store; restraint
  lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing board layout, text authority,
  and gesture routing splits by concern.

## LIVE STATUS / LEDGER (flip per piece, same commit)

| # | item | status |
|---|---|---|
| 1 | Record file + kickoff rulings landed, branch pushed | DONE (93b5b720) |
| 2 | The `Sync/` line: `tombstonedKinds` + `block_comment` + two-client stale pin (orchestrator) | DONE (37b9a6e7) — pin red-on-old VERIFIED BY REVERT (all 5 expectations fail, the comment purged live, stores diverge); full PurgeConvergenceTests 20/20 green headless |
| 3 | U1 true delete (core + panel door) | NOT-STARTED |
| 4 | U2 gutter cards | NOT-STARTED |
| 5 | U3 panel pristine pass | NOT-STARTED |
| 6 | Mac-target test runs + the walk (stage via oct12coordinator) | HELD — stage |
| 7 | The ladder (fable-reviewer, whole diff) | NOT-STARTED |
| 8 | Bout-start board snapshot + in-flight row on main | HELD — until the release session reports |
| 9 | Ticket VX-179 description gains branch/record pointers; Done rides the PR merge | NOT-STARTED |
| 10 | Closeout: PR → merge commit; worktree + branch removed; debris tidy; MOBILE PARITY line | NOT-STARTED |

**MOBILE PARITY (provisional):** the Mac faces are Mac-only; U1's core ops are shared — the phone's
comments sheet gains no purge door this run (a `notes/MobileSoul.md` ledger row lands at closeout).
