# VX-827 — ladder round 1 (cold review, fable-reviewer, 2026-11-06)

**Diff under review:** `origin/main...vx-827-lineage` (branch head at review start: d015fc324).
**Anchor:** `notes/plans/fixes/vx-827-lineage.md`. Canon read: CLAUDE.md + auto-loaded, MCPSpec in
full, SurfaceContracts (The app, The Library, The note, Doors), TEXTKIT2_NOTES (seam check only —
the diff touches no `EditorTextView`/`PaneSurface`/`BlockRangeIndex`/`PaneTextAuthority` line,
verified by name grep), SyncSpec not re-read in full (verified: no `Sync/`, no `Persistence/`
migration, no custody file in the diff — the record's claim holds).

Findings land here incrementally as they are traced. Format:
`[severity] · file:line · what · evidence · fix`.

## FINDINGS

**[MINOR] · App/Variorum/Variorum/Features/History/CommitsFaceModel.swift:222–235, 807–821 +
Sources/VariorumCore/Operations/Operations+LineageBringBack.swift:67–70 · A RELATIVE's buffer is
read without a flush — the `.take`-form bring-back can mint a stale take, and the relative pane's
"the take now" can show stale words.** Evidence (traced): `CommitsFaceModel.start()` flushes only
`postID` — the note the face opened on (its own doc at :219–221 claims "the take's pending typing
is written FIRST, so 'the take now' is now", which holds only for the HOME note);
`LineageBringBack.run` flushes nothing; `Operations.bringBackFromLineage(.take(id))` copies
`working_text` as stored. A relative placed in ANOTHER note, that note live in a second window
with pending typing not yet autosaved → (a) the lineage face's pane shows that relative's "now"
stale, and (b) Bring back as take (the header's act passes `.take(shownTakeID)`; the pane's foot
on a relative's "now" row the same) mints the stale text as the new take. The same-note arm exists
too (the sheet hosts aside, a second window on the face's own note typing after the open). The
precedent everywhere else is flush-first (the panel's restore rule; her doors' "flush the pending
buffer first"; the MCP door flushes every open note). No data is lost (the source keeps its
buffer), so MINOR, not MAJOR. **Red-on-old pin:** the Mac-target model pin machinery that stages a
pending buffer (`BlockHistoryPaneTests.aRestoreFlushesThePendingBufferBeforeItLands`'s re-pointed
form drives exactly this seam) staged on the RELATIVE's note, then `bringBack()` on the lineage
face → the minted take's text misses the pending words on the old code. **Fix shape:** flush the
SOURCE's note before the act — `LineageBringBack.run` resolves the source block's live placement
(one read) and `flushExistingAutosave(forPost:)` on it before `runner.run`; and the relative-role
`CommitsFaceModel.start()` also flushes the relative's placed note (when placed and ≠ postID) so
the pane's "now" is now. The `.commit` form needs nothing (immutable text — the home face's
posture already documents that).

**[MINOR · ticket-class, not a ladder fix] · Sources/VariorumCore/Operations/Operations+LineageBringBack.swift:102–107
(`lineageCrossesWing`) + Sources/VariorumCore/Queries/LineageTree.swift:386 (`home_wing` raw) ·
The wing fence compares RAW stored wing ids while every listing resolves a dangling/dead wing to
Home.** Evidence: `LineageHome.wingID` carries `container.wing_id` unresolved;
`MCPReadTools.resolvedWing` and `NoteFacts.wingID` read a wing id with no live `wing` row as `''`
(Home, R-13ia-2's rule), so a note whose wing died or dangles LISTS in Home beside the target —
yet `lineageCrossesWing` reads it as another wing: the face draws "in another library — the wing
‹name-or-empty›" with go-to only, and the op refuses `notInLineage`. Reachable only through sync
convergence (every local wing delete refuses unless empty; "no op mints one today" — the U2
adjudication's identical finding on `Queries.liveTagIDs`, already a born-ticket candidate
(Low · Suspected · Debt)). The fence errs CLOSED (refuses, discloses nothing), so nothing unsafe.
**Disposition proposed:** join the already-filed dangling-wing ticket (one class: `liveTagIDs`,
`lineageCrossesWing`/`LineageHome.wingID`, and `LineageFaceModel.read`'s wing-name read, which has
no `deleted_at` filter and would name a tombstoned wing — that last is arguably right); no
red-on-old pin exists without hand-built rows, so a ladder fix would be hollow by the guard.

**[NIT] · notes/plans/fixes/vx-827-lineage.md (U3b "what is OWED") · U3's canon deltas are named
but not DRAFTED, unlike U1/U2's.** U1 and U2 left exact D-lines (D-U1-1…4, D-U2-1…5) for the
closeout's two-file landing; U3a/U3b leave only the owed list's names (SurfaceContracts' Block
History bullet rewrite — the current bullet at "The note" describes the retired panel —, the
Lineage face's line, AppSpec §9's `bringBackFromLineage` contract line, §12's mode-row untouched).
The orchestrator lands them either way (ledger row 6 is NOT-STARTED by design), but drafting them
now from THE DESIGN MEMO + U3b-P RULED would make the landing mechanical and reviewable. Fix: add
D-U3-1…3 draft lines to the record before closeout.

**[NIT] · App/Variorum/Variorum/Features/History/CommitsCompareView.swift:64–68 + the U3a record's
P-U3a-5 · "✕ on a third box only" vs the built face.** The record's P-U3a-5 reads "only a third
box can be put away (✕)"; the view renders ✕ on EVERY box while three stand, and
`CommitsFaceModel.removeBox` removes any index while `count > 2`. Defensible reading ("a box can
be put away only while a third stands"), but the record's letter and the build diverge — say which
in the #264 bundle so her ruling lands on what is actually built. Related, same bundle: on the
Lineage face the word "now" means two things — the pane's "against now" wash compares a relative's
moment against the RELATIVE's own take-now (`paneComparison` keys `takeID(of: selection)`), while
the header's "Compare with now" compares against the HOME block's now (`openCompare(against:)` →
`homeLeadTakeID`). Both leans are reasonable; the double meaning deserves a P-line of its own
rather than riding P-U3b-4 silently.

**[NIT] · App/Variorum/Variorum/Features/History/CommitsFaceModel.swift:215 ·
`Queries.mcpShownTake` read for the ✓ chosen mark** — a generic rendered-take rule living under an
MCP name (the implementer flagged it too). Rename at next core touch (`Queries.shownTake` or
similar); no behavior change.

## CLEAN BILL (checked myself, found solid)

- **No `Sync/`, no custody, no DDL, no migration** anywhere in the diff (path grep over the whole
  range); the record's claim holds, so the full SyncSpec re-read was not owed. The one new write
  (`bringBackFromLineage`) is a single `variant` INSERT in one transaction — S1-shaped, captured by
  the standing outbox trigger and PINNED so (`LineageBringBackTests` asserts `db.outboxContains`);
  no edge, commit, placement or default is written; I10 untouched (it adds a take).
- **No editor-seam file touched** (`EditorTextView` / `PaneSurface` / `BlockRangeIndex` /
  `PaneTextAuthority` — name grep empty). Both faces are read-tier SwiftUI `Text` (P3: no second
  live editor, no new liveness mechanism); the full-pane host REPLACES the mode's surface, so no
  hidden editor can take a keystroke or routed act, and `‹ back` re-arrives by the mode round
  trip's carry captured at the open with the one-shot caret/find seeds dropped (17o R1-1).
- **The stub retirement (her F-U1-1) is built exactly to the ruling:** `MCPNoteStructure.lineage`'s
  `.beyondGrant` arm is ABSENT (never counted, never hinted); `beyond_reach`'s fixed lineage
  sentence rides EVERY `with_lineage` answer unconditionally (a conditional key would itself be the
  oracle — correctly avoided), set before the page budget weighs it; `parent_beyond_grant` is
  untouched. The carriage pin's re-point is honest (asserts no `beyond_grant` byte anywhere, the
  three hidden far sides absent, the sentence only when lineage is asked) and the two-store
  catalog's `read_note · kin with lineage` arm is the standing red-on-old.
- **`list_note_lineage` honors R-825 and her VX-817 fence line in code I traced:** the subject
  decided at READ with the once spend (`consumes: true`), each peer re-decided `consumes: false`
  (never spending), an unreachable peer simply absent; no edge id, no position key; `archived`
  always present; VX-812's list form exact (cap 200, no repeats, exclusive, per-item transaction +
  Activity line + once spend, all-refused = error answer); VX-606's schema walk covers it
  (`additionalProperties: false`, suite green); refusal logging byte-matches `read_note`'s posture.
  Its six catalog arms + server suite re-run green here.
- **`list_notes` `tag`:** parsed at the call door before any read, `remove_tag`'s parse and ONE
  shared sentence; the fence pick (naming-nothing ≡ worn-only-beyond-reach ≡ hidden-wing = the one
  empty listing) pinned byte-identical; every kept row still passes the per-note rule; cursor
  shapes untouched (VX-859/VX-808 respected), the gathering's readable-ordinal re-key preserved
  under the filter; cost ∝ wearers via the hoisted ONE wearer rule (`tagWearersSQL`, shared with
  `tag_unused_in_reach` byte-for-byte) with the CROSS JOIN plan + library-growth pins — re-run
  green. Rows' `entry_date` null-when-undated and `tag_ids`+`tags` (the note's own, by path);
  `read_note`'s JSON forms carry them on the live read only (a version read carries neither, as
  `books`); the golden-byte guard re-pinned as a DELIBERATE flip, named.
- **VX-815:** the trace is honest (the nothing-shape is the core's tolerant read; the briefed
  "granted-empty ≠ fence" red-on-old restated truthfully as a green-on-both control, the real
  red-on-old stated against the nothing-shape); the fix sits after every refusal return by
  construction, so hidden = missing is untouchable by placement; `holdsNothing` = empty-or-newlines
  (P-U2-2(a) as built); titled/tagged empty notes keep their header.
- **VX-778** stayed predicate-narrow exactly as the vx-878 agreement demands (core-only,
  `mcpGrantPlaceTitle == nil` — the listing's own gone predicate; no pane file in the diff); the
  red-on-old pin exists and the suite is green.
- **`bringBackFromLineage` matches U3b-P RULED field by field:** NULL parent (the edge carries
  lineage), label = the source's name through the stored-text normalisation, fan's END past
  archived takes (the `MAX(fan_position)` idiom of `Operations+Variant`), never chosen/default/
  locked, no touch/churn/undo, refusals in the ruled order, the fence IN the op reading
  `Queries.lineageTree` inside the transaction (∝ the lineage, P1-pinned), the scraps crossing
  nothing, the refusal worded in the shared table (W16). The exact-transition suite pins every
  field, every refusal writing nothing, and the untouched-tables invariant.
- **`Queries.lineageTree` / `lineagePeers`:** the exact-stamp cascade edge admission is
  `versionHistoryPredicate`'s doctrine verbatim-in-meaning (R-U1-1, sustained — I agree: without it
  no Trash node could exist, and tombstone-means-decided keeps a deliberately-unmade edge out);
  one-column UNION walks terminate on cycles by construction; MATERIALIZED + CROSS JOIN per the
  VX-654 lesson with plan + growth pins (re-run green, library ×15 flat at 661); the BFS depth/via
  rule is deterministic (checked the comparator and the k-parity bounds of the Myers backtrack by
  hand — both sound); nodeFacts' chosen→default fallback matches I3's read rule; peers' relation
  direction mapping (source=subject ⇒ peer holds the ORIGINAL) checked against §7's edge reading.
- **`TextCompare` is OverallModel §8's legal diff and nothing more:** view-time, stored nowhere
  (the model's `compareCache` is an in-memory bounded cache keyed by content identity, not stored
  state); word tokens, byte-preserving runs (pinned); the Myers search bounded by `editBudget` with
  the coarse one-change answer past it — P1 honored, no corpus coupling anywhere in the diff. No
  word-level change tracking as stored state exists in this run.
- **`CommitRail` and `LineageFamily`:** interleave/fold/AI-pair/filter/opening/step semantics match
  THE DESIGN MEMO; the bracket spellings pinned equal to `Operations.mcpEditCommitNames`; the
  family's acts-by-state table matches P-U3b-3/-4/-5 (a relative never reaches
  Restore/Rename/Unarchive/Put-back-in-place — `paneActs` branches checked; the foot's relative
  bring-back routes through the fenced op via the ONE `LineageBringBack` road; deleted takes
  suppressed on a relative's rail at the view).
- **P-1:** the three previously-undeclared writer acts are now declared; the registry walk asserts
  set-equality BOTH ways and carries both faces' lines; the `.id(node.blockID)` on the ancestor
  swap's composition avoids the stale-`.task` trap (checked deliberately — the task restarts with
  the member).
- **The retirement is clean:** `BlockHistoryPane.swift` + `SavepointHistory.swift` deleted whole;
  the moved types byte-live in `Features/History/`; every pin in the U3b-5 table matches the diff
  (deleted suites' subjects no longer exist; `RestoreLandingRewriteHopTests` — VX-668's fix pin —
  survives); the origin doors build `.lineage(select: original)` requests on the history road and
  the old seams (`requestOriginHistory`, `originHistoryRequest`, the inspector case) are gone; the
  three sheet hosts present `BlockHistorySurface`; the tutorial sweep matches W1–W16 and the walk's
  finders still hold.
- **Suites, verified myself at review head:** the run's new core suites 86/86
  (`LineageBringBack|LineagePeers|LineageTree|LineageFamily|CommitRail|TextCompare|TagWearersListing|MCPGrantPlaces`),
  the new MCP suites + the two-store catalog 15/15, the tool-list/schema/empty-note suites 37/37,
  `Tools/verify-pins` OK (16 + 15), and `xcodebuild build-for-testing` (Mac, Debug) **re-run green
  by this reviewer** (0 errors). Canon files untouched by the diff — the two-file landing correctly
  deferred to closeout.

**Standing condition, not a finding:** every Mac-target BEHAVIOR claim is compiled, not yet run or
walked — the record says so itself; the closing window's `-only-testing` batch and the 23-row walk
are the observation. The window must run before merge, as already queued with nov5.

**FINDER-FIXES: none.** Finding 1's fix is small, fully specified above, and carries its pin; it
belongs to the implementer under the cross-model flow. No `Sync/` lines exist in this diff.
