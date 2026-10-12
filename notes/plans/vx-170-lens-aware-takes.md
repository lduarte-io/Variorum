# VX-170 — lens-aware Takes · VX-171 — hidden-in-lens · the design record

**Tickets · VX-170 (lens-aware Takes filters) + VX-171 (a lens cannot blank a block) + VX-172 (read_note through a lens, already Todo in the 13n project) · no branch of their own — members of tonight's 13n-c pass (VX-165), her scheduling word 2026-10-11: the U8 pass with the other MCP items, never the currently in-flight unit.** Born at the 2026-10-11 MCP editorial session (a Claude session working her readme draft through the door); ruled by her the same day in that session's question round. The PROVISIONALs are logged at `notes/QUESTIONS.md` #211. The tickets point here; this file is the record.

## Her rulings (2026-10-11)

- **R-VX170-1 — the grammar is FOUR forms** (she chose the stronger set over the recommended three): `in <lens>` · `in <lens>, not in <lens>` (the first names a take on the block, the second names none) · `<lens> disagrees with <lens>` (both name takes, different ones) · `<lens> disagrees with the chosen takes`. Arbitrary boolean trees deferred.
- **R-VX170-2 — non-matching blocks stay as collapsed one-line rows.** The note's map stays whole, counts stay honest, and a zero-match filter says so in place — no empty room, no false offer.
- **R-VX170-3 — a matching block expands the filter-named take(s) plus the chosen take for contrast**; the rest of the fan stays behind its usual control.
- **R-VX170-4 — the control is a masthead `show ▾` popover** (the order-menu/census masthead-popover idiom), resting as "all takes", wearing a quiet chip while a filter is active.
- **R-VX170-5 — persistence is session-only, per note** (the Takes-row-memory precedent): survives mode flips within the session, resets on the next open.
- **R-VX171-1 — hidden-in-lens is a per-lens HIDDEN mark on the lens choice**, not a legal empty take: empty/whitespace takes stay illegal everywhere; the Lenses editing surface shows a ghost row for a hidden block; every lens READ — the Mac's lens rendering and VX-172's `read_note` through a lens alike — skips the block whole (no blank paragraph). Ruled to ride tonight — **subject to the LOCKSTEP CATCH below, checked after her ruling.**
- **R-MERGE-1 — the door's merge button is APPROVED at the edit rung**: `choose_take` (per block) + apply-lens-as-chosen (wholesale — the human gesture "make this lens the note" already exists), each one undo entry, edit rung only. Ticket minted (VX-174); NOT tonight's scope unless her word adds it.

## THE LOCKSTEP CATCH (checked 2026-10-11 against `Persistence/Migrations.swift:214`, after R-VX171-1 was ruled)

`lens_choice` is a **synced** table (the 11a addition) and `variant_id` is `TEXT NOT NULL`. Every hidden shape — nullable `variant_id` or a new `hidden` column — is therefore a synced schema change: **a SyncSpec §12 lockstep event** (the next migration on the marker it finds, its own commit before any code that uses it, a mirror artifact, the mirror deploy only on her explicit go, SyncSpec read in full by whoever builds it). The "small once ruled" sizing in the question round predated this check and was wrong.

**Consequence for tonight:** VX-170 (pure Takes-surface UI, zero schema) and VX-172 (read-only door addition, zero schema) ride freely. **VX-171 rides tonight only if she gives the lockstep go explicitly**; absent that word, its shape stands ratified here and the build takes its own small window. Tonight's orchestrator: do not improvise a local-only side table to dodge the lockstep — hidden marks are lens semantics and must sync with the lens, or a lens reads differently per device.

## The design

**The control.** Takes masthead, `show ▾`, a popover listing the four forms with lens pickers inline (a note's saved lenses; "the chosen takes" as the fixed second operand of the last form). Resting label "all takes"; active label the expression in words (e.g. "show: claude's cut disagrees with chosen"); a quiet chip marks the filtered state. Clearing is the first row ("all takes").

**Semantics.** Per block, a lens contributes one fact: it names a take there or it doesn't. `in X` ⇔ X names a take on the block. `in A, not in B` ⇔ A names one, B names none. `X disagrees with Y` ⇔ both name takes and they differ. `X disagrees with the chosen takes` ⇔ X names a take ≠ the block's rendered/chosen take. **A hidden mark (once VX-171 exists) counts as naming NOTHING** for every form — it cannot satisfy `in X` and cannot disagree (PROVISIONAL P-VX170-1, #211 — mine, hers to reverse).

**Rendering.** Non-matching blocks: the collapsed one-line row (first-line excerpt, the fan count). Matching blocks: expanded per R-VX170-3, the existing Takes idioms untouched (tinted cards, "✓ chosen", one live-editor ring). Zero matches: one honest muted line in place ("no blocks match — X and Y agree everywhere" in the disagree forms' case). Filter state never changes what any take IS — it is a view, cost ∝ matches (P1).

**Persistence.** A view-local, per-note, session-only memory beside the Takes row memory; never synced, never a setting.

**VX-171's shape** (build per the lockstep catch): the hidden mark lives on the lens choice row; `save_lens` (door) and the Lenses surface (Mac) gain a way to express it; the ghost row in Lenses editing is the visible truth; lens reads skip the block. The uniqueness rule (`uq_lens_choice_live` on lens_id + block_id) is untouched — hidden is a state of the one choice row, never a second row.

**VX-172's adjacency** (its own ticket, already Todo): `read_note` with `lens_id` returns the note as that lens renders it — per block the lens take, else the chosen take; in the `with_ids` form each block says `via: lens | chosen`; once VX-171 lands, hidden blocks are absent from the render (and say `via: hidden` in the with_ids form only).

## Non-goals (tonight)

Boolean expression trees · filtering by take author/client label · any Lenses-surface redesign · VX-173 (batch take-adding, Parked) · VX-174 (the merge button — approved, minted, unscheduled) · any change to what lenses ARE on the store beyond VX-171's one mark.

## Acceptance (the unit shapes)

- **VX-170:** view-model tests over a fanned fixture for all four forms (incl. the hidden-counts-as-nothing rule once applicable), the collapsed/expanded split, session-memory reset, zero-match honesty; one use-shaped walk on a real multi-lens note (the readme-review notes in her store are the natural fixture).
- **VX-172:** door tests — the lens render matches the Mac's lens read byte-for-byte on the same fixture; `via` markers correct; a dangling/foreign `lens_id` refuses with the uniform not-shared shape (no oracle).
- **VX-171 (only on her lockstep go):** the migration in its own commit; convergence tests per the standing rule (no sync change unreviewed without one); ghost-row and skip-everywhere behavior pinned; the door's hidden expression.
