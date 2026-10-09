# 13n-b design memo — the WIRE DOCUMENT (the structured shape beside the text format)

**Status: DRAFT FOR HER RULINGS — written 2026-10-09 at her ask** (*"I feel
like the design is suffering for using an incomplete format as the basis
for the mcp - what design gaps are there when we consider that?"*). The
P-5 friction doctrine applied: three U2 forks (AF-5/6/7) and two of her
corrections (R-13nb-9/10) in one sitting all orbit the same seam, so the
seam gets a memo before U3 builds on it. Binding context: R-13n-8 (the
text format IS the import/export form; 13m's edition shares bones),
R-13nb-7…10, AF-5, P-13n-4/P-13nb-4.

## 1. The diagnosis

The Level 0 format was built as a DOCUMENT INTERCHANGE form: round-trip,
human- and LLM-authorable, id-free, deliberately lossy (a file is coarse,
not forensic). The MCP door also needs a LIVE WORKSPACE view: addressable
(ids), full-fidelity (everything the live note knows), ephemeral (ids go
stale under her structural ops — her R-13nb-9 words: *"even just a merge
changes the id, so it's better live"*), revalidated per call. One shape
cannot be both — a file's ids rot; a workspace without ids can't be
written into. The forks were the two layers separating.

**The doctrine this memo fixes:** TWO first-class shapes, each with a
stated fidelity contract.

- **The text format (Level 0)** — the DOCUMENT: interchange, import,
  export, clipboard. Carries prose + fan + tags. Stays byte-pinned,
  id-free, R-13n-8 untouched. Its gaps are FILE-FORMAT questions and
  belong to 13m/v2, never patched ad hoc for the wire.
- **The wire document** — the WORKSPACE: what `read_note` answers when a
  structured view is asked for (today's `with_ids`), and the addressing
  vocabulary every write tool uses. JSON, full-fidelity, live-only. Its
  gaps are THIS PHASE's and are closed by spec'ing the shape once, below.

## 2. The wire document's shape (the spec U3 builds against)

```
{ note_id, title, entry_date?, book_contexts: [{reading_id, name,
    section_id?, section_name?}]?,            // G-1, if ruled in
  blocks: [ { block_id, name?, text,          // text = the SHOWN take,
                                              // internal newlines intact
      takes: [ { take_id, label?, chosen, locked, text,
                 commits?: [{commit_id, kind, message?, created_at,
                             text?}] } ],     // only under with_commits
                                              // (R-13nb-7); text omitted
                                              // in list form, asked per
                                              // commit if large — P1
      comments: [ { comment_id, text, created_at } ] } ] }
```

Contract lines: ids are REAL row UUIDs, live-only, revalidated per call
(AF-5, R-13nb-9); the same fence/decide filter as the text form, pinned;
active takes only (archived takes deliberately absent — the app's own
read posture); `locked` carried so the U3 edit rung refuses predictably
rather than by surprise; cost ∝ the note (+ the asked commits), P1.

## 3. The gap enumeration (her question answered whole)

**Tier A — already closed by the two-layer split (the pattern named):**
ids/addressing (AF-5) · block names carried (R-13nb-8) · commits by
explicit ask on read (R-13nb-7) and search (R-13nb-10) · ids-never-in-
files (R-13nb-9).

**Tier B — open gaps in THIS phase's path, with dispositions:**

- **G-1 — CHAPTERS are unreachable on the connected road.** The ruled
  lean set has no section vocabulary, yet R-13n-8's own sentence says
  structure travels "through TOOLS (create_book, sections, rules)", and
  her tutor use case (build lessons in a book) wants chapter placement.
  Read side: neither list_notes nor the wire document says which chapter
  holds a note. OPTIONS: **(a) RECOMMENDED** — list_notes/wire document
  carry section facts; write-new gains `create_section` +
  `add_note_to_book` gaining an optional section arg (two small tools'
  worth, U3; curated books only, the app's own refusals). (b) defer
  whole to a post-launch ticket (the file road's folder=chapters is the
  only chapter door). (c) read-only: section facts carried, no write.
- **G-2 — WRITE FIDELITY is below READ fidelity.** `create_note` /
  `import_document` take the TEXT format, so an agent that reads at
  wire-document fidelity authors back at Level 0 fidelity: no
  multi-paragraph blocks (P-13nb-4), no block names, no comments, no
  chosen-take label. OPTIONS: **(a) RECOMMENDED** — `create_note`
  accepts EITHER payload: the text format (unchanged) OR a wire-document
  subset ({title?, blocks:[{text (may be multi-paragraph), name?,
  takes:[{label?, text}]}]}) minted through the same ordinary ops; the
  FILE door stays text-only (R-13n-8 untouched). Lands U3. (b) v1 stays
  text-only; the create-then-merge workaround (merge joins with a
  newline) is the recorded road to multi-paragraph blocks. Either way
  `import_document` stays text-only — it is BY DEFINITION the file
  format's door.
- **G-3 — COMMENTS are invisible in the text read.** The text format
  never carried comments, yet the suggest rung WRITES them — an agent on
  the default read can't see the margin notes it or she left. The wire
  document carries them (already in AF-5's shape). DISPOSITION
  (recommended): accepted asymmetry, stated in the tool description
  ("comments ride the structured view"); comments-in-the-FILE is a
  13m/v2 format question, not the wire's.
- **G-4 — note metadata the wire omits:** `floating_notes` (her
  free-floating note text — real content an agent can't see),
  entry_date (read-only context), word targets. OPTIONS: (a) carry
  floating_notes + entry_date read-only in the wire document (one field
  each, U3); **(b) RECOMMENDED for v1 lean-ness** — omit; a ticket
  records floating_notes as the one real content omission, hers to pull
  in at a word.

**Tier C — RETIRED AS A FRAME (R-13nb-14, her ruling striking it: "The
MCP should be as useful as the user at the keyboard … the bar for AI is
higher" than the file's). The list below stands only as the INVENTORY
the format-schema sitting now designs carriage for — within grant and
rung, the wire exposes the full model; an exclusion needs affirmative
justification. Named IN by R-13nb-14: take ancestry, whole-note
Versions, lineage, the tray. Named OUT at her own word: block-level
tags (underbaked — VX-128). Archived reach + the file-side carriage:
the sitting's option sets. Original list, kept as the inventory:** lineage edges (coarse-not-forensic; a
view, not wire data) · whole-note Versions (app-only by design,
version rows are fenced everywhere) · presentations/callout frames
(rendering vocabulary; 13m's format question) · block-level tags (the
pool's tool, no AI use case yet) · the archived search facet (UI-only
until her word — R-13nb-10's note) · take branch ancestry
(parent_variant_id — forensic-adjacent, out) · multi-paragraph blocks in
the TEXT format (P-13nb-4 stands; the file question is 13m's).

## 4. What this memo does NOT reopen

The lean tool set's five read tools (the wire document is read_note's
view, not a sixth tool — AF-5's reasoning stands); the text format's
byte-pinned round trip; R-13n-8's two-form split (file now, edition at
13m); the grant grammar; the fence.

## 5. Her rulings (landed 2026-10-09 — R-13nb-11/12/13 in the plan's sitting record)

1. G-1 chapters: **(a) READ + WRITE, ruled** — U3.
2. G-2 write fidelity: **(a) EITHER payload on create_note, ruled** — U3;
   file doors (import_document included) stay text-only.
3. G-4: **omit + ticket, ruled** — VX-127 (floating_notes is faceless;
   face-or-retire is hers).
4. Tier C: pending her one word — and RESHAPED by R-13nb-13: the
   FILE-side items (the boundary marker, comments/commits/names/callouts
   in files) move into the pulled-forward FORMAT-SCHEMA sitting if she
   picks it; the WIRE-side exclusions (lineage edges, Versions, take
   ancestry, block tags, archived facet UI-only) stand for ratification
   as wire decisions.

## 6. The pulled-forward format sitting (R-13nb-13 — her call on shape)

Her words: the data must not be contorted to the limited markdown
import/export model; the variorum FILE FORMAT design may pull forward
"even if it's just the design sitting without building it." The
architect's proposed shape: a NARROW format-SCHEMA sitting (prep doc +
option sets, the 13n sitting's form) scoped to THE DATA SHAPE ONLY —
entities and fidelity (blocks with REAL boundaries, takes, commits,
comments, names, callout frames), the id policy (R-13nb-9: ids live,
files careful), and what rides file vs wire — producing ONE schema with
TWO serializations: the 13n-b wire document (built now) and 13m's file
edition (built at 13m, sharing bones by construction, R-13n-8's own
promise). 13m keeps sharing/publishing/rendering. SCOPE GROWN by
R-13nb-14 (the keyboard bar): the schema also carries whole-note
VERSIONS (list/read + the write side's rung), LINEAGE edges, take
ANCESTRY, THE TRAY (deleted things + Put back's rung), and ARCHIVED
reach (notes · takes · books — each an option set); the prep carries a
STAGED delivery proposal (U3-pre-launch vs follow-on effort) for her
cut. SCOPE GROWN AGAIN by R-13nb-15 (carriage settings, her direction):
the FILE side is parameterized by CARRIAGE PROFILES — the dial set
(trash · unplaced blocks · commits · comments · names · versions · …),
opinionated per-format defaults, remembered preferences, optionally
NAMED audience sets — plus the export TAXONOMY (the Level 0 text · the
no-lock-in plaintext export · the 13x sealed pair · 13m's edition, one
job each) and the profile-storage shape (named sets carry user prose;
the `setting` table's no-prose promise forbids that home — a small
synced table with encrypted names, or local-only; the sitting rules
it). The WIRE stays profile-free: rungs and grants are its only dials
(R-13nb-14). Timing: the sitting prep lands before U3's brief so U3
builds the wire serialization against the ruled schema.
