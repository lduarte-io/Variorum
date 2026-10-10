# The format-schema sitting — PREP (pulled forward from 13m at her word)

**Status: PREP FOR HER SITTING — written 2026-10-09 by the 13n-b
orchestrator.** The ruling that opened it: **R-13nb-13** (*"we should NOT
be contorting the variorum data to fit this limited markdown import /
export model. If we need to pull forward the variorum file format design
to do this stage properly, we can do that. even if it's just the design
sitting without building it."*) — shape picked by her: the NARROW
schema sitting. Binding context carried whole:
`notes/plans/phase-13nb-memo-wire-document.md` (the two-layer doctrine),
the 13n-b sitting record R-13nb-1…19, R-13n-8 (the text format is the
import/export form; 13m shares bones). **What this sitting produces:**
ONE ruled schema — the variorum document's data shape — with TWO
serializations (the 13n-b WIRE document, built now; 13m's FILE edition,
built at 13m), the carriage-profile design, and the staged launch cut.
**What it does NOT reopen:** the grant grammar (four rungs confirmed),
the fence, note-level access (durable), ids-live (R-13nb-9), the undo
stack (firm, R-13nb-19), the export pin (files mint, never reconcile).

## 1. The constraint set (already ruled — the sitting designs INSIDE these)

- **The keyboard bar (R-13nb-14):** within grant and rung the wire
  exposes the full model; exclusions need affirmative justification.
- **The rung is the only read dial (R-13nb-17):** uniform reach per
  rung; per-call parameters are call shapes, never configuration; NO
  grant-side carriage knobs, ever.
- **Carriage profiles are FILE-side only (R-13nb-15):** dials +
  opinionated per-format defaults + remembered preferences + optional
  named audience sets.
- **Ids are live (R-13nb-9):** the wire carries row UUIDs revalidated
  per call; a FILE carries ids only if the sitting rules a careful
  scheme (default lean: it doesn't — "even just a merge changes the id").
- **All on the plan (R-13nb-16):** every carriage named; the launch cut
  hers; the remainder = named tickets.

## 2. THE INVENTORY — entity by entity (the sitting's spine)

For each: what the WIRE carries (keyboard bar default), what the FILE
EDITION may carry (a dial), what the LEVEL 0 TEXT carries (mostly
fixed). ✔ = already ruled/built · ○ = sitting rules it.

| Entity | Wire (keyboard bar) | Edition file (dial) | Level 0 text |
|---|---|---|---|
| Note identity, title | ✔ carried | ✔ carried | ✔ `{t:"…"}` |
| entry_date | ○ read-only field (cheap) | ○ dial | out (13m may add) |
| Blocks: order + REAL boundaries | ✔ wire doc | ✔ (the format's point) | **○ THE BOUNDARY MARKER — §3** |
| Block names | ✔ carried (R-13nb-8) | ○ dial, default on | out |
| Callout frames (presentation) | ○ carry read-only (cheap) | ○ dial | out (blockquote transform only) |
| Takes: text, label, chosen, locked | ✔ wire doc (+locked) | ○ dial, default on | ✔ Alternates (label; chosen positional; locked out) |
| Take ancestry (parent tree) | ○ IN per R-13nb-14 — one field | ○ dial, default off? | out |
| Archived takes | ○ explicit param (the app's own kept-but-out-of-view posture) | ○ dial | out |
| Commits (savepoints) | ✔ with_commits / include_commits (R-13nb-7/10) | ○ dial ("history comes along?") | out — history is lived (R-13n-8) |
| Comments (live) | ✔ wire doc | ○ dial, default on | out (13m question) |
| Deleted comments | ○ follow the tray's answer | ○ dial, default off | out |
| THE TRAY (deleted blocks/takes) | ○ IN per R-13nb-14 — read + Put back's rung | ○ dial, default OFF (her lean: "your trash isn't carried over… maybe") | out |
| Whole-note VERSIONS | ○ IN per R-13nb-14 — list/read; save_version = write-new (R-13nb-18); restore/promote = ○ (edit rung? ask-only? never?) | ○ dial ("editions of the document") | out |
| Lineage edges | ○ IN per R-13nb-14 — read-only edge list | ○ dial, default off | out |
| Note tags | ✔ carried + apply_tag | ✔ carried | ✔ `{#path}` |
| Block tags | OUT (underbaked, her word — VX-128) | out | out |
| floating_notes | OUT (faceless — VX-127) | out until faced | out |
| Books: chapters | ✔ read+write (R-13nb-11) | ✔ (folders=chapters today; edition = real sections) | n/a (folder road) |
| Books: rule/outflow/extents/trait | ○ read? write? (the tutor builds books — rule-setting is power; refusals exist) | ○ dial | out (R-13n-8 stands) |
| Archived notes/books reach | ○ explicit param mirroring the app's facet posture | ○ dial | out |
| Lenses | ○ list/read (save_lens exists; keyboard users read lenses) | ○ dial, default off | out |
| References | ○ list names/URLs only (file bookmarks NEVER — local-only security scope) | ○ names/URLs dial | out |
| Wings | scope fact only (grants already wing-scoped) | out (a file is one book/note) | out |
| Canvas layouts | out (Debug-only surface in Release — 17y) | out | out |

## 3. THE BOUNDARY MARKER (P-13nb-4's resolution — the file's one grammar change)

The in-place chosen text cannot say "this paragraph break is inside a
block." Options for the EDITION (and optionally Level 0 — one grammar,
her call):
- **(a) RECOMMENDED — an explicit block-separator line** (e.g. a lone
  `⁂` or `---` variant chosen to survive hard-wrapping and never
  collide with prose): paragraph breaks inside a block stay bare blank
  lines; block boundaries get the marker. Reads cleanly, authors
  cleanly by hand or LLM, round-trips exactly. Cost: the marker must be
  escaped if her prose ever IS that line (fail-honest refuse or escape).
- **(b) Indent/fence multi-paragraph blocks only** (delimited like
  Alternates): no change for the common case; multi-paragraph blocks
  wrap in a fence. Cost: two block syntaxes.
- **(c) Edition-only solution; Level 0 stays as-is** (P-13nb-4 stands
  for text; the structured create_note covers AI). Least change;
  the clipboard form keeps the limit.
A format-version token in the header rides any grammar change (the
capture-token header exists; one more braced token versions the file).

## 4. CARRIAGE PROFILES (R-13nb-15 — the file-side design)

- **The dial set (proposal):** takes (all vs chosen-only) · take labels
  · locked flags · commits · comments · deleted comments · block names
  · callout frames · lineage · ancestry · versions · the tray ·
  entry_date · book settings (rule/outflow/extents). Each dial a
  carriage, never a meaning change.
- **Defaults (proposal, hers):** Level 0 text = TODAY'S EXACT SHAPE
  (compat — prose + fan + tags; byte-pinned); the EDITION = everything
  except the tray and deleted comments; "share with an AI chat" named
  set = edition minus versions/lineage (lean context).
- **Named sets:** v1 or later — ○. If v1: they are user prose, so NOT
  the `setting` table (the no-prose E2EE promise) — a small synced
  table (name encrypted; a §12 event) or LOCAL-ONLY (profiles as
  machine preference; no event). RECOMMENDED: local-only in v1 — zero
  lockstep, and a profile is arguably a device-side authoring
  preference; revisit if she misses them across Macs.
- **The manifest line:** every exported file says what it carried (one
  header token) — "no commits here" means not-carried, never
  none-existed. Import stays mint-only (the export pin).

## 5. THE EXPORT TAXONOMY (named so each road has ONE job)

1. **Level 0 text** — interchange + clipboard (Copy full text) + the
   wire's file door (`import_document`). Lossy by design; profiles
   apply narrowly (its default IS its identity).
2. **The plaintext no-lock-in export** — the whole store, open SQLite
   (EXISTS today; her "sqlite export format"). Definitionally
   everything; no profiles.
3. **The 13x sealed pair** — machine transfer with key custody.
   Whole by definition; no profiles.
4. **13m's EDITION** — the shareable full-fidelity DOCUMENT; where
   profiles chiefly live; shares the ruled schema's bones with the
   wire document by construction.

## 6. THE STAGED LAUNCH CUT (R-13nb-16 — proposal for her table)

**U3 as already assigned (ruled, unchanged):** edit rung (edit_take +
insurance brackets + expectedText + the F2-class in-transaction
re-decide guard), structural tools, with_commits + include_commits,
sections read+write, create_note either-payload, set_block_name,
Allow-AI-here, the activity face, list-scalability shapes, the walk +
her live round.

**Proposed ALSO-U3 (cheap, high-value, she named them):** the tray
(read + put_back on the edit rung) · versions (list/read +
save_version) · lineage + ancestry read fields (two JSON field
families) · archived reach (one explicit param each on list/search).

**Proposed NAMED FOLLOW-ON TICKETS (post-launch unless she pulls in):**
lenses list/read · references read · callout-frame carry · book
rule/outflow write tools (the tutor's full loop) · restore/promote
version via wire · deleted-comments read.

**Sizing honesty:** U3 with the also-U3 column is likely TWO
implementer sessions (U3a edit-rung core · U3b the keyboard-bar
carriage) — the phase grows from three ruled units to four at her
word, one session each, laddered as ever. The alternative keeping
three units pushes the also-U3 column into the follow-on tickets.

## 6b. NAVIGATION — the MCP moving the app for her (her question, 2026-10-09: "will it move them to the compare tab? and what about opening compare with the new version of the note next to the previous note?")

Today NOTHING navigates: writes land in rows, open panes update through
observations, the receipt speaks — but the lens does not open itself and
no tab moves. The design tension and its proposed resolution:

- **The keyboard bar argues FOR it** (the fact-check payoff IS seeing
  the side-by-side; a keyboard user opens the lens she just made) while
  **the calm doctrine argues for CONSENT** (an external process yanking
  panes mid-keystroke is focus theft, the cardinal sin).
- **Proposed shape, two layers:** (1) **OFFER, the default** — write
  receipts grow a one-press door ("saved the lens 'english readings' —
  Open ›"): the agent requests attention, she spends it; no grant
  change (showing discloses and modifies nothing). (2) **MOVE, her
  dial** — a `show_in_app(target)` tool that genuinely navigates
  (mechanically easy: the server lives in the app; the deep-link/
  LandingTarget machinery is the road; P-4 discipline — composition,
  never decision-bearing broadcasts), gated by etiquette she rules:
  only while the app is frontmost, never cross-app activation, maybe
  only within N seconds of her own last ask.
- **THE CEILING RULE (proposed as doctrine):** a navigation target must
  be a state the app's own doors reach — the wire never gets app states
  the keyboard lacks. Her Compare-with-versions example decomposes
  exactly here: Compare exists and versions have their pane, but
  "Compare preloaded with version X beside current" was not found as a
  one-press app state — if ruled wanted, it is an APP feature first
  (a good one), and the wire points at it for free afterwards.
- Targets inventory for the sitting: open note (at block) · open lens ·
  open Compare (takes) · open Compare (version beside current — needs
  the app state above) · open book/chapter · open the Versions pane.

## 7. The sitting's question list (the batches I will run)

1. §3 boundary marker: (a)/(b)/(c), and does Level 0 adopt it or
   edition-only?
2. §2's ○ rows: carriage per entity (the table walked once).
3. §4 dials + defaults ratified or amended; named sets v1/local vs
   later; the manifest line yes/no.
4. §6 the cut: also-U3 in or out; four units ratified or three kept;
   the follow-on ticket list named.
5. Versions' write side beyond save_version: restore/promote on the
   wire — edit rung, ask-only, or never-in-v1.
6. Book rule/outflow on the wire: read-only now, write at follow-on?
7. NAVIGATION (§6b): offer-only v1, or offer + the move dial? The
   etiquette gates; the ceiling rule ratified; Compare-with-versions as
   an app feature (its own ticket) — and which targets ship when.
