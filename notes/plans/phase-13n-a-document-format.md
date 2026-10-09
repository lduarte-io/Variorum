# Phase 13n-a — the Variorum document format (Level 0)

## KICKOFF MESSAGE (for a fresh orchestrator session)

You are kicking off 13n-a, the first of the MCP door's two efforts — ruled
at the 2026-10-09 sitting (`notes/plans/phase-13n-sitting-record-2026-10-09.md`,
R-13n-1…11; the mockups `notes/plans/13n-sitting-mockups/mcp-door-mockups.html`
§8 carry the format sample). Preflight per CLAUDE.md in full (this plan, the
sitting record, the master plan incl. in-flight, TICKETS, QUESTIONS, the
resiliency protocol — no SyncSpec or TEXTKIT2 read needed: this phase touches
neither seam, and that absence is itself verified below). Mint the effort's
ticket on the VX board at kickoff ("13n-a: the Variorum document format"),
branch and worktree per the standing rules, declare surfaces against the
in-flight table. ONE acceptance unit, one implementer session, the standard
ladder. Standing cast applies; the diff has no editor seam, no custody, no
`Sync/`, so `opus-reviewer` is eligible.

## What this phase builds

**The no-connection road of the MCP door, complete:** a round-trippable
text format any LLM can author, its import door, and the push gesture.
Three deliverables:

1. **The format, specified and parsed (Domain).** The import format IS the
   shipped export format (R-13n-8): blocks as paragraphs, the chosen take's
   text in place, the fan following in the `--- Alternates for this block ---`
   / `take: "label"` / `--- end alternates ---` section (unlabeled takes
   numbered, `take: N`), plus the capture microsyntax in the body's first
   line: `{t:"…"}` title, `{#tag/path}` tags. A pure
   `Domain/VariorumDocument` (or implementer's name) with `parse` and
   `serialize`, tested independently. Parsing is fail-honest: a malformed
   alternates section (no preceding paragraph, unterminated) refuses the
   import with a message naming the line — never a silent partial import.
   The microsyntax grammar matches `Shared/CaptureMicrosyntax` (only braced
   forms parse; tokens disappear); core cannot depend on the app target, so
   the brace grammar is implemented in Domain — whether the app's capture
   face later delegates to it is the implementer's call, noted either way.

2. **The import door (Operations + App).**
   - `importDocument` (core operation): mints a note from one parsed
     document — blocks paragraph-per-block (the standing bulk rule), the
     in-place text as each block's chosen take AND `default_variant_id`'s
     take, labeled takes joining the fan at the end (never chosen, never
     locked, labels ride), tags adopted/minted by path in the destination
     wing (R-13ia-1), title from `{t:"…"}` else the filename. Empty takes
     skip (the export's own rule mirrored); an entirely empty document
     refuses. ONE transaction per note.
   - `importBook` (composite): a FOLDER imports as a book — subfolders =
     chapters (`reading_section` rows, folder name = chapter name),
     filename order (digit-aware, the Bookcase's a–z rule) = order within;
     book name = folder name; the book lands unshelved, kind `book`, no
     rule, in the current wing; notes land as members seated in their
     chapters. A single FILE imports as a bookless note in the Pool
     (P-13n-2, provisional).
   - **Undo: one import = ONE compound structural-undo entry** (R-13n-6) —
     folder or file; the inverse tombstones everything minted on the
     import's stamp; the redo revives exact rows (the `restoreContainer`
     exact-stamp machinery is the precedent). Touch stamps, no churn
     (structural-op convention).
   - Faces: File ▸ Import… (file or folder) and drop onto the Bookcase
     (folder = book). Receipts speak what landed ("imported “o ladrão de
     raios” — 12 notes in 3 chapters · ⌥⌘Z undoes"). Refusals name the
     malformed line. Sentence case everywhere (her standing rule).

3. **Copy for AI (App).** The note ⋯ menu gains "Copy for AI" — the current
   note serialized to the clipboard in this format (R-13n-11). The export
   side exists (`Queries.alternatesSection` et al.); this face adds the
   microsyntax header line and uses the SAME serializer the round-trip
   tests pin.

## What this phase must NOT touch

- **The export pin stands:** no export path writes a row; import is its own
  door minting fresh rows through operations — a file is bulk entry, never
  reconciled truth (R-13n-8).
- **No schema change.** Everything mints ordinary rows; no new tables, no
  migration, marker untouched, zero `Sync/` — imported rows reach the
  outbox through the ordinary triggers like any mint.
- **No editor-seam work.** Import never touches `EditorTextView` /
  `BlockRangeIndex`; minted notes open through the ordinary doors.
- Commits and book settings do not ride the format (R-13n-8 — the true
  full-fidelity form is 13m's variorum edition; structure travels through
  13n-b's tools on the connected road).
- Multi-paragraph SURFACE blocks are not expressible in v1 (P-13n-4);
  takes' internal newlines inside alternates sections ARE preserved.

## Acceptance (use-shaped, per the sizing rule)

- **Round-trip pins:** export → parse → serialize byte-identical on (a) a
  fanless note, (b) a fanned note with labeled + unlabeled takes, (c) a
  note with internal newlines inside a take. Parse-side state-transition
  tests for `importDocument`/`importBook` (exact rows: chosen, default,
  fan order, labels, tags-by-path, sections, membership order, the one
  undo stamp).
- **The live round:** a PT/EN sample book (two chapters, fanned blocks —
  the mockup §8 sample extended) imported through the real File ▸ Import
  door into a dev store; opened in Lenses with a lens per language; then
  ⌥⌘Z once — the whole book gone; ⇧⌥⌘Z — back whole. A stage claim for
  the app leg (headless core tests run freely).
- Tests run at the unit's END; the previous closeout is the baseline.

## Open items for the implementer brief (not blockers)

- The Import door's exact File-menu placement and the drop target's outline
  (the Bookcase's false-offer rule applies — light only where a drop acts).
- Whether `importBook` is one transaction or one-per-note inside one undo
  compound (the resiliency and size tradeoff is the implementer's, the ONE
  undo entry is not).
- The `.variorum`/`.md`/`.txt` extension question: accept all three on the
  door, write `.md` from Copy for AI (PROVISIONAL — log it).

## Closeout

The standard ritual: results here; the master-plan 13n rows (the
resequencing from R-13n-1/9 if this effort merges first); tickets closed or
re-owned; MOBILE PARITY line (expect "nothing mobile-visible" — the doors
are Mac faces; imported content syncs as ordinary rows); 13n-b's plan
written with its kickoff message (the sitting record's R-13n-3…7/10/11
carry its rulings); the handoff; PR, merge commit, push, hard stop.

---

## THE OVERNIGHT RUN (2026-10-09, kickoff ~04:15 MDT) — her mandate and standing orders

Opened by `/architect-phase` at her word: *"let's get rolling. I'm going to
sleep, so I want you to rule and build provisionally. I'll be back in the
morning. you can do that #143 merge + kickoff."* (#143 merged: `062e8534`.)
Her second order, mid-kickoff, BINDING: *"if you get done before I am back,
you'll finish with an application refresh but not a merge to main until i
can review and test it."* So: the unit builds, ladders, and walks tonight;
the run ends with the /Applications refresh from this branch's tree at a
zero-instance window (A1 first; HELD instead if her real-store instance is
alive — never quit it); **PR opened but NOT merged**; the morning bundle
carries her review+test checklist. Disputed or product-flavored edges land
PROVISIONAL here and in QUESTIONS, never silently.

Effort: VX-117 (child of VX-25, project 13n) · branch `vx-117-13n-a` ·
worktree `~/dev/variorum-vx-117` · the Pro. Orchestrator: Fable
(`/architect-phase`); implementer `opus-implementer` (xhigh); cold reviewer
`opus-reviewer` (no editor seam / custody / `Sync/` in this diff — the
sitting record's eligibility call).

## The binding principles (the 13b constitution, copied per the architect-phase skill)

- **P-1 — One capability registry.** Every user-facing act is declared
  exactly once: verb, scope (block/take/post/book), per-mode availability
  rule, its doors (menu / context / bar / shortcut / palette), and its
  refusal copy. Surfaces render their doors FROM the registry; gating is
  data, never per-view if-statements. A registry-walk test asserts every
  declared door exists and every rendered door is declared. This kills the
  D3/D4 class structurally — the capability matrix stays green by
  construction instead of by audit.
- **P-2 — Fire-and-DO (R115).** A rendered door either performs the act —
  including any mode-switch choreography, done visibly for the user — or
  delivers the operations layer's real refusal. A door that can never act in
  its context isn't rendered. Lecture-and-redirect is retired.
- **P-3 — One text surface, one liveness authority.** ONE TK2 surface
  component (live + read modes; one measurement brain — the width-gated
  remeasure; the shared canary) that every pane composes; the live editor
  core's identity machinery (`BlockRangeIndex`, crystallization) becomes its
  live mode, not a sibling implementation. "What text does this pane show,
  and is it live" is answered by ONE pure, unit-tested authority
  (`PaneTextAuthority`); views never re-derive it. Its invariants stated as
  code: exactly one live pane; the live pane is buffer-authoritative; read
  panes are projection-authoritative once caught up.
- **P-4 — Broadcasts carry signals, never decisions.** NotificationCenter
  may announce that something happened (mode changed, post opened); no
  listener derives business state or availability from a broadcast, and no
  flow's correctness depends on broadcast ordering. Cross-feature flows
  route through composition. (Stage 0's survey enumerates today's
  notification bus; Stage 1 disciplines it.)
- **P-5 — The friction doctrine (R116).** Repeated pushback against a rule
  marks an under-architected feature. The response is never another patch:
  write the feature's DESIGN MEMO — intended behavior whole, edge cases
  enumerated on paper, refusal wordings, undo story — get the author's
  rulings on the product-flavored edges, then build to the memo. Happy path
  ships first, but the edges are *decided at design time*, not discovered by
  the author. First two memos owed: **merge** and **the W ceremony**.
- **P-6 — The tutorial is the executable spec (R113).** The guided tutorial
  flow is the contract for every happy path. It stays green — automated
  where the harness allows, screenshot-walked otherwise — and any change
  that breaks a tutorial step is a regression by definition.
- **P-7 — Find bugs before she does.** Every layer keeps a proactive
  harness: the ops-layer soaks (exist), the board/view-model invariant soak
  (Stage 1), the registry walk (P-1), the per-batch scripted screenshot
  walkthrough. Red-on-old stays absolute: no bug-class fix without a pin
  that fails on the pre-fix code.
- **P-8 — Standing law, consolidated.** P1–P3 performance invariants bind
  the rebuilt layer exactly as they bind the substrate (invalidation ∝
  realized rows; one live editor; virtualized long views). Overlays, never
  rendering attributes. Chrome `fixedSize` texts always carry a `lineLimit`
  (the b6dae25 class). `Theme/VoiceControls.swift` is THE chrome vocabulary.
  Complexity lives in the store; restraint lives in the UI.
- **P-9 — No god objects in the frontend either.** A view model mixing
  board layout, text authority, and gesture routing splits by concern
  (`TakesViewModel` at 890 lines is the standing counterexample). Same
  hygiene rule as the substrate, applied where it was being waived.

Constitution applications specific to THIS unit: the two new Mac doors
(File ▸ Import…, the note ⋯ menu's Copy for AI) are ROUTED vocabulary —
they are DECLARED in the capability registry (verb, availability, refusal
copy) and covered by the registry walk (P-1); the Bookcase drop target
lights only where a drop would act (§12's false-offer rule); import never
creates a second text surface or touches the liveness authority (P-3 —
minted notes open through the ordinary doors); receipts/refusals ride the
one status seam with their KIND decided at the door.

## Environment traps (the standing invariant core — brief-verbatim for the implementer)

Instance checks use `pgrep -fl 'Variorum.app/Contents/MacOS'` AND
discriminate by PATH; treat real-store instances by STORE, not path —
NEVER quit/kill one; no Release builds or /Applications refreshes while
one lives. Mac tests run from `App/Variorum/` with suite-level
`-only-testing` ONLY, and EVERY `xcodebuild test` run (and any walk,
Debug-app launch, or dev-store reset) requires a HELD `Tools/stage` claim;
headless `swift build`/`swift test` on the core package is free. NEVER add
a custom build configuration (anything not named exactly "Debug" builds
the packages Release and strips the DEBUG oracles). Swift Testing's
"passed" count INCLUDES skipped tests — read the `skipped:` lines before
claiming a gated suite ran. zsh `pipestatus`. Walks: `cliclick` +
`Tools/WalkKit/` on the DEV-STORE Debug build only
(`io.lduarte.Variorum.debug`), under the held stage claim; screenshots in
gitignored dirs. Never `git checkout` over uncommitted work; push after
every commit; never force-push. Backups of any real store are WAL-safe
with UTC names into `Backups/safety-copies/` (the A1 rail) — but this
unit should never touch the real store at all.

## UNIT RECORD (LIVE STATUS — the implementer owns this section from its first commit)

- **NOT DONE BY THIS SESSION (first, per the contract):** (1) the GUI WALK
  (W1–W7 below) — HELD by `Tools/WalkKit/guard.sh --author` (exit 3: her
  real-store `/Applications/Variorum.app`, PID 73118, was live all night;
  her instance is never quit, so no session may drive the GUI until she
  closes it) — the unit therefore does NOT close on its acceptance gate
  yet: the headless round (`SampleBookDrillTests`) and the door suites are
  evidence, not the walk; (2) the `/Applications` refresh (the
  orchestrator's, and HELD anyway while her instance lives); (3) the
  review ladder; (4) canon deltas, QUESTIONS entries and the master plan
  (merge-moment ledgers — the proposals are listed at the end of this
  record); (5) FORK-A…D below are returned, not decided.
- STATE: **BUILT + LADDERED (closed at round 2, 0B/0M) — GUI WALK + REFRESH
  HELD, PR OPEN AND UNMERGED (her order).** Implementer session 1
  (`opus-implementer`, 2026-10-09 04:20–05:25 MDT), the rulings fix pass,
  ladder round 1 (0B/1M/4m/4n, all dispositioned FIX except F5's wording),
  its fix round (nine pin-first fixes), ladder round 2 (0B/0M/1m/3n —
  verdicts all implemented-as-worded; R2-1/R2-3 fixed orchestrator-side
  pin-first, R2-2/R2-4 wording). FINALS on the closed tree: core WHOLE
  PACKAGE 2,478/284 + 40/6 green (standing gated skips only; +52 over the
  13s-b baseline); the four 13n-a suites + export + paste 86/14; Mac
  consuming suites (door + registry) 43/2 under stage after the round-2
  core fixes. No revert is in flight. Tickets born: VX-118 (FORK-D),
  VX-119 (the 13c undo-pair class + R2-1's rule), VX-120 (door package
  semantics; the Pro probe answered). What remains for the unit to CLOSE:
  the W1–W7 GUI walk (THE WALK below) and the /Applications refresh — both
  held all night by her live real-store instance, both ready at her
  zero-instance window; and her review+test, whose merge is the merge
  moment (ledger proposals in the closeout section).
- FIX PASS (the architect's rulings R-ARCH-13na-1/2): see "FIX PASS
  (rulings)" at the end of this record — its own live status.
- Per-piece lines land here as `DONE (hash)` / `IN-PROGRESS — exactly what
  remains` / `NOT-STARTED`; unverified claims marked PENDING; revert
  announcements per the resiliency protocol (no revert starts until this
  record names it and a committed pre-revert state exists).

### The pieces (in build order)

1. **Domain — the format.** `Domain/CaptureTokens.swift` (the capture brace
   grammar MOVED into core byte-for-byte; the app's `CaptureMicrosyntax.parse`
   delegates — one brain), `Domain/TagPath.swift` (the typed-path slash rule;
   `TypedTagPath.segments` delegates), `Domain/VariorumDocument.swift`
   (model + markers + `parse` + `serialize`, fail-honest line-numbered
   refusals), `Domain/VariorumDocumentFolder.swift` (a folder → the book
   plan: chapters, digit-aware order, extension filter). Core tests.
   — DONE (`0f1a22c9`; `VariorumDocumentTests` 17/17 then, 18/18 with
   piece 4's NFC pin). The app's two
   delegations (`CaptureMicrosyntax.parse` → `CaptureTokens.parse`,
   `TypedTagPath.segments` → `TagPath.segments`) compile on the Mac AND the
   phone target (`VariorumMobile` generic-simulator build green); their
   pins — the app's capture suites, the quick note's, the typed-tag
   pickers' — are green at the end (piece 6), zero test edits.
2. **Queries — one serializer.** `exportPost(includeVariants:)` re-expressed
   over `VariorumDocument.serializeBody` (the export becomes the
   serializer's client — byte-identity pinned by the existing export
   suites); `Queries.variorumDocument` + `copyForAIText` (header line +
   the export body). Round-trip pins (a) fanless (b) labeled+unlabeled fan
   (c) internal newlines in a take. — DONE (`2d8d9e66`;
   `DocumentFormatRoundTripTests` 5/5 — (a)(b)(c) + Copy-for-AI = header
   over exactly the fan export + the no-write pin; the export's own suites
   `ExportProjectionTests`, `ChapterAssemblyExportTests`,
   `PostRenderQueryTests`, `BlockPresentationTests` green on the
   re-expressed export).
3. **Operations — the import door.** `importDocument` (one note, one
   transaction, one undo entry — `revertMintedContainer`'s pair) and
   `importBook` (one transaction for the whole folder, one undo entry whose
   inverse tombstones exactly the minted notes + the book on one stamp; the
   redo revives them through `restoreReading`'s body). State-transition
   tests. — DONE (`512ecebf`; `DocumentImportOperationTests` 10/10 — exact
   rows for both ops, import(export(note)) re-exports byte-identical, the
   one undo entry, undo↔redo on the same rows, her own note filed in the
   imported book survives the undo, E13 refusal mints nothing, the daily
   Journal guard on the inverse, intake hearing an imported tag. Enabling
   refactors, each behaviour-identical: `mintFanBlock` private→internal,
   `restoreReading`'s body → `restoreReadingRows(db:)` (diff is
   whitespace-only), `assertBookNameIsFree` → `requireBookNameFree(db:)`,
   `adopt(tag)` → `adoptPath(path)`. The 35 suites over those paths
   (+ `ImportOperationTests`): 279/279 green).
4. **App — the faces.** File ▸ Import… (file or folder; the `.importFiles`
   declaration upgraded), the Bookcase drop (folder = book, file = note;
   outline only where a drop acts), Copy for AI (`.copyForAI`, the two
   `note ▾` menus + ⌘K), the copy (receipts/refusals). App tests.
   — DONE (`79652a96`). `Features/Import/DocumentImporter.swift` (read
   off-main under the security scope, plan through the pure core rule,
   a NAME PREFLIGHT so a collision refuses before anything is minted, run
   every item in ONE runner turn inside ONE compound undo entry, speak),
   `DocumentImportCopy.swift` (every sentence, pinned), the
   `BookcaseImportDrop` delegate (file drags only; the outline draws only
   while one is over the board), `CopyForAI` (flush the note's pending
   typing, then the ONE serializer onto the pasteboard; a test seam for a
   private board). Registry: `.importFiles` verb "Import…", doors
   menuBar+palette+surface (`ShelfView.surfaceCapabilities` — the walk's
   union gains its line); `.copyForAI` (post, bottomBar+palette,
   `noteScoped`) rendered by BOTH `note ▾` menus (Write's only in note
   contexts — the scraps bar composes it with a pool) and wired in ⌘K. The
   dead `ImportPanels` left `ImportModel` (the sidebar Library drop and the
   pool drop keep the plain import — see FORK-D). Debug app build green;
   `DocumentImportDoorTests` + the capture/registry/import/versions suites
   100/100 (8 suites, 0 skipped). **A DEFECT the door test found, fixed
   pin-first:** macOS hands paths back DECOMPOSED, so a folder-named book
   stored NFD bytes (Swift compared equal, SQLite did not); every name the
   import derives from a PATH is now stored NFC — her text untouched.
   Pin `VariorumDocumentTests.namesTakenFromThePathArePrecomposedButTextIsNot`
   red on the pre-fix planner (3 failed expectations), green after.
5. **The live round** (stage claim; captures in the gitignored dir named in
   the walk section below). — **GUI WALK HELD** (see THE WALK below: her
   real-store `/Applications/Variorum.app` is live — PID 73118, launched
   ~02:45, HID idle 90 min — and `Tools/WalkKit/guard.sh --author` exits 3
   "her app is running — STOP"; her instance is never quit, so no session
   may drive the GUI until it is closed). DONE headless (`643af3da`): the
   PT/EN fixture `notes/plans/13n-a-sample/o ladrão de raios/` (committed —
   original prose, two chapters, fanned blocks, one take with line breaks;
   her morning test can import it as-is) read from DISK the door's way,
   imported as one book, read through a lens per language, ONE undo takes
   the book + notes + lenses, ONE redo brings them back whole —
   `SampleBookDrillTests` 1/1.
6. **Close** — the named suites green at the end, every row dispositioned.
   — DONE (this commit). Finals, all at the END of the unit:
   - **core, the whole package:** `swift test` → **2,460 tests / 284 suites
     + 40 / 6, all passed** (the 9 skips are the pre-existing gated
     measurement/integration tests; baseline at 13s-b 2,426/280 + 40/6 —
     exactly this unit's +34 tests in +4 suites).
   - **Mac app, widened to every suite over a changed file or surface**
     (stage held; no pointer-injecting suite in scope, her app on screen):
     **297 tests / 40 suites + 6 / 2 (`SearchPickerBrainTests`,
     `RuleEditorMakeTagTests`), 0 skipped, all passed** — the registry walk,
     the three capture suites, the quick note's mint/door/word suites, the
     import faces + CRLF door + confirmations, Versions, the vocabulary
     sweep, CommitBar layout, the note-deletion family, split-at-newlines,
     formatting surfaces, the Bookcase's row-freeze/census/quick-entry/
     masthead-popover/tour-offer suites, masthead tags, chord legibility,
     undo hint/refusal + destructive-undo warning, the command-routing
     family, and `DocumentImportDoorTests` (re-run with the registry walk
     after the last cleanup: 38/38).
   - **builds:** the Mac app Debug + test target green; the phone
     (`VariorumMobile`, generic iOS Simulator) green — `Shared/` changed.
   - Zero `Sources/VariorumCore/Sync/` lines; no schema, no migration,
     marker untouched; no editor-seam file (`EditorTextView`,
     `BlockRangeIndex`, `PaneSurface`) touched.

### THE WALK (RUN 2026-10-09 ~10:30 MDT — her app quit by her and the walk sanctioned; the record is "WALK RECORD" right after the steps)

Precondition: `Tools/WalkKit/guard.sh --author` exits 0 (her app closed BY
HER, idle machine); `Tools/stage claim`; the Debug app from this worktree's
DerivedData (`xcodebuild -scheme Variorum -configuration Debug build`), dev
store. Captures → `notes/plans/13n-a-screens/` (gitignored — add the line
to `.gitignore` in the walk's commit), one per row, BOTH voices (Settings ▸
Appearance, Terminal and Study) for rows W1, W2, W5.

- **W1 — File ▸ Import… (the folder → a book).** File menu: the item reads
  "Import…". In the panel: ⌘⇧G → the fixture's parent
  (`…/notes/plans/13n-a-sample`) → select `o ladrão de raios` → Import.
  Expect the book to OPEN (fire-and-DO) and the receipt
  "Imported “o ladrão de raios” — 4 notes in 2 chapters · ⌥⌘Z undoes";
  the book view lists chapters "1 o semideus", "2 a excursão", then
  unfiled "posfácio". Capture the book + the receipt.
- **W2 — Lenses, a lens per language.** Open "abertura" → Lenses (⌘4):
  the left column is Portuguese; "+ column" → "New lens — pick existing
  takes" → flip each of the three blocks to its "english" take. Capture:
  PT | EN side by side; block 3's unlabeled take (line breaks) visible in
  the fan.
- **W3 — ⌥⌘Z once.** The whole book is gone from the Bookcase (and the
  four notes from the Library); the Edit menu's redo item reads "Redo
  Import". Capture.
- **W4 — ⇧⌥⌘Z.** The book is back whole — chapters, notes, the english
  lens. Capture.
- **W5 — Copy for AI.** In "abertura", `note ▾` → "Copy for AI"; the quiet
  receipt; `pbpaste` shows `{t:"abertura"} {#percy/pt-en}` then the body
  with its Alternates sections (note: this writes HER system clipboard —
  say so in the record). Also ⌘K → "Copy for AI". Capture the menu.
- **W6 — the Bookcase drop.** Undo the import (⌥⌘Z), then drag the
  `o ladrão de raios` folder from a Finder window onto the Bookcase board:
  the outline lights ONLY over the board and only during the file drag;
  dropping lands the book (the board stays; the receipt speaks). Also
  drag a BOOK ROW across the board — the outline must NOT light. Capture
  both. (If a Finder file drag turns out to carry plain text too, a book
  row's note-drop would claim it over a row — check; that is the one
  drop interaction the headless pins cannot see.)
- **W7 — a refusal names its line.** Copy the fixture, delete the FIRST
  `--- end alternates ---` line in `01 abertura.md`, import the copy: the
  refusal names the folder, the file, the line where the next section
  opens, and that the one opened on line 5 never ended; nothing lands.

#### WALK RECORD (LIVE STATUS — the walk driver, 2026-10-09)

- **NOT DONE BY THE WALK (first):** the `/Applications` refresh (not this
  session's); no fix of anything seen (anomalies are REPORTED here, never
  fixed). W1–W7 all RUN — every row worked; five anomalies and two
  hesitations recorded at the end of this record.
- Stage claimed ("13n-a walk", W1–W7, 60 min); `guard.sh --author` exit 0
  (her app absent, HID idle); the Debug app built from THIS worktree
  (`xcodebuild -scheme Variorum -configuration Debug build`, DerivedData
  `Variorum-dpsxczocduggenewfhncdsuvqhsm`, build 5974,
  `io.lduarte.Variorum.debug`), launched `open -n` on the dev store (PID
  15366). The dev store's voice on arrival: Study (restored at the end).
  Captures: `notes/plans/13n-a-screens/` (gitignored — the line was
  already in `.gitignore`).
- **W1 — WORKED, one visual anomaly.** File menu reads "Import…" (no
  chord); the panel's message "Pick a document, or a folder — a folder
  becomes a book, its folders its chapters."; picking `o ladrão de raios`
  → Import OPENED the book in Outline: "book · 2 chapters · 4 notes",
  chapters "1 o semideus" (abertura, a escola), "2 a excursão" (o museu),
  then unfiled "posfácio"; the Bookcase row "o ladrão de raios
  #percy/pt-en #viagens · 4 notes · 2 ch · 89w", unshelved; the Library
  lists the four notes. **ANOMALY (visual): the receipt is TRUNCATED** —
  because the door opens the book, the quiet receipt lands in the book
  navigator column's narrow bottom bar and reads only "Imported “o ladrão
  de raios”…" (Study) / "Imported “o ladrão de…" (Terminal); the counts and
  "⌥⌘Z undoes" are never visible, and the line is not exposed to
  Accessibility, so the full sentence could not be read live at all.
  Both voices: imported in Study, ⌥⌘Z'd (the bottom bar said "Undid:
  Import", Edit menu "Redo Import" — the first import's book and notes now
  sit in the dev store's Trash), flipped to Terminal, imported again (the
  book W3/W4 act on). Captures: `w1-file-menu-import-study.png`,
  `w1-file-menu-import-terminal.png`,
  `w1-import-book-opened-receipt-study.png` (+ `-b`),
  `w1-import-book-opened-receipt-terminal.png`,
  `w1-bookcase-after-import-study.png`,
  `w1-bookcase-after-import-terminal.png`,
  `w1-bookcase-terminal-before-reimport.png`,
  `w1-undo-first-import-bookcase-study.png`,
  `w1-library-after-import-terminal.png`.
- **W2 — WORKED.** "abertura" opened in Write (three single-sentence
  blocks, ⑂2 ⑂2 ⑂3); Lenses (⌘4): the left column "Chosen (the note)" is
  Portuguese; the "+ column" menu's item reads "New lens — arrange existing
  takes" (the script's "pick existing takes" is the plan's wording, not the
  app's); each block flipped to take 2 = the english take; the lens SAVED
  as "english" (💾 → "Name this lens") so W4 can look for it — the save
  registered no structural undo (Edit still "Undo Import"). Takes (⌘2,
  expand all): each fan reads "✓ chosen" (Portuguese, unlabeled — F5's
  domain) · "choose english" · and block 3's unlabeled "choose" take with
  its three lines intact. Captures (both voices):
  `w2-abertura-open-write-terminal.png`, `w2-abertura-open-write-study.png`,
  `w2-lenses-initial-terminal.png`, `w2-column-menu-terminal.png`,
  `w2-lenses-new-lens-terminal.png`,
  `w2-lenses-pt-en-side-by-side-terminal.png`,
  `w2-lenses-english-lens-saved-terminal.png`,
  `w2-lenses-pt-en-side-by-side-study.png`,
  `w2-takes-fan-terminal.png`,
  `w2-takes-fan-expanded-unlabeled-take-terminal.png`,
  `w2-takes-fan-expanded-unlabeled-take-study.png`.
- **W3 — WORKED, one behavioral anomaly.** ⌥⌘Z once (with "abertura"
  open in Write): the book is gone from the Bookcase, the four notes from
  the Library; Edit menu items read "Undo Structural Change" (disabled) ·
  "Redo Import ⌥⇧⌘Z"; the bottom bar said "Undid: Import". **ANOMALY
  (behavioral): the open note's pane outlives its deletion** — the Write
  pane stayed on "abertura", now "in no book", empty ("0w in note", the
  status reading "open tail" — a live-looking editor on a tombstoned
  note), and "abertura" stayed in the sidebar's Open strip (⌘⇧1) after the
  undo; nothing was typed into it (not exercised). Captures:
  `w3-undo-while-note-open-study.png`, `w3-bookcase-book-gone-study.png`,
  `w3-library-notes-gone-study.png`, `w3-edit-menu-redo-import-study.png`.
- **W4 — WORKED, one behavioral anomaly.** ⇧⌥⌘Z (from the Library): Edit
  menu back to "Undo Import"; the receipt "Redid: Import"; the Bookcase
  row back ("4 notes · 2 ch · 89w"); the book opens whole — chapters "1 o
  semideus" / "2 a excursão", unfiled "posfácio"; "abertura" reopened from
  the book shows its three blocks and, in Lenses, the saved **english**
  lens with all three english takes. **ANOMALY (behavioral): the visible
  Library did not refresh on the redo** — while the Library was the
  surface on screen, the book and the four notes stayed absent (captured
  immediately and again after ~5 s); leaving to the Bookcase and coming
  back showed them. (The W3 undo's Library was entered AFTER the undo, so
  whether the undo refreshes a visible Library was not observed.) Not
  distinguished by this walk: whether the lens rows were ever tombstoned
  by the undo (they came back either way). Captures:
  `w4-redo-library-notes-back-study.png` (the stale list, receipt
  visible), `w4-redo-library-after-wait-study.png`,
  `w4-redo-bookcase-study.png`, `w4-library-reentered-study.png`,
  `w4-book-back-whole-chapters-study.png`,
  `w4-abertura-reopened-study.png`, `w4-lenses-after-redo-study.png`.
- **W5 — WORKED, one visual anomaly. HER CLIPBOARD:** saved before the
  row (every item and type, through `NSPasteboard` — it was EMPTY: 0
  items, changeCount 1414) and restored after (cleared back to empty,
  verified 0 items / 0 bytes); the row wrote it four times. `note ▾` →
  "Copy for AI" from BOTH menus (Write's in Study and Terminal, Takes' in
  Terminal) and ⌘K → "Copy for AI" (Study): each put ONE plain-text item
  on the board (`public.utf8-plain-text`), and all four copies were
  byte-identical; `pbpaste` = `{t:"abertura"} {#percy/pt-en}`, a blank
  line, then the body with its three Alternates sections — `diff` against
  the fixture `01 abertura.md` differs ONLY by the file's final newline
  (FP-1's edge). The receipt: "Copied for AI — the note with its takes and
  tags, ready to paste into any chat." — whole in Study; **ANOMALY
  (visual): in Terminal the receipt truncates** ("…its takes and tag…" in
  Write, "…its takes and tags,…" in Takes). Captures:
  `w5-note-menu-copy-for-ai-write-study.png`,
  `w5-copy-for-ai-receipt-write-study.png`, `w5-palette-open-study.png`,
  `w5-palette-copy-for-ai-study.png`,
  `w5-palette-copy-for-ai-receipt-study.png`,
  `w5-note-menu-copy-for-ai-takes-terminal.png`,
  `w5-copy-for-ai-receipt-takes-terminal.png`,
  `w5-note-menu-copy-for-ai-write-terminal.png`,
  `w5-copy-for-ai-receipt-write-terminal.png`.
- **W6 — WORKED.** ⌥⌘Z first (the W1 book gone; "Undid: Import"). The
  fixture folder dragged from a Finder window (`open -R`, closed again at
  the end) with `cliclick`, in Terminal: (a) with the **welcome shelf
  solo'd** (the ladder's owed look, P-13na-6) — the board's outline lit
  over the empty board, went OFF over a book row, came back over the board;
  the drop landed the book ON welcome (the strip's welcome solo now listed
  it first) with the full receipt in the Bookcase bar: "Imported “o ladrão
  de raios” — 4 notes in 2 chapters · ⌥⌘Z undoes" (whole here — the W1
  truncation is the book navigator's bar only); undone; (b) with **All**
  — the same outline behaviour; the drop landed the book UNSHELVED, the
  same receipt. (c) The plan's open question — **a Finder drag dropped ON a
  book row** ("the field guide"): no outline, no receipt, nothing landed —
  the field guide still 42 notes, the Edit menu unchanged — so a row's
  note-drop does NOT claim a Finder drag (it is a silent no-act, which is
  the false-offer rule's letter). (d) **A BOOK ROW dragged across the
  board** ("o ladrão de raios"): the title chip rides the cursor, the
  board outline never lights (over rows or over empty board); the drag
  cancelled with Esc, the book unmoved. Captures:
  `w6-undo-before-drop-bookcase-terminal.png`,
  `w6-file-drag-over-board-soloed-welcome-terminal.png`,
  `w6-file-drag-over-book-row-soloed-welcome-terminal.png`,
  `w6-file-drag-back-over-board-soloed-welcome-terminal.png`,
  `w6-file-drop-landed-soloed-welcome-terminal.png`,
  `w6-file-drag-over-board-all-terminal.png`,
  `w6-file-drag-over-book-row-all-terminal.png`,
  `w6-file-drop-landed-all-receipt-terminal.png`,
  `w6-file-drag-over-field-guide-row-terminal.png`,
  `w6-file-dropped-on-book-row-terminal.png`,
  `w6-book-row-drag-over-board-no-outline-terminal.png`,
  `w6-book-row-drag-over-empty-board-mid-terminal.png`,
  `w6-book-row-drag-cancelled-terminal.png`.
- **W7 — WORKED.** A copy of the fixture in the session scratchpad with
  the FIRST `--- end alternates ---` (line 11 of `01 abertura.md`)
  deleted, imported through File ▸ Import… twice: (a) while the W6 book
  (same folder name) was still LIVE — the PARSE refusal wins over the E13
  name preflight; (b) after ⌥⌘Z, in Study — the same refusal, a toast:
  "Couldn’t import “o ladrão de raios” — “1 o semideus/01 abertura.md”,
  line 14: a new alternates section starts before the one on line 5
  ends." — the folder, the file (chapter-relative), the line where the
  next section opens (14 after the deletion), and line 5. Nothing landed:
  the Bookcase and the Library unchanged, no new Trash row (the Trash's
  newest rows are the W7-prep undo's own), and the Edit menu kept "Redo
  Import" (a refused gesture registers nothing). Captures:
  `w7-broken-copy-while-same-name-book-live-terminal.png`,
  `w7-before-clean-import-bookcase-study.png`,
  `w7-refusal-names-file-and-line-study.png`,
  `w7-library-nothing-landed-study.png`, `w7-trash-after-walk-study.png`.
- **Close:** the dev instance quit by identity (`pgrep` empty after);
  the dev store left in Study (as found), appearance untouched; the W6
  book undone (the Bookcase as found, plus the dev store's Trash holding
  the walk's undone imports — each undo leaves the book "and 4 notes" row
  AND the four notes as their own rows); her clipboard empty as found;
  the stage released. **ANOMALIES, for the orchestrator (reported, not
  fixed):** (1) W1 — the import receipt truncates in the book navigator's
  narrow bottom bar after the door opens the book (both voices; the
  counts and "⌥⌘Z undoes" never show there, and the line is not exposed
  to Accessibility); (2) W3 — undoing the import with one of its notes
  open leaves that pane on the dead note ("in no book", empty, "open
  tail") and the note in the Open strip; (3) W4 — the redo does not
  refresh a Library that is on screen (re-entering shows the rows); (4) W5
  — the Copy-for-AI receipt truncates in Terminal (Write and Takes); (5)
  visual, minor — the refusal toast sits over the Bookcase's quick-entry
  field (both voices). **Hesitations (not defects):** the soloed-shelf
  drop puts an imported book on the Welcome shelf, which §12 says "holds
  the SEEDED content only" — P-13na-6's context mint and that line meet
  here; the Trash's double listing of an undone import (book "and 4
  notes" + each note) reads busy.

### Implementer calls (each with its one line of reasoning)

- **IC-1 — the capture grammar MOVED into core; the app delegates.** The
  plan left "whether the app's capture face later delegates" to me: one
  rule, one home (`CaptureTokens`, byte-for-byte), so the format's header
  and her capture boxes can never read a token differently; the app's
  capture suites are the move's pins. Same for `TypedTagPath.segments` →
  `TagPath.segments`.
- **IC-2 — the header is read on the FIRST NON-BLANK line** (the plan says
  "the body's first line"): forgiving of a leading blank line an LLM or an
  editor adds; tokens on any other line are her text.
- **IC-3 — the format names `.paragraph`, never `default_segmentation`**:
  R-13n-8's "paragraph = block on entry" is the format's own rule, and an
  Alternates section must attach to one paragraph.
- **IC-4 — take-marker leniency, canonical spelling first.** `take: "x"` /
  `take: N` are the canonical forms (what the serializer writes); the parser
  also reads curly-quoted labels, a bare unquoted label, `take: ""` as
  unlabeled, and a COMPACT section (no blank lines between marker and text).
  Lower-case `take:` only, so a prose line opening "Take:" stays prose. A
  take's text keeps everything but the one blank line the serializer puts on
  each side of it.
- **IC-5 — `importBook` is ONE transaction** (the plan's open item): a book
  lands whole or not at all; a folder of notes is author-scale.
- **IC-6 — member order: the chapters' notes in chapter order, then the
  folder's top-level files (unfiled)** — the order the book view and the
  reading export already present them in.
- **IC-7 — touch, never churn; baseline = rendered length;
  `last_major_revision_at` untouched** — the structural convention the plan
  names, with `copyPost`'s "the copy starts clean" precedent for the
  baseline.
- **IC-8 — imported tags go through the ONE application road**
  (`insertPostTag`), so a living book whose rule hears an imported tag picks
  the note up — R-13u4-1's doctrine for the same `{#tag}` token.
- **IC-9 — an empty subfolder still makes its (empty) chapter**: "subfolders
  = chapters", literally.
- **IC-10 — the import's undo inverse refuses when the imported book has
  since become THE daily Journal** (`dailyJournalCannotBeDeleted`, the
  delete doors' own guard) — the entry stays on the stack.
- **IC-11 — Copy for AI's `{t:"…"}` is the STORED title only**; a note she
  never named carries no title token (the importer then names it by its
  file) — a derived date is not a name she typed (13k K1's letter).
- **IC-12 — the File-menu placement** (the plan's open item): the shipped
  "Import Files…" item's own slot, its verb now "Import…" (a folder is the
  point); the panel takes files AND folders, several at once.
- **IC-13 — a gesture is all-or-nothing and ONE undo entry:** every picked
  item parses before anything mints (the first malformed line refuses the
  whole gesture); a NAME PREFLIGHT refuses a folder named like a live book
  (or like another folder in the same pick) before item one, so a refused
  gesture leaves nothing — not even a rolled-back book in the Trash.
- **IC-14 — where the doors land:** File ▸ Import… OPENS what a lone item
  made (fire-and-DO, the restore doors' precedent) and says what several
  made; the Bookcase drop stays on the Bookcase (the new book appears on
  it; the receipt names what landed, "to the Pool" for a file).
- **IC-15 — names taken from a PATH are stored precomposed (NFC)**; her
  text is never touched (the defect the door test found — piece 4).
- **IC-16 — the drop outline** lights only while a FILE drag is over the
  board (`BookcaseImportDrop` accepts `.fileURL` alone, so book rows and
  notes dragged across the board never light it); a dropped file the door
  does not read refuses by name rather than being pre-filtered (hover
  cannot read a drag's files without loading them — W6 checks this live).

**Known limits, recorded (not defects of the plan's letter):** a title
containing `"}` or a tag path containing `}` cannot ride the header line
(the capture grammar's own limit); a label with a line break cannot ride a
`take:` line; a take whose own text holds a line reading exactly like a
`take: …` marker or an end marker splits there (the format has no escape —
the canonical export never writes one, an LLM essentially never will).
*Added by the ladder fix round:* an untitled, untagged note whose FIRST
paragraph is nothing but brace tokens copies with no header, so that
paragraph re-imports as the header (F9's residual — prose beside a token is
body since F9); a directory inside an imported folder is passed over as a
PACKAGE only when THIS Mac's LaunchServices says it is one (R2-4 — on the
Pro, `.rtfd` reads as a package and is skipped, while `.textbundle` and an
extension-named plain folder like `percy.v2` read as ordinary directories
and walk in as chapters; the door-level shapes and the Air's probe are
VX-120's); and a
multi-item gesture whose op refuses on item 2+ still rolls the earlier
items back through tombstoning inverses (they would sit in the Trash beside
the refusal) — every folder-shape refusal is now a planner preflight (E13's
name, F6's blank chapter name), so no folder shape reaches it; a fault
arriving mid-flight still could (F6's recorded class).

### PROVISIONALs and forks returned to the orchestrator

- **P-13na-1 — a file nested DEEPER than a first-level subfolder rides into
  its first-level chapter**, ordered by its path (chapters never nest).
  Alternatives: refuse the folder naming the nested path; ignore nested
  files.
- **P-13na-2 — the folder name hits E13's duplicate-book-name guard:** the
  import REFUSES ("a book named … is already on your Bookcase"), minting
  nothing. Alternatives: auto-suffix "(2)" (the versions' naming
  precedent); allow the twin.
- **P-13na-3 — tags the import MINTED stay as vocabulary across ⌥⌘Z**
  (AppSpec §9 excludes tags from structural undo; the applications die and
  revive with their notes). Alternative: tombstone an import-minted tag
  that has no other application at undo time, and revive it on redo.
- **FORK-A (consequence of the plan's "standing bulk rule", returned for the
  architect, NOT changed): spacing.** The bulk rule stores the blank line
  between two paragraphs as one trailing newline on the first (the
  2026-07-12 spacing ruling), so an imported document — an export of hers,
  or an LLM's Markdown — shows a blank line between every paragraph in
  Write, exactly as pasting it does today. Text round-trips byte-identical;
  rows do not (`"A"` exports as `A\n\nB`, re-imports as `"A\n"`). The
  alternative would be a format-specific reading: a blank line is the
  separator, k ≥ 3 newlines store k−1 (the exact inverse of
  `joinRenderedTexts`) — row-identical round trips, but a second
  segmentation rule beside paste's.
- **FORK-B (same root): a hard-wrapped paragraph splits into one block per
  line** under the bulk rule (the mockup §8 sample is hard-wrapped for
  display; a real export never wraps, and LLMs rarely do). Markdown
  semantics (single newline = soft wrap) would keep it one block.
- **FORK-D: the sidebar's Library drop and a pool's scraps drop stay PLAIN
  imports** (`ImportModel` → `importPost`/`importBlocks`, the global
  segmentation, no format reading) — the plan names only File ▸ Import… and
  the Bookcase drop. So a Variorum document dropped on the Library row lands
  with its markers as text. Proposal: a follow-up ticket routes the Library
  drop's FILES through `DocumentImporter` (one file door, one rule).
- **FORK-C: an export the import refuses.** A FANNED block whose chosen take
  is BLANK exports its Alternates section with no paragraph above it (the
  export's own rule); the plan rules that shape malformed, so re-importing
  that export refuses, naming the line. Alternative: read a paragraph-less
  section as a block whose chosen take is empty.
- **P-13na-4 — Copy for AI puts PLAIN TEXT on the clipboard** (the plan's
  "write `.md` from Copy for AI"): the format is Markdown-compatible, so
  saved as `.md` it re-imports; no file is written, no second pasteboard
  type is offered. Alternative: also offer `net.daringfireball.markdown`.
- **P-13na-5 — the door reads `.variorum`, `.md`, `.markdown`, `.txt`,
  `.text`** (the plan's "accept all three", plus the two spellings the
  shipped import already accepted).
- **P-13na-6 (ladder F2, the orchestrator's FIX — placement taste is hers)
  — a folder dropped on the Bookcase while a shelf is solo'd lands ON that
  shelf** (the context mint, AppSpec §12; File ▸ Import… still lands
  unshelved). Alternative: unshelved as first built, with a receipt that
  names where the book went.
- **P-13na-7 (ladder F4, option (b)) — a stub is an empty note:** a
  header-only file (anywhere) and a blank or whitespace-only file INSIDE a
  folder mint an EMPTY note (zero blocks — ⌘N's shape), named by its
  header else its file; a blank file picked ALONE still refuses ("nothing
  in it to import"). Alternatives: (a) refuse the whole folder (as first
  built); (c) skip stubs and name them in the receipt.

### For the closeout (merge-moment ledgers — proposals, not applied)

- **AppSpec §9** gains `importDocument` / `importBook` (the format's own
  inverse-join reading — R-ARCH-13na-1 — never the bulk rule; the fan at
  the end; tags by path through the one application road; touch without
  churn; a stub mints an empty note (P-13na-7); ONE undo entry whose
  inverse tombstones exactly what was minted on one stamp and whose redo
  revives what died on THAT stamp — the book only when its own tombstone
  is it (ladder F1) — through the restore doors' exact-stamp bodies; the
  E13 guard on the folder name; `importBook`'s `shelfId` context mint).
  **The round-trip sentence, if canon carries one, states its exact domain
  (ladder F5) — never a bare "rows round-trip":** export → re-import
  preserves block texts (the chosen takes), fan membership, the
  ALTERNATES' texts in fan order with their labels, and stored spacing;
  the v1 format does NOT carry the chosen take's label, its fan position,
  or a chosen ≠ default split (a re-imported chosen take is first,
  unlabeled, and the default), nor locked or archived states; the three
  byte-level corners (one stored trailing newline reads unspaced; a blank
  line inside a surface block is a boundary; a blank-chosen fan after a
  fanless paragraph lands on that paragraph) stand; and BLANK content does
  not ride (R2-2) — a blank alternate take and an empty block are neither
  exported nor re-imported. Any export re-imports (never refused, every
  NON-BLANK take arriving). The source's wording is
  `Domain/VariorumDocument.swift`'s type doc comment.
- **AppSpec §12** gains the import door (File ▸ Import… — a file → the
  Pool, a folder → a book; the Bookcase drop — a context mint onto the
  solo'd shelf (P-13na-6); receipts with ⌥⌘Z that say "to the Pool" only
  for a bookless note and otherwise name the book that collected it (ladder
  F3); refusals naming file and line) and Copy for AI in both `note ▾`
  menus + ⌘K; the format's one home is `Domain/VariorumDocument` (the
  export is its client).
- **QUESTIONS:** P-13na-1…7 + FORK-A…D (or their rulings), and the ladder's
  proposed lines (round 1's dispositions — not written to
  `notes/QUESTIONS.md` by a build session):
  - **(F4)** a blank or header-only file inside an imported folder:
    refuse the book (as first built), mint an empty note (built,
    PROVISIONAL P-13na-7), or skip it and name it?
  - **(F5)** should the format carry the CHOSEN take's label (and so its
    fan position) — a v2 marker? Today Copy for AI → re-import of a
    picked-language note (her PT/EN notes) drops the chosen take's label
    and moves it to the front of the fan; the full-fidelity answer
    remains 13m's edition.
  - **(F2)** the Bookcase drop's placement: the context mint (built,
    PROVISIONAL P-13na-6) vs unshelved with a receipt naming where the
    book went.
- **MOBILE PARITY:** nothing mobile-visible (Mac doors; imported rows sync
  as ordinary rows; `Shared/`'s capture parse now delegates to core —
  behaviour-identical on the phone, its target builds).
- **A follow-up ticket** for FORK-D if the architect agrees (the Library
  drop's files through `DocumentImporter`).

### FIX PASS (rulings) — LIVE STATUS (continuation implementer, `opus-implementer`, 2026-10-09)

- **NOT DONE BY THIS PASS (first, per the contract):** (1) the Mac app
  suites were NOT re-run — the brief named the core suites; the app
  changed by zero lines, and `DocumentImportDoorTests` asserts counts,
  receipts and refusal copy only, never a block's text or shape (read,
  not run); (2) the GUI walk stays HELD (unchanged — W1–W7 still read
  right: the reading changes stored spacing, not what the walk checks);
  (3) no QUESTIONS / canon / master-plan edit (merge-moment ledgers — the
  two surprises below are for the orchestrator's bundle); (4) no review.
- STATE: **CLOSED** — both rulings built pin-first, finals green, pushed.

Scope, exactly: R-ARCH-13na-1 and R-ARCH-13na-2 (the section below this
record). No other refactor; the app is untouched; no revert is in flight.
IC-3 ("the format names `.paragraph`") is superseded by R-ARCH-13na-1 —
the format no longer consults `SegmentationRules` for its body.

1. **R-ARCH-13na-1 — the inverse-join body reading.** — DONE (`79ec0f90`). `VariorumDocument.paragraphs(_:beforeSection:)`
   replaces the bulk call: a blank line separates, a single newline is
   content (a block's lines joined back with `"\n"`, verbatim), b blank
   lines after a piece store `storedSpacing(blankLines:)` = b when b ≥ 2
   (k = b + 1 ≥ 3 ⇒ k − 1) else 0; the run before an Alternates header is
   spacing like any other; the document's leading/trailing runs are edges.
   `bulkSegments` and every other entry road untouched (pinned side by
   side). **Pins, red on the as-built parse first** (6 tests, 9 issues —
   the family pin misread 1,350 of 1,413 block lists), green after:
   `VariorumDocumentTests.theBodyIsTheExactInverseOfTheJoin` (inverse∘join
   = identity over every 1–3-block sequence of twelve shapes: unspaced,
   stored spacing 2/3/4, single newlines inside, indent + trailing spaces
   kept, fanned or not), `.theJoinsOneUndecidableSpacingReadsUnspaced`
   (RECORDED, see below), `.aSingleNewlineIsContentAndABlankLineIsTheBoundary`;
   `DocumentImportOperationTests.anUnspacedNoteRoundTripsRowForRow` and
   `.aSpacedNoteRoundTripsRowForRow` (export → parse → `importDocument` →
   the stored shape compared: each slot's takes in fan order, labels,
   chosen, default), `.aHardWrappedFileImportsOneBlockPerParagraph` (a
   hard-wrapped `.txt` through the door's own file road → one block per
   paragraph, line breaks inside). As-built expectations that encoded the
   bulk reading, updated in the same commit: the sitting sample's and
   the header test's block texts lose the stored `"\n"`;
   `theBodyIsTheStandingBulkRule` became
   `theFormatsReadingIsItsOwnAndPasteKeepsTheBulkRule`;
   `aSurfaceBlocksInternalNewlineImportsAsABlockBoundary` (P-13n-4's old
   record) is superseded by the single-newline pin;
   `aDocumentMintsOneBooklessNote…`'s first take and baseline; the drill's
   Portuguese lens text. **The sample fixture was NOT hard-wrapped — no
   fixture edit**; `SampleBookDrillTests` now asserts all three Portuguese
   blocks as single sentences. The byte-identity pins
   (`DocumentFormatRoundTripTests` 5/5, `serializeThenParseThenSerializeIsByteStable`,
   `importingAnExportRendersTheSameExportBack`) stayed green untouched.
   The four suites: 39/39.
   **THE DOMAIN, stated exactly (what inverse∘join = identity covers):**
   every block list in which (i) no fanless block is empty (the export
   skips a blank fanless block — as ever); (ii) no block's text holds a
   blank line or opens with one (a blank line inside a surface block is a
   boundary — P-13n-4, narrowed from "every newline" to "a blank line");
   (iii) **no block stores exactly ONE trailing newline** — the join writes
   m = 0 and m = 1 as the same `"\n\n"`, so that value is undecidable from
   the bytes and reads unspaced (a property of `joinRenderedTexts`, not a
   choice of the parse; it is the shape a two-newline paste stores, so a
   pasted-Markdown note's blank lines between paragraphs come back as
   plain block boundaries — the export bytes are identical either way);
   (iv) a fanless LAST block stores no trailing newline (FP-1 below);
   (v) the blank-chosen fanned block — piece 2.
   **Fix-pass calls:** **FP-1 — the document's trailing blank run drops**
   (the as-built edge doctrine, kept: the ruling reads the run BETWEEN
   pieces; a file's final newline — every POSIX editor adds one — is not
   her spacing). **FP-2 — no trim:** a block's lines are kept verbatim
   (indent, trailing spaces) — the join never trims, so the inverse cannot;
   the bulk rule's per-piece trim is paste's, not the format's.
2. **R-ARCH-13na-2 — the paragraph-less Alternates section is legal.** —
   DONE (`58a4f6e6`). The parse reads the
   section first, then: paragraphs above ⇒ the last one's fan (as ever);
   NONE above and ≥ 1 non-blank take ⇒ `Block(text: "", alternates:)`;
   none above and no take ⇒ `alternatesWithoutParagraph` at the header
   line (not export-producible — the ruling's "only this shape stops
   refusing"). `importDocument` needed NO change: it already mints take 0
   (here the empty one) as chosen AND `default_variant_id`, the section's
   takes after it at the fan's end — pinned on rows. **Pins, red on the
   old parse first** (4 tests, 4 issues; the extended family misread 273 of
   1,686 block lists — exactly the blank-chosen ones, which threw), green
   after: `DocumentImportOperationTests.anyExportReimportsWholeEvenAFannedBlockWithABlankChosenTake`
   (a note opening with a blank-chosen fan, and another right after a
   fanned block: export → import → identical rows, the blank take chosen
   and default); `VariorumDocumentTests.aParagraphLessSectionIsAFannedBlockWithABlankChosenTake`
   (at the start, after the header line, after another section, alone);
   `.theBodyIsTheExactInverseOfTheJoin` extended to blank-chosen blocks at
   every position where their section has no paragraph above;
   `.everyMalformedSectionRefusesNamingItsLine` — its two
   `alternatesWithoutParagraph` cases now carry NO take (still refusing,
   same lines 1 and 11 — green on both sides), plus one new line: an
   unterminated paragraph-less section now names `unterminatedAlternates`
   at its header (the section is read before its legality can be judged;
   the old parse said `alternatesWithoutParagraph` there — still a
   refusal, same line, the truer reason). Unterminated / garbled refusals
   all green, unchanged. **RECORDED, green on both sides by design:**
   `aBlankChosenFanAfterAFanlessParagraphReimportsOntoThatParagraph` — the
   export writes the SAME bytes for "a fanless paragraph, then a
   blank-chosen fan" and "that paragraph carrying the fan", so the import
   reads the latter: nothing refuses, every take arrives, but on the
   paragraph above (the blank block itself is not re-minted). "Any export
   re-imports whole" therefore holds as NEVER REFUSES + EVERY TAKE ARRIVES
   everywhere, and as IDENTICAL ROWS wherever the section has no paragraph
   above it. The app's refusal copy for `alternatesWithoutParagraph`
   ("…needs a paragraph of its own just above it") stays TRUE as a remedy
   and is untouched (the app is out of this pass's scope). The four
   suites: 42/42.
3. **Finals** — DONE (this commit), headless at the END, on the tree at
   `58a4f6e6` (the record commit changes no code):
   - **the four 13n-a core suites** (`VariorumDocumentTests`,
     `DocumentFormatRoundTripTests`, `DocumentImportOperationTests`,
     `SampleBookDrillTests`): **42 tests / 4 suites, all passed, 0 skipped**
     (was 34: +10 new tests, −2 superseded — 21 + 5 + 15 + 1).
   - **the export suites + the paste road** (`ExportProjectionTests`,
     `ChapterAssemblyExportTests`, `PostRenderQueryTests`,
     `BlockPresentationTests`, `BlockTakesProjectionTests`,
     `Phase13SurfaceQueryTests`, `TakeLabelTests`, `DisplayTitleTests`,
     `ImportOperationTests`, `SegmentationRulesTests`,
     `SegmentationLineEndingTests`, `NewlineSplittingTests` — anchored
     filter): **143 tests / 12 suites, all passed, 0 skipped.**
   - Zero `Sync/`, zero schema, zero app lines; the serializer and the
     export are byte-unchanged (only `parse` moved).
   **The two surprises, for the orchestrator (neither is a choice this
   pass made — both are properties of the export's bytes):** (a) the
   ruling's "spaced AND unspaced alike" holds for unspaced blocks and
   stored spacing ≥ 2, but NOT for a block storing exactly ONE trailing
   newline — the join writes it like an unspaced block, and that is the
   shape a two-newline paste (ordinary blank-line Markdown) or typed
   blank lines store, so such a note re-imports with plain boundaries
   where it had one-line spacing (bytes identical); only a join change
   could separate them, and the join is pinned. (b) "any export re-imports
   whole" holds as never-refuses + every-take-arrives everywhere, and as
   identical rows wherever the blank-chosen section has no paragraph above
   it; after a FANLESS paragraph the bytes equal that paragraph's own fan,
   so the takes land on it.

### LADDER FIX ROUND (round 1's dispositions) — LIVE STATUS (fix-round implementer, `opus-implementer`, 2026-10-09)

- **NOT DONE BY THIS ROUND (first, per the contract):** (1) the GUI WALK
  stays HELD (her real-store `/Applications/Variorum.app`, PID 73118, was
  live throughout; W6 — the Bookcase drop — now also owes a solo'd-shelf
  look: drop the fixture while a shelf is solo'd and see the book on it);
  (2) the whole core package and the widened Mac set were NOT re-run — the
  brief named the 13n-a + export/paste core suites and the focused Mac
  suites; (3) the phone target was not rebuilt (this round touched no
  `Shared/` or mobile file — verified by grep — and core compiles under
  `swift build`); (4) no `notes/QUESTIONS.md`, canon or master-plan edit
  (the three proposed lines sit in the closeout list); (5) two things SEEN
  and returned, not fixed — they are outside the dispositions' letter:
  (a) the single-note import pair `revertMintedContainer` /
  `reapplyMintedContainer` (shared with the copy ops since 13c 1B) has
  F1's shape — import a file, delete that note by hand (`deleteContainer`
  registers no undo entry), ⌥⌘Z (the inverse finds it dead: a quiet
  no-op), ⇧⌥⌘Z: the redo sees it dead and `restoreContainer` brings back
  the note she deleted (traced by reading, not run); (b) a PACKAGE handed
  to the door itself walks as a folder (F7's line below).

Scope, exactly: the ORCHESTRATOR DISPOSITIONS at the tail of
`notes/plans/13na-ladder-round1.md` — F1, F2, F3, F4 as option (b), F5's
wording, F6's preflight refusal, F7, F8's move, F9's tokens-only header.
Nothing more. No revert is in flight. QUESTIONS lines are PROPOSED in the
closeout list below, never written to `notes/QUESTIONS.md` (merge-moment
ledger; her merge).

- STATE: **CLOSED** — every disposition built (F1–F9), pins red-first
  where behavior changed, finals green, everything pushed.
- F1 (redo keyed on the undo's own stamp) — DONE (this line's commit).
  The inverse returns the stamp it wrote and hands it to the redo through
  a `LockIsolated` box (P-13ib-6's undo-time box); the redo revives the
  imported notes that died on THAT stamp and the book only when its own
  tombstone is that stamp. Pin
  `DocumentImportOperationTests.redoAfterTheBookWasDeletedByHandReturnsTheNotesNotTheBook`
  (the reviewer's probe + one more ping-pong) — red on the old redo
  (10 issues: 4 notes × 2 cycles left in the Trash, the book's tombstone
  replaced twice), green after; the two suites over the op 17/17.
- F4 (a blank/whitespace/header-only stub mints an empty note; option (b),
  PROVISIONAL — P-13na-7 below) — DONE (this line's commit). The parse
  refuses `.empty` only for a BLANK document (no header, no block); a
  header-only document is a stub; inside a folder a blank file is a stub
  too (`VariorumDocumentFolder.folderNote`); the single-file door keeps
  its "nothing in it to import" for a blank file (option (b)'s letter).
  The op mints a stub as an EMPTY note. **Fix-round call FR-1 — the empty
  note is ZERO blocks, ⌘N's own shape** (`createPost` mints no block); the
  reviewer's option text said "one empty block … the store shape a fresh
  New Note has", and New Note's real shape is the stated reason, so the
  shape follows it. Pins, red on the old code first (5 tests, each a
  refusal: `.empty` ×4, `.emptyImport` ×1), green after:
  `VariorumDocumentTests.aHeaderOnlyDocumentIsAnEmptyNoteAndABlankOneStillRefuses`,
  `.aStubInsideAFolderIsAnEmptyNote`;
  `DocumentImportOperationTests.aDocumentWithNoBlocksMintsAnEmptyNote`,
  `.copyForAIOfATitledEmptyNoteReimportsAsThatEmptyNote` (the invariant —
  "any export re-imports whole" — extended to the stub),
  `.aFolderWithStubsSeatsEachAsAnEmptyNoteInItsPlace`. Superseded as-built
  expectations, in the same commit: `anEmptyDocumentRefusesAndMintsNothing`
  became `aDocumentWithNoBlocksMintsAnEmptyNote`; the header-only line of
  `everyMalformedSectionRefusesNamingItsLine` moved into the new parse
  pin. The four 13n-a suites 47/47.
- F9 (the header line is a header only when it is tokens alone) — DONE
  (this line's commit). The first non-blank line is read as the header
  ONLY when token removal leaves nothing but whitespace; a first line of
  prose beside a literal brace token is body, untouched (IC-2 refined).
  Pins, red on the old header rule first (2 tests, 8 issues), green after:
  `DocumentImportOperationTests.aFirstLineOfProseBesideABraceTokenSurvivesReimportByteIdentical`
  (an untitled, untagged note whose first paragraph holds `{#dream}` and
  `{t:"Title"}` as prose: Copy for AI → import → no tag, no tag row, named
  by its file, the body export byte-identical) and
  `VariorumDocumentTests.theHeaderIsReadOnTheFirstNonBlankLineOnly` (its
  mixed-line half was the superseded as-built expectation — "the tokens
  go, the prose stays" — now pinned as body; a tokens-only line with
  extra spacing still reads as the header). The four 13n-a suites 48/48.
  **The residual, stated (narrower than the line F9 retires):** an
  untitled, untagged note whose FIRST paragraph is nothing but brace
  tokens (e.g. a paragraph reading exactly `{#dream}`) copies with no
  header, so that paragraph re-imports as the header — the format has no
  escape; a titled or tagged note is immune (its header comes first).
- **The app-side pins, red first (one WIP commit — the pins + two
  behavior-neutral scaffolds they need to compile; each fix commit below
  turns its own pin green):** the scaffolds are F6's `blankChapterName`
  reason + its copy line (never thrown yet) and F2's drop seam
  (`BookcaseImportDrop.shelfID` + `land(_:)`, landing exactly as built —
  no shelf reaches the op). Red runs: core
  `VariorumDocumentTests.aChapterFolderWithABlankNameRefusesTheFolderBeforeAnythingMints`
  (2 issues — no throw; its deeper-folder line is a guard, green on both
  sides); Mac `DocumentImportDoorTests` under a held stage claim — 13
  tests, 9 green, the 4 new pins red with 7 issues:
  `aFolderDroppedOnASoloedShelfLandsOnThatShelf` (the book's `shelf_id`
  nil), `aNoteCollectedByALivingBookIsNotSaidToLandInThePool` (old text
  "Imported “flying” to the Pool · ⌥⌘Z undoes"),
  `aBlankChapterFolderRefusesBeforeAnythingIsMinted` (the op's
  mid-gesture refusal; item one's note left in the Trash),
  `aPackageInsideAFolderIsNeitherAChapterNorAFile` (old text "… 1 note in
  1 chapter …" — the `.rtfd` became a chapter). — DONE (this line's commit).
- F6 (a blank chapter-folder name refuses in the planner's preflight) —
  DONE (this line's commit). `VariorumDocumentFolder.plan` refuses
  `blankChapterName` (no file named; the door says "Couldn’t import
  “spaced book” — one of its folders has a blank name, and a chapter needs
  one.") before any file parses; the op's own `invalidSectionName` guard
  stays as defense. Core pin green (the four 13n-a suites 49/49); the door
  pin `aBlankChapterFolderRefusesBeforeAnythingIsMinted` — green at the
  next door run (F2's: 13 tests, F2 + F6 pins green, F3 + F7 still red as
  designed). **The class, RECORDED as a known limit (the
  disposition's second half):** any op refusal on item 2+ of a multi-item
  gesture still rolls the earlier items back through their inverses, and
  those inverses tombstone — so the earlier items would sit in the Trash
  beside a refusal saying nothing landed. The preflights (the E13 name
  check, now the blank chapter name) are the guard that keeps it
  unreachable from any folder shape; what remains reachable is a fault
  arriving mid-flight (the wing dying under the gesture).
- F2 (the Bookcase drop is a context mint; PROVISIONAL — P-13na-6 below)
  — DONE (this line's commit). `importBook` gains `shelfId:` (validated
  as `createReading` does — live, same wing; never placed);
  `DocumentImporter.importURLs`/`run` thread a `shelfID` (File ▸ Import…
  passes nil — unshelved, the plan's letter); the drop's `land(_:)` passes
  the board's `mintShelfID`. Pin `DocumentImportDoorTests.aFolderDroppedOnASoloedShelfLandsOnThatShelf`
  red at 5693f1ad (`shelf_id` nil), green at the door run (13 tests: F2 +
  F6 green, F3 + F7 still red as designed); new-API state test
  `DocumentImportOperationTests.aFolderImportedOntoAShelfLandsOnItAndADeadOrForeignShelfRefuses`
  (a dead and a foreign-wing shelf refuse, nothing minted). The four 13n-a
  suites 50/50.
- F3 (the receipt says "to the Pool" only for a still-bookless note) —
  DONE (this line's commit). Each `.note` landing carries `collectedBy` —
  the books holding it as a MEMBER after its tags ran, read in the same
  runner turn through `Queries.noteMemberships` (the membership truth the
  Pool reads); "to the Pool" only when empty, else "Imported “flying” —
  collected by “dream journal”". **Fix-round call FR-2 (copy edges, no
  product behavior):** two books read "“a” and “b”", three or more "“a”
  and N other books"; a multi-item gesture counts bookless notes "to the
  Pool" and collected ones "collected by “x”" (one book) or "collected by
  your books" (several), parts listed "a, b and c". Pin
  `aNoteCollectedByALivingBookIsNotSaidToLandInThePool` red at 5693f1ad
  (old text "Imported “flying” to the Pool · ⌥⌘Z undoes"), green at the
  door run (14 tests — F7's pin alone still red, as designed); the copy
  test `theReceiptsSayWhereEachNoteWent` added.
- F7 (a package directory is neither a chapter nor a file) — DONE (this
  line's commit). `readFolder` reads `.isPackageKey` and passes a package
  over (the walk already skipped its contents; the package itself had
  become an empty chapter named after it). Pin
  `aPackageInsideAFolderIsNeitherAChapterNorAFile` red at 5693f1ad (old
  text "… 1 note in 1 chapter …", one section), green at the door run:
  `DocumentImportDoorTests` 14/14, 0 failures. **Known limit, recorded:**
  a package INSIDE a folder is ignored — its text never imports (an
  `.rtfd` is not a document the door reads; a `.textbundle`'s Markdown
  would need the package opened). **Seen, NOT fixed (outside F7's
  letter):** a package handed to the door ITSELF (dropped on the Bookcase;
  the panel does not offer one) is a directory to `plan(_:)` and walks as a
  folder — a `.textbundle` would land as a book named "x.textbundle" with
  its `text.md` as a note. Returned to the orchestrator.
- F8 (`CopyForAI` moves to the shared home) — DONE (this line's commit).
  `CopyForAI` moved byte for byte from `Features/Import/DocumentImporter.swift`
  to `Core/Views/CopyForAI.swift` (the Mac shared home, beside
  `RemoveFromBook` — three features consume it: `CommitBar`,
  `TakesBottomBar`, `ShellActions`); its two sentences moved with it, from
  `DocumentImportCopy` to `CopyForAI`'s own statics (same names, same
  strings — the only two reference lines inside the body changed to
  match). Parity: zero test edits; `DocumentImportDoorTests` +
  `CapabilityRegistryTests` (the registry walk) 43/43, 0 failures.
- F5 (the round-trip claims state their exact domain) — DONE (this
  line's commit; wording only, zero behavior). `VariorumDocument`'s type
  doc comment now states what round-trips exactly — block texts, fan
  membership, the alternates' texts in fan order with their labels,
  stored spacing — and what does NOT in v1: the chosen take's label, its
  fan place, the chosen ≠ default split (a re-imported chosen take is
  first, unlabeled, the default), locked/archived states, plus the three
  byte-level corners; "any export re-imports whole" reads "re-imports —
  never refused, every take arriving". The closeout proposals above carry
  the same domain for any canon sentence, the new PROVISIONALs
  P-13na-6/7, and the three PROPOSED QUESTIONS lines (F4, F5, F2 — not
  written to `notes/QUESTIONS.md`; her merge's ledger). The architect's
  ruling text R-ARCH-13na-1 ("ROWS round-trip") is the orchestrator's and
  is left as written; the closeout proposal now governs any canon line.
- **Finals — DONE (this line's commit), all at the END, on the tree at
  `5c891581` (the record commit changes no code):**
  - **core, the four 13n-a suites** (`VariorumDocumentTests`,
    `DocumentFormatRoundTripTests`, `DocumentImportOperationTests`,
    `SampleBookDrillTests`, anchored filter): **50 tests / 4 suites, all
    passed, 0 skipped** (was 42: +8 — F1 1, F4 4 net (one superseded test
    renamed), F9 1, F6 1, F2 1).
  - **core, the export suites + the paste road** (the fix pass's twelve,
    anchored): **143 tests / 12 suites, all passed, 0 skipped** —
    unchanged, as the export and the bulk rule are untouched.
  - **Mac, focused** (stage claimed 05:56, renewed, released 06:09):
    `DocumentImportDoorTests` + `CapabilityRegistryTests` (the registry
    walk — `CopyForAI` moved, `ShelfView`'s drop changed) +
    `BookcaseViewModelTests` (the board the drop sits on): **"Test run
    with 48 tests in 3 suites passed"** (14 + 29 + 5), no skipped line,
    `** TEST SUCCEEDED **`. Per-fix door runs between: red 13/9-green at
    `5693f1ad`; after F2 (F2 + F6 green); after F3 (14, F7 alone red);
    after F7 14/14; after F8 43/43 with the registry walk.
  - Zero `Sources/VariorumCore/Sync/` lines; no schema, no migration,
    marker untouched; no editor-seam file touched.

## THE IMPLEMENTER BRIEF (self-contained; the spawn names this section)

You are the 13n-a implementer — `opus-implementer`, ONE acceptance unit,
working tree `~/dev/variorum-vx-117` (branch `vx-117-13n-a`; run
EVERYTHING from this absolute path, never the main checkout). Read, in
full, before any code: this plan file top to bottom (it is self-contained);
`notes/plans/phase-13n-sitting-record-2026-10-09.md` (R-13n-1…11 — the
rulings you build to); `notes/SessionResiliencyProtocol.md` (binding: the
checkpoint protocol — commit per coherent piece, push after every commit,
LIVE STATUS from the first commit, synchronous foreground waits only, no
subagents); the mockups' §8 for the format sample
(`notes/plans/13n-sitting-mockups/mcp-door-mockups.html`). The format's
authoritative existing half is `Sources/VariorumCore/Queries/Export.swift`
(the Alternates section + the join rules) — your serializer MUST reuse or
byte-match it, and the round-trip pins prove it. Build the deliverables in
this plan's "What this phase builds" exactly; honor "What this phase must
NOT touch"; the acceptance section names your evidence. Commit messages:
sentence case, stating mechanism and pin where a fix lands, ending
`Part of VX-117`; NO attribution trailers of any kind. Tests at the END of
the unit, never a full-suite start. Stage claims for every Mac
`xcodebuild test` run and for the walk (`Tools/stage claim` — hold it,
renew it, release it). The live round's captures land in a gitignored dir;
the record's walk section lists them. Where the plan leaves an implementer
call (named in "Open items"), decide it, record it in the UNIT RECORD with
one line of reasoning; where you hit a PRODUCT-flavored fork the plan does
not answer, STOP that half and return the fork to the orchestrator with
your proposal (the architect rules; the rest of the unit continues).

## ARCHITECT RULINGS ON THE RETURNED FORKS (Fable, 2026-10-09 overnight — PROVISIONAL under her mandate "rule and build provisionally"; each is hers to keep or reverse in the morning)

- **R-ARCH-13na-1 (FORK-A + FORK-B — one root): the format parses with the
  INVERSE-JOIN reading, superseding this plan's own "standing bulk rule"
  LETTER for the FORMAT only.** A blank line separates blocks; a SINGLE
  newline is content inside its block (I4's spirit: internal newlines are
  content); k ≥ 3 newlines store k−1 as the first block's trailing spacing
  (the exact inverse of `joinRenderedTexts`). What this buys, against the
  as-built bulk reading: ROWS round-trip (an export re-imports to the same
  store shape, spaced and unspaced alike), hard-wrapped files — Gutenberg
  novels, old txt, exactly her Percy Jackson case — import as whole
  paragraphs instead of one block per line, and LLM Markdown (soft-wrap
  semantics) reads correctly. Paste and every other entry road are
  UNTOUCHED — the format is a grammar with a defined inverse, not a paste.
  The plan's letter was written before the implementer surfaced the
  row-shape consequence; R-13n-8's round-trip spirit outranks it. Evidence
  owed: row-identical round-trip pins (spaced AND unspaced), a hard-wrap
  fixture pin (one paragraph, many lines → ONE block), the existing
  byte-identity pins staying green.
- **R-ARCH-13na-2 (FORK-C): the paragraph-less Alternates section is LEGAL
  and mints a block whose chosen take is empty** — the exact store shape
  that exports it (a fanned block with a blank chosen take; I10 satisfied —
  live takes exist). The invariant bought and pinned: **any export
  re-imports whole** (the fail-honest refusals keep covering unterminated
  and garbled sections; only this export-producible shape stops refusing).
- **R-ARCH-13na-3 (FORK-D): deferred by ticket — VX-118** (Backlog, project
  13n): the Library and scraps drops route their FILES through
  `DocumentImporter`. Deferral with a named owner, not vagueness.
- **IC-1…16 adopted; P-13na-1…5 adopted as built**, all PROVISIONAL to her
  morning bundle (the QUESTIONS entry lands at HER merge, per the
  refresh-not-merge order).

## THE WALK VERDICT + ANOMALY DISPOSITIONS (orchestrator look-pass, 2026-10-09 morning — her ask: "make sure it LOOKS good")

**Verdict: the surfaces are GOOD.** The imported book reads native and calm
in both voices (W1 captures); Lenses' PT|EN columns are the mockup's
promise delivered (w2-lenses-pt-en-side-by-side-*); the fan is clean, the
unlabeled take keeps its line breaks; the drop outline lights only where
the drop acts; W7's refusal copy is exemplary (folder, file, both lines).
No surface clutter. Every defect lives in the STATUS seam or a stale-view
class. Dispositions:

- **WA-1 (W1) — FIX IN-UNIT.** The import receipt lands in the book
  navigator's NARROW bottom bar and truncates in both voices (counts and
  ⌥⌘Z never show; not visible to Accessibility). The quiet receipt belongs
  on the window's MAIN bottom bar's trailing end (the one status seam);
  P-8's lineLimit law applies either way.
- **WA-2 (W5) — FIX IN-UNIT, copy ruling (PROVISIONAL, 13s-a re-voices):**
  the Copy-for-AI receipt shortens to **"Copied for AI."** — the current
  sentence truncates in Terminal; receipts say what happened, teaching
  lives elsewhere.
- **WA-3 (W3) — FIX IN-UNIT IF THE MECHANISM IS THE EXISTING ROAD, else
  ticket.** Undoing an import leaves an open note's pane live on the dead
  note (and in the Open strip). A synced tombstone of an open note must
  already close/park panes somewhere — find THAT road and route the undo's
  tombstones through it; pin on the import-undo path. If no such road
  exists (a pre-existing class for every remote deletion), TICKET it with
  the trace and do not improvise one overnight-style.
- **WA-4 (W4) — TRACE, THEN FIX OR TICKET.** Redo doesn't refresh an
  on-screen Library (rows appear only on re-enter). First check whether
  Put back from the Trash refreshes a live Library — if IT also fails,
  this is a pre-existing revival-observation class: ticket with the trace.
  If Put back works, find what the redo road misses and fix with a pin.
- **WA-5 (W7) — TICKETED, VX-121.** The refusal toast covers the Bookcase
  quick-entry box — a toast-PLACEMENT class (any toast there collides),
  pre-existing shape surfaced by the new door.
- **WA-6 (Trash busy) — TRACE with a TIME-BOX.** An undone import shows a
  book row ("and 4 notes") AND four separate note rows; the
  deleteReadingWithNotes idiom reads as one row. Stamps DO match (the
  inverse writes one stamp), so find what the Trash grouping actually keys
  on; fix if one honest line, else ticket with the trace.
- **WA-7 (Welcome shelf) — RECORD + her bundle.** The drop onto a solo'd
  Welcome lands the book there BY CONSTRUCTION of P-13na-6 (the drop
  passes the same mintShelfID as + New Book, so it matches the standing
  context-mint behavior exactly). Whether Welcome should refuse context
  mints GENERALLY is a standing design question for her, not this unit's.
- **WA-8 (unlabeled take reads "choose") — RECORD.** The fan's standing
  idiom for unlabeled takes, not this unit's; her bundle carries the line.
- The W2 script wording ("pick existing takes" vs the real "arrange
  existing takes") was the walk script's error, not the app's.

### WALK-FIX PASS — LIVE STATUS (walk-anomaly implementer, `opus-implementer`, 2026-10-09)

- **NOT DONE BY THIS PASS (first):** no GUI walk (the orchestrator re-walks);
  WA-5/7/8 are not this pass's (ticketed / her bundle). PENDING items below.
- Scope: WA-1, WA-2 (fix in-unit), WA-3, WA-4 (trace first: fix only on an
  existing road, else ticket), WA-6 (30-minute time-box). No revert in flight.
- WA-1 — IN-PROGRESS (trace).
- WA-2 — NOT-STARTED.
- WA-3 — NOT-STARTED (trace).
- WA-4 — NOT-STARTED (trace).
- WA-6 — NOT-STARTED (time-boxed trace).
- Finals — PENDING.
