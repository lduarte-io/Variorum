# VX-980 — gate 2 (batch 2), recorded while batch 3's implementer was live in the worktree

*A file of its own so the run record has one writer at a time; folded into `vx-980-search-fixes.md` (THE GATES AND THE WALK) at the next seam.*

### GATE 2 — batch 2 (claim `vx980-gate2`, 2026-11-19 05:47–05:55, nov18's GO): the walk PASSED; the suites carry ONE red, a stale pin

**The tree under test.** The gate snapshot `~/dev/variorum-vx-980-gate` at `8a170e934` (batches 1 + 2), `build-for-testing` done there.

**The suites (test-without-building, 31 TYPE names — batch 2's READY-FOR-GATE list plus `ShellChromeTests`, added because the batch declares two registry acts).** Swift Testing: **"280 tests in 31 suites failed with 1 issue"**; XCTest "Executed 0 tests"; 0 `skipped` lines. `CapabilityRegistryTests` green, `ShellChromeTests` green, 30 of 31 types green.
- **THE ONE RED — `DataSafetyRoadCountsTests.thePaneHandsTheOpenLibrarysRoadToTheModel`** (`App/Variorum/VariorumTests/Protection/DataSafetyRoadCountsTests.swift:136`): a source-shape pin matching the literal `roadCounts: roadStanding?.copyCounts))` in `DataSafetyPane.swift`. Batch 2 added `searchIndexDoors:` AFTER that argument, so the closing parentheses moved and the text now reads `roadCounts: roadStanding?.copyCounts,`. The hand-off the pin protects is intact (read in the source). PIN STALENESS, test-only — not a load red, so no alone re-run. The fix (the expectation matches the argument without the trailing parentheses, nothing else) went to batch 3's live implementer as a rider with its own commit; the type re-runs at gate 3.

**The launch.** 05:49:30 → drawn in about TEN SECONDS, straight to the Bookcase. So gate 1's nine-minute blank was a cold read of the second backup folder (VX-1013 stands; a later launch the same night is quick). No "different library" notice this time although the launch came right after a 31-suite test-host run — the test-host cause guessed in VX-1015 is therefore doubtful (the ticket is corrected).

**The walk (the snapshot's Debug product; Settings read and pressed through Accessibility — the words guard withheld every Settings capture with -25200, the known macOS 27.0.1 behaviour, so no Settings screenshot was taken).**
1. Settings ▸ Data Safety: the Search index section after the restore matter — its line "Search reads an index Variorum keeps on this Mac, built from your notes. Nothing of yours lives only in the index, so checking it or rebuilding it is always safe.", the doors Check Index and Rebuild Index, nothing under them.
2. Check Index → "The search index is in step with your notes — 4,857 entries."
3. Rebuild Index → "Rebuilt from your notes. The search index is in step with them — 4,857 entries." (the same count).
4. Left to Diagnostics and came back → the row quiet again (the answer is the visit's, P-980-B2-2).
5. Settings search "search index" → one result, "Search index · Data Safety · Check that the index search reads matches your notes, or rebuild it from them. Nothing of yours lives only in it."; pressing it opens Data Safety on the row.
6. ⌘K "rebuild" and "index" → only passages from notes, no index command; no index or rebuild item in File, Edit, View, Note or Help.
(The out-of-step and failure lines are pinned by `DataSafetySearchIndexTests`, not walked — reaching them would need a raw edit of the dev store's index.)

**The dev store, as found and as left:** not locked; Standard ("You're in Standard." read in Settings ▸ Protection, nothing pressed there); signed out; the restore-hold banner standing, Resume Sync never pressed; the words card untouched. Changed: only the derived search index, rebuilt in place. No Restore-list door touched (the pane lists 118 copies on the dev store). No instance left; no new `Variorum-*.ips`.
