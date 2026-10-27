# VX-562 — Book Outline: the highlight follows your scroll, and the book's nav info pins up top

**STATUS: OPEN — kicked off 2026-10-27 (architect-phase, wave 2; coordinator `oct27coordinator`).**
Ticket: VX-562 (single ticket — Improvement · Confirmed · Books · High · Pre-launch; project "v1 release readiness") · Branch: `vx-562-outline-follow` · Worktree: `~/dev/variorum-vx-562` (the Pro).

**Her kickoff words (2026-10-27, verbatim):** *"VX-562 contact oct27coordinator for your walk + staging needs"* — the wave-2 shape: stage traffic through the coordinator only (REQUEST → READY → GO; never self-claim), no `/Applications` refresh and no release without her word, PROVISIONAL-and-continue with every question bundled for her morning.

**Her design rulings (already on the ticket, verbatim):**
- The follow rule (2026-10-26 planning session): the outline's highlighted chapter/note follows what you're VIEWING as you scroll — *"maybe not [highlight the one you're typing in], it just follows what your view is."* The caret is ignored.
- Pre-launch at her own written word (the 10-21 improvements note): *"make the note that you're currently on highlight on the left bar ABSOLUTELY pre launch."*
- The pin's content (same note): the navigation info (number of chapters and notes) stays fixed at the top while scrolling (a beta ask she liked), widened by *"show during scroll what # note you're in, maybe what chapter you're in."*
- Scope guard (the ticket): VX-300 keeps the editing-parity scope; this ticket is ONLY the two pieces above. Viewport→block→note mapping exists (block IDs ride the text), so cost stays viewport-proportional (P1).

**Cast:** Fable architect/orchestrator (this session) · `opus-implementer` (xhigh), fresh per batch · the cold reviewer decided by the diff at ladder time — `fable-reviewer` if the diff touches the editor seam / read tier internals (`EditorTextView`, `BlockRangeIndex`, `PaneSurface`, the one measurement brain), `opus-reviewer` if it stays in book-view chrome and a read-only geometry consumer. Pin-before-fix per the hallucination guard; the ladder over the whole diff.

**Not in this effort (rider candidates, offered — never seated without her word):** VX-96 (Book Outline: reveal-without-focus roads keep the title-over-blank beat — Bug · Confirmed, this exact surface) · VX-616 ("+ new chapter" renders on a gathering's navigator foot — a door that can never act — Bug · Confirmed) · VX-563 (a keyboard way to navigate the in-note book view — Improvement · Confirmed, adjacent to the follower). Bundled in §MORNING BUNDLE.

---

## THE BINDING PRINCIPLES (the 13b constitution, P-1…P-9 — copied byte-verbatim per the architect-phase skill; binding on every batch)

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

**Application notes that bind the same way (the skill's precisions):** P-1's scope is the ROUTED vocabulary, grown incrementally — surface-local doors that already work are not retro-declared wholesale; acts whose only doors are inline declare `.surface`, never mis-file under `.contextMenu`. The FULL-DOCUMENT editor is never absorbed into the pane surface; both surface kinds consult the ONE authority. Storage-coupled code lives feature-side, never in shared `Registry/`/`Surface/` layers. Every equality-gated sink delivers its stored state AT WIRE TIME, and overlay geometry refreshes trigger on every input axis (storage edits, width reflows, AND the first post-layout display pass) — state computed before layout exists is garbage that equality gates then freeze. The closing form for a recurrence of a fixed class is the sweep table: instance × host/path, each cell FIXED-with-named-pin or provably SAFE with the mechanism stated.

---

## DESIGN (pending the recon — filled before the implementer brief)

*PENDING: the Explore recon of the Outline surface (navigator, content column, existing highlight state, viewport reading machinery, masthead) lands here as §Design, with the follower's mechanism, the pinned header's home, the PROVISIONAL calls and the batch brief.*

## LEDGER

| # | Item | Status |
|---|---|---|
| 1 | The follow-highlight: the Outline navigator's highlighted chapter/note follows the viewport as the content scrolls (the view, never the caret) | NOT-STARTED |
| 2 | The pinned nav info: chapters + notes counts fixed at the top while scrolling; the current note # (and chapter) said during scroll | NOT-STARTED |
| 3 | The walk (Opus walker, seeded sherlock, store left as found) + the test batch under coordinator GO | NOT-STARTED |
| 4 | The ladder (one round minimum; reviewer per the diff) | NOT-STARTED |

## MORNING BUNDLE (for her — PROVISIONALs, riders, taste calls; grows as the run proceeds)

- **Riders offered (cheapest while this code is open; none seated without your word):** VX-96 · VX-616 · VX-563 (see "Not in this effort" above).

## ENVIRONMENT TRAPS (carried verbatim into every batch brief)

Instance checks use `pgrep -lx Variorum` and `pgrep -lf "MacOS/Variorum$"` (the looser pattern matches builds) plus `xcrun simctl list devices booted`; treat real-store instances by STORE, not path — NEVER quit/kill one; no Release builds or /Applications refreshes while one lives. `xcodebuild build-for-testing` compiles without the runner; Mac tests from `App/Variorum/`, suite-level `-only-testing` only, confirm the "Test run with N tests" line (Swift Testing's count INCLUDES skipped tests — read the `skipped:` lines); zsh `pipestatus`; NEVER add a custom build configuration (anything not named exactly "Debug" builds the packages Release and strips the DEBUG oracles). EVERY `xcodebuild test` run needs the stage — and the stage comes ONLY as the coordinator's GO (REQUEST → READY → GO; a FREE stage is never an invitation); headless `swift build`/`swift test`/`xcodebuild build|build-for-testing` never needs it. The dev store is library e11e5233, HELD since 10-20, signed out, Study — NEVER press Resume (one press consumes the hold); restore the store exactly as found; walk content to the Trash or removed, and say which. After every Debug launch, dismiss a What's New sheet if one shows. Backups WAL-safe with UTC names into `Backups/safety-copies/`, always before touching the real store (the A1 rail). Never `git checkout` over uncommitted work; commit per piece, push after every commit; never force-push or rewrite pushed history. Commits carry NO attribution trailer (her standing rule). The resiliency protocol binds: LIVE STATUS from the first commit, synchronous foreground waits only (poll with `grep -q '<EXIT LINE>' <log> && break; sleep 5` loops, never `tail -f | grep -m1`), no subagents from the implementer (one Sonnet read-only external-facts agent at most).
