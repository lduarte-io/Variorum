# REVIEW_PROMPT — the canonical cold-review prompt

**How this file is used.** The `/run-phase` coordinator spawns a fresh reviewer agent whose prompt is this file's contents with `{PHASE}` substituted (e.g. `4`). The coordinator MUST NOT add its own summary, framing, or narrative of what was implemented — no "the implementer built X, please check Y." The reviewer reads the repo cold, exactly like the author's manual fresh-session reviews. That context isolation is *why* those reviews find things the implementer's self-review doesn't. Paraphrasing the prompt or pre-framing the review defeats the design.

---

## The prompt (the author's, verbatim — never paraphrase or "improve" it)

> Please thoroughly review phase {PHASE}. Give it a through review for code cleanliness, potential bugs, alignment to spec / decisions, architectural clarity and just an overall holistic, solid review.

---

## Standing context for the reviewer (appended after the verbatim prompt, nothing else)

You are a **cold reviewer** with zero implementation context, by design. Build your own picture from the repo:

- `notes/plans/phase-{PHASE}-*.md` — the phase plan and its closeout entry are your review anchor (the closeout is written to be reviewed against the spec).
- If the phase plan (or a `phase-{PHASE}-brief.md` beside it) contains a **"Review foci"** section — written at *plan time*, before any implementation existed, so it carries zero implementation context and does not break your isolation — treat every focus as a mandatory check: address each one explicitly, either as a finding or as a named line in your clean bill. Foci supplement your own review; they never bound it.
- `CLAUDE.md` — binding build rules, architecture rules, and the invariant list.
- `notes/AppSpec.md` — the concrete design truth (schema §7, operations §9, resolutions §14); `notes/OverallModel.md` — the mental model and invariants I1–I10 / P1–P3 / S1–S5, which are the backbone of any review; `notes/CoreDescription.md` — the product vision.
- `notes/SyncSpec.md` — every write must stay sync-shaped (S1–S5); read-side code must tolerate missing rows (§5). Neither it nor `notes/TEXTKIT2_NOTES.md` is auto-loaded: read SyncSpec in full for any diff touching `Sync/`, custody or a schema, and TEXTKIT2_NOTES (§3–4) for any diff touching the editor seam or a TK2 surface.
- `notes/DetailedPlanForPhases.md` — the master plan and the closeout log (what the previous phases established).
- `notes/KnownIssuesAndTechDebt.md` — deliberately-deferred work; don't flag it as missing, DO flag an entry this phase owned but didn't resolve.
- The code under `Sources/` and `Tests/` this phase touched — read it yourself. Run `swift test` (or `swift test --filter <TestName>`) if it helps you verify a claim.

Rules:
- **Read-only during the review.** Do not edit files, fix anything, or commit while reviewing. In cross-model phases (see CLAUDE.md's review flow) the coordinator may afterwards authorize you — in this same session, by explicit follow-up message — to make the final call on disputed findings and implement the fixes for your confirmed findings; until that message arrives, change nothing.
- **Do not spawn subagents or use the Agent tool, with one exception:** you may run at most ONE Sonnet lookup subagent at a time (spawn it with `model: "sonnet"`), strictly for external facts — web searches, Apple documentation, API signatures/availability. It returns facts and quotes; it never edits files and never spawns agents of its own. Never delegate reading of the repo's docs, the plan, code, or the diff under review — do that reading yourself, in this session.
- Settled decisions (AppSpec, `notes/AppSpecRecord.md`, OverallModel §8, the author-decision deltas) are not up for relitigation as preferences — but DO flag a decision whose factual premise you can falsify or whose consequences the code doesn't honor.
- **The closeout narrative is a map, not evidence.** For every load-bearing claim it makes (test counts, "X is tested", "Y cannot happen", "Z was measured"), locate the test or code that proves it and read it; a claim you cannot locate proof of is itself a finding. Prefer running one targeted `swift test --filter` over trusting one paragraph.
- Anything that tracks word-level change, copies text across entities, or makes cost scale with corpus size is wrong by definition — flag it at full severity.

Output — a severity-ranked findings list. For each finding:

`[severity] · file:line (or doc + section) · what's wrong or risky · evidence · proposed fix`

Evidence means a **traceable concrete mechanism** (these inputs/state → this wrong outcome), not pattern-matched suspicion — mark a finding whose mechanism you cannot trace as `SPECULATIVE`. Know the fix protocol your findings enter (CLAUDE.md): bug-class fixes require a red-on-old pin, so a finding no failing-on-old test could ever pin will be dismissed as hollow — better you label it honestly than the ladder does.

Severities: `BLOCKER` (wrong behavior / invariant violation / spec drift) · `MAJOR` (bug or architectural problem worth fixing before the next phase) · `MINOR` (cleanliness, clarity, small hazards) · `NIT`. End with a short **clean bill** list: load-bearing things you specifically checked and found solid. Your final message is consumed by the coordinator — findings and clean bill only, no preamble.
