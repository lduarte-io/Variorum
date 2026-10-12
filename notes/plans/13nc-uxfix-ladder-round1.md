# 13n-c UX-fix ladder — round 1 (cold review, opus-reviewer, 2026-10-11)

**Reviewer model: Opus 5.5 (`claude-opus-5-5`), xhigh — FRESH, zero implementation context.** Prompt:
`notes/REVIEW_PROMPT.md` verbatim (PHASE = 13n-c) plus a mechanics-only note naming the range and the fix-pass
record's seven "look first" items as the mandatory focus list. The reviewer stayed read-only; the orchestrator
landed this record from its report. **Same-model flow (Opus implemented, Opus reviewed): the orchestrator
(Fable) arbitrates against the spec** — dispositions below are the orchestrator's.

- **Scope:** `35ebf3e3..519915f7` — the UX-walk fix pass (dispositions rows 1, 3–18 + 4b, plus her ruled
  W-UX-2 and W-UX-19).
- **Status: ROUND 1 COMPLETE — 0 BLOCKER · 0 MAJOR · 4 MINOR · 2 NIT.** No BLOCKER/MAJOR, so no further
  cold round is earned; the six accepted findings go to the fix-pass implementer, and the orchestrator
  verifies the fix diff line-by-line (recorded in the addendum below) before closeout.
- **The reviewer's own scope check concurs with the orchestrator's:** no `Sync/` / `Server/` / `Persistence/` /
  custody / migration / editor-seam lines; `MCPGrantRule` byte-untouched; no trailers; the stored-default
  meanings unchanged (W-UX-2's start is her ruling). Its own Mac run under a held-and-released stage claim:
  **112 tests / 8 suites green** on the tip.

## Findings and dispositions

| # | Sev | Where | Finding (short) | Disposition |
|---|---|---|---|---|
| UXR1-1 | MINOR | `MCPPaneCopy.swift:231-265` (W-UX-13) | Activity's refusal sentences name the wrong side on two-sided acts: a wing move refused at the DESTINATION logs the wing, and `refusedPhrase` words it as the thing moved ("refused moving “research” to another wing" — research is the wing); same for `add_note_to_book` / `file_note_in_chapter` refused at the book side ("refused adding “diary” to a book" — diary is the book). Second case: the `target ?? "a note"` fallback says "a note" for book/wing-kind rows whose title didn't resolve ("refused making a book in a note"). The pass's pin checks only no-tool-id/no-underscore, so it's green on both sides. | **ACCEPT — FIX (implementer):** switch on the logged `kind` for the three two-sided acts (the note side unnamed is honest: "moving a note to “research”"), and the fallback noun follows the kind ("a book" / "a wing"). Pin RED-on-old per the reviewer's shape (the three acts with `targetKind` wing/book + a nil-title book/wing row). Words stay under P-13nc-UX-13's PROVISIONAL umbrella — her copy pass may reword, but false statements die now. |
| UXR1-2 | MINOR | `MCPPane.swift` rows + `MCPGrantSheet.swift:412-418` (W-UX-19) | Change… is offered on rows whose target is GONE (no delete path revokes grants, so a live grant on a deleted book/wing lists "(gone)"): a dead wing's sheet mislabels as **Home** (`wingName` fallback) with a live confirm that can only throw `mcpGrantScopeNotFound` and roll back; a deleted book's sheet speaks the FALSE fenced-reason sentence; an act whose notes are all gone reads "These 0 notes" disabled. The record's "inert rows open on current facts" holds for fenced targets only. | **ACCEPT — FIX (implementer):** a pure rule (`offersChange(row)`-shaped) decides the offer — a single row whose target doesn't resolve, and an act with zero live members, keep Revoke only. Pin RED-on-old (today every row offers it). The dead-wing Home mislabel and the false book sentence die with the door; the other replace-sheet roads (the receipt, the popovers) open on live targets by construction — the implementer confirms and says so in its record. |
| UXR1-3 | MINOR | `LibraryCatalogView.swift:701-774` (W-UX-3) | The bulk row's every child is `.fixedSize()`, so its minimum width is the sum of its labels — measured offscreen: Terminal ~714 pt at 3 notes (fits her walked 1380-pt window by ~9 pt), 12+ notes overflow it, and the app's own 1240-pt `defaultSize` overflows by ~80 pt — the T-1 panel-push the fix set out to remove, recurring. Nobody has seen the row on screen (the walk's known ⌘-click limit). | **ACCEPT — FIX (implementer picks the idiom, as the original disposition let it):** every door findable and honestly worded at the 1240-pt default with the panel open — wrap (`ViewThatFits` two-line fallback) or shorter door labels (the row already leads with "N notes selected"); lesson 5 and the panel line track whatever wins. **Geometry oracle pin** (W-UX-18's style) RED today at the 1240-pt default. |
| UXR1-4 | MINOR | `MCPGrantSheet.swift:293-300` + `MCPAskSheet.swift:81-87` (W-UX-9) | Two code comments state as FACT the dead-Return/Esc claim the pass's own record retracted as a cliclick artifact — and at least nine working sheets pair `VoicedButtonStyle` with `.keyboardShortcut(.defaultAction)`, so a maintainer who believes the comment will "fix" them or misread these two sheets. | **ACCEPT — FIX (implementer):** reword both to the record's truth (system styles chosen as the closer match to the disposition's "the ask sheet's filled button"; the dead keys were the test artifact). Record class, no pin possible. |
| UXR1-5 | NIT | `MCPShareRoad.swift:40-43` · `MCPGrantSheet.swift:479` · `TutorialSeeder.swift:2626` · `EditorCommands.swift:486/490` | Stale comments: `approving` still says "the grant rides the approve"; `place` says "nil = a book default"; `submit` says "approve-with-grant"; the seeder comment quotes lesson 1's retired sentence; the grey View item's `.help` is dead (macOS draws no tooltip on a grey item — the verify leg's own finding) and the comment claims it shows. | **ACCEPT — FIX (implementer):** the four comment edits; the dead `.help` either said-dead in the comment or dropped (implementer's call, recorded). |
| UXR1-6 | NIT | `MCPPane.swift:126-130` (W-UX-8) | The WAITING header + "was let go" line can linger over nothing (the line clears only on `act`/`deny`/`share`/`copy`, survives closing and reopening Settings, and can sit stale above FRESH asks). The staleness predates this pass at `.top`; new is the empty-section face. | **ACCEPT — FIX (implementer), smallest honest:** a `.waiting` note clears when Waiting's rows change or on a fresh pane appear (implementer's call); pin or ritual as cheap as honest. |

## Clean bill (the reviewer's, summarized — all seven mandatory foci addressed)

1. **W-UX-1:** every host presents by OPENING, none by bare id; the getter nils on every removing road;
   T-U4-5 intact; `detach()`'s raise-counter reset is safe (host state dies with `.ready`).
2. **W-UX-2:** `.nothing` · no book · `.once` from the first frame; `submit` → `approve(granting: nil)` →
   zero rows at the core op; the non-approval start unchanged and pinned.
3. **W-UX-6:** the monitor consumes ONLY ⌘L-with-one-wing; ⇧⌘L, ⌃⌘L, plain l, Esc pass; availability
   tracked current in both window kinds; no other ⌘L handler exists.
4. **W-UX-19's act Change…:** one transaction, a gone member's grant revoked and the live re-minted,
   any refusal rolls the whole act back (the gone-target FACES are UXR1-2).
5. **W-UX-16:** `fixedSize(vertical:)` over the lazy stack builds 15 rows for a 3,000-row list — P1/P3
   unharmed; D-W1's first-frame reservation kept.
6. **W-UX-9:** meets the disposition; only the comments wrong (UXR1-4).
7. **The flipped-text observation:** nothing in the range touches those texts; stays a watch item.

Plus: W-UX-14's pin reads the catalog (sentences only under-claim); W-UX-4/5/10 labels and counts correct;
+4b display-only with the fence unchanged; every new colour a voice token; message kinds correct (refusals);
nothing regresses the earlier rounds' verified items (R2-1(a), B8, D-W1 all re-checked).

## ADDENDUM — the fix leg (orchestrator, landed after the fixes)

*(Opens when the implementer hands back; the orchestrator's line-by-line verification of the fix diff and the
suite finals land here before closeout.)*

*(The implementer's record of the fix leg — each finding's fix, its pin's red count, the walk and the finals, and
the found F-R1-1 — is the "ROUND-1 FIX LEG" addendum at the end of `notes/plans/phase-13n-c-mcp-launch-readiness.md`.)*
