# 13n-c combined ladder — round 1 (cold review, fable-reviewer, 2026-10-11)

**Reviewer model (stated per the plan's §5 rule): Fable 5 (`claude-fable-5`), xhigh.**

- **Prompt:** `notes/REVIEW_PROMPT.md` verbatim (PHASE = 13n-c) plus a mechanics-only note naming the range.
- **Scope:** `33bd8772..0d2f6ef3` — the whole Opus-reviewed span (U1's R1 fix and R2 onward, U2–U5, both Stage B
  fix passes, the walk's fixes) AND Stage C (U6), one ladder per the takeover schedule item 3. The plan's §6
  FABLE-OWED ledger was treated as the mandatory focus list; every row whose "Reviewed by" column was open is
  dispositioned below.
- **Process:** read-only; the one stage claim (`fable-cold-review-13nc`, targeted Mac suites) was released after
  its run; no instance was touched; nothing was edited but this record.
- **Anchors:** the plan read whole (rulings, D-1…D-5, §3, §6, §7, every unit record, both Stage B fix records,
  the HELD-WALKS record); the four prior ladder records (`13nc-u1-ladder-round{1,2}.md`,
  `13nc-stageB-ladder-round{1,2}.md`) as the prior rounds' findings-and-dispositions anchor; CLAUDE.md + the
  auto-loaded canon; AppSpec §12's MCP DOOR line; `notes/plans/phase-13n-b-mcp-door.md`'s rulings where cited.

**Status: ROUND 1 COMPLETE — 0 BLOCKER · 0 MAJOR · 1 MINOR · 2 NIT.** The owed span and U6 are sound where it
matters: the fence re-key, the one-answer byte-identity, the rungTooLow hoist, the gathering reach, the wing
move's two-sided grant boundary and its exact-row inverse all traced correct and pinned for real.

**Verification run by this reviewer's own hands (not trusted from the records):**
- whole headless package: core **2,633 / 301** green · `VariorumMCPTests` **92 / 14** green · workbook **40 / 6**
  green — exactly the U6 banner's finals; the only skips the standing gated suites.
- targeted Mac run (stage claimed and released): **119 tests / 8 suites green** — `MCPAsksWaitTests`
  (incl. `noSceneHostsTheAskSheet`, F-15's pin), `TutorialMCPChapterTests` (F-17's truth pins),
  `MCPWingFacesTests` (D-U6-1/D-U6-2), `WingSwitcherChordTests` (D-W3/D-W4), `MCPShareFacesTests`,
  `MCPGrantSheetTests`, `MCPSetupMenuTests`, `CapabilityRegistryTests`.
- range hygiene: zero `Sync/`, `Server/`, schema/migration, custody, editor-seam lines (`git diff --name-only`);
  the ONE `Persistence/` change is the purely additive `AppDatabase.observe(tracking:_:)` (F-22); zero
  commit trailers across the range; canon files untouched (deltas held for the merge, correctly).

## Findings (severity-ranked; format: [severity] · where · what · evidence · fix)

### F1 — [MINOR] · `Sources/VariorumCore/Operations/Operations+MCPWingMove.swift:174-233, 265-293` · the wing-move replays resolve a DEAD stood-in wing as "effectively Home" instead of OBSOLETE, and the divergence check scopes the leaving vocabulary by the STORED wing id — two traced consequences

**Mechanism (traced, both directions symmetric):** `revertMCPWingMove`'s obsolete guard is
`sameEffectiveWing(db, note.wingId, rows.destinationWing)` + `wingIsLive(rows.sourceWing)`;
`sameEffectiveWing` (`Operations+Tag.swift:204-209`) resolves a dead wing id to `''`, and the divergence check
(`refuseIfWingMoveChangedSince:272`) builds `Queries.wingScope(column: "t.wing_id", wingID:)` from the entry's
STORED wing id — for a dead id that is `t.wing_id = <deadID>`, which matches no Home (`''`) tag.

1. **The invariant-grade manifestation (sync-reachable only):** client moves a note wing B → wing A
   (`mcpMoveNoteToWing`); A's tombstone arrives by sync while the note stands in it (Delete Wing refuses while
   contents live, so no local door reaches this — but wings sync, and the dangling-pointer state is first-class
   everywhere else: `mcpResolvedWing`, `wingScope`'s `''` arm read it as Home). The note now reads effectively
   Home; she applies a HOME tag to it (the tag road offers the effective wing's vocabulary). Her ⌥⌘Z on the
   client's entry: the obsolete guard passes (stored `A` == stored `A`), source B is live, and the divergence
   check — scoped `t.wing_id = A` — NEVER SEES the Home application. The replay lands: the note returns to wing
   B carrying a live application on a Home tag — a CROSS-WING application (R-13ia-1's one-wing vocabulary; §9's
   "splitting a vocabulary across wings" — exactly what P-13nc-U6-3 refuses in the live-wing case), a row no
   shipped door can otherwise mint (her own move door re-points by path).
2. **The letter-grade manifestation (door-reachable, benign outcome):** client moves note Home → A; she runs
   Move Everything to Another Wing on A (her door moves the note on — stored `''`), then deletes the now-empty
   A. Her ⌥⌘Z on the client's entry: `sameEffectiveWing('' , A-dead)` → `'' == ''` → NOT obsolete, and the
   replay proceeds (revives the note's pre-move Home memberships). The recorded rule (P-13nc-U6-3, T-U6-4, the
   13i-d letter quoted in the file's own doc) says a note "moved on by her door … makes the entry OBSOLETE
   (quiet)". The landed state is coherent (everything stays in Home), but the entry replays where the design
   says it must no-op. While A still lives the guard reads it right (`'' != A` → obsolete) — only A's death
   flips it.

**Red-on-old pin (bug-class, manifestation 1):** stage note in live wing B with a B tag; `mcpMoveNoteToWing`
B → A; tombstone wing A by direct write (the sync-arrived shape the fence tests already use for "a stale synced
row"); `applyTag` a Home tag to the note; run the entry's inverse → today it lands and
`post_tag` holds a live row pairing a `wing_id=''` tag with a note in B (assert the cross-wing pair); with the
fix it refuses `wingMoveChangedSince` (or no-ops obsolete). Manifestation 2 pins the same way through the doors
(assert the replay writes nothing).

**Fix:** resolve wing liveness FIRST in both replays — treat a dead `rows.destinationWing` (undo) /
`rows.sourceWing` (redo) as OBSOLETE (the stood-in wing is gone, so the entry's world is — the 13i-d
`revivalWingScope` letter: a replay that would cross wings does nothing), and scope
`refuseIfWingMoveChangedSince`'s vocabulary read by the EFFECTIVE wing
(`try Queries.wingIsLive(db, id: wingID) ? wingID : ""`) so it can never miss the resolved-Home vocabulary.
Either half alone closes manifestation 1; the obsolete half also closes 2. Feeds P-13nc-U6-3's #211 entry
either way (the dead-wing row of that question's table).

**DISPOSITION (CLOSED — the cross-model flow run to the end, 2026-10-11):**
- **The U6 implementer (Opus) AGREED on both manifestations**, with its own trace confirming the premises
  (`sameEffectiveWing`'s equal-ids short-circuit; `applyTag` landing a Home tag on a dangling-wing note; no
  trigger firing on a wing tombstone, so the direct-write staging is the honest sync shape) — and three
  refinements: (1) the OBSOLETE half is the real fix (both wings live for either replay; conflicts with no
  revival rule, all of which assume live wings); (2) the effective-wing scoping alone would be WRONG-shaped
  (in manifestation 2 it would wedge the entry behind a misleading `wingMoveChangedSince` about tags she
  never applied) and is redundant under the obsolete half; (3) an optional #211 alternative — record the
  EFFECTIVE source at capture so such an undo lands in Home.
- **The reviewer's FINAL CALL (Fable 5): the obsolete half, exactly as the implementer refined it** — both
  replays require BOTH of the entry's wings live (`wingIsLive` on the stood-in wing before `sameEffectiveWing`,
  and on the target wing as before); the vocabulary scoping is NOT shipped (refinement 2 is right — under the
  obsolete half it is byte-identical SQL), replaced by a doc precondition on `refuseIfWingMoveChangedSince`
  ("`leaving` MUST name a LIVE wing — the replays' guards ensure it") so the coupling cannot be silently
  broken; refinement 3 recorded as the #211 alternative, not built (sync-only).
- **Built by the reviewer (this session):** pin
  `MCPWingMoveActsTests.aDeadWingMakesTheReplayObsoleteInEitherDirection` — **RED-ON-OLD, commit `6fac6d5f`,
  5 issues on the pre-fix tree** (the undo moved the note and carried the live Home application cross-wing —
  `wing == away` / `tags == before` / `crossWing == 0` all red; the redo moved from a dead source; the
  door-reachable case revived the let-go membership), the suite's other 10 tests green on both sides (no
  existing pin tombstones a wing — the implementer's claim, verified). **FIX commit `3122cb2e`**
  (`Operations+MCPWingMove.swift` only — core, no face): the pin GREEN, `MCPWingMoveActsTests` 11/1 green.
  **Suite green after:** the whole headless package — core **2,634 / 301** (the baseline + this pin) ·
  `VariorumMCPTests` **92 / 14** · workbook **40 / 6**, standing skips only; no Mac surface touched, so no
  stage run owed. The plan's P-13nc-U6-3 entry gained the dead-wing row (the running PROVISIONALs list).
- Next per the flow: one implementer sanity pass over the fix span, then round 2.

### F2 — [NIT] · the plan's U6 Pieces table (`phase-13n-c-mcp-launch-readiness.md`, row U6-8) · the cell reads NOT-STARTED while the banner, U6-6 and U6-9 record the Mac run (618/99 `TEST EXECUTE SUCCEEDED`)

The orchestrator's LIVE STATUS already names it "an unflipped row, not missing work" — but the plan is the ONE
running record, and a future reader of the U6 record alone reads a hole that isn't there. Fix: flip the cell
with a pointer to the banner finals. No pin (record hygiene).

### F3 — [NIT] · `Sources/VariorumMCP/MCPSession.swift:54-56` vs the app faces · the advice says "until you disconnect" where every app face says "until it disconnects" (P-13nc-U4-1)

Deliberate register difference (the advice addresses the client as "you"), and the durations' wire tokens are
unchanged — so nothing can mislead a client. Noted only so her copy pass sees the pair together; if she reads
them as one vocabulary, one of the two moves. No pin (copy).

## THE FABLE-OWED LEDGER — every open row dispositioned (this round's mandatory focus)

| Row | Verdict | What this reviewer traced and verified |
|---|---|---|
| F-1 (D-1, ⌘J leg kept) | **CONCUR** | Premise re-verified by my own grep: `createOrOpenJournalEntry` (`Operations+Container.swift:80`) is the ONLY mint of a note's own `profile='journal'`; `LibraryViewModel:70` is a read filter, not a mint; copy roads carry the profile. Conservative direction (more asks). R2-2's graduation consequence is correctly a #211 question (P-13nc-4), not code. |
| F-2 (D-2, docs delivery) | **CONCUR** | Both halves built from one fact set: the guide chapter (truth-pinned, `TutorialMCPChapterTests` green under my own Mac run) + `MCPSession.instructions` (bounded 2,000 — her ruling; pinned `MCPAdviceServerTests.theAdviceIsBoundedAsStated`, `theAdviceSaysTheSameFactsTheGuideTeaches`). The first-connect-book alternative stays hers (P-13nc-2). |
| F-3 (D-3, R-AIR-3's clause on wings + every duration) | **CONCUR** | `MCPPaneCopy.confirm` takes a REQUIRED `scope:`; `liveReachClause` is exhaustive (book → her sentence, wing → D-3's twin, note → none); every duration keeps it (membership is live for any duration — sound). On screen at W-4 ("Grant read in “Home” always, including notes added later"). |
| F-4 (D-5, Sync/ untouched) | **CONCUR** | Verified by name over the whole range: zero `Sync/` lines; the fold classifiers read `ai_private_at` as engagement only; no `Sync/` file reads the fence. |
| F-5 (the re-keyed fence classifier) | **CONCUR — solid** | ONE fragment `dailyJournalLegForBook` feeds all three sites (member leg, book facts, grantable filter) so they cannot drift; NULL-safe; the own-profile leg kept; version/pool/tombstoned containers read nil. Mutation-checked five ways (M1–M5, re-read, each red count plausible against the pins I read); `designatingAnotherDailyJournalMovesTheFence` characterizes R2-4's ruled consequence. |
| F-6 (a fenced NOTE answers the one answer) | **CONCUR** | `MCPRefusalCopy.words(.fenced, target)` returns `words(.notShared, target)` byte-for-byte; `words(_:_:asked:)` never appends the asked sentence to `.fenced`; the ask still queues (`MCPAsking`). Byte-identity pinned under a Home-wing read grant across read/export/search/set_entry_date and PROVEN on a real client (walk turn 3, compared by script). AppSpec §12's letter wins over AF-6's clause — the right call. |
| F-7 (a fenced BOOK answers the one answer) | **CONCUR with ruling (a)** | Option (b)'s premise fails exactly as the orchestrator said (a Private mark set AFTER a read is the case to protect). `reaches` returns false for every grant on a fenced book; the decision `.ask(.fenced)` maps to the one answer; a fenced book never raises an ask (`MCPAsking`'s `!(book && fence)` gate). Proven live (walk turn 5). |
| F-8 / F-10 (rungTooLow before the fence — recorded by U1, built by the R1 Fable reviewer, never Fable-re-reviewed) | **CONCUR — re-reviewed and CORRECT** | The hoist (`MCPGrantRule.decide:237-239`) fires only when a LIVE grant reaches the target; for a fenced note `reaches` admits only a per-ask grant naming it, so the grant IS the client's knowledge — no oracle opens. A spent/revoked grant is not live and falls through to the one answer (pinned: `aLiveGrantHolderAskingHigherHearsTheHonestRungAndALapsedGrantTheOneAnswer` — the lapsed-grant byte-equality is exactly the right guard). `offersAlways: fence == nil` holds on the hoisted ask. |
| F-9 (T-2 concurrence — canon over AF-6) | **CONCUR** | CLAUDE.md's own rule (code aligns to spec); the visible cost (a client that read a note hears the one answer once she marks it Private) is the fence's point. The closeout checklist carries the AF-6 supersession — right place. |
| F-11 (the bulk grant op's refusal set) | **CONCUR** | Every note through the one `insertMCPGrant` (same fence/liveness checks as the single op); any refusal throws inside the one transaction → whole act refuses (P-13nc-U3-1, recorded with its alternative); dedup, empty-pick refusal, one stamp. |
| F-12 (Change… as REPLACE) | **CONCUR** | `revokeReplacedMCPGrants` requires each named grant to exist AND be this client's (`mcpGrantNotFound` else); already-revoked rows are no-ops (revoke's own rule); one stamp; a refused new grant rolls the whole transaction back so the old grants stand (the doc's promise is the transaction's own). |
| F-13 (`MCPGrantRule.reach` inside the rule file) | **CONCUR** | Read OFF `decide` itself (highest rung whose decision allows; `consumes: false` so it spends nothing), never a parallel rule — the faces' WHY is the very grant the server would use. `mcpNoteReach`/`mcpBookReach(es)` name the wider place through the authorizing grant's scope only. |
| F-14 (popover Revoke on a wider grant; share doors' render gate) | **CONCUR** | The revoke names THE grant `reach` returned (P-13nc-U3-6 — the why line names it; T-17 hands the FACE judgment to the UX walk, correctly separated); the gate reads `mcpFencedBookIDs` — the complement of the offer's own fence filter on the SAME two fragments, never a parallel fence; `BookSettingsModel.isGrantable` is `mcpBookFacts(...).fence == nil` (F-21's twin). |
| F-15 (arrival X; answer acts only on a waiting ask; denied client's asks forgotten) | **CONCUR** | The self-presenting sheet is gone from `VariorumApp.swift` (the comment + `noSceneHostsTheAskSheet`, green under my own run); `answer` removes-then-acts so one ask can never mint two grants; `deny` forgets the client's asks (a glyph that could only refuse is a dead door — P-2). The cap protects only asks she has open. Wire untouched. |
| F-16 ("until it disconnects") | **CONCUR** | ONE source (`MCPPaneCopy.durationWord`); every live "while connected" string in the app is a comment; the connection-only offer rule holds (sheet + ask road). See F3 (NIT) for the advice's second-person variant. |
| F-17 (the fence's user/model statements) | **CONCUR** | Lesson 4's sentences are true of the build I traced (the two fenced classes; per-ask once/until-disconnects; never always; the ⌘J wherever-filed sentence = D-1; snippets closed — `kind='post'` excludes pools, pinned server-side; the looks-exactly-like-nothing sentence = the byte-identity pin); the advice's twin sentences pinned in `MCPAdviceServerTests`. Truth pins green under my own Mac run. |
| F-18 (⌥⌘A's mint road) | **CONCUR** | Pure `MCPShareChord.decide`: no history → the sheet; already reaching at ≥ the rung → refusal, nothing written; else once/connection only — a key never mints always (a fenced note takes the same per-ask-legal answer). `mcpNewestGrant` counts revoked rows — a fact about her last choice; defensible and recorded. |
| F-19 (the answer road reads CURRENT facts) | **CONCUR** | `refreshAsk` re-reads through `askStanding` (the ONE derivation site), keeps stamp/place, forgets a gone target with the said refusal (`MCPAskCopy.gone`, seam-aware); `durations(for:)` re-reads the refreshed fence, and a book fenced since offers NOTHING (a dead door never drawn); the op's own in-transaction fence check is the belt under her press. |
| F-20 (lesson 1's privacy sentence) | **CONCUR** | On screen and true: grants are local-only rows (no outbox, no sync — `Operations+MCPGrants` header); "what a client reads goes wherever that client sends its work" is the honest boundary A-4 set. |
| F-21 (Book Settings' grant row gated on the fence's own facts) | **CONCUR** | `isGrantable` = the very read `insertMCPGrant` refuses on; parity-pinned to `mcpFencedBookIDs`. Walked (the Private book's row disappears — W-9). |
| F-22 (the ask watch + `AppDatabase.observe(tracking:_:)`) | **CONCUR** | The API is purely additive (no schema, no caller changed); the watch tracks `reading` + `wing` only, fetch = `asksStanding` in one read ∝ the queue (≤ 8), restarted on set changes, stopped when empty; the measured limit (a note's death indistinguishable from an autosave on `container`) is honestly recorded AND pinned (`RegionObservationTests.thePlacementTableCannotTellATrashFromAnAutosake` family), with the dead-note mark caught at Waiting's render and her press — the right trade under P1. |
| F-23 (`decideGathering` + `mcpGatheringFacts`) | **CONCUR** | The decision is `decideWing`'s READ on the gathering's wing (open book included — P-13nc-U6-5, hers), never consuming, never asked (the authority's gathering decide raises no ask; a gathering can be no grant's scope); a fenced gathering gets the fenced-book decision → the one answer. Facts through `mcpReadingFacts(kind:)` — the SAME statement and fence fragments as a book's, kind-split so no road mistakes one for the other; every write tool still reads `mcpBookFacts` alone (M5/M7 mutation-checked; M7's hollow-pin catch and regrowth is exactly the guard working). Members filtered note-by-note through `decide` — the honest count, proven live (the Private member neither listed nor counted). |
| F-24 (the new inverse over a cross-library move) | **CONCUR, with F1 (MINOR) at its dead-wing corner** | The hardest class, done right: her door's body moved VERBATIM (diff read; her suites green unedited); the exact rows read before/after inside the act's own transaction; the inverse flips only those rows (tombstone-the-added, revive-the-removed under tag-live/target-same/no-live-twin, exact-stamp membership revival under `restoreContainer`'s letter — sealed only for a sealed note, finished takes its row back, one wing, no live pair — purge intents voided, the ownership revival pass); the redo mirrors with her frozen refusal re-run; the stamp ping-pong (`LockIsolated` forward/backward) matches GRDB's ms-precision formatter exactly. The divergence refusal is the right default (writes nothing silently; P-13nc-U6-3 a #211 question). The one hole is F1's dead-wing resolution. |
| F-25 (`move_note_to_wing`'s grant boundary) | **CONCUR** | R1's two decisions exactly as ruled (note at EDIT through `decide` — the fence rides inside it, so a fenced note moves only per-ask; destination at WRITE NEW through `decideWing` — a book grant can never name a destination, the open book is read-only); ONE ask, source first; `guardWingMove` re-decides BOTH on one standing read inside the act's transaction and spends the once grants as one union (both or neither — a refused act spends nothing; M1–M4 mutation-checked, M4 proving the guard is the only spending road); the left books named only under read reach on the SNAPSHOT standing (P-13nc-U6-2, AF-10 (f) — deliberate and recorded); the frozen sentence behind a readability gate (P-13nc-U6-4); `move_block`'s cross-wing refusal kept. D-U6-2's activity-title fix is surgical (`logsReceiptTitle: false` for this one tool, every other byte-unchanged). |

## Clean bill (checked by this reviewer's own hands and found solid)

- **The fence re-key (U1):** one derivation site, one fragment, three sites that cannot drift; the byte-identity
  of fenced = unshared = nonexistent pinned under the decisive Home-wing read grant AND proven on a real client;
  the ⌘J own-profile leg's premise re-traced from a clean grep; the five mutation checks' design is the real
  hallucination guard. The six J8 sentences + the wire's three are the mockup's words.
- **The security rule's edits (F-8/F-10):** the rungTooLow hoist is correct and oracle-free; a lapsed grant
  falls back to the one answer, pinned byte-equal.
- **The gathering reach (U6):** read-facts-only under wing-level reach; never a target, never an ask, never a
  spend; the per-note fence filters every member and every count; the prefilter-vs-rule drift class was caught
  by the implementer's own M7 and closed by a grown pin.
- **The wing move (U6):** two-sided decision, union spend, exact-row inverse/redo with stamp ping-pong — read
  line-by-line; her door byte-identical through the verbatim extraction; refusals hers; the live round proved
  the sweep, the undo/redo, the frozen refusal, the show etiquette, and found D-U6-2 — which is why live rounds
  run.
- **The ask road (U4 + Stage B + close-out):** arrival X complete (no self-presenting host — pinned), one ask
  one grant, current-facts refresh at press, the region-tracked watch with its measured limit recorded and
  pinned, denied clients' asks forgotten, the cap protecting open sheets.
- **The grant UX core (U2/U3):** `PlaceLabels`' collision ladder (facts, never ordinals; per-place first-unique
  rung) and the one context line; the grantable-books read reusing the Bookcase's own derivations
  (`memberLastEditedSQL`/`shownMemberNoteJoinSQL` — byte-equal refactor, read in diff); the sheet's duration
  gating (fence withholds always; connection only while connected; `onChange` snaps a stale selection; the
  confirm disabled rather than dead); Change-as-replace one-stamp semantics; the bulk act's one-row/one-Revoke
  grouping (exact-stamp on read, no schema).
- **P1 across the span:** every new query ∝ the page, the books, the grants, the act or the queue; the two
  books×clients one-shots are Bookcase-scale and documented; the gathering page ∝ its assembly (the Bookcase's
  own class); nothing scales with the note corpus; nothing tracks word-level change; no text copied across
  entities (the move is pointer moves + application-row re-points).
- **Neutrality and copy:** the O-4 source sweep is a real literal-level net over all four trees with guarded
  fences (read in full); the wire-neutrality and advice pins are live; sentence case held; the provider names
  live only in the fenced setup copy and the keyword list.
- **Hygiene:** zero `Sync/`/schema/custody/editor-seam lines in the whole range (verified by name); the one
  `Persistence/` addition is additive; zero commit trailers; canon untouched pre-merge; the capability registry
  declares every new door (⌥⌘A, ⌥⌘,, ⌘L, the icon, Waiting's Answer…, the setup menu) with the collision sweeps
  re-run at the tip and recorded inline; prior rounds' findings (U1 R1/R2, Stage B R1/R2) all closed or routed
  exactly as their dispositions say — I checked R2-1's fixture fix, R2-3's inert-fence build, R2-4's
  characterization pin, R2-5's empty-Activity line, B1/B2/B4's builds, and the walk's D-W1…D-W4 pins (green
  under my own run where Mac-hosted).
- **Finals reproduced:** core 2,633/301 · MCP 92/14 · workbook 40/6 (whole package, my run) + the 8-suite Mac
  batch 119/8 green under a held-and-released stage claim.

## ORCHESTRATOR VERIFICATION OF THE FIX LEG (before round 2)

The round's fixes and the sitting's ruled edits (`0d2f6ef3..513c9e04`) verified by the orchestrator's own hands:
fence diff clean (the eight non-notes files are the wing-move core + advice + two copy faces + their tests; zero
`Sync/` · `Persistence/` · migration · editor-seam · custody lines); zero trailers; tree clean, stage free, no
instance; the F1 sanity pass returned SOUND (the implementer's own suites re-run green on the fixed tree); the
advice's while-connected sentence present at `MCPSession.swift:58` with its executed pin and two mutations.
Round 2 (fresh fable-reviewer) runs over `0d2f6ef3..513c9e04`.
