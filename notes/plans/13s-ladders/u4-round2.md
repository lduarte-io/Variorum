# U4 ladder — ROUND 2 (cold re-review of the round-1 fixes, Opus, 2026-10-08)

**Target:** the round-1 fixes on `vx-7-13s-voice-onboarding` (worktree `~/dev/variorum-13s`), exactly
`57869648` (F1, MINOR-2 — the ⌘/ `note ▾` row) · `8e5de1c8` (F2, MINOR-3 — the fence's sentence ends)
· `3656d539` (F3 + F4 — P-U4-1 restated, P-U4-5's sentence) · the record commits `adeb6251` and
`6b23ee09`. The commits after `6b23ee09` (`b96b9965`, `d1adc482`, `bd3d3ce3`) are the landing ladder's,
not U4's — excluded. **Prompt:** `notes/REVIEW_PROMPT.md` verbatim, scoped as a round 2 (do the fixes
close the findings, are the pins honest, does anything new open). **Anchor:** `u4-round1.md` whole (its
findings and the ARBITRATION), the plan's U4 RECORD + U4 FIX ROUND. MINOR-1's disposition (the build
stands; the taste call is hers) is SETTLED and not relitigated here — only whether the restatement
carries it faithfully and honestly.

**Scope check (asked first):** the five U4 fix commits touch exactly `HelperView.swift` (a static copy
row), `HelperCurrencyTests.swift`, `DeadVocabularyTests.swift` and the plan file — no editor seam, no
custody/keychain, nothing under `Sources/VariorumCore/Sync/`, no default's meaning. The window's one
`Sync/` change (`SeededFurnitureDedupe.swift`, `63379bca`) is U1b's, Fable-reviewed, not in this diff.
Opus scope holds.

**My evidence seat:** headless only, in the scratchpad. The fence: a twin built from HEAD's
`DeadVocabularyTests.swift` itself (`#expect` → a counting `expect`, `#filePath` → an env path, `swiftc`),
plus a behavioural-revert twin whose ONE edit re-adds `|| end.hasSuffix("?")`; the pre-sweep tree is
`git archive 0f4055fb` of the four scanned roots. The ⌘/ pin: a twin of the row tuple at
`57869648^` and at HEAD (each extracted verbatim) with the four constants' lines verbatim and the pin's
three checks. No `xcodebuild`, no app launch, nothing swapped in the shared tree.

## Findings

**Verdict: 0 BLOCKER · 0 MAJOR · 1 MINOR · 2 NIT.** No round 3 is earned.

- **[MINOR] · `notes/plans/phase-13s-voice-onboarding.md:915` (P-U4-1 as restated by `3656d539`) · The
  restatement presents the take-vs-whole-note "saved moment" collision as something option (a) creates
  and option (c) avoids; in fact the collision is pre-existing, deliberate and app-wide, and NONE of
  (a)/(b)/(c) removes it — so her three-way call can be made on a false premise.** Evidence (traced at
  HEAD; every non-guide site below pre-dates U4 — checked against `0f4055fb`; of the guide's three, two
  are pre-U4 lessons the landing re-voiced and `:1618` is the landing's own, `192fb512`): (1) "saved moment" is the app's
  standing PER-TAKE noun at about twenty rendered sites the three options never touch — Block History's
  whole face on both platforms, including the empty lines that read word for word like the Versions
  pane's: `Features/Tray/BlockHistoryPane.swift:75` *"No saved moments yet — ⌘S saves one."*,
  `VariorumMobile/Features/Takes/MobileBlockHistory.swift:192` *"No saved moments yet — Commit Take in ⋯
  keeps one."*, and `Shared/BlockHistoryFace.swift:53, 72, 151, 157, 194, 197` (*"Saved moment restored
  into this take"*, *"This saved moment predates a split"*, *"Saved moment named “x”."* …), plus the two
  bars' history-door tooltips (`CommitBar.swift:621`, `TakesBottomBar.swift:387`), the registry
  (`CapabilityRegistry.swift:878`), a refusal (`Shared/OpsRefusalTable.swift:148`, *"That saved moment
  isn't there any more."*) and the landed guide (`TutorialSeeder.swift:1379, 1503, 1618`). (2) **The
  Versions pane already uses the noun for BOTH meanings:** its restore confirm's cost line
  (`Shared/VersionsCopy.swift:153–155`, *"1 saved moment" / "N saved moments"*) counts
  `Queries.RestoreCost.savedMoments` = `COUNT(*) FROM commit_point` on the outgoing blocks' live takes
  (`Sources/VariorumCore/Queries/RestoreCost.swift:79–80, 137–139` — population 1, per-take commits),
  two inches from that pane's own *"No saved moments yet. ⌘⇧S saves the whole note"* (`:50`). (3) The
  sharing is BY DESIGN: the phone's Versions empty line was written as Block History's twin
  (`MobileVersions.swift:249`, *"the `BlockHistoryController.noSavepoints` precedent exactly"*), and the
  registry's design note names the teaching pair *"⌘S↔⌘⇧S — this TAKE's moment beside this NOTE's"*
  (`CapabilityRegistry.swift:892–893`). **The degradation:** the restated text says (a) *"half-recreates
  the very confusion her R-VX83-10 reason names"* and calls (c) *"the only option that avoids BOTH the
  retired word AND the whole-note noun"* — true at the seven sites only. If she picks (c) to retire the
  collision, a ⌘S user still opens Block History to *"No saved moments yet"* (one take) and Versions to
  *"No saved moments yet"* (the whole note); the R-VX83-10 confusion, if it is real, lives in the shared
  noun itself, not in U4's seven definitions. This is the same class as round-1's MINOR-1 (a PROVISIONAL
  "not yet an honest choice for her") — a missing fact, not a wrong build; the disposition (the build
  stands, the call is hers) is untouched. No red-on-old pin applies (a record finding). · **Fix (record
  only):** add to P-U4-1, before it reaches QUESTIONS, that the shared noun pre-dates U4 by design (the
  ⌘S↔⌘⇧S take's-moment / note's-moment pairing), lives at ~20 per-take sites and inside the Versions
  pane's own restore-cost line, and stands under every one of (a)/(b)/(c); and that removing the
  take/whole-note confusion itself would be a separate door (re-nouning one side — e.g. the four
  whole-note sites plus the cost line, or Block History's face), orthogonal to the three-way choice and
  hers to open as a follow-up ticket if she wants it. No code moves.

- **[NIT] · `notes/plans/phase-13s-voice-onboarding.md:915` (P-U4-1's site list) · The dictionary
  entry is cited at `HelperView.swift:368`, a line F1 had already moved.** Evidence: `57869648` (F1)
  added a net 8 lines above it before `3656d539` (F3) was written; at F3's own tree and at HEAD the
  "commit" entry's text is at `:376`, and `:368` now reads *"+ "takes. Archived takes stay behind with
  ""* (the merge entry). F3's record row says the seven sites are given "by file:line". · **Fix:** `:368`
  → `:376`, or cite it by symbol (`HelperView.allEntries`, the `"commit"` entry), which does not drift.

- **[NIT] · `App/Variorum/Variorum/Features/Help/HelperView.swift:236–258` ("The note's bars") · F1
  removed the helper's only pointer to Block History's home without giving the door its true line, so
  the ⌘/ helper now teaches no road to Block History at all.** Evidence (traced): after `57869648`, no
  `HelperView.groups` row mentions history (case-insensitive grep: the three hits are F1's own comment
  lines); the one remaining mention is the dictionary's "commit" entry, *"…editable afterwards from Block
  History"* (`:378`), which names the panel but not its door. The group's own governing rule
  (`:232–235`) is *"a door which moves without a line here is a door she cannot find"* — exactly what
  happened when Block History left `note ▾` for the bar at `06263d16`: the stale "history (…)" text was
  the only line it had. F1 fixed the false half (the wrong menu) exactly as arbitrated and as round 1's
  own suggested text read; the missing half remains. Both bars' `.help` strings already carry the true
  sentence (*"a block's commits are the history door beside commit"*, `CommitBar.swift:767–768`,
  `TakesBottomBar.swift:515–516`). Out of unit, the same staleness sits in two doc comments,
  `CommitBar.swift:756` and `TakesBottomBar.swift:447` (*"**note ▾** (R6-2): history, the seal, the
  entry date"*) — fix-when-touched. · **Fix (optional, cheap):** give the door a line in this group, e.g.
  a parenthetical on the `note ▾` row or a sibling row — *"\(BlockHistoryPath.name.lowercased()) — the
  door beside commit"* — composed from `BlockHistoryPath.name`. Pin (red on HEAD, green after):
  `HelperView.groups.flatMap(\.items)` contains a row whose text names `BlockHistoryPath.name`
  case-insensitively.

## Round-1 findings — closure, each answered

- **MINOR-2 (the ⌘/ `note ▾` row) — CLOSED.** The row now reads *"save a version · versions… · make
  every newline a block · seal / unseal · the note's date · delete note…"* — both bars' `note ▾` menus
  item for item and in order (`CommitBar.swift:796–861`, `TakesBottomBar.swift:457–507`: the version
  pair, the split-at-newlines repair, Seal/Unseal, the date, the conditional wing doors left unsaid as
  the comment says, Delete Note…), each door from the same constant the menu renders
  (`VersionsPath.saveVerb`/`menuLabel`, `SplitAtNewlinesCopy.noteDoor`, `RecoveryCopy.deleteNoteTitle`;
  all `nonisolated` enums, so the static `groups` composes them like its `StarCopy`/`ContextBarDoors`
  rows), lowercased to the sibling `block ▾` row's grammar. **The pin is honest — red-on-old
  re-verified at my seat:** the twin of `57869648^`'s row → **RED, 3 issues** (a history door; no
  `Versions…`; no `Save a Version`); HEAD's row → **GREEN, 0**. It binds the real `HelperView.groups`
  row by its key prefix (exactly one row carries it), so the Mac run cannot pass vacuously. No other
  test binds this row: every suite that reads `HelperView.groups` was read (`MarkdownActsTests:272`,
  `WalkBuildRoundTests:827`, `CapabilityRegistryTests:572`, `CommitVocabularyTests:79`,
  `ChordLegibilityTests:113`, `ContextBarShapeTests:91`, `SavepointNamingTests:699`,
  `QuickNoteTests:500`, `CanvasDebugOnlyTests:127`) — each keys on another row or on a property the new
  row keeps (no "savepoint", no retired phrase, no chord). `import Foundation` is needed for
  `localizedCaseInsensitiveContains` and is the only other edit.
- **MINOR-3 (the fence's "?" hole) — CLOSED.** `isLabelShaped` now ends a sentence at "." or "!" only,
  its doc says why. **Re-verified by behavioural revert at my seat:** the old-matcher twin → **exactly 1
  control failure, at the new literal (`DeadVocabularyTests.swift:261`)**; HEAD → **0 of 17**; HEAD's
  tree walk → **0 offenders, 0 stale allow entries, the >600-files floor met**; the pre-sweep tree
  (`0f4055fb`) → **exactly the 11 recorded offenders** (the narrowing widens nothing that ships). The
  "That's a savepoint." sentence control still holds the prose side.
- **NIT-1 (P-U4-5's literal-fragment reading) — CLOSED.** The added sentence is accurate: both fragments
  it cites (`"restore this savepoint"`, `MobileBlockHistory.swift:486`, and `"history (savepoints) · seal /
  unseal · the "`, `HelperView.swift:245`) are among my twin's 11 pre-sweep offenders, and "a long
  composed label can slip" matches watch-out 4. (LIVE STATUS row 1 keeps its original wording; the
  arbitration scoped the fix to P-U4-5 and the F4 row says the sentence corrects it — accepted.)
- **NIT-2 (the merge guard) — CLOSED, and already satisfied.** `closeout-checklist.md` item 10 carries it;
  the landing's guide now reads *"quiet commits · show"* (`TutorialSeeder.swift:1004`), matching
  `SavepointRuns.runLabel` (`Sources/VariorumCore/Domain/SavepointRuns.swift:104–105`).
- **MINOR-1 (P-U4-1) — the restatement CARRIES the arbitration faithfully, with the gap above.** Every
  element the arbitration required is present: the SEVEN sites (all seven verified verbatim at HEAD,
  one line number drifted — NIT above); the Versions collision at its four sites (`VersionsCopy.swift:49–51`,
  `MobileVersions.swift:251–252`, `MobileNoteActions.swift:254`, `CapabilityRegistry.swift:909` — each
  verified verbatim); the two explanations (`TourScript.swift:101` and `TutorialSeeder.swift:964`, the
  guide's ONLY remaining rendered "savepoint" — verified by grep); options (a) built / (b) savepoint per
  R-13s-32's letter / (c) no noun; stated as HER three-way taste call with the build standing and nothing
  rebuilding; the round-1 judgment (R-13s-32 permits, never requires) represented as round 1 wrote it;
  the old appeal to R-VX83-10 in (a)'s favour removed. The MINOR above adds a fact round 1 did not trace;
  it does not reopen the disposition.

## Clean bill (load-bearing things checked and found solid)

- **Pathspec discipline:** each U4 fix commit touches only its item's files (F1: `HelperView.swift`,
  `HelperCurrencyTests.swift`, the plan; F2: `DeadVocabularyTests.swift`, the plan; F3–F5 and the opener:
  the plan alone). No canon edit, no `Sync/`, no schema, no core source.
- **Both pins red-on-old by my own behavioural revert** (above), matching the record's counts exactly
  (3 → 0; 1 → 0 of 17; tree 0; pre-sweep 11).
- **The core-suite claim (2425/280 + 40/6) was not re-run, deliberately:** the fix round touched no file
  under `Sources/` or `Tests/` (the +1 over U4's 2424 is U1b's `SeededFurnitureDedupeTests`, outside this
  diff), so nothing in it could move.
- **The record is honest about what is pending:** every Mac pin RUN (`HelperCurrencyTests` and
  `DeadVocabularyTests` are already in the U4 stage command) and the walk, with the fixed ⌘/ row added to
  the walk's helper capture and to the final window's runsheet (`closeout-checklist.md` B).

## ARBITRATION (orchestrator, same-model ladder)

- **MINOR — FIX (record only):** P-U4-1 gains the round-2 facts verbatim-faithful: the shared noun predates U4 and is designed (the ~20 per-take sites; the Versions pane using it for BOTH meanings side by side; the deliberate ⌘S↔⌘⇧S pairing), so NONE of (a)/(b)/(c) removes the clash — removing it would mean renaming one side, a SEPARATE decision for her, outside the three-way choice. The disposition is not reopened; the choice sheet gets honest.
- **NIT (cite) — FIX:** the dictionary entry cited by name, not line.
- **NIT (the helper's missing Block History road) — FIX, adopted as in-ladder:** the group's own rule says a moved door gets a line; the helper teaching NO road to Block History fails the phase's bar. One line built from `BlockHistoryPath.name`, with the reviewer's named pin red on HEAD → green. The two stale doc comments: fix-when-touched, recorded.
- All three in ONE short U4 implementer pass; no round 3 (nothing above NIT in code); the ladder closes on its report with dispositions written.
