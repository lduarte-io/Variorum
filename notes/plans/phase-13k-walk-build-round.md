# Phase 13k — The Walk's Build Round (formatting ergonomics, cards & the bar)

**Status: ACTIVE from 2026-08-02 — opened by the AUTHOR HERSELF at the
tail of the 2026-08-01/02 housekeeping session** (the 9d/QoL
precedent, but at her explicit instruction with FULL phase
discipline): *"you can go ahead and /architect-phase on these items
that have accumulated this session … let's get these items done
though and then i'll kick off 13e. make sure to follow normal phase
rules - give yourself a phase name (like 13k or something, wherever
we are …) let's bring real phase discipline to these issues."*
The name is **13k** (13j exists — Deletion & the Trash; 13k is next
free).

**Cast (the recent standing shape, adopted unless she redirects):
Fable architect/orchestrator (the housekeeping session itself) · a
FRESH Opus implementer per batch · ONE Fable cold reviewer at phase
end, standard ladder.** The author is PRESENT for this phase's
sittings — it opened inside one.

**Baselines at open (13g's finals, verified by that phase's own
runs):** core 1001/110 · Mac 1139/197 (ONE recorded environment-gated
tripwire red on unlocked sessions — the `TakePaneMeasureTests` row in
KnownIssues; 13e owns its A47c re-run) · mobile 14/4 · tutorial spine
51/7.

**Scope guards, binding:** NO schema anywhere in this phase (every
row is faces / read-side projections / editor input / Domain
vocabulary — if any row turns out to want a schema change, STOP: that
is a SyncSpec §12 lockstep event and hers to authorize). Zero
`Sources/VariorumCore/Sync/` lines expected (the standing rider
routes any exception to Fable). `renderedText`, export BODY
projections, and the bridge's join brain stay byte-untouched except
where a row explicitly says otherwise (K1 touches DISPLAY-title
surfaces only — titles have never been body content).

**What is deliberately NOT here (stays 13e's):** W26 (the system-wide
quick-note hotkey — her deliberate slotting, "so that i'm sure to
land on it again"); the kickoff-sweep rows (windowless capture-first ·
note-window top-clip · the A47c tripwire); the E1 swatches/real-emoji-
picker work beyond the two riders pulled here; the 13e ledger proper
(A13(b), A17–A21). Fenced ``` code blocks stay WANTED-LATER
(recorded in the 13e plan; not scope here or there).

---

## The binding principles (the 13b constitution, copied verbatim per the `/architect-phase` skill; the skill's application notes bind by reference)

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

## Environment traps (bind by reference + the invariant core)

The 13c plan's "Environment traps" section binds VERBATIM, as every
phase, PLUS the two 13g standing rules: **never address a Variorum
instance by process name** (bundle id `io.lduarte.Variorum` /
`io.lduarte.Variorum.debug` or PID only — the batch-1 incident rule)
and **Mac test runs use the cwd-independent `-project` invocation**
from `App/Variorum/`, suite-level `-only-testing` only, always
confirming the "Test run with N tests" line. Instance checks:
`pgrep -fl 'Variorum.app/Contents/MacOS'` discriminating by PATH;
NEVER quit/kill a real-store instance; no Release builds or
`/Applications` refreshes while one lives; A1 backup before ANY
real-store touch; zsh `pipestatus`; never a custom build
configuration; never `git checkout` over uncommitted work; never
push. The known tripwire red (`TakePaneMeasureTests`, unlocked
sessions) is RECORDED at each acceptance, never papered over.

## THE KICKOFF RECORD (the housekeeping session, 2026-08-01/02)

The phase's rulings all landed in that session, recorded same-turn:

- **The #49–#52 walk** ran early and in full — verdicts verbatim in
  `notes/plans/phase-13e-takes-block-management.md`'s "THE WALK RAN
  EARLY" section and QUESTIONS.md's #49–#52 status lines. #49, #50
  ratified whole; #51/#52 rulings below became this phase's ledger.
- **Her closing rulings (2026-08-02, the kickoff message):** smart
  books SHOW on note cards (*"the number of specifically defined
  smart books you have is probably small, no? you still have to
  choose to deliberately create a smart book"*); pools show their
  created day (*"i think that would be helpful"*); `2026-08-01`
  format stands (*"easier to scan than august 1, 2026"*); tag cards
  *"should fold into the bar if you deliberately choose that but it
  should default to visible"*; chips *"should show leaf only"*;
  block-menu fire-and-speak *"is good i think"*.
- **Pulled from the 13e additions at her word** (*"maybe some of
  what's riding 13e should come in here as well … maybe even handle
  one of the 13e sittings we talked about but that ended with
  uncertainty"*): the context/nav bar bundle (the uncertainty-ended
  conversation — tags placement), the takes-callout rendering rider,
  and the code tint.

## THE LEDGER

| Row | Item (ruling, her words where quoted) | Batch | Status |
|-----|----------------------------------------|-------|--------|
| K1 | **The #52(a) retirement:** literal "Untitled" is a TITLE again — only a BLANK/nil title counts as no title; NO sweep (*"i can delete them or rename them myself"*); the ⌘N nil-mint half STANDS (new notes still store no title and show dates until named) | 1 | pending |
| K2 | **Nameless pools show their created day** (*"i think pools can show their created day, i think that would be helpful"*) — the `DisplayTitle` chain gains the pool's `created_at` local-day fallback; pools still have no `entry_date` | 1 | pending |
| K3 | **Tag chips display LEAF ONLY** (*"chips should show leaf only"*) — the #52(e) alternative as ruled: leaf shown, full path in the tooltip, color stays keyed on the WHOLE path (two different `…/goals` stay distinct colors) | 1 | pending |
| K4 | **Note cards show SMART-book membership too** — her ruling reverses the shipped curated-only #51(c). Mechanism is MEASUREMENT-FIRST under P1: smart books are few and deliberately created (her ground); bounded per-row evaluation (per-note tags + profile + entry_date vs each smart spec), measured at design-corpus scale with a corpus-scale guard (cap or async fill) if the numbers say so. **IN-BATCH PROPOSAL GATE:** the implementer proposes mechanism + measurements BEFORE wiring; the architect rules | 1 | pending |
| K5 | **⏎ list continuation:** ⏎ at the end of a texted list line mints the next lead (`- ` or `- [ ]`); ⏎ on an EMPTY list item removes the lead and exits the list. Ordinary edits through the ordinary input path — ⏎'s ratified STRUCTURAL semantics (open-tail at document end; one_block's newlines-don't-mint; A15's ⇧⏎) are byte-untouched: continuation only adds lead TEXT where the newline landed. Edges the build must pin: document-end open tail; one_block mode; sealed/locked refusal rides the edit path; ⌘Z ungroups cleanly (newline+lead undo together) | 1 | pending |
| K6 | **The right-click Callout door:** the editor context menu gains the Callout submenu beside Format (today it lives only in the menu-bar Block menu + ⌥⌘C; she went looking for it in the right-click — 2026-08-01). Registry-declared (P-1); same routed transform as every other door (13c R2-2's letter) | 1 | pending |
| K7 | **The formatting toolbar — BOTTOM BAR** (*"i think the formatting toolbar should be added to the bottom - if i decide it's too cluttered later i'll remove it then, i think other users would need it though"*): the seven formatting acts as visible buttons riding the bottom bar's standing two-group grammar; every button the SAME registry act as the menu (P-1 — no second brain) | 2 | pending |
| K8 | **Indented/nested lists — Tab indents** (*"we should allow indented lists and it should happen when you click tab"*): a vocabulary extension — the line-scoped tokenizer's column-0 rule widens to leading-space list lines (Domain: `MarkdownSyntax`/`MarkdownRendering`; face + Read rendering follow; display==stored holds byte-for-byte). UNINDENT door: ⇧Tab + Format ▸ Indent/Outdent rows PROPOSED to her (she knows ⌘[ is taken; she floated *"maybe if you click in it's an option?"*) — **ruling pending (sitting Q3)** | 2 | pending |
| K9 | **Callout frames RENDER in Take mode** (her 2026-08-01 instruction: *"callouts are supposed to be added to take mode as well"*) — today the frame draws only in Write's `BlockDecor` overlay; the setting door already routes from the boards (13c R2-2). Shape — one frame around the block's whole takes region vs per-card tint vs header badge — **ruling pending (sitting Q4)** | 2 | pending |
| K10 | **The code tint** (*"code blocks should have their own tint - i'll rule on that"* — inline `` `code` `` SPANS; fenced blocks are wanted-later, NOT here) — **ruling pending (sitting Q2)**; whatever she rules, the geometry stays visibly distinct from callout frames (span-hugging, never block-wide) | 2 | pending |
| K11 | **The context/nav bar redesign** (pulled from the 13e additions): ALWAYS the compact icon row — her screenshot: ← · book · ＃ · › — no spelled-out back chip, no collapse/grow (*"the collapsing and growing in that bar is a little annoying to me"*); the › chevron becomes a REAL forward door (⌘]'s face — *"after you just went back, i feel like you should be able to go forward"*); "in xyz book" becomes a BOOK ICON (click = the book when exactly one; *"command click on lets you see the list of books (or there's a dropdown if there's several books it could be in)"*); tags placement — **ruling pending (sitting Q1)** | 3 | pending |
| K12 | **Tag cards DEFAULT VISIBLE** (#52(d) flipped: *"tag cards should fold into the bar if you deliberately choose that but it should default to visible"*) — folding becomes a deliberate, sticky user choice, not the bar's default state; reconciled with K11 by the Q1 ruling | 3 | pending |

## Batch structure (one FRESH Opus implementer per batch, strictly sequential)

- **Batch 1 — the fully-ruled set: K1 K2 K3 K4 K5 K6.** No open
  rulings; K4 carries its in-batch proposal gate (propose → architect
  rules → wire). Brief: the ledger rows above ARE the brief, plus:
  K1/K2 live in the `DisplayTitle` brain (13g batch 7 — find via
  grep; every view + export surface consumes it; K1 additionally
  re-verifies the 13g export-heading tests against the new rule);
  K3 in the tag-chip face (13g batch 6/7); K4 in the Library list's
  card assembly (13g batch 6) + a Queries-side bounded read; K5 in
  the editor input path (TEXTKIT2_NOTES binds; the A15/⇧⏎ and
  idle-mint rulings are byte-sacred); K6 in
  `EditorTextView.menu(for:)` + the registry declaration. Every
  behavior change red-on-old; the spine rides every run.
- **Batch 2 — the ruling-gated formatting set: K7 K8 K9 K10.**
  Spawns only after sitting round 2's rulings land in this file.
- **Batch 3 — the bar: K11 K12.** Spawns after Q1's ruling; visual
  loop screenshots for her flick (propose-only on look details).
- **The ladder:** ONE cold review at phase end over the combined
  diff, fresh reviewer, `notes/REVIEW_PROMPT.md` verbatim, standard
  rounds/cap.

## SITTING RECORD

### Round 1 (2026-08-02, the kickoff — rulings recorded above)

All of "THE KICKOFF RECORD" is round 1; her verdicts are in the
ledger rows and the 13e plan's walk section. Recorded same-turn,
repo-first.

### Round 2 (pending — the question batch: Q1 tags/bar · Q2 code tint · Q3 unindent · Q4 takes-frame shape)

Asked at the kickoff sitting (she is present). Rulings land here
verbatim when she answers; batches 2–3 gate on them.

## Batch records

*(appended per batch by the implementer, verified by the architect —
counts by the architect's own runs at every acceptance)*
