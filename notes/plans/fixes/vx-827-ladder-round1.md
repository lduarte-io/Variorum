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

## CLEAN BILL

(at the end)
