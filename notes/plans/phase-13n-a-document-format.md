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
