# 13s U1a — cold review, ROUND 1 (Fable, 2026-10-08)

**Target:** `git diff 66b0086b..85198217 -- App/ Sources/ Tests/` on `vx-7-13s-voice-onboarding`
(worktree `~/dev/variorum-13s`; 66b0086b = the branch's main-merge base). All 28 files in the
diff read whole, in this session. Anchor: the U1a BRIEF, the U1a RECORD (piece notes,
PROVISIONALs, STAGE WINDOW RECORD, WALK RECORD) in `notes/plans/phase-13s-voice-onboarding.md`;
rulings R-13s-1…42; mockup v5 (`notes/plans/13s-mockups/onboarding-tour.html`, the "first open"
and "not now" frames read at line level). No "Review foci" section exists in the plan or beside
it (checked by grep). Seat constraints honored: headless `swift test` only
(`TourOfferTests` + `AppearanceSettingsTests` run here, 19/19 GREEN); the Mac-suite and walk
claims judged from the record and the code. The two red `PostureSwitchTests` on main are the
known VX-106 baseline, outside this diff — not chased.

**Verdict: 0 BLOCKER · 0 MAJOR · 0 MINOR · 3 NIT.**

---

## Findings

**[NIT] · App/Variorum/Variorum/RootView.swift:812 (`tourOfferLine`) + TourOfferLine.swift
(`TourOfferModel.holdsRow`) · a window opened AFTER the offer retires in-process still reserves
the empty 24-pt row · evidence:** `holdsRow` is a `let` fixed at model init
(`atLaunch != .retired`), and `RootView.tourOfferLine` gates on it, not on the phase or on
whether THIS window ever drew the line — so in a session where the user answers the offer and
then opens a second window, that fresh window's Bookcase carries 24 pt of dead space between the
quick-entry box and the ⌘K bar with nothing ever shown in it (next launch is clean). P-U1a-4's
recorded text covers "the emptied row keeps its height" for the window where the line left (the
no-jump reason is real there); the fresh-window consequence is outside its letter and has no
no-jump reason. **Not pinnable as a bug** (no old behavior regressed — the old tree had no row;
this is a provisional's edge, honestly a taste call). **Fix (if taken):** none needed now — fold
this sentence into P-U1a-4's QUESTIONS entry at the merge so the alternative ("collapse, or gate
the row per-window") is judged with it.

**[NIT] · App/Variorum/Variorum/VariorumApp.swift:478 (the About `Window` scene) · the About
window wears chrome the platform's About panel doesn't · evidence:** a plain
`Window("About Variorum", id:)` scene (a) lists itself in the Window menu's auxiliary section —
the walk's own W-U1a-2, confirmed in source: nothing excludes the scene — and (b) carries the
title-bar text "About Variorum", where the system About panel (and Apple's own apps) shows an
untitled panel. Both flow from the same scene declaration; one pass (scene exclusion from the
windows menu + a hidden-title window style) addresses both. Taste-grade, PROPOSE-ONLY territory
(the design posture) — this echoes and extends W-U1a-2 rather than re-opening it; hers or a
later polish row's. No pin (clarity/chrome, degradation traced above).

**[NIT] · App/Variorum/Variorum/Features/Onboarding/TourOfferLine.swift:224
(`TourOfferLineOracle`) · the DEBUG oracle is process-global and unscoped, unlike its sibling ·
evidence:** `BookcaseRowOracle.recordFrame` is owner-scoped (17y B2's C4 rule) precisely so two
mounted boards can't cross-talk; `TourOfferLineOracle.drawn`/`contentFrame` are bare statics and
`onDisappear` of ANY offer line calls `forget()` — a future two-window-Bookcase DEBUG suite (the
`DebugOracleTwoWindowTests` class) would read torn state. Today's suites mount one window each
(harness `RootView` mounts pass `tourOffer: nil`, so no second line exists anywhere), so nothing
is red now — test-harness hygiene only, worth the owner parameter whenever a suite first needs
it. No pin (no current red is constructible; by the guard's own rule that makes a bug-class
finding hollow, so it is filed as hygiene).

---

## Clean bill — checked and found solid

1. **The Study default flip (the reason this round is Fable's — a default's meaning).**
   `Queries.themeSettings` seats `ThemeSettings.unsetStoreVoice` (= .study) before the row loop;
   a stored valid value always wins; a garbage value falls to the SAME store default (the
   pre-existing `?? settings.voice` pattern, deliberately re-seated and pinned); the memberwise
   placeholder `ThemeSettings().voice` stays Terminal, and every storeless host
   (`themeStore?.settings ?? ThemeSettings()` — ReadPostView, TakesBoardView, EditorView,
   ThemeStore's initial value) still draws it — I enumerated the construction sites. Nothing is
   written (no seed, no outbox row — pinned in
   `aFreshStoreWakesInStudyAndAStoreThatCarriesAVoiceKeepsIt`, run green here). The recorded
   red-on-old (3 issues on the unflipped read) is red by construction: the suite asserts `.study`
   where the old read returns `.terminal`. `setThemeVoice` has no effective-value no-op guard, so
   picking a voice on an unset store writes an explicit row — the record's "a store showing Study
   carries an explicit row" reasoning about her real store holds for the PRE-flip world it argues
   from. Mobile never reads this default (`MobileVoicePreference` is local; no
   `Queries.themeSettings` caller under `VariorumMobile` — grepped). Her real store's row is
   PENDING her word, correctly recorded as author-only, with the one-click remedy stated.
2. **The TourOffer rule.** The full (phase × event) table traced by hand: the record is written
   AT the "not now" press (write-before-phase, so a crash mid-step fails toward quiet); "yes"
   writes nothing (Q12's no-resume honored); retired is absorbing; `phase(atLaunch:)` retires on
   ANY stored value including unrecognized and empty ones — failure direction matches R-13s-13's
   absolutism; UserDefaults' NSNumber→string bridging also lands retired. The timer schedules
   only in `.helpRoad`, cancels on every exit, and its task checks cancellation after the sleep.
   `TourOfferTests` (8) exhausts the table including the two-step no-road-back property; run
   green here.
3. **Spec/mockup conformance of the copy and chrome.** The approved mockup's offer line is
   byte-shaped as built: V mark · "Welcome to Variorum. Take the tour?" · yes · not now — NO
   dismiss × (R-13s-6's early reconciled reading had one; v5, the approved spec, does not; the
   build follows v5 and the brief). The transient names "Help ▸ Take the Tour" per the brief's
   ruled fallback, said in the record (P-U1a-9), and menu item, registry verb and sentence derive
   from ONE constant. No em dash, no emphasis caps, sentence case throughout; the stub refusal
   speaks (18i's door-that-did-nothing rule).
4. **Composition and the cross-feature rule.** ShelfView receives a VIEW (`offerLine: AnyView?`),
   never the onboarding model; RootView composes; the app delegate owns the one model; the Help
   door rides `ShellRouter.tourRequested` in exactly the `whatsNewRequested` shape (compared side
   by side). Domain rule pure in `VariorumCore/Domain` (the NoteCardFace precedent). The Shelf's
   quick-entry move retires `listContentHeight` cleanly (sole use removed) and leaves
   `QuickEntryCopy.placeholder` untouched (the brief's "exact current wording kept").
5. **Registry P-1.** `.takeTour` declared `[.surface, .menuBar]`, rendered in
   `EditorCommands.menuRendered`, and the surface walk unions `TourOfferLine.surfaceCapabilities`
   (the DiagnosticsPane class); "not now" and About undeclared on named precedents, both argued
   in source comments. Verified the registry walk pin text.
6. **The icon and the mark.** `icon.json` read: default fill srgb(0.98824, 0.07059, 0.04706) =
   #FC120C with the faithful two-tone SVG; dark/tinted carry the white mono V (dark ground) —
   P-U1a-6 as recorded; glass/specular/translucency/shadow all off ("flat print").
   `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon` intact in the pbxproj (no project edit, as
   claimed); no stale `appiconset` reference anywhere; exactly TWO mark placements exist
   (About + the offer line — Q19's letter, grepped). The two-commit icon swap (deletion rode
   f8edff25, replacement f4af2eec) read together per the record's note.
7. **The Mac pins and the stage record (judged from code + record, as instructed).** The three
   first-pass reds are each the corrected text I read: (1) the same-`.global`-space geometry
   comparison, (2) centre-in-right-half PLUS the unchanged right-alignment inset check (weaker
   but honest; the walk owns the taste call), (3) the TakesEntryBandTests process-fresh
   typography reset — whose defer captures the as-found globals BEFORE the reset and restores
   them after (verified in source, lines 116–121), with the red/green pair methodology recorded.
   Run-1 arithmetic checks (5+6+2+29+7 = 49). The leak class's closeout watch item is recorded
   where the closeout will read it.
8. **Justified edits.** All six voice-naming test edits (TakesEntryBand ×2, MastheadLayout ×2,
   MastheadStamp, ModeSwitchFeel) make a previously-implicit world explicit and carry the
   justification in place; none weakens an assertion.
9. **Hygiene.** No `Co-Authored-By`/`Claude-Session` trailer on any of the 33 commits in range
   (grepped). Nothing under `Sources/VariorumCore/Sync/`; no schema, no custody, no editor-seam
   file (BlockRangeIndex/EditorTextView/PaneTextAuthority untouched — `EditorTypography` touched
   only from test code); S1–S5 untouched by construction (the one new read writes nothing); P1
   untouched (all new chrome is constant-cost). PROVISIONALs staged in the plan file, the shared
   ledger correctly left for the merge moment. The walk's W-U1a-1 (focus after "yes") is
   correctly carried to U2's brief rather than patched under the stub.

**Disposition note:** all three findings are NITs with no pinnable red; none blocks the unit.
Under the cross-model flow they go to the implementer verbatim next; my recommendation is
record-only dispositions (NIT 1 → P-U1a-4's ledger text; NIT 2 → ride W-U1a-2's existing note;
NIT 3 → a one-line hygiene note for whichever session first mounts two Bookcases in DEBUG), with
no code change in this unit.

## DISPOSITIONS (orchestrator, 2026-10-08 ~04:05 — the cross-model exchange complete; the round AND the ladder close)

The implementer AGREED to all three findings, mechanism and record-only disposition alike, disputing none (its three confirmations, each traced to file:line, are in its exchange message and stand as the agreement of record). The reviewer's final call was already record-only on all three; with zero fixes there is nothing for a round 2 to re-review — **the U1a ladder closes at round 1 with a clean bill (0B · 0M · 0m · 3 NIT, all record-only).**

- **NIT-1 — AGREED, record-only:** folds into P-U1a-4's QUESTIONS text at the merge, with the implementer's named alternative (hold the row per window, only in a window that drew the line this session).
- **NIT-2 — AGREED, propose-only (taste):** rides W-U1a-2's note for her or a later polish pass; the one scene-level pass (exclude from the Window menu + hide the title bar) is the named shape.
- **NIT-3 — AGREED, hygiene note:** the oracle gains an owner parameter whenever a suite first mounts two Bookcases; no change now.
