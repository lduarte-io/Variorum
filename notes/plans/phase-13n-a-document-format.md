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

- STATE: IN-PROGRESS (implementer session 1, `opus-implementer`, started
  2026-10-09). No revert is in flight.
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
   — DONE (this commit; `VariorumDocumentTests` 17/17 green). The app's two
   delegations (`CaptureMicrosyntax.parse` → `CaptureTokens.parse`,
   `TypedTagPath.segments` → `TagPath.segments`) compile-check PENDING with
   piece 4's app build; their pins are the app's capture suites (run at the
   end, PENDING).
2. **Queries — one serializer.** `exportPost(includeVariants:)` re-expressed
   over `VariorumDocument.serializeBody` (the export becomes the
   serializer's client — byte-identity pinned by the existing export
   suites); `Queries.variorumDocument` + `copyForAIText` (header line +
   the export body). Round-trip pins (a) fanless (b) labeled+unlabeled fan
   (c) internal newlines in a take. — DONE (this commit;
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
   tests. — DONE (this commit; `DocumentImportOperationTests` 10/10 — exact
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
   — DONE (this commit). `Features/Import/DocumentImporter.swift` (read
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
   may drive the GUI until it is closed). DONE headless (this commit): the
   PT/EN fixture `notes/plans/13n-a-sample/o ladrão de raios/` (committed —
   original prose, two chapters, fanned blocks, one take with line breaks;
   her morning test can import it as-is) read from DISK the door's way,
   imported as one book, read through a lens per language, ONE undo takes
   the book + notes + lenses, ONE redo brings them back whole —
   `SampleBookDrillTests` 1/1.
6. **Close** — the named suites green at the end, every row dispositioned.
   — NOT-STARTED

### THE WALK (HELD — the steps, for whoever holds the stage once her app is closed)

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
- **W7 — a refusal names its line.** Copy the fixture, delete the
  `--- end alternates ---` line in `01 abertura.md`, import the copy: the
  refusal names the folder, the file and line 5; nothing lands.

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
