# U2 ladder — ROUND 1 (cold review, Fable, 2026-10-08)

**Target:** UNIT U2 (the tour engine and frames), diff `20c49b51..e1dcdd43 -- App/ Sources/ Tests/`
(4,086 insertions over 26 files), branch `vx-7-13s-voice-onboarding`, worktree `~/dev/variorum-13s`.
**Prompt:** `notes/REVIEW_PROMPT.md` verbatim. **Anchor:** the plan file whole (R-13s-1..42, the U2
BRIEF, the U2 RECORD with its stage/walk/fix/verify records, PROVISIONALs P-U2-1..16), the U2 UI
assessment (`13s-ladders/u2-ui-assessment.md`), mockup v5's HTML. No "Review foci" section exists in
the plan or beside it — checked; the brief's three BUILD-VERIFY flags and the record's watch-outs
were treated as foci instead, each addressed below or in the clean bill.
**My evidence seat:** headless only (the Air-style fence given in the brief): I read the whole diff
at e1dcdd43, confirmed the tour files are byte-identical at HEAD, re-ran the core tour suites myself
(`swift test --filter "TourWalkTests|TourQueriesTests|TourOfferTests"` → **33/3 GREEN**), verified
the mockup correspondence and the quoted door constants by my own greps, and judged the Mac-pin and
walk claims from the records (two green stage windows; three revert-verified red-on-old checks;
the stale-binary episode and its correction read in full and found internally consistent).

## Findings

- **[MINOR] · `Sources/VariorumCore/Domain/Tour.swift:656–667` (ringGroups `.write`/`.makeTake`/`.takeIcon`/`.takesMode`) · The off-target re-anchor rule the brief states ("the tour tolerates them and re-anchors") is implemented for in-note wanders and the early/leg steps, but an AREA-level wander during the tour's middle leaves no ring and no road back** · Evidence (traced): `ringGroups(.write)` and `.makeTake` return a `sidebarMode(.write)` fallback only `if case .note = facts.place`; at `.area(...)` they return `[]`. `ringGroups(.takeIcon)` away from the note returns `[[.takeBadge(id)]]` — an anchor only `TourBadgeLocator` can find in Write's editor, so off the note nothing is ever lit (and `followBadge` keeps polling the window 4×/s for a badge that cannot exist there). `.takesMode` likewise returns only `[[.takesBlock(id)]]`, absent off the Takes board. Concrete degradation: at step 6 she clicks Library in the sidebar (the assessment's B3-class off-target click); no ring lights, `isRoadBack` is false (it mirrors the fallbacks), so no A7 sentence either, and the card sits in its corner describing "The ⑂2 in the margin" with no margin on screen and no `next`. She is not stranded (End tour is present, the sidebar is visible, returning to the note restores everything — steps 2/3 and the legs DO carry fallbacks, pinned in `wanderingOffAtStepTwoMovesTheRingToTheRoadBack`), but the tour's own A7 fix was built precisely so ring and words never contradict; here they contradict by silence. Red-on-old pin: a headless walk to `.takeIcon` (or `.write`) reporting `.area(.library)` asserting a non-empty lit-able group (e.g. `.sidebarOpenRow(tourNoteID)` — the exact candidate the legs already use) fails on the current rule · Fix: give the note-centric steps an area-wander fallback group member (`sidebarOpenRow(state.tourNoteID)`, the same shape as `.legTags`), and extend `isRoadBack` to match; one table, one mirror, plus the walk pin.

- **[MINOR] · `Sources/VariorumCore/Domain/Tour.swift:504–521` (`enter(.legEnd)`) with `:341–348` (`reduce(.facts)`) and `:497` (`finishAtGuide`) · Leaving Snippets at leg 4 directly INTO the field guide finishes the tour but first yanks her off the guide she just opened** · Evidence (traced): at `.legSnippets`, a fresh report with `place == .book(guideID)` advances to `.legEnd` (`advance`, line 464: left Snippets by any road); `enter(.legEnd)` sees `place != .area(.bookcase)` and appends `.navigate(.area(.bookcase))`; back in `reduce`, `finishAtGuide` accepts the same report (she IS at the guide) and appends `.finish(completed: true)`. The engine performs effects in order: the window navigates to the Bookcase, then the tour finishes — net, she asked for the field guide (⌘K is a live road from Snippets) and ends on the Bookcase with the guide closed, while the rule's own `finishAtGuide` says arriving at the guide from anywhere IS the finish (both roads end at the field guide, R-13s-1). Red-on-old pin: headless — walk to `.legSnippets`, `report(.init(place: .book(guide)))`, expect effects `== [.finish(completed: true)]`; today they are `[.navigate(.area(.bookcase)), .finish(completed: true)]` · Fix: in `reduce(.facts)`, check `finishAtGuide` when the settle LANDS on `.legEnd` before `enter`'s choreography is kept (or have `enter(.legEnd)` skip the navigate when `place` is already the guide). The non-guide exit (yank home, ring the guide row) is P-U2-7's designed choreography and stays.

- **[NIT] · `App/Variorum/Variorum/Core/Views/TourSpotlight.swift:110–116` (`lit`) + `:209` (the modifier's `lit`) · Two on-screen COPIES of the same anchored door both ring at once** · Evidence: `presence` deliberately refcounts copies ("the Bookcase's starred shelf and its own"), but `isLit` is per-ANCHOR and every registered copy draws its own `TourRing`, so a tour target that appears twice (a STARRED Sherlock in All view sits under the virtual starred shelf and under Welcome; reachable by starring the book and re-running the tour from Help) rings twice, and the two rings' `onGeometryChange` reports race for `frames[anchor]`, so the card sits beside whichever copy reported last. A3's one-ring rule holds per group, not per copy. Cosmetic, edge-conditioned, honest to record rather than fix blind — the walk never hit it · Fix if wanted: light only one copy (e.g. the first reporter wins while lit), or record as accepted with A3's reading ("one anchor, each of its copies is the door").

- **[NIT] · `App/Variorum/Variorum/Features/Onboarding/TourOverlay.swift:572` (`TourOracle.endDoorFrames`) · The DEBUG oracle's door-frame dictionary is never cleared on the overlay's disappear** · Evidence: `onDisappear` resets `TourOracle.overlay` and `cardFrame` but not `endDoorFrames`; `TourEndCardTests` clears it by hand per room, so today's pins are sound, but the next pin that forgets the manual reset reads the previous mount's frames as this mount's. Test-oracle hygiene only, no product path · Fix: clear it in the same `onDisappear` branch.

## Dispositions of the record's own open items (checked, not re-raised)

- **The stale-binary episode (the "ONE STILL-RED" → CORRECTION):** read in full and verified
  consistent — the inverse build's timestamp (09:33:04) vs the walk (09:35–09:42), every walk
  observation explicable by the three inverses, the live-path pin (`theEndCardsDoorsWrapThroughTheLiveOverlay`)
  strictly stronger than the component pin it replaced, and the rebuild-after-restore lesson
  recorded. The end card's live re-walk on the fresh binary is still owed to the NEXT window —
  correctly tracked in the record, not a finding.
- **The two Run-2 reds (`TakesArticleScrollTests`):** the record's trace (pure layout-model test U2
  never reaches; green alone 40/40; the U1a watch item's process-global typography class) is
  consistent with the diff — U2 touched that suite's surfaces only with inert modifiers. Accepted
  as pre-existing, owned outside U2.
- **The focus re-grab residual:** correctly recorded-not-fixed under the hallucination guard and
  owned as VX-112; the two candidate roads are plausible and the proposed red-pin-first path is the
  right one.
- **P-U2-12 (undeclared tour chrome / `openTutorial`):** the reading is consistent with the
  recorded What's New / Open the Tutorial precedent and is already flagged for the author;
  no new door went undeclared that the precedent doesn't cover. Not re-litigated.
- **A2's unbuilt card-width flex:** reason recorded in its row (no cheap widow measure); accepted.

## Clean bill (load-bearing things specifically checked and found solid)

1. **The pure rule's step machine** (`Tour.reduce`/`settle`/`advance`/`remember`): monotonic, bounded
   (`Step.allCases.count`), edge-gated exactly as documented — step 10's box-went-live edge counts
   only on the report that carried it (`freshReport` + `previousBookNoteLive`), a "next" never finds
   a stale edge, baselines reset on entry and re-rest (`takeBaseline` on block change), a caret move
   can never fake a take (remember runs before advance, so the baseline absorbs the same report),
   and an already-fanned block must GROW to count (Q14's second-tour case, pinned).
2. **B2 Today's Entry / the own-note gate:** `ownNoteCandidate` demands bookless + not the toured
   note + the facts' id matching the place — stale note-facts can never advance it (the id rides the
   answer in `TourEngine.noteFacts` and in `Facts.note`), and the journal entry's book membership
   excludes it. Pinned headlessly.
3. **R-13s-12 (no dim):** nothing in the overlay or the spotlight draws over the room — the ring is
   the door's own overlay, the tour layer renders only the card's rectangle, the probe hit-tests nil,
   the ring `allowsHitTesting(false)`. The A3 panel slot draws INSIDE the sheet, above the app's own
   scrim, dimming nothing further.
4. **The copy contract:** every card byte-matches the approved table; the five departures are exactly
   the recorded five (P-U2-1/2/3/5 + BUILD-VERIFY 2); I independently confirmed the approved strings
   ARE the mockup's own text and the departure texts are NOT in the mockup; door-naming prose quotes
   the doors' constants (`scrapsDoorTitle`, `StarCopy.starRow`, `WorkspaceNaming.openSectionHeader`,
   `NoteBoxCopy.editDoor` — all located and exact); the tone pin (no em dash, no emoji, no shouting
   caps, A5's time-promise scoped to the fork door) is real and tight. R-13s-32's savepoint sentence
   stands untouched.
5. **The three BUILD-VERIFY resolutions:** step 7's "choose" header, leg 4's "Scraps", step 9's
   note-selected sentence — each matches the real code it claims (I read `TakeChooseHeader`'s claim
   in the record against the pinned departure, `PostDetailView.scrapsDoorTitle:74`, and the W21
   carry description), with the product alternatives correctly routed to her (P-U2-2/3).
6. **The ⑂ badge coupling:** the editor's conventions are pinned at the source
   (`EditorView.swift:909/940` — `⑂\(count)` title, blockID identifier, confirmed by my own grep);
   the locator is read-only, bounds its `visibleRect` by the badge's own bounds (the stage window's
   find, fixed and red-on-old at 2a4cfd95), searches one window's contentView only, and polls only
   during the one step that needs it. Nothing decorates the live storage; the TextKit 2 seam
   (`EditorTextView`/`BlockRangeIndex`/`PaneSurface`) is untouched in this diff — verified by stat
   and by reading every editor-adjacent hunk (two SwiftUI chrome doors wearing inert modifiers).
7. **The queries** (`tourLandmarks`/`tourNoteFacts`): live-rows only, `status='member'`,
   `kind='book'`, archived excluded, wing-scoped, exact-name match (renamed = hers), bounded by name
   and by one note's rows — P1 honored; missing landmarks degrade (nil, never a guess), pinned.
8. **Composition and ownership:** features render `.tourAnchor`/`.tourKeepClear`/`TourPanelSlot`
   from shared vocabulary and never hold the tour's model; the spotlight rides the environment and
   is nil (fully inert, structure unchanged) outside a tour — the anchors-inert claim is proven by
   the 210/49 Run 2 over every surface that gained one; the engine's doors hold the slot weakly
   (no cycle on a window closed mid-tour); facts observation lands on the overlay's small body,
   not the shell's.
9. **The offer lifecycle:** "yes" writes nothing (quit mid-tour re-offers, Q12), the end card
   records completed at once (P-U2-11 — a later leg exit never downgrades: `finish` carries
   `state.completed`), End tour before it records ended, Help restarts at step 1 as a NEW engine
   (pinned in the real shell, including W-U1a-1's caret release and the R-13s-13 never-returns read-back).
10. **The fix round's three fixes:** F-U2-W-1 (TourDoorStyle + the one door table + the live-path
    pin), F-U2-W-2 option A (`showPoolTucked` idempotent, effect at leg-3 entry, exactly-once pinned),
    A1–A7 — each present in the diff exactly as the record claims, each with its pin, the
    revert-verified red-on-old evidence in the VERIFY WINDOW RECORD consistent and specific.
11. **Sync/custody:** nothing under `Sources/VariorumCore/Sync/`; the tour writes no store rows
    (completion is device-local chrome, P-U1a-1); every store mutation the tour witnesses is her own
    act through the ordinary operations.
12. **No literal colour:** ring and chrome are tokens; the `.black.opacity` shadows sit inside the
    colour pin's recorded shadow exemption (NoLiteralColourTests:162–168, read).

**Verdict: 0 BLOCKER · 0 MAJOR · 2 MINOR · 2 NIT.** The unit is solid: the rule is genuinely pure
and thoroughly walked, the app half is thin and composition-clean, and the record's evidence
discipline (trace-before-touch, red-on-old by revert, the stale-binary correction) is exemplary.
Both MINORs are small, pinnable, and inside the rule file; neither blocks the next unit.
