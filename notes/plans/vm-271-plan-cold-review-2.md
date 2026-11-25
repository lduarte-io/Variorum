# VM-271 — cold review of the phone editor core plan (draft v2, round 2)

**Reviewed:** `notes/plans/vm-271-phone-editor-core.md`, DRAFT v2 (branch `vx-1033-nov-22-sitting`, head `cdff1428c`), read twice, with round 1 (`notes/plans/vm-271-plan-cold-review-1.md`) beside it.
**Tested against:** `main` at `b23550bc8`: the phone editor (`VariorumMobile/Features/Write/`, `Features/Takes/`), `Shared/EditorBrain/*`, `Shared/AutosaveCoordinator.swift`, `Shared/AppSession.swift`, `Sources/VariorumCore/Operations/*`, `Sources/VariorumCore/Domain/{BoundarySnapping,SegmentationRules,KeepOnTopDivide,MergeJoin,StoredText}.swift`, and the Mac's dispatch in `Features/Editor/EditorSurfaceController.swift` / `EditorViewModel.swift` as the reference for ruled results. Canon: CLAUDE.md, AppSpec, OverallModel, CoreDescription, `notes/TEXTKIT2_NOTES.md` §3, `notes/MobileSoul.md` §2/§3/§5, and in the worktree `phone-editor-inventory.md`, `phone-editor-audit.md`, `ios-text-input-research.md`.
**Posture:** read-only; nothing built, run or installed. "Inference" marks my reasoning about UIKit as opposed to code I read or a sourced or measured fact. Examples use neutral text ("Alpha", "Hello world"); none comes from her notes. The sync reviewer is covering sync in depth; I note sync only where it crosses a mechanism I was testing.

---

## 0. Verdict

v2 is a real improvement on v1. The identity table exists and most of its rows are geometrically right (I re-derived the carve, the whole-block delete, Return's four arms and the compound's two shapes against `BlockRangeIndex`, `TypedReturn` and `CrossBlockCompound` and they match). The saver is now the session's coordinator, not a second writer. The marked range is excised rather than the region withheld. The map is never rebuilt from the page. Those are the right calls.

It is not ready to build. The new half of the design — the doors that make the ruled page synchronously from the map's facts and ask the store afterwards — has three holes that, built as written, corrupt or silently move her writing:

1. **The plan never says what the editor's own observer, gate and delegates do with the editor's own edits** (§7 step 3, §8.6's repairs, §12.2). Read literally, rule 2 saves the door's post-edit text by value, the act task's "flush every pending save" lands it, and the operation then runs on text that already contains its own result: a divide at a multi-space seam cuts the wrong word in half in the store, a compound refuses after the page changed, and a ⌫-join stores the second paragraph twice (N1).
2. **The facts the doors decide on are wrong for every block the editor's own acts produce** ("known without asking (one take, no comments)", §5.3), and the join's fan authorization comes from the map instead of the store. Return in a fanned block followed by ⌫ — her commonest correction — silently releases the block's other takes to lineage. The identity oracle cannot see it (N2).
3. **Regions whose text an in-flight act changes, but whose identity it keeps, are not held.** Their next saves carry a pre-act compare-and-set base, so the editor's own act mints a "conflict" take — round 1's M2, back by another road (N3).

Beyond those: the join's refusal set differs from the Mac's (N4, a direct conflict with her 2026-11-22 ruling); the open end's type-time crystallization is timed at the wrong keystroke and its trim has no door (N5); the rescue and "every flush road waits for acts" cannot be built on `AutosaveCoordinator` and `AppSession` as they are, so the shared-code changes are undercounted (N6, N7); and the proof plan checks the editor against itself, not against the Mac, so the parity divergences above pass every planned test (N15).

I would not approve v2. §10 lists what I would require. None of it changes the direction; most of it is specification that the implementer would otherwise guess, and two items (N2's store-read authorization, N3's hold-and-rebase) change the shape of the doors for the gestures whose ruling depends on store-only facts.

---

## 1. Round 1's findings, checked against v2

| R1 | v2's claim | Verdict | Evidence |
|---|---|---|---|
| **B1** no identity rule | §8 table, head re-pointed, tokens on re-identifiable regions, oracle | **RESOLVED BUT INTRODUCES N2, N3** | All six of round 1's B1 scenarios now have a correct row (I re-derived each: J9 with the trailing newline removes the deleted block's *own* break; select-all leaves the head on the open end; the carve removes the carved block's own break with before-wins, `BlockRangeIndex.swift:257-265`; the fanned divide tokens both halves; `.above` moves A's mark to the new `"\n"`; Delete/Archive remove the block's own break). But the facts the rows decide on are wrong for successor blocks (N2), only identity-changing regions are held (N3), and the extract-prefix row is ambiguous (§3 below). |
| **B2** "the page wins" duplicates | compound computed at the door | **RESOLVED ON PAPER; "page wins" survives at the rebase (N10)** | The door now writes `leading.newText` (+ `"\n"` + `trailing.newText`). But §10.1 sets `stored` from the op's result unconditionally, so whenever the op's result differs from the page the next save overwrites it with `expectedText == row` and no rescue fires — the page silently wins, one step later. And N1's literal observer re-creates B2's duplication directly. |
| **B3** refused/diverted saves | placement check, rescue, structural deliveries don't wait | **RESOLVED ON PAPER ONLY** | The placement check is a sound mechanism (her call). The rescue cannot be built on the coordinator as it is (N6); "every flush road waits for acts" needs `AppSession` changes the plan does not list (N7); deliveries are not fenced against the editor's own in-flight acts (N9); the structural undo door is not serialized with the act task (§7 below). |
| **M1** seam ⌫ cannot follow | caught in `deleteBackward`, ruled edit made there | **RESOLVED BUT INTRODUCES N2, N4** | The delete join's space is now right. But round 1's M1 said "read the fan on the reader pool, then re-issue" — the store read is what the Mac authorizes on (`EditorSurfaceController.swift:2470-2482`). v2 dropped it and decides from the map, whose fan facts are wrong for the editor's own successors (N2). The refusal list is also wrong (N4). |
| **M2** normalizing ops, stale CAS bases | normalize at the gesture; stored from results | **RESOLVED BUT INTRODUCES N3, N5** | True for door gestures. Not true for type-time crystallization, which has no door (N5), nor for non-tokened regions an act rewrites while she keeps typing — the coordinator's run snapshot is captured at the first `record` and kept (`AutosaveCoordinator.swift:143-153`), so v2's later update of `stored` does not reach it (N3). The exact M2 failure ("a 'conflict' take minted by the editor's own act") recurs. |
| **M3** "a reading" does two jobs | `stored` and `settled` | **RESOLVED**, with a third value to reconcile | The coordinator's per-run `expectedText` is a third copy v2 does not mention (N3). |
| **M4** repairs drop later typing | invert only the offending change | **RESOLVED ON PAPER** | For a struck break, yes. For a *refused act* (§8.5) after a delete or type-over she has typed past, the inverse is undefined: it must restore deleted blocks' text that is no longer on the page, around her newer typing (N12). §8.6 step 3's fallback ("all the text stays in the surviving region") leaves the struck block's text in the library too, so the next save duplicates it. |
| **M5** slots and fresh flags | facts kept fresh; minted blocks known | **RESOLVED BUT INTRODUCES N2** | "Known without asking (one take, no comments)" is false for divide's C (comment copies, `Operations+Structural.swift:241`), divideW's B and C (B carries every other take; both get comment copies, `:470`), extract's block (`:132`), merge's A′ (both sides' comments, `:924-925`) and the carry-all's A′ (fanned). Only `newBlock` and crystallization mints are truly bare. |
| **M6** headless vs composed | the split, `pageArms` | **RESOLVED**, one inconsistency | §17's "run 1 adds … new files in the core package's Domain" omits that U2's identity table and oracle must live and run in the phone target under stage claims (§14.1 says so). |
| **M7** writer not wired | coordinator stays the saver; one act task; flush roads wait | **RESOLVED ON PAPER ONLY** | See N7: `flushExistingAutosave`, `flushPendingTypingBeforeRound` (+`hasPendingAutosave`), `savepointOnLeaving`, `runCopying`, `flushEveryOpenPost` know only the coordinator (`AppSession.swift:383-387, 421-423, 591-639, 668+`). Token-held saves are invisible to all of them. "The debounce … only enqueues to that task" is also false: the debounce is the coordinator's own `Task` (`AutosaveCoordinator.swift:155-162`). |
| **M8** rule 5 / `unmarkText` | marked range excised; per-kind settle | **RESOLVED** (pending the probe) | How a prediction's suffix is *discarded* is unknown; predictions start off. |
| **M9** nothing mints the open end | idle clock + durability moments | **RESOLVED BUT INTRODUCES N5** | "Stores the text exactly as it stands" must keep the Mac's trailing-newline-run rule or a Return-then-pause in a fresh note makes one block of two paragraphs. |
| **M10** idle rebuild merges | never rebuild from the page | **RESOLVED** | — |
| **M11** check blind / cries wolf | projection in order, exclusions | **RESOLVED ON PAPER** | It will cry wolf on every type-time crystallization trim (N5) unless the page is normalized, and N10's silent rebase erases real mismatches before the leaving check can see them. |
| **M12** test narrower than the route | §8.6 step 2 routes hers | **NOT RESOLVED** (N11) | The "hers" test is unchanged: "exactly the selection, or exactly the one break at her caret". Round 1's own scenario — a word delete or accelerated held delete at a block's start removing `word⏎` — fails it, so the gate declines it (§9.1 reason 3) or §8.6 inverts it. The Mac clamps it (deletes the word, keeps the break) or J9-deletes a one-word block. |
| **M13** lower/raise as routine | named; probe Q11; gate | **RESOLVED**, partially | §12.2 still lowers and raises for any outside change touching the caret's region — including the structural undo of the act she just made (its region is by definition hers). Name that cost too. |
| **M14** perf bar missing | §14.5 every unit | **RESOLVED** | — |
| **M15** sequencing; U3 too big | split; decisions gate run 2 | **RESOLVED**, but see §8 | U2 and U3a are each still more than one session; the Write screen's chrome has no unit (N16). |
| MINOR menu merge = unmark | §8.4 | RESOLVED | — |
| MINOR divide at a newline run | §8.1 | RESOLVED, imprecise | `seamTrimmedHalves` also drops horizontal whitespace inside the run (`BoundarySnapping.swift:249-268`): `"a\n  \nb"` cut at the blank becomes `"a\n"` + break + `"b"`, so the spaces leave the page. "The run stays" is not quite true. |
| MINOR list order | §8.1 | **PARTIAL** | "List continuation and the list exit run first, as on the Mac" — but the Mac's exit is not content: it deletes the lead, then retracts the continuation newline inside the flight and mints an empty block below (VX-655; `EditorSurfaceController.swift:977-1017, 1081-1091`; `EditorViewModel.swift:1836-1856`). That is a structural act with a text change to A and needs its own row. |
| MINOR Returns beside locked/gap | §5.4 | RESOLVED | — |
| MINOR sealed face | §5.4 | RESOLVED BUT the doors must check the seal *before* the page edit | `TypedReturn` and `EditorEditRoute` do not decide seals ("A sealed post never reaches here — the gate refuses at the seal before any plan runs", `EditorEditRoute.swift:522-523`; `TypedReturn.swift:39-44`). §7 never says the doors run §9.1's belts first. |
| MINOR unique bindings | §5.2 | RESOLVED, tie-break missing | "A second one … is stripped" — say which: the one not at the map's offset. |
| MINOR undo after repairs/doors | §12.3 | RESOLVED BUT over-clears | §7 step 4 clears text undo for every door, including the clamp, which #109 deliberately keeps on text undo (`CrossBlockCompound.swift:196-203`). |
| MINOR multi-range | §9.1, §10.4 | **RESOLVED BUT INTRODUCES an error** | "One change over the union" deletes the text between the ranges, which the system keeps (research §1: it replaces one range and deletes the others). |
| MINOR settle triggers / marked-range timing | §6 | RESOLVED | — |
| MINOR proofreading | §13.1, probe | RESOLVED | — |
| MINOR phone's own executor | §8.3 | RESOLVED BUT `CrossBlockCompound.Outcome` has no variant id | Binding M needs the merged take's id; `Outcome` carries `caretBlockID` only (`CrossBlockCompound.swift:308-319, 609-613`). A read after the act, or a shared change. |
| MINOR re-check after every wait | rule 4 | RESOLVED | — |
| MINOR runner contention | §19.8 | RESOLVED (named) | — |
| MINOR old editor's files | §19.4 | **RESOLVED ON PAPER** | The switch's branch in `MobileWriteView`, "Open in the new editor" in the old ⋯ menu, and the liveness registry's retyping all edit files the old editor runs. Harmless, but §19.4's "not edited until U6" is untrue as written. |
| MINOR receipts | §9.2, §20.7 | RESOLVED | — |
| MINOR dictated / hardware Returns | §10.2 | PARTIAL | A hardware ⇧⏎ arrives as `insertText("\n")` (`MobileEditorTextView.swift:1010-1013`); telling it apart needs a priority `UIKeyCommand`. Unstated. |
| MINOR safety copy + label | §15.1 | RESOLVED | — |
| MINOR VoiceOver | Q17 | RESOLVED | — |
| NITs | — | RESOLVED | — |
| §9 "D, narrowed" | adopted | **CHANGED, not adopted** | Round 1's shape was "decline, decide **against the store**, apply next turn". v2 decides against the map and applies synchronously. For gestures whose rule reads store-only facts (any fan question), that is the regression behind N2. |
| §7 real ops, adversary, kills, self-test | adopted | RESOLVED BUT the oracle is blind to takes and comments and to parity (N15) | — |

---

## 2. New findings, ranked

### BLOCKERS

#### N1 — The editor's own edits have no specified handling, and the natural reading corrupts stored text

**Sections:** §3 rule 2, §6, §7 steps 3–4, §8.6, §9.1, §11.1, §12.1.

**Mechanism.** A door makes its ruled edit "through the text view's own calls" inside the keyboard's call. That edit is a storage edit like any other. Inference, strongly supported by how the phone works today: `NSTextStorage` processes it synchronously inside the door's call, so the storage delegate's notices fire and the editor's observer (§6) runs *during* step 3, before step 3's mark writes and before step 4 queues the operation. `textViewDidChange` and `textViewDidChangeSelection` follow (§6 settles on both). The plan does not say whether the observer, the gate or those delegates know the edit is the door's own. Each possible default is wrong:

- **The observer treats it as typing (rule 2).** Scenario: block A reads `Hello   world` (three spaces). Caret after `Hello ` → `TypedReturn` → `.divideAtCaret` → the planner settles the cut to 8 (`world`'s start). The door replaces `"   "` at [5,8) with one `"\n"` → the page reads `Hello⏎world` (11 units). The observer sees A's region (the new `"\n"` has no mark yet) read `Hello\nworld` and queues it by value with `basedOn` = A's stored `Hello   world`. Step 4 queues `divide(A, cut: 8)`. The act task "flushes every pending save" first: the save lands (row == expected), A now holds `Hello\nworld`. Then `divide(A, cut: 8)` cuts `Hello\nwo|rld` → `seamTrimmedHalves` → A = `Hello\nwo`, C = `rld` (`Operations+Structural.swift:222-231`). §10.1 sets the regions' stored texts from that result. The page shows `Hello` / `world`; the store holds `Hello\nwo` / `rld`. If she does not type in C before leaving, C stays wrong in the store. **Stored corruption.**
  Same road, other rows, for an implementer who re-reads the merged region rather than following §6's "strikes no break" split: the ⌫-join's observer save puts `Alpha Beta` into P's take, then `merge(P, N)` stores A′ = `Alpha Beta Beta` (duplication); the compound's observer save lands the post-edit text in the leading take, then `CrossBlockCompound.apply`'s compare-and-set against the plan-time `oldText` (`CrossBlockCompound.swift:553-564`) refuses the whole compound with `bufferChangedSinceGesture` — after the page already shows the ruled result, and with the leading take now holding text that duplicates the trailing block's surviving suffix.
- **The observer treats it as a struck break not through a door (§8.6)** — which is what §6 literally says for any change that strikes a break. Where the door's edit is not "hers" by §8.6's test — a join that puts a space in place of the break, the middle carve (it removes a break that is not the one at her caret), J9 with the trailing newline — step 3 "inverts the offending change": the ruled edit is undone on the page while its operation is queued. Where it *is* hers — a join whose delete join is "nothing" (an edge already whitespace) removes exactly the break at her caret; the join-case compound replaces exactly her selection — step 2 routes it through the shared rule **a second time** and queues a second act against a page that already shows the first one's result.
- **The gate is consulted for the door's own edit.** VM-78 measured that `replace(_:withText:)` consulted `shouldChangeTextIn` in none of 24 acts with a hardware keyboard connected (`TEXTKIT2_NOTES.md:177`); with the software keyboard and with `insertText` it may. Where it is consulted, §9.1 reason 3 ("strikes a break and is not shaped like hers") declines several door edits: the middle carve removes the *carved* block's break, not the one at her caret (`Atext⏎⏎Ctext`, caret at C's start, removes offset 5, not 6); J9 with the trailing newline removes `"\nBeta"` where her selection was `"Beta\n"`; the non-join compound re-inserts a `"\n"`. Reason 2 declines J9 over a locked block, which #33(a) deletes. The door's edit silently does not happen; step 4 then queues the op anyway.
- **"The text view's own calls" re-enter the doors.** §4 names `insertText(_:)` as one of them. A subclass's `self.insertText` *is* the door override. The phone's existing helper `MobileMarkdownActs.inputReplace` sets the selection and calls the public `insertText`/`deleteBackward` (`MobileMarkdownActs.swift:60-75`). From inside a join door, selecting the break and calling `insertText(" ")` re-enters the `insertText` door with a cross-break selection; the route answers `.editInBlock` (the #111 degenerate clamp) and the "join" becomes `Alpha ` + break + `Beta`.

**Data at risk:** stored text, corrupted or duplicated.

**Change required.** Specify an **own-edit scope**, entered by every door, repair and outside change: (1) the door computes the whole post-edit map (offsets, marks, bindings, tokens, held regions) *before* touching the page; (2) inside the scope the observer verifies the storage against that expected map and records nothing, and §8.6 does not run; (3) the gate answers yes inside the scope; (4) the edit uses `super.insertText` / `super.deleteBackward` or `replace(_:withText:)` (never the overridden public methods), with a re-entrancy guard; (5) marks are written in the same main-actor turn, before the scope closes; (6) the selection and settle delegates do not queue saves for regions the act holds (N3). Add the corresponding probe questions (§6 below, P1).

#### N2 — The doors decide fan questions from facts the map cannot have; Return then ⌫ in a fanned block silently folds the fan

**Sections:** §5.3 ("For a block this editor minted, those facts are known without asking (one take, no comments)", line 190), §7 step 2, §8.1 (fanned divide), §8.2 (join), §14.2.

**Scenario.** Block A has takes T1 (shown), T2, T3. She presses Return mid-paragraph. Keep-on-top: `divideW` mints B = [T1's first half, T2 whole, T3 whole] and C = [T1's second half] (`KeepOnTopDivide.swift`, `Operations+Structural.swift:393-416`). Comments are copied to both (`:470`). The map, per §5.3, records B and C as "minted by this editor: one take, no comments". She presses ⌫ at C's start (the ordinary "undo that Return"). The rule is `.mergeTextedSeam` — geometry only; "the fan is the executor's STORE read" (`EditorEditRoute.swift:77-87, 508-523`). §7 step 2 checks the map: one take each → the door writes `B1 C1` (with the delete join's space) and queues `merge(B, C, joining: .deleteKeystroke)`. `merge` has no fan fence ("`ops.merge` has no fan fence", `EditorSurfaceController.swift:411-420`); it lands. A′ has one take; B — holding T2 and T3 — is released to lineage. The note no longer shows that it has other takes, and nothing was said. The Mac, from the same state, refuses in words: "The block above has takes — backspace won't fold a fan away" (`EditorSurfaceController.swift:2470-2482, 2507-2518`), which is her #34 (ii) ruling.

The same wrong facts make the carve of an emptied C (which carries A's copied comments) proceed on the page and then refuse in the op (`blockCarriesUnshownText`), a visible flicker and an inverse; and make a carry-all A′ (fanned) look bare.

The identity oracle (§14.2) compares "block ids with their texts" in the library with the editor's regions. After the fold they agree (A′'s one take equals the page), so **the oracle passes the fold**. The self-test (§15.4) has no "Return then ⌫ in a block with takes" step.

**Data at risk:** takes silently removed from the note (recoverable in lineage, but a ruled-never keystroke result and "lost silently" in the sense of constraint 4).

**Change required.**
- Facts for every successor come from the operation's result or a read, never from "this editor minted it": `DivideWResult.first.variants.count` for B; comment travel per the op (`copyLiveComments` on divide, divideW, extract, merge); carry-all's fan. Until known, a successor's facts read as "unknown", and any door that would act on them declines and re-issues after the read (round 1's M1 shape).
- The join's fan authorization is the store's, as on the Mac: pass a `guardedBy:` fan check to `merge` (the parameter already exists, `Operations+Structural.swift:852-855`) so a fan arriving between the door and the op refuses inside the transaction, and invert. Same for keep-on-top: read the fan first, exactly as `runKeepOnTopDivide` does, including its fallback to the plain divide when the store says unfanned (`EditorSurfaceController.swift:613-643`) and its `takesChangedDivide` refusal (`:644-653`).
- The oracle compares, per block, the live fan (ids, texts, status), the chosen take, comment counts and presentation — not just ids and texts.

### MAJORS

#### N3 — Regions an act rewrites but does not re-identify are not held, so the editor's own act mints conflict takes

**Sections:** §8.5 ("A region with a token is not saved until the operation's result binds it"), §10.1, §11.2.

Tokens go only on regions whose *identity* may change. Several rows change a region's *stored text* without changing its identity: the single-take divide's A (trimmed first half), the non-join compound's leading and trailing edges, the clamp, select-all-and-retype's leading edge (the compound's `keepsFirst` road, `CrossBlockCompound.swift:438`), the extract source, the list exit's retraction. Typing in such a region after the door and before the op returns is recorded into the coordinator with `basedOn` = the pre-act stored text, and **only the first record of a run sets the run's `expectedText`** (`AutosaveCoordinator.swift:143-153`). §10.1 later updates the map's `stored`, but not the coordinator's pending run.

**Scenario.** A long note. She selects from the start of `Alpha one` into `Gamma three` and types `New text`. The first key is the door: compound queued (insure, CAS, deleteBlock per covered block — on a long note, a long runner turn; §19.8). `ew text` lands in the leading region (not tokened in the non-join row) and is recorded with `basedOn` = `Alpha one`. The compound lands: the row holds `N`. The debounce fires: `autosave(text: "New text", expectedText: "Alpha one")` meets `N` → displaced ≠ expected ≠ text → a 'conflict' take `N` is minted on the block (`Operations+Variant.swift:66-75`). The block is now fanned, and the next ⌫-join beside it refuses as fanned. The same happens on the most ordinary sequence when the keyboard applies a late autocorrection to the last word of A after a mid-paragraph Return (whether that order happens is probe Q6).

**Change required.** Every region an act touches — identity *or* text — is held from the door until the act's result arrives; held typing is recorded afterwards with the result's text as `basedOn`. State it in §8.5 and make it a column of the identity table.

#### N4 — The ⌫/⌦ join's refusal set is not the Mac's

**Sections:** §7 step 2 ("a backspace beside a fan, an archived take, a comment or a locked take is refused"), §8.2 rows 2–3 (lines 299–300).

The Mac's texted-seam merge refuses on exactly one fact: a live **active** fan of more than one take on either side, read from the store (`EditorSurfaceController.swift:2470-2482`; `liveActiveFans` filters `status == .active`, `:2525-2534`). It does **not** refuse an archived take, a comment, or a locked take: "Locked takes deliberately do NOT refuse: merge COPIES the rendered texts" (`EditorEditRoute.swift:519-523`); merge carries both sides' comments (`Operations+Structural.swift:924-925`). The guards v2 lists are the *carve's* (`EditorEditRoute.swift:454-478`), which apply only when one side is empty. Built as written, ⌫ at the start of a paragraph after a commented paragraph refuses on the phone and joins on the Mac. Comments are an everyday feature, so this is a frequent divergence from her 2026-11-22 ruling ("backspace at block start joins with mac's exact rules").

**Change required.** Split §8.2's refusal row: the carve declines on fan, unshown text, lock and gap (from facts, re-checked by the op); the join refuses only on a live active fan (from the store, N2). Add the Mac's fan sentence in phone words (`seamFanRefusal` names Mac roads).

#### N5 — The open end: type-time crystallization fires at the next character, not at Return, and its trim has no door

**Sections:** §10.5, §13.2.

`SegmentationRules.crystallizedBoundary` mints a paragraph only once a *later* non-blank segment exists (`SegmentationRules.swift:149-167`). At the Return itself (`Hello⏎`) nothing crystallizes; the paragraph mints when she types the first character of the next one. `TypedReturn` answers `.content` for any Return in a tail with text and for a note with no blocks (`TypedReturn.swift:130-137`). So §10.5's "At a Return in it, the shared planner says which completed paragraphs become blocks … the page is normalized inside the door" describes a moment at which the planner returns nothing. The real moment is an ordinary keystroke, which has no door.

The piece is trimmed (`trimmedPiece`, `:191-203`). iOS's double-space period leaves `sentence.␣` at a paragraph's end, so the trailing space is ordinary, and every fresh note (a journal entry, her main phone road) runs through this until the first idle mint. Either the page is normalized outside a door, one line above her caret, while she types (the K2 class on the commonest road), or the stored text differs from the page and §13.2's check — which "expects no differences" except the idle mint — reports a mismatch on every such paragraph.

Separately, "the idle mint stores the text exactly as it stands on the page" must keep the Mac's trailing-newline rule (`CrystallizationPlanner.swift:158-214`: r trailing newlines keep r−1 as the open tail and the last becomes its separator). Read literally, `Hello⏎` + a pause mints one block `Hello\n`, and her next paragraph is typed inside it as content: one block where the Mac makes two. And the chip-off `oneBlock` kind (the whole open end mints as one block verbatim, `:215-217`) has no row.

**Change required.** Restate §10.5 per kind: typing (fires at the next character; decide, with her, between (a) normalizing the previous line through the text view's own calls on the next turn, (b) minting it untrimmed as the idle mint does, (c) crystallizing only at Return, one paragraph late); bulk (the paste door, normalized inside it — as on the Mac); idle (the trailing-run rule stated); one-block. Encode the chosen difference in §13.2's expected differences. Extend §20.3 to cover the typed road too.

#### N6 — The rescue cannot be built on `AutosaveCoordinator` as it is

**Sections:** §11.3, §11.4, §20.1.

- The coordinator reports only the *first* error of a batch (`AutosaveCoordinator.swift:219, 246, 249-251`), and the error does not tell the editor which entry failed. Two refused regions in one flush (the Mac merged two blocks she typed in) produce one notice.
- A refused entry goes back into `pending` and has no road out: `pending` is `private(set)` (`:43`) and there is no discard API. After a rescue rebinds the region to a new block, the old entry retries at every flush, is refused, and fires the error again. Either the editor rescues it again (duplicate blocks of her words) or it remembers and ignores it, and the coordinator stays dirty forever: `isDirty` true, `hasPendingAutosave` true (`AppSession.swift:421-423`), so every sync round flushes and every projection consumer that defers on dirty defers.
- "At the region's place" is undefined when the region's block is gone and its neighbours may be gone too (a Mac merge releases both). Which surviving region anchors `newBlock(.after/.before)`, and what if that anchor dies between the read and the write?
- The rescue can itself be refused: sealed (covered), note deleted elsewhere (not covered), anchor gone (not covered), take archived elsewhere (not in §11.4's list at all; `editableVariant` refuses it).

**Change required.** List the coordinator changes the rescue needs (a per-entry refusal callback carrying the variant id and the text; a way to remove an entry once rescued) beside §20.1's two, for her word — or move the rescue's bookkeeping into an editor-side wrapper that never lets a refused entry stay in the coordinator. Define the anchor rule and the rescue's own refusal road ("words kept on the page, typing stops, Copy offered" for every rescue refusal, not only the seal).

#### N7 — "Every flush road also waits for acts in flight" needs shared changes the plan says it will not make

**Sections:** §0 ("The two additive changes in §20.1 are the only shared-code changes this plan foresees"), §11.1, §17.

The flush roads are in `Shared/AppSession.swift`, compiled into the Mac: `flushExistingAutosave` (`:383-387`; used by VersionActs, the copy family, note deletion), `flushPendingTypingBeforeRound` gated on `hasPendingAutosave` (`:634-639`; sync's VX-683 occasion), `savepointOnLeaving` (`:668+`), `runCopying` (`:591-596`), `flushEveryOpenPost` (`:612-616`). Each knows only the coordinator. An act in flight and its token-held saves are invisible to all of them; in particular `hasPendingAutosave` is false while a token region holds her typing, so sync's round proceeds without flushing it (the sync reviewer should trace what the pull then does to the blocks the act is about to touch). For them to wait, `AppSession` needs a per-post "acts in flight" hook — a third shared change, Mac-compiled.

**Change required.** Name the hook (for example a per-post async fence the editor registers and `flushExistingAutosave`/`flushPendingTypingBeforeRound`/`savepointOnLeaving` await, absent = today's behaviour), list it in §20.1 for her word, and say that `hasPendingAutosave` must count held saves.

#### N8 — The durability order flushes before it waits for acts

**Section:** §11.5 ("settle what is forming by its kind, mint the open end, flush the saver, wait for acts in flight").

An act's held saves enter the coordinator only when the act binds. Flushing first and then waiting returns with those saves *recorded but debounced*: the leaving savepoint (`closeAutoCommit` reads rows) misses them, and a kill after backgrounding loses them. The open end's mint is itself an act.

**Change required.** Settle → mint the open end → wait for acts (each of which flushes first) → flush → repeat until the coordinator is clean and no act is queued → then continue.

#### N9 — Deliveries are not fenced against the editor's own in-flight acts

**Section:** §12.2.

An act's write commits on the runner; GRDB's observation then delivers the new projection on the main actor, and the act task's continuation also resumes on the main actor. Their order is not guaranteed (inference; nothing orders them). If the delivery runs first, the map still holds unbound tokens, and the projection holds block ids the map has never seen and lacks ones it holds. §12.2 applies "structural changes (a block added, removed, merged …)" through the text view's own calls — that is, it applies the editor's own act a second time, as if it came from another device. The old editor avoids this by deferring projections while it is busy (its policy's busy input is "autosave dirty or a mint in flight", audit F2; its structural doors then settle through one fresh read); v2's §12.2 has no such rule.

**Change required.** While any act is queued or in flight, structural differences are deferred (text facts may still update); the diff treats token regions as pending ids; a delivery is applied only against a map with no unbound tokens.

#### N10 — Rebasing `stored` on the op's result lets the page win silently

**Section:** §10.1 ("After every operation returns, each touched region's stored text is set from the operation's result").

If the result's text differs from the region's settled text — a remote edit landed between the door and the op, the op normalized differently from the door (a table error), the delete join was resolved on store texts that differ from the page — then the next save sends the page with `expectedText` equal to the row, no rescue fires, and the difference is overwritten without a trace. §13.2's leaving check then sees agreement. This is B2's "the page wins", one save later.

**Change required.** After an act returns, compare each touched region's result text with its settled page text. Equal: rebase. Different: count and trace it, keep the CAS base at the *old* stored text so the next save takes the S5 rescue road, and say it during the trial.

#### N11 — M12 is not resolved: keyboard deletes anchored at her caret are still "not hers"

**Sections:** §8.6 step 1, §9.1 reason 3.

"Hers only if its old range is exactly the selection she had, or it removed exactly the one break at her caret." A word delete (hardware ⌥⌫), ⌘⌫, or the software keyboard's accelerated held delete at N's start removes `word⏎` — more than the break. If it arrives at `deleteBackward` with a selection, the door routes it correctly; if it arrives by any other call (which call carries it is probe Q6), the gate declines it or §8.6 inverts it, where the Mac's route clamps it (the word goes, the break stays, `CrossBlockCompound.swift:169-247`) or J9-deletes a one-word block.

**Change required.** "Hers" = the range equals her selection, **or** an empty-replacement deletion whose range ends at her caret (backward) or starts at it (forward). Keep stale-position proposals (non-empty replacements, ranges not anchored at the caret) out.

#### N12 — The inverse of a refused act is undefined once she has typed past it

**Sections:** §8.5, §8.6 step 3.

v2 writes the page before the store answers; the Mac never does ("The store leads — the surface is never pre-written optimistically", `EditorSurfaceController.swift:285-290`). So every act the store can refuse or alter needs an inverse. For a compound or J9 refused after the door (a lock or seal arriving, the CAS, N2's guard), the inverse must put back covered blocks' text that is no longer on the page, around whatever she typed into the leading region since. §8.6 step 3 says "nothing is ever restored from saved text", which forbids the only source. For chained tokens (⏎ then ⏎ in the new block, first act refused) the second act names a token that never binds; the plan has no cascade rule. The step-3 fallback "all the text stays in the surviving region" leaves the struck block in the library still holding its text, so the next save duplicates it unless a merge is queued.

**Change required.** Keep each act's pre-door page snapshot of the regions it removes until the act returns. On refusal: restore the removed regions from that snapshot at their old positions, keep everything typed since where it is, refuse every act chained on its tokens, and say so. For §8.6's fallback, queue a merge (an act with a token) so the library follows. Alternatively, for acts whose refusal cannot be predicted from the page, hold her keystrokes during the flight and replay them after it, as the Mac does (`scheduleCrossBlockCompound`'s deferred keys).

#### N13 — Return's divide rows omit the planner and the seal

**Sections:** §7 step 1, §8.1 rows 5–6.

`.divideAtCaret` carries no cut. The Mac runs `plan(.divideAtCursor)` (`EditorSurfaceController.swift:1070-1071`), which settles the cut with the sentence pull (`StructuralGesturePlanner.swift:200-221, 232-237`; `BoundarySnapping.swift:141, 150-162`). `Hello. A |cat` (caret before `cat`) divides before `A` (the #161 tie): `Hello.` / `A cat`. `.divideAtWordStart` runs `plan(divideAtExactCut:)` (`:169-173, 243-250`). The planner also returns the locked-take, gap, open-tail and nothing-to-do refusals and routes a fan to `.divideW` (with a nil cut meaning refuse). §8.1 says only "the whitespace at the cut", with no source for the cut. And no door runs the seal/stood-down/gone belts before writing the page.

**Change required.** Name the planner calls in the rows; make §9.1's belts 1–2 the first step of every door.

#### N14 — Rows that are missing or wrong

- **Return over a cross-break selection.** `TypedReturn` answers `.content` for any selection (`TypedReturn.swift:124-126`); on the Mac the newline then meets the route with replacement `"\n"`. In the new core the catch conditions overlap ("the text is `\n`, or the selection crosses a break"). Say that a cross-break selection goes to §8.3 whatever the text.
- **The list exit** (VX-655) and outdent: see §1's MINOR row. The exit is lead deletion + continuation-newline retraction + `newBlock(.after)`, with A's text changing (N3) and a blind `autosave` in the act body (`EditorSurfaceController.swift:998-1003`).
- **Extract, prefix case.** The minted block is placed *before* A (`Operations+Structural.swift:105-107`), so A's old break (or the head) goes to the token and the new `"\n"` to A. "The source keeps its mark where the operation keeps its identity" reads either way; the wrong reading swaps the two blocks' texts. Extract also trims the span's outer edges (`trimLeading`/`trimTrailing`), which the page must match.
- **The structural undo/redo door** must enqueue to the act task, or an Undo pressed while an act is queued undoes the act before it.
- **§8.4's "Divide choosing takes, Merge choosing takes"** name sheets the phone does not have (ruled exclusion, `MobileStructural.swift:458-464`; MobileSoul §4.5). **"Merge with … Next"** does not exist on the phone (only `mergeWithPrevious`, `MobileStructural.swift:237-360`).
- **`makeBlockAcrossBlocks`, `mergeChain`** (planner cases): the phone refuses the first in words and has no door for the second. Say so.
- **The rescue's mint** (a `newBlock` with a token) and **crystallization's `oneBlock` kind**: no row.
- **Caret landing** is absent from every row. Most rows land right by the edit's own geometry (I checked the carve's VX-290 landings, the join, `.emptyBlock(.above)`), but J9, Delete/Archive (AppSpec §9: "land at the start of the block below, else the end of the block above"), the compound and Merge with Previous need an explicit selection write, and VX-290 is a ruling. Add a caret column.

#### N15 — The proof plan checks the editor against itself, not against the Mac

**Sections:** §14.2, §14.3, §15.4.

The oracle runs "the real shared rule and the real operations" from the editor's starting state and asserts the library equals the page. If the editor refuses a join the Mac performs (N4), nothing runs, and the library equals the page. If the editor folds a fan the Mac refuses (N2), the library equals the page. Both pass. "Every row of the review's table of Mac results (its §3) is a named case" helps only where that table has the case, and it has neither. The self-test's steps (§15.4) also miss both.

**Change required.** A parity oracle: for each named case, the Mac's expected outcome (blocks, fans, chosen takes, comments, caret, refusal or not) written as a fixture from the Mac's own executor logic and suites, compared with the phone's outcome. Add self-test steps: Return then ⌫ in a block with takes; ⌫ after a block with a comment; ⌫ after a locked block; Return before a one-letter sentence opener; Return at a block's first word; the list exit; a fresh note typed through two paragraphs with a trailing space.

#### N16 — Sequencing: the Write screen's chrome has no unit, and U3a's trial runs without outside changes

**Section:** §17.

`MobileWriteView` drives the note's chrome through the old view model: `renameNote`, `lockNote`/`unlockNote`, `setEntryDate`, `copyNote`, `presentFind`, `undoDoor`, `structural`, `jumpToBlock`, `header`, `displayTitle`, `take/releaseAutosaveHold`, `arrive`, `placeMemory` (25+ members). Tags, membership, versions, references, the tray, the block list, block selection, the comments sheet and the callout/name/commit rows are further files wired to it. "No feature is made to work with both editors" means each must be rebuilt for the new screen, and only some appear in U5a/U5b. Either the new screen launches with a stated minimal chrome (and the trial lives with it), or the units grow.

U3a's trial is on "chosen notes" of her real, synced store, but §12.2 (changes from the library) is U4. During U3a the Mac's edits to an open note have no specified handling in the new editor. At minimum U3a needs a conservative posture: any structural delivery for the open note lowers, rebuilds and raises (or closes the note with a sentence), and text deliveries to other regions wait.

### MINORS

- **§9.1/§10.4 multi-range.** The system replaces one range and deletes the others; "one change over the union" deletes the text between them. Decline a multi-range change that crosses a break, or treat it per range.
- **§12.3 undo.** Keep text undo after the clamp (#109's own reason). Clearing inside the keyboard's call, while UIKit's event undo group is open, is unprobed (inference: `removeAllActions` mid-group has been known to trip NSUndoManager's grouping bookkeeping); and "scoped to this text view's actions" needs the target UIKit registers typing undo with, which is unknown. Defer the clear to the next turn or probe it (P2).
- **§5.2 marks.** Say when re-marks are written (after the pass, never inside the storage delegate's callback) and which duplicate is stripped.
- **Doors not covered** (§4 below lists every road). Dictation, Live Text's "Scan Text" (`setMarkedText`/`unmarkText`), Translate's "Replace with Translation" and an IME composition can each replace a cross-break selection without a door; §8.6 step 2 must wait for the replacement to stop forming, and saves for those regions must be held meanwhile. Simplest: decline a break-striking change whose replacement is marked or a dictation placeholder, with a sentence.
- **Text drops** into the note from another app are not addressed (§13.1 turns off drags *within* the note only).
- **Find.** State that replace stays off (`supportsTextReplacement = false`, `MobileEditorTextView.swift:1074`).
- **§10.3.** The switch writes the note's segmentation, which also governs paste and fresh-text crystallization (`kindForTailEdit`, `CrystallizationPlanner.swift:117-123`). Say so.
- **§11.6** omits forming text at a kill (a long dictated utterance may be all forming) and saves awaiting a rescue.
- **§14.3** asserts "no text older than the debounce lost at a kill", which contradicts §11.6's own stated exposure (token regions, the open end).
- **§13.2's periodic check** during the trial reads the whole page on the main thread every few seconds of pause: O(note) at her note lengths. Run it off a snapshot.
- **§15.5's first-change `insureTakes`** is a new quiet auto-commit occasion. AppSpec §9 lists the occasions as ruled; it writes into her real store and syncs to the Mac. List it in §20.
- **§20's run-2 gate** omits §20.5 (composition at durability moments), which U3a builds.
- **U4's two-device session**: name the account and stores. The Debug Mac app never signs into her account; the phone holds her real store. The road is her real account with Release-class builds and a scratch note, or a vxtest account on a simulator against the Debug Mac via the prod test road.
- **Dictation's final result** can arrive after the text view resigns (inference); leaving or locking mid-dictation needs a bounded wait.
- **Facts' freshness from deliveries** (§5.3) must map shown (peeked) takes, as §13.2 does.

### NITS

- §20.12 is stale: §2 records that she asked for both second-round reviews.
- §11.2 "compared as the library stores text": name `StoredText.stripped` (U+0000 only, `StoredText.swift`).
- §17 "What each run touches" omits U2's phone-target files.
- U1's whole-page snapshot per pass on the 50,000-word page will distort Q16's latency reading; snapshot on the short page only.

---

## 3. The identity table, row by row

Checked against `TypedReturn.swift`, `EditorEditRoute.swift` (incl. `SeamCarvePlan`), `BlockRangeIndex.swift`, `CrossBlockCompound.swift`, `StructuralGesturePlanner.swift`, `KeepOnTopDivide.swift`, `MergeJoin.swift`, `BoundarySnapping.swift` and `Operations+Structural.swift`.

| § | Row | Page | Marks/tokens | Operation | Verdict |
|---|---|---|---|---|---|
| 8.1 | `.content` | ✓ for an in-region caret | — | — | **Wrong for a cross-break selection** (goes to §8.3 with `"\n"`); **the list exit is not content** (missing row); "text in the open end → §10.5" points at a mis-timed rule (N5); chip off = `oneBlock` crystallization unmentioned |
| 8.1 | `.emptyBlock(.below)` | ✓ (`"\n"` after trailing whitespace; the Mac's trailing rule, `TypedReturn.swift:216-220`) | ✓ T on the new `"\n"` | ✓ `newBlock(.after(A))`; T genuinely bare | ✓. Chain case (A empty): the new `"\n"` sits right after A's marked break — the own-edit scope must mark before the observer's uniqueness check runs (N1) |
| 8.1 | `closingEmptyTail` | ✓ nothing inserted | ✓ | ✓ | ✓ |
| 8.1 | `.emptyBlock(.above)` | ✓ `"\n"` at A's start | ✓ (B1 #5 fixed) | ✓ `newBlock(.before(A))` | ✓; caret lands at A's start, as the Mac's `caretOffset: 0` (`EditorSurfaceController.swift:1009-1015`) |
| 8.1 | divide, one take | **Cut source missing** (planner settle / exact cut, N13); "the run stays" imprecise (spaces in the run are trimmed) | ✓ C on the new break | ✓ `divide`; but planner refusals not routed; C's facts wrong (comment copies, N2); A's text changes → must be held (N3) | **Incomplete** |
| 8.1 | divide, several takes | ✓ | ✓ B and C | Keep-on-top needs the store read, the unfanned fallback (B binds to A), `compose == nil` refusal, nil-cut refusal | **Incomplete**; B's facts are *fanned* (N2) |
| 8.2 | carve | ✓ the carved block's own break; first-region case re-points the head to the survivor | ✓ | ✓ `deleteBlock(…, .emptyWithNothingUnshown)` | ✓ geometry (both landings verified); guards depend on correct facts (N2) |
| 8.2 | join | ✓ delete join (resolved by the op on store texts; equal after a flush if nothing is forming) | ✓ M | `merge(…, .deleteKeystroke)` **lacks the store fan check** (N2); A′ carries both sides' comments; presentation kept only if both agree — the decor must follow the result | **Wrong refusal set** (N4), **unauthorized fan** (N2) |
| 8.2 | refuse | — | — | — | **Wrong set** (N4): join refuses on live active fan only; carve declines on fan/unshown/lock/gap. Two sentence sources (diagnosis vs. the fan sentence), not one |
| 8.3 | `.deleteWholeBlocks` | ✓ own break; first region takes the following break; empty page → head = open end | ✓ | ✓ per block, one entry | ✓; J9 takes a locked block (#33(a)) — gate must not decline the door's edit (N1); caret = `caretLandingAfterRemoving`, set explicitly |
| 8.3 | `.editInBlock` (clamp) | ✓ | — | ✓ ordinary save | ✓, but must **not** clear text undo; A's region text changes (N3) |
| 8.3 | compound, join | ✓ `leading.newText + trailing.newText` | ✓ M on the leading break/head | ✓ `apply`; fan from the store at run time | **Binding needs the merged variant id** (not in `Outcome`); CAS needs no intervening save of the edges (N1/N3); inverse if the store refuses to join unspecified |
| 8.3 | compound, no join | ✓ one `"\n"` kept/inserted, trailing binding | ✓ | ✓ | Edges' text changes → hold (N3); if the store *joins* where the page kept a `"\n"`, the inverse (remove the `"\n"` at her caret) is unspecified |
| 8.3 | refuse / awaiting sync | — | — | — | ✓ |
| 8.4 | Divide | ✓ "as Return's divide" | ✓ | ✓ (the phone's menu divide is caret-based, `MobileStructural.swift:108-208`) | ✓ given N13's fixes |
| 8.4 | Divide/Merge choosing takes | — | — | — | **Names things the phone does not have**; remove |
| 8.4 | Merge with Previous / Next | ✓ no character change | ✓ | ✓ plain `merge` or carry-all `mergeCeremony` per the store's fan (`MobileStructural.swift:285-343`) | "Next" does not exist; A′ may be fanned and carries comments (facts); caret to the join needs an explicit write |
| 8.4 | Extract / Make Block | Extract: seam trim **and** the span's outer trim | **Prefix case ambiguous** (A's mark must move to the new `"\n"`) | ✓ | **Ambiguous**; Make Block across blocks (phone refuses) and fanned middle span (refuses) not stated |
| 8.4 | New Block Below | ✓ | ✓ | ✓ | ✓ |
| 8.4 | Delete / Archive Block | ✓ | ✓ | ✓ | caret landing (AppSpec §9) needs a write |

**Acts and answers with no row:** `TypedReturn` — none missing as cases, but the list exit (which reaches `.emptyBlock(.below)` with a retraction) is a distinct act. `EditorEditRoute.Route` — all cases covered (`.refuseFindReplace` is unreachable with `findReplacing: false`). `StructuralGesturePlanner.Plan` — `.mergeChain`, `.makeBlockAcrossBlocks`, `.divideW` from the menu on a one-word take (nil cut) have no row. `CrystallizationPlanner.Kind` — `.typing` mis-timed, `.oneBlock` missing, `.idle`'s trailing-run rule unstated, `CrystallizationReconciler`'s corrections/deletions after a mint returns not mapped onto tokens. Menu doors in `MobileBlockMenu` — comments, callout, name and commit are not structural but need a block id (unavailable on tokens, §8.5) and are in no unit (N16). Structural undo/redo, Put back from the tray, and the takes sheet's `takeToBlockBelow`/`takesToBlocks` — undo has no page-edit spec beyond "by §12.2"; the sheet-borne acts are covered by "rebuild when the sheet closes".

---

## 4. The doors

### 4.1 Roads that reach the page without the four overrides or the menu

| Road | What v2 does | Right? |
|---|---|---|
| Hardware Return | `insertText("\n")` door | ✓ |
| Hardware ⇧⏎ | arrives as `insertText("\n")` | ✗ needs a priority `UIKeyCommand` (unstated) |
| Hardware ⌦, ⌥⌫, ⌘⌫, held-delete acceleration | unknown call (Q6); if not a door: gate reason 3 / §8.6 | ✗ narrow "hers" test (N11) |
| ⌘X / ⌘V / edit menu Cut, Paste | `cut(_:)`, `paste(_:)` doors | ✓; the doors must write/read the pasteboard themselves and lose smart insert/delete spacing (feel) |
| Edit menu "Delete" (`delete(_:)`, where offered) | not a door → gate → "exactly her selection" → hers → §8.6 step 2 next turn | acceptable fallback |
| Edit menu Replace… (spelling) | private road; within a word | ✓ in-region |
| Translate → "Replace with Translation" | private road over the selection; not a door | fallback via §8.6 step 2; unprobed |
| AutoFill → Scan Text (Live Text) | `setMarkedText` + `unmarkText` (research §4) | ✗ forming replacement over a cross-break selection; not addressed |
| Prediction bar / autocorrect on a selected word | may not ask (research table) | §8.6; fine if rare |
| Double-space period, smart dashes | no ask, in-region | ✓ rule 2 |
| Text replacement expansions | in-region (may contain newlines → content) | ✓ |
| IME composition over a selection | `setMarkedText` replaces the selection — not a door | ✗ not addressed |
| Dictation over a selection; dictation "new line"/"new paragraph"; spoken editing commands | not doors; "new line" is content (§10.2) | partly; cross-break dictation not addressed |
| Drag and drop into the view | not addressed (drags within the note are off) | ✗ |
| Find and Replace | replace off today | ✓ if kept; say so |
| VoiceOver rotor editing | Q17 | open |
| Text undo/redo (shake, ⌘Z, three-finger) | cleared after every door | ✓ except over-clearing the clamp |
| Structural undo/redo (the line's Undo) | §12.2 | ✗ not serialized with the act task |
| Writing Tools, iOS 27 proofreading | off if silenceable | ✓ |
| `insertText(_:alternatives:style:)` (dictation alternatives) | bypasses an `insertText(_:)` override (inference) | in-region, ✓ |

### 4.2 Is the synchronous, mark-changing edit inside `insertText`/`deleteBackward` safe?

Partly evidenced: the phone's list continuation already makes a second edit inside the keyboard's `insertText` call and works on her phone (`MobileMarkdownActs.swift:160-199`). What is not evidenced, and what v2 does not specify:

- **Re-entrancy into the editor's own observer:** N1. The observer will run inside step 3.
- **Re-entrancy into the doors:** calling the public `insertText`/`deleteBackward` from a door re-enters it (N1); use `super` or `replace`.
- **The gate:** consulted or not depending on the road and on a hardware keyboard (VM-78). The scope must make the answer irrelevant.
- **The autosave:** any `record` during the scope is wrong (N1, N3).
- **UIKit's undo grouping:** the door's `replace` registers inside the keyboard event's undo group; clearing inside that group is unprobed (MINOR above).
- **The out-of-process keyboard:** after `deleteBackward` was asked and a space was inserted instead, the keyboard's context and auto-shift/autocorrect bookkeeping follow UIKit's input-delegate notifications. Probe Q7 tests "carries on correctly"; it should also test autocorrect-revert state (P3).

**What the observer must do with the editor's own edits:** verify against the door's expected map and do nothing else (N1). The plan currently says nothing.

---

## 5. The saver, traced

Against `AutosaveCoordinator` (`record`/`flushNow`/`isDirty`/`isUnlanded`, per-variant `pending`, first-edit snapshot, first-error-only notice, refused-back-into-pending) and `AppSession`'s flush roads:

1. **Save by value + the coordinator.** `record(variantID:text:charDelta:basedOn:)` already takes text by value. ✓. But the coordinator keys by variant and keeps the run's *first* `basedOn`; v2's per-region `stored` is not the coordinator's base once a run has started (N3).
2. **Token-waiting regions.** Their saves cannot enter the coordinator (no variant id). They live in the editor until binding — invisible to every flush road (N7) and to `hasPendingAutosave`.
3. **The act: "flush every pending save, then run".** Correct ordering on the serial runner (no suspension between `flushNow` returning and `runner.run` being called). Breaks when the pending set contains the door's own post-edit text (N1) or typing into a region the act rewrites (N3).
4. **The placement check.** Sound as a refusal. Its consequence — a refused entry that stays in `pending` forever — needs coordinator changes (N6).
5. **The rescue.** Undefined anchor; refusable; duplicates or sticks without a discard API (N6). It is also an act: it needs a token and must go through the act task.
6. **The takes sheet's card editor.** Not built for the new editor until U5b. When it is: it records into the same per-variant entry as the page. If the page has a pending run for take V when the sheet opens, the card's first `record` overwrites the run's text with the card's (built on the store, without the page's pending words) while keeping the page run's base. The sheet's open must flush the page first (today's phone sets the page uneditable while the sheet is open, inventory §4, but I found no flush on open in the inventory's description). State it for U5b.
7. **Flush roads.** `flushExistingAutosave` (versions, copies, deletion), sync's `flushPendingTypingBeforeRound`, `savepointOnLeaving`, `runCopying`, `flushEveryOpenPost`, the background flush (`MobileLivenessAuthority.flushAll` → each editor's `finish()`), the lock (`mobileWillLock`). Only the last two go through the editor; the five `AppSession` ones need N7's hook.
8. **Orderings that break:** door → observer records → act flush → op (N1); door → keystrokes into a rewritten non-token region → op → debounce save with stale base (N3); durability flush → wait for acts → act releases held saves into a debounce → savepoint misses them → kill (N8); op commits → delivery processed before the act task binds → structural diff re-applies the act (N9); refused entry → rescue → old entry retries forever (N6).

**What a kill can lose**, corrected: the debounce window in ordinary regions; every keystroke typed into any region the act holds (all touched regions after N3's fix) until the act returns and the debounce after it; the open end since the last mint; forming text (possibly a whole dictated utterance); words awaiting a rescue.

---

## 6. UIKit/TextKit assumptions v2 newly leans on

| # | Assumption | If false | Probe detects? | Probe step to add |
|---|---|---|---|---|
| U1 | The doors' own `super`/`replace` calls produce storage notices synchronously inside the call, in a fixed order with the selection and did-change delegates | N1's scope is mis-timed | No | **P1:** inside each door, log `shouldChangeTextIn(Ranges)` (with and without a hardware keyboard), both storage notices, `textViewDidChangeSelection`, `textViewDidChange`, and whether `self.insertText` / `super.insertText` / `replace` re-enter the overrides |
| U2 | Clearing the undo manager inside the keyboard's call is safe, and can be scoped | exceptions, or other fields' undo cleared, or a shake replays the door edit | Q12 partly | **P2:** `removeAllActions()` and `removeAllActions(withTarget: textView)` inside `deleteBackward`/`insertText`; log NSUndoManager warnings; shake afterwards |
| U3 | ⌫ at a block's start always reaches `deleteBackward`, including right after Return autocorrected a word | the join is missed or a revert acts across the break | Q6 partly | **P3:** misspelled word, Return (autocorrected), then ⌫, then ⌫ again; log the calls and ranges |
| U4 | Word delete, ⌘⌫ and held-delete acceleration select-then-`deleteBackward` | N11 | Q6 partly | **P4:** each at a block's start and across an empty block; log whether a selection is set first |
| U5 | A cross-break selection is only ever replaced through the doors | unruled structure from dictation, IME, Live Text, Translate | No | **P5:** start each over a cross-break selection; log calls, gate consults, marked range |
| U6 | Nothing drops text into the view | content arrives unrouted | No | **P6:** drag text from another app into the note, at a caret and onto a selection |
| U7 | Dictation's final result arrives before the editor's teardown | the last words land in a dead view | Q5 partly | **P7:** dictate, then leave the note; dictate, then lock |
| U8 | UIKit does not commit a showing prediction on backgrounding | a guess is saved | Q5 partly | **P8:** with predictions on, background with one showing |
| U9 | The caret after `replace(_:withText:)` lands at the end of the inserted text, also when the edit is before the caret | caret drift after `.emptyBlock(.above)` and the middle carve | Q7 partly | **P9:** log the selection after inserts and deletes before, at and after the caret |
| U10 | A priority `UIKeyCommand` for ⇧⏎ suppresses the `insertText("\n")` | ⇧⏎ makes a block | No | **P10** |
| U11 | Facts from deliveries arrive before the next structural keystroke | N2's class | No (not a UIKit fact) | U3b hosted test: a take added between two keystrokes |
| U12 | Attribute writes for marks are legal at the moment they are made | exceptions or layout corruption | Q10 partly | Log where marks are written relative to the storage notices |

---

## 7. What an implementer would still have to guess; contradictions; names that do not exist

- How the observer, gate and delegates treat the editor's own edits (N1). Which call the door uses (`super`, `replace`, the public method).
- Whether successors' facts come from results; how a token region's facts read (N2).
- Whether non-token regions an act rewrites are held (N3).
- The join's refusal facts (N4); the cut source for Return's divide (N13); the order of the two `insertText` catch conditions (N14).
- When type-time crystallization fires and what it normalizes; what "exactly as it stands" does with trailing newlines (N5).
- The rescue's anchor, its refusals, and how a rescued entry leaves the coordinator (N6).
- How flush roads learn about acts (N7); the durability order (N8); whether deliveries wait for acts (N9).
- What happens when an act's result differs from the page (N10); the inverse of a refused delete/type-over and of chained tokens (N12).
- Caret landings (N14).
- How tokens are represented inside the shared rules' `BlockRangeIndex.Entry.blockID`/`variantID` strings and resolved when the act runs (`newBlock(.after(token))`, `CrossBlockCompound.Plan` fields are `let`); the plan implies but never states that tokens are first-class in every effect.
- How the merged variant id is obtained after `CrossBlockCompound.apply`.
- **Contradictions:** §0/§20.1 "two additive changes" vs §11.1's flush roads and §11.3–11.4's rescue (N6, N7); §11.1 "the debounce only enqueues to that task" vs the coordinator's own debounce `Task`; §5.3 "known without asking" vs the operations' comment travel and keep-on-top's fan; §14.3's kill assertion vs §11.6; §19.4 "old files not edited" vs the switch's branch, the ⋯ item and the liveness registry; §20.12 vs §2; §12.2's lower-rebuild-raise for the caret's region vs §12.4's keyboard-up peek (reconciled only by the probe).
- **Names that do not exist on the phone:** "Divide choosing takes", "Merge choosing takes", "Merge with Next" (§8.4).

---

## 8. Sequencing and sizing (§17)

- **U1 (probe):** one session. Add P1–P10. Keep the whole-page snapshot off the long page.
- **U2 (core):** more than one session as written — the pure geometry, the identity planner for ~20 rows plus the missing ones, the real-ops oracle in the phone target, the random-change harness with an adversary and kill points, the saver order model, 20,000-block benchmarks. Split: **U2a** geometry + identity planner + parity/identity oracle (with fans, comments, caret); **U2b** the random-change test with the adversary and kill points + the saver order model. U2 also depends provisionally on §20.2 (the rescue) and §20.3 (the idle mint), contrary to "U2 does not need them".
- **U3a:** more than one session — text view, observer, marked-range excision, the open end (both mint roads), the coordinator integration and its shared changes, the rescue, every durability road (leaving, background, lock, seal, commit doors, through `MobileLivenessAuthority`/`MobileRelock`), the checks, the switch, the base look, and her trial. Split typing + saving + the checks from the open end + durability + rescue. Add the conservative outside-change posture for the trial (N16).
- **U3b:** coherent, but the in-note switch (VM-141) includes a design sitting with her; schedule it before the unit, not inside it.
- **U4:** the two-device evidence needs a named account/store road (MINOR).
- **Missing:** the Write screen's chrome (N16); the comments sheet and the non-structural block-menu rows; the decisions §20.5 and §20.7 in the run-2 gate; the shared-code changes of N6/N7 for her word before run 2.
- **Evidence kind:** U2's state-transition tests are the right kind for a core library; but they must include the parity oracle (N15), or they cannot close the parity the author ruled.

---

## 9. The strongest remaining case against the design

v2 kept the right half of D — accept-then-read inside a block — and replaced the structural half with something that is, in one respect, further from the Mac than v1: it is **optimistic**. The Mac decides at the keystroke whether a key is a structural gesture, but it never writes the page until the store has answered; facts that only the store holds (fans, unshown text, locks, adjacency, comment travel) authorize the act inside the act. v2 writes the ruled page synchronously from a mirror of those facts and lets the store answer afterwards. Everything N1–N3, N9, N10 and N12 describe is the cost of that choice: the mirror must be perfect at keystroke time (it is not, for the editor's own successors); every region the act touches must be held and rebased (only some are); deliveries must not re-apply the editor's own acts (unfenced); and every refusal needs an inverse, which is undefined once she types past it. These are the 13c R3-1 lessons ("a projection names targets, it never authorizes") arriving on the phone by a new door.

A skeptic would also say the design now has four copies of structure and text that must agree — the page's marks, the map, the coordinator's pending runs, and the library — and that every seam between them is currently left to the implementer.

The honest alternative within her constraints is a **split door**: act synchronously only where the ruled result depends on page geometry and facts the editor truly knows (Return's `.emptyBlock` arms; the single-take divide of a block whose take count the editor learned from a result; the carve of a block the editor itself minted empty this session; the clamp); for every gesture whose rule reads a store-only fact (any join, any fanned divide, any carve of a block with unknown facts, every compound), decline at the door, read, and re-issue through the text view's own calls on the next turn (round 1's M1 shape, React Native's October 2026 shape), with keys typed in the gap held and replayed as the Mac does. That costs the probe's A8 question on those keystrokes, but it removes N2, most of N12, and the optimistic-rebase class at its root. If the probe shows the synchronous door is clean and the facts are exact, v2's shape is faster to the eye; if not, this is the fallback v2 already half-names in §7's last paragraph — it should be the planned default for store-fact gestures, not the emergency road.

Second, independent: the plan's units still do not account for the Write screen's chrome, so "four runs and eight units" is an undercount, and her phone keeps today's editor (and its traced windows) for the whole of it. That is her ruling and not for review, but the timeline she is accepting is longer than §17 says.

---

## 10. Changes required before approval, in priority order

1. **The own-edit scope** (N1): expected map computed before the edit; observer verifies, records nothing; gate bypassed; `super`/`replace` only, with a re-entrancy guard; marks written in the same turn. Probe P1/P2.
2. **Facts from results, authorization from the store** (N2): no "known without asking" beyond `newBlock` and crystallization mints; `merge(guardedBy:)` fan check on the ⌫/⌦ join; keep-on-top's store read and fallback; adopt the split door (§9) for store-fact gestures unless the probe and U3b's hosted tests show the map can be exact.
3. **Hold-and-rebase every touched region** (N3), with the hold as a column of the identity table; **the result-vs-page comparison before rebasing** (N10); **the inverse of a refused act**, chained tokens included (N12).
4. **Fix §8.2's refusal set to the Mac's** (N4), and **name the planner and the seal-first belt in Return's rows** (N13).
5. **Restate the open end per crystallization kind**, with the typed road's timing and normalization decided with her and encoded in §13.2 (N5).
6. **Enumerate every shared-code change** — the placement parameter, the coordinator's per-entry refusal and discard, `AppSession`'s act fence and `hasPendingAutosave`, the merged variant id — and put them to her before run 2 (N6, N7). Define the rescue's anchor and its own refusals.
7. **Durability order** (N8) and **deliveries fenced while acts are in flight** (N9).
8. **Widen "hers"** to caret-anchored empty-replacement deletions (N11); add the missing rows and the caret column; remove the rows for things the phone does not have (N14).
9. **A parity oracle and self-test steps** for the divergences above; the oracle compares fans, chosen takes, comments and caret (N15).
10. **Sequencing:** split U2 and U3a; add the chrome or state the trial's minimal chrome; give U3a's trial a conservative outside-change posture; schedule the in-note switch's design sitting before U3b (N16, §8).
11. The MINORs and NITs above.

**Residual risks the author should accept knowingly even after these changes:** the synchronous door's effect on the out-of-process keyboard can only be measured on her phone (K2); custom attributes on `"\n"` are measured for typed characters in the simulator, not for every device road (K1); the phone's message-line rule means a join or Return made by accident has no visible Undo; and the old editor's traced windows stay on her phone for the whole effort, by her ruling.
