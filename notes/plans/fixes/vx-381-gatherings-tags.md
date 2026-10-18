# VX-381 — Run: Gatherings & tags (VX-284 part A)

**STATUS: IN PROGRESS — kicked off 2026-10-18 (the kickoff record below); written 2026-10-17 at her VX-284 split sitting;
branch `vx-381-gatherings-tags`, worktree `~/dev/variorum-vx-381`.** Members (sub-issues of VX-381): **VX-250 ·
VX-240 · VX-241 · VX-249 · VX-247 · VX-111 · VX-194.** Umbrella: VX-284 (`notes/plans/fixes/vx-383-duplicate-note.md`
§"The split" carries her rulings verbatim). Cast (her word 2026-10-17): Opus orchestrates (her 2026-10-13 cast
rule), `opus-implementer` builds, `opus-reviewer` cold-reviews — all at **xhigh**; no editor seam, `Sync/`, custody,
Keychain or default's-meaning content is expected, so no Fable round is owed (if a diff reaches one, say so to her
before the ladder). Runs WITHOUT her: every copy item below is already ruled.

## KICKOFF PROMPT (paste into a fresh session on the Pro, in `~/dev/variorum`)

> /architect-phase vx-381 — Run: Gatherings & tags, part A of VX-284's split (her 2026-10-17 rulings are in
> `notes/plans/fixes/vx-383-duplicate-note.md` §"The split"; this file is your plan). Cast: Opus orchestrates,
> `opus-implementer` at xhigh, `opus-reviewer` at xhigh, fresh per unit/round. Mint the branch `vx-381-gatherings-tags`
> and the worktree `~/dev/variorum-vx-381` from `origin/main`, push the branch, add your in-flight row atomically, and
> run everything from the worktree. Nothing in `Sources/VariorumCore/Sync/`, custody or the Keychain (VX-378 holds
> that slot). The stage: claim `Tools/stage` for every Mac batch and walk (no coordinator session is live at this
> writing; if one announces itself, route asks through it). Her words rule; where a ticket says "decide", decide
> PROVISIONALLY, record it in this file, and bundle it for QUESTIONS at the merge. VX-216 (author-attended) is NOT
> yours; it runs after your merge. Close with CLAUDE.md's full ritual.

## Members and the rulings they carry (each ticket's body is the trace; her words are already on them)

- **VX-250** — her QUESTIONS #217 answers, exact words given: (1) the mint receipt SHORTER (`BookcaseCopy.shownByMint`,
  `ShelfViewModel.swift`): "Tagged #essays — the gathering shows it now." · "Tagged #essays and starred — the gathering
  shows it now." · "Starred — the gathering shows it now." · "Added to the gathering."; **the one open decision**
  (PROVISIONAL, recommended yes): the shared `shownByTagging` (R98's collect receipt) shortens with it. (2) Greyed
  hovers SHORTER (`GatheringMint.Blocker.reason` + `GatheringNoteDoor.cannot`): "Archived — unarchive it to add notes."
  · "Its rule needs #essays, which no longer exists." · "Its rule can't match a new note."; the remaining blockers in
  the same terse register; a purged/unknown tag path: "Its rule needs a tag that no longer exists."; enabled-state
  hovers as drafted. (3) ALLOW NOT TERMS at the mint: a NOT over a tag the planner isn't applying is satisfied; a NOT
  contradicting a tag it must apply still greys; the in-transaction `matchesRule` belt stays; pins: a NOT rule mints,
  `#a AND NOT #a` greys. (4) VX-240's face.
- **VX-240** — the Settings scene's `.opening` arm (`SettingsSceneContent.swift`) shows "Opening your library…" with a
  spinner instead of "Open the main window first." (her wording, #217). A chrome face — not custody code.
- **VX-241** — the collect receipt on an ARCHIVED gathering says the honest thing (tags applied; the gathering shows
  it after unarchive); wording PROVISIONAL (no shouty caps — her rule). Reachable through the chip's add picker.
- **VX-249** — R98's collect-existing door (`collectPostIntoSmartReading`, `Operations+SmartCollect.swift`) treats a
  star term as satisfiable by SETTING the star through the union-star road (`writeStar`, so intake hears it), same
  transaction and unwind; the receipt names the star; CAP-EXEMPT (her ruling, P-VX217-c); reuse `GatheringMint`'s
  planner where its rules match. Pin: the ★-rule collect refuses on old, sets + reports on new.
- **VX-247** — `Operations.deleteTag` (`Operations+Tag.swift:103`) registers ONE structural-undo entry with an
  exact-row redo (§9's contract): the inverse revives the subtree's tag rows and their applications on the delete's
  exact stamp; the quiet-half rule (VX-246 U2) binds. Pin red-on-old. The Trash/restore road stays VX-238.
- **VX-111** — the shared-note edit notice counts BOOK rows only, live books only (13i-c's readers); the masthead is
  already right. Pin-before-fix.
- **VX-194** — `CalmButtonStyle` reads `@Environment(\.isEnabled)` and draws a token-derived disabled face (her
  ruling: FIX IT IN THE STYLE); fold VX-214 batch 3's one-off on the gathering foot (`GatheringNoteDoor.swift`) back
  into the style; sweep the 17 uses for anything that relied on the old full-strength face. Pin: a disabled calm
  button renders visibly distinct, red on old.

## Suggested units (the orchestrator re-sizes at kickoff and records it here)

1. **U1 — the gathering doors' words and faces:** VX-250 (+ VX-240) · VX-241 · VX-194 (the style fix first, so the
   greyed faces are honest before their words are checked). Walk in both voices: the mint door, the collect door,
   an archived gathering, the Settings scene mid-ceremony (a Debug-only re-key on the DEV store, or a mounted test).
2. **U2 — the operations:** VX-249 (the collect door's star) · VX-247 (tag-delete undo) · VX-111 (the notice's
   counter). Headless pins first; one Mac batch over every suite that exercises the changed source files.

## Overlaps to respect (the runway's §2 conflict map, as of 2026-10-17)

- **VX-383 (part C)** reads the one tag-application road (`insertPostTag`, `Operations+Intake.swift`) and changes
  `Operations+Versions.swift`'s duplicate body; this run changes `Operations+Tag.swift` and `Operations+SmartCollect
  .swift`. No shared file is expected; closeouts serialize (first ready merges first, the next rebases).
- **VX-382 (part B)** touches the book view and the shell's landing road only.
- **Settings:** VX-240's arm is in `SettingsSceneContent.swift`; VX-234 (her wording pass) may touch pane copy — rebase
  carefully if both land close.
- **VX-216** (hers, after this merge) reworks the book/gathering menus and the settings sheets — keep this run's copy
  edits minimal and in the named registers so her sitting starts from a clean face.

## Environment traps (carried verbatim into every brief)

Instance checks use `pgrep -fl 'Variorum.app/Contents/MacOS'` AND discriminate by PATH (the test host matches
mid-run); treat real-store instances by STORE, not path — NEVER quit/kill one; no Release builds or /Applications
refreshes while one lives; `xcodebuild build-for-testing` compiles without the runner; Mac tests from
`App/Variorum/`, suite-level `-only-testing` only, confirm the "Test run with N tests" line; zsh `pipestatus`;
NEVER add a custom build configuration; suites running beside a live session flash the test host's windows on
screen; backups WAL-safe with UTC names, ALWAYS before touching the real store (this run never touches it);
screenshots in gitignored dirs only; never `git checkout` over uncommitted work; commit per piece and push after
every commit (`notes/SessionResiliencyProtocol.md`); synchronous foreground waits only — poll a log with
`grep -q '<EXIT LINE>' <log> && break; sleep 5` in a loop, never `tail -f | grep -m1`; never force-push, never
rewrite history; commits name their member and `Part of VX-381`, with NO attribution trailer of any kind. The dev
store's Castle credentials, if a lock screen appears, are `~/.variorum/dev-castle.env` (never invent, never commit).

## KICKOFF RECORD (2026-10-18, the orchestrator)

- **Seated:** branch `vx-381-gatherings-tags` cut from `origin/main` (base `5fb276a12`, after VX-383's merge
  `d40ac965d`, so part C's changes are in this base), worktree `~/dev/variorum-vx-381`, the Pro. In-flight row
  flipped on main (`23608d43`); VX-381 and all seven members In Progress on Linear.
- **Cast as run:** she launched THIS session as the orchestrator (a Fable harness session — her launch is the
  governing word; the plan's "Opus orchestrates" line is noted, and the Fable budget here goes to coordination
  and adjudication only, zero implementation). Subagents exactly per the plan: `opus-implementer` at xhigh, one
  per unit; `opus-reviewer` at xhigh, fresh per round; no Fable round owed (no editor seam, `Sync/`, custody or
  default's-meaning content expected — if a diff reaches one, STOP and say so to her before the ladder).
- **Units adopted as suggested** — U1 then U2, one implementer session each; the ladder runs ONCE over the run's
  combined diff after U2, then the orchestrator's walk, then closeout.
- **Overlaps re-checked at kickoff:** VX-378 holds the Sync/-custody slot (this run touches none); VX-382 is not
  yet kicked off (no shared file expected); VX-383 is already in this base. The stage: **oct18coordinator is live**
  (her kickoff word) — the run announces itself and routes window asks through it; claims are held per Mac batch
  and walk, released between.
- **Rider check (CLAUDE.md's kickoff rule):** membership stays exactly as she fixed it at the 2026-10-17 split
  sitting; nearby open Low/Medium tickets in this run's areas (e.g. VX-364 dangling-wing outflow refusal, VX-355/
  VX-385 the Pool's receipt home, VX-45 copy family) are NOT taken — listed in the handoff for her to offer at
  VX-216 or a sweep.
- **PROVISIONAL rulings made at kickoff (bundled for QUESTIONS at the merge):**
  - **P-VX381-1** — the shared `shownByTagging` (R98's collect receipt) SHORTENS with the mint receipt, to the
    same register ("Tagged #essays — the gathering shows it now."). The ticket's recommended option; the two
    sentences read identically today, and leaving the long form would split one receipt family into two voices.
    One line to reverse.

## UNIT BRIEFS (self-contained — an implementer reads THIS FILE IN FULL plus the named documents, nothing else is assumed)

### U1 BRIEF — the gathering doors' words and faces (VX-194 first, then VX-250 + VX-240 + VX-241)

**Where:** work ONLY in `~/dev/variorum-vx-381` (branch `vx-381-gatherings-tags`, upstream set). Commit per
coherent piece, push after EVERY commit; each commit's message names its member and carries `Part of VX-381`
(e.g. `VX-194: CalmButtonStyle reads isEnabled — token-derived disabled face. Part of VX-381`), stating the
traced mechanism and the pin for bug-class fixes. NO attribution trailer. Read first: this plan file IN FULL,
`notes/SessionResiliencyProtocol.md` (the checkpoint protocol binds from your first commit — LIVE STATUS flips
in this file's §LIVE STATUS ride each piece's commit), and QUESTIONS.md #217 (her verbatim words, ~line 2443).
Never touch `Sources/VariorumCore/Sync/`, custody/Keychain code, migrations/schema, or editor-seam files
(`EditorTextView`, `BlockRangeIndex`, `PaneSurface`); if a trace reaches one, stop and report. No subagents.
Copy rules: sentence case, never shouty caps; her exact strings land byte-for-byte.

1. **VX-194 FIRST** (so the greyed faces are honest before their words are checked): `CalmButtonStyle`
   (`App/Variorum/Variorum/Theme/CalmGrammar.swift:165`) reads `@Environment(\.isEnabled)` and draws a
   token-derived disabled face — muted ink, no hover or press response (tokens from the voice layer, never a
   literal colour). Fold VX-214 batch 3's one-off disabled face on the gathering foot
   (`App/Variorum/Variorum/Features/BookView/GatheringNoteDoor.swift`) back into the style — delete the one-off.
   Sweep the 17 files using `CalmButtonStyle` for anything relying on the old full-strength face. Pin: a
   disabled calm button renders visibly distinct from enabled (attribute/snapshot oracle), red on old,
   revert-verified.
2. **VX-250 (1) — the mint receipt, SHORTER** (`BookcaseCopy.shownByMint`, `ShelfViewModel.swift` ~:746; a
   second caller sits in `BookStructureModel.swift` ~:803): her exact strings — "Tagged #essays — the gathering
   shows it now." · "Tagged #essays and starred — the gathering shows it now." · "Starred — the gathering shows
   it now." · "Added to the gathering." (#essays stands for the applied tag path(s); keep the existing
   multi-path join idiom). Under **P-VX381-1** (kickoff ruling above) the shared `shownByTagging` shortens to
   the same register, so the tags-only mint arm still reads exactly `shownByTagging`.
3. **VX-250 (2) — greyed hovers, SHORTER** (`GatheringMint.Blocker.reason`,
   `Sources/VariorumCore/Domain/GatheringMint.swift`, + `GatheringNoteDoor.cannot`): her exact strings —
   "Archived — unarchive it to add notes." · "Its rule needs #essays, which no longer exists." · "Its rule
   can't match a new note." Fold the remaining blockers (finished, no rule, unreadable rule, date/kind terms)
   into the same terse register (draft them; the orchestrator checks at the unit close). Deleted tags: the path
   reads from the tag's TOMBSTONED row (the name usually survives); when NO row knows the path (purged, or a
   sync gap): "Its rule needs a tag that no longer exists." Enabled-state hovers stay as drafted.
4. **VX-250 (3) — ALLOW NOT TERMS at the mint** (the Domain planner): a fresh note satisfies `NOT #x` by not
   wearing #x, so the planner treats a NOT over a tag it is NOT applying as satisfied; a NOT contradicting a
   tag it MUST apply still greys; the in-transaction `matchesRule` belt stays untouched. Pins: a NOT rule now
   mints (red on old); `#a AND NOT #a` still greys.
5. **VX-240 — the mid-ceremony face:** `SettingsSceneContent.swift`'s `.opening` arm shows "Opening your
   library…" with a spinner (her exact wording, #217) instead of the stub "Open the main window first." A
   chrome face only — no custody code.
6. **VX-241 — the honest receipt on an ARCHIVED gathering:** the chip's add picker lists archived gatherings
   (13i-e: explicit adds stay open) and `collectPostIntoSmartReading` applies tags correctly — only the
   receipt's claim ("shows it now") is false while archived. Fix at the receipt layer: on an archived target
   the receipt says the honest thing — tags applied; the gathering shows it after unarchive. Draft the
   wording (PROVISIONAL, sentence case; the orchestrator approves at the unit close). Pin: the archived-target
   collect speaks the honest receipt, red on old.

**Evidence (the unit closes on it):** every pin red-on-old verified by behavioural revert; `swift build` +
`swift test` (core) green where Domain changed; ONE Mac batch from `App/Variorum/` over every suite exercising
the changed source files (suite-level `-only-testing` only; confirm the "Test run with N tests" line; grep the
tests for the changed types when in doubt). A Mac `xcodebuild test` run REQUIRES a stage GO
(the coordinated-window protocol below) — never a direct `Tools/stage claim`.
The both-voices walk is the ORCHESTRATOR'S acceptance act after the unit — leave the tree walkable. Fill your
unit's LIVE STATUS lines (DONE (hash) / IN-PROGRESS / NOT-STARTED, PENDING for unverified claims) with every
piece. The environment-traps section above binds verbatim.

### U2 BRIEF — the operations (VX-249 · VX-247 · VX-111; runs AFTER U1 so the receipt register exists)

**Where/rules:** identical to U1's header (worktree, commits per member + `Part of VX-381`, push every commit,
read this file in full + the resiliency protocol + #217, no `Sync/`/custody/schema/editor seam, no subagents).

1. **VX-249 — the collect door sets the star** (`collectPostIntoSmartReading`, R98,
   `Sources/VariorumCore/Operations/Operations+SmartCollect.swift`): treat a star term as satisfiable by
   SETTING the star through the union-star road (`writeStar`, so intake hears it), in the SAME transaction
   with the SAME unwind. CAP-EXEMPT by her ruling (P-VX217-c's twin): the 15-star limit never blocks it.
   Reuse `GatheringMint`'s planner where its rules match R98's, so ONE authority decides satisfiability
   (NOT-term semantics included, post-U1). The apply-and-report receipt NAMES the star it set — under
   P-VX381-1's register that is "Starred — the gathering shows it now." / "Tagged #… and starred — …"
   composed exactly as the mint's family. Pin: the ★-rule collect REFUSES on old, SETS + REPORTS on new;
   exact state-transition coverage for the star write + unwind.
2. **VX-247 — undo for tag delete:** `Operations.deleteTag` (`Operations+Tag.swift:103`) registers ONE
   structural-undo entry with an exact-row redo per AppSpec §9's contract: the inverse revives the subtree's
   tag rows AND their applications (post_tag/block_tag) dead on the delete's EXACT stamp; the redo re-applies
   exactly what the undo un-did (ids and stamps — never a re-run); the quiet-half rule (VX-246 U2) binds — an
   undo that finds the act's result already gone changes nothing and retires its entry. Check every door into
   `deleteTag` registers through the one road. Pin red-on-old (delete → ⌥⌘Z revives subtree + applications),
   revert-verified; a redo pin (undo → redo returns to the exact post-delete rows).
3. **VX-111 — the shared-note edit notice counts books only:** the notice
   (`App/Variorum/Variorum/Workspace/MultiBookEditNote.swift`) fires "in N books" counting gatherings — a
   bookless note in 2 gatherings trips it. The membership readers are RULED to count BOOK rows only, live
   books only (13i-c); align this counter to those readers (the masthead is already right — read how it
   counts). Pin-before-fix: the bookless-note-in-2-gatherings case red on old (notice fired / wrong count),
   green on new; a true 2-book note still speaks.

**Evidence:** headless pins FIRST (`swift test` on the core package — no stage needed), exact state-transition
tests for both op changes; then ONE Mac batch over every suite exercising the changed source files (a stage GO,
per the protocol below). LIVE STATUS flips per piece. The environment traps bind verbatim.

## THE STAGE THIS WINDOW (oct18coordinator's protocol, 2026-10-18 — binds every session in this run)

The stage is COORDINATED: oct18coordinator HOLDS it between grants, so a direct `Tools/stage claim` is refused
and a free-looking stage is never an invitation. Headless `swift build`/`swift test`/`xcodebuild build`/
`build-for-testing` never need it; EVERY `xcodebuild test` does. The flow: the ORCHESTRATOR sends the
coordinator a REQUEST early (what · minutes · claim name), a READY ping when the session can start NOW, and
runs only on the coordinator's GO (which carries the exact claim line); RELEASE + one result line after.
Implementers never talk to the coordinator — they message the orchestrator when ready for their batch (suite
list + minutes), wait in the foreground, and run only on the orchestrator's relayed GO. Walk windows that set
dev credentials (the Debug-only re-key) use exactly `~/.variorum/dev-castle.env` and restore the dev store's
posture (keys, store, Debug prefs re-export + diff) before RELEASE, or report what they left. After every
Debug launch, dismiss a What's New sheet if one shows. Merges serialize with vx-382 through the coordinator
(send branch · tested tree · tip; merge commit only, on its GO).

## ARCHITECT RULINGS (in-batch forks — the implementer proposes, the architect rules; repo-first)

- **R-VX381-A1 (2026-10-18, U1 / VX-194 — the fold step's premise was false):** the ticket's "fold the gathering
  foot's one-off back into CalmButtonStyle" does not apply — `GatheringNoteDoor` was NEVER a calm button (it is
  `.borderless` + accent/faint ink, drawn exactly like BookView's own "+ new note"/"+ new entry"/"+ new chapter"
  foot doors; VX-214 batch 3's comment says VX-194's style "is not this surface's"). Ruled (a): the gathering
  door KEEPS its local face (it already greys honestly per R-VX214-3), its stale comment corrected, the fold
  recorded NOT APPLICABLE. (b) — moving it onto CalmButtonStyle — would put a bordered button beside the book's
  borderless doors and break her VX-217 "the bottom of a book and the bottom of a gathering should look the
  same"; (c) — a new shared foot-word style — would edit BookView's doors while VX-382 (part B, the book view
  doors) is live in parallel. Her "fix it in the style" intent is served by the style gaining honesty app-wide;
  marked PROVISIONAL for her bundle only because it departs from the ticket's literal step. One line to reverse
  (build (b) or (c)).
- **R-VX381-A2 (same exchange):** `CeremonySheetChrome`'s confirm button carries its own
  `.opacity(canConfirm ? 1 : 0.45)` ON a CalmButtonStyle — a genuine one-off that would DOUBLE-DIM once the
  style is honest. Ruled: fold it into the style (delete the local opacity) — WITH the check that the button is
  actually `.disabled(…)` when `canConfirm` is false (the environment's `isEnabled` must be what carries the
  face; if the opacity was the only signal on an enabled-but-inert button, wire the disable rather than losing
  the face).

- **R-VX381-A3 (2026-10-18, U2 / VX-247 — the confirm's false sentence):** the shared tag-delete confirm
  (`TagDeletion.consequence`, Mac AND phone) ends "There is no undo for this." — false once `deleteTag`
  registers its entry. Ruled (a): DROP the sentence on both platforms; the confirm still names the consequence,
  and the calm idiom doesn't advertise mechanisms in confirms (the Delete Book confirm's precedent). The true
  replacement line ((b), "You can undo this with Undo Delete Tag.") is the recorded alternative — one line to
  add if she wants the road said. PROVISIONAL for her bundle (a copy call).
- **R-VX381-A4 (U2 / VX-249 — the phone):** the core change makes the PHONE's ★-rule collect succeed too, with
  a receipt that names no star ("Added by tagging — …" for a star-only collect). Ruled (a): the phone stays
  untouched this run (mobile is its own project; no simulator window beside this stage), and the star case
  joins VM-21 (the phone's VX-241 twin — one phone receipt fix covers both arms). The closeout's MOBILE PARITY
  line carries it.
- **R-VX381-A5 (U2 / VX-249 — the chip):** a collect that SET the star speaks the mint family verbatim
  ("Starred — the gathering shows it now." / "Tagged #x and starred — the gathering shows it now."); the chip's
  LIVE-gathering tags-only receipts keep their shipped words — two voices on the chip until VX-216 unifies them
  (her sitting; already routed there at U1). PROVISIONAL.

## U1 COPY APPROVALS (the orchestrator, 2026-10-18 — the implementer's drafts, each still PROVISIONAL for her bundle)

- **APPROVED — VX-241's receipt pair:** "Tagged #essays — the gathering shows it once it's unarchived." /
  "It already matches — the gathering shows it once it's unarchived." (her register, sentence case, honest claim).
- **APPROVED — the remaining blocker hovers:** "Finished — reopen it to add notes." · "No rule yet — give it one
  to add notes." · "Its rule can't be read — edit it to add notes." · "Its rule needs an entry date, which a new
  note doesn't have." · "Its rule needs a kind of note, which a new note doesn't have." (the terse register of
  her three, held).
- **SUSTAINED — P-VX381-U1-1:** an any-of whose NOT option the fresh note already meets takes no tag
  (`#a OR NOT #b` mints bare; receipt "Added to the gathering.") — the vacuous-satisfaction reading, coherent
  with her ALLOW-NOT ruling; bundled for QUESTIONS.
- **Observations routed:** the chip's live-gathering receipt (a third voice for R98's receipt) → VX-216's
  sitting (noted for her handoff); the phone's twin of VX-241 (MobileMembership lists archived gatherings and
  overclaims) → a VM ticket minted at this approval; the cross-wing-tag hover corner ("…which no longer
  exists." for a live tag of ANOTHER wing — wings isolate, so the tag is genuinely unreachable here) →
  recorded for her bundle, no ticket unless she wants the wording split.

## U2 APPROVALS (the orchestrator, 2026-10-18 — each sustained PROVISIONAL rides her bundle)

- **SUSTAINED — P-VX381-U2-1** (the any-of-with-nested-NOT refusal keeps the mint's conservative arm; fresh-note
  plans byte-identical) · **P-VX381-U2-2** (tag liveness checked in the gathering's WING — wing isolation is
  canon, R-13ia-1; a cross-wing application would have been a worse wrong) · **P-VX381-U2-3** (an undo meeting a
  live same-path tag REFUSES naming `duplicateTagPath` and keeps the entry — the live-unique index would be
  violated; a quiet skip would silently eat her undo; rename-then-undo works) · **P-VX381-U2-5** (an application
  whose note died after the delete stays dead on undo — the exact-stamp discipline, restoreBlock's rule).
- **SUSTAINED WITH A FLAG — P-VX381-U2-4** (redo's subtree rule also takes a child tag SHE made under the
  revived tag since the undo — consistent with the block world's redo-delete taking a take branched since, but
  it is the one item here that deletes something of hers made between the halves; the quiet alternative — a
  grown subtree retires the redo — is recorded in the U2 record). FIRST ITEM for her bundle.
- **APPROVED — the composed wording** "Starred — the gathering shows it once it's unarchived." / "Tagged #x and
  starred — the gathering shows it once it's unarchived." (mechanical composition of the two approved families).
- **CLOSEOUT CARRIES (noted now so the ritual can't miss them):** AppSpec §9's structural-undo list gains
  `deleteTag` ("Excluded: … tags" keeps meaning tag APPLICATIONS); the VX-246 record's sweep table gains the
  registration's row; the MOBILE PARITY line names VM-21 (the phone's ★-collect now succeeds with a starless
  receipt — R-VX381-A4).

## LADDER (after U2 — one ladder over the run's combined diff)

Fresh `opus-reviewer` at xhigh per round, `notes/REVIEW_PROMPT.md` VERBATIM, zero framing, over the combined
diff vs the merge base. Findings land here repo-first before any fix session sees them; fixes by a fresh
implementer with red-on-old pins; round 2 re-reviews the fixes; a new BLOCKER/MAJOR earns round 3; hard cap
three. Same-model ladder: the orchestrator arbitrates against the spec. Every finding gets a written
disposition here.

## LIVE STATUS

- **Kickoff (2026-10-18):** DONE — worktree seated, in-flight row flipped (`23608d43`), tickets In Progress,
  briefs written, P-VX381-1 ruled. Coordinator announce: PENDING.
- **U1 (VX-194 · VX-250 · VX-240 · VX-241):** IMPLEMENTER-CLOSED 2026-10-18 (the U1 implementer; awaits the
  orchestrator's both-voices walk and the run's ladder). **NOT DONE, stated first:** the both-voices WALK (the
  orchestrator's acceptance act, by the brief — the tree is walkable); VX-194's "fold the gathering foot's one-off into
  the style" step (NOT APPLICABLE — R-VX381-A1: the door was never a calm button); the chip's LIVE-gathering receipts
  ("collects by filter") and the PHONE's twin of VX-241 (observations below — not this unit's). No revert in flight;
  the tree is clean at the record's commit.
  - **Evidence.** Core (headless): full `swift test` — VariorumCoreTests "2903 tests in 337 suites passed", the
    6-suite target 40/40; ONE red in the 362-test MCP package, `MCPHarnessTimeLimitTests.aPeerThatNeverAnswers…`
    (15.96 s against its 15 s wall-clock bound under full parallel load; touches nothing of U1; 3/3 green alone —
    a load flake, recorded). Mac (one stage window under the coordinator's GO, claim `vx-381-u1-batch`, released):
    RUN 1 red-on-old on a prebuilt behaviourally reverted tree (CalmGrammar ignoring `isEnabled`, the ceremony's old
    0.45 opacity back, the old receipt tail + mint arm, both collect deciders ignoring the archive, `cannot` re-framed,
    `nonReadyFace` always stub) — "Test run with 29 tests in 4 suites failed … with 49 issues", the 9 failures exactly
    the new/edited pins (the VX-240 spinner pin caught `.opening` and failed on `shown > 0`); the guards green. RUN 2 on
    the fixed tree (4c26f4a1's sources) — "Test run with 135 tests in 18 suites passed", 0 skipped: CalmButtonDisabled-
    FaceTests · VocabularySweepTests · SettingsLockCloseTests · GatheringCollectReceiptTests · VX209LeavesCastle-
    ConfirmTests · BlockTagSheetVoiceTests · MergeCeremonySheetTests · TakesDivideTests · DivideWCeremonyTests ·
    MembershipChoiceTests · AddToBookMintTests · ArchivedMarkTests · ShelfModelTests · TimelineAndReadingsTests ·
    ProtectionSurfaceRenderTests · LobbyAutoAskTests · CopyRegisterPinTests · BlocksWorkbenchFaceTests.
  - U1.1 **VX-194 — FIXED** (f20af818). Traced: `CalmButtonStyle.makeBody` drew ink/border/paper from the role alone
    and dimmed only on `isPressed`; nothing read `isEnabled`, so a disabled calm button drew pixel-for-pixel live
    (a scratch replay of the old body: 0 differing pixels of 1,330 inked). Fix: the body reads
    `@Environment(\.isEnabled)`; disabled = ONE quiet face for every role (`faint` ink, `line` border, `surface`
    paper, no press dimming; the role's weight kept so labels never reflow). Sweep of the 17 files: ONE calm-button
    one-off — `CeremonySheetChrome`'s confirm `.opacity(canConfirm ? 1 : 0.45)`, folded per R-VX381-A2 (the button IS
    `.disabled(!canConfirm)`, so the environment carries the face). Faces that now grey for the first time: the
    lobby's unlock/open doors while busy (`StoreLockView`, `LibraryMissingView`), Blocks' bulk merge under 2 picked,
    Canvas's order door when empty. Pins `CalmButtonDisabledFaceTests` (3: every voice × role distinct and quieter; a
    container's `.disabled` draws the same face; the ceremony confirm dims ONCE) — red on old, green on new.
  - U1.2 **VX-250 (1) — DONE** (3b69e030): her four mint receipts verbatim; P-VX381-1's `shownByTagging` in the same
    register. Pin `VocabularySweepTests.herShorterMintReceiptsLandVerbatim` + two justified edits — red/green above.
  - U1.3 **VX-250 (2) — DONE** (9c6d2611): `Blocker.reason` = whole sentences; her three verbatim + her purged-tag
    fallback ("Its rule needs a tag that no longer exists."); `GatheringNoteDoorCopy.cannot` says the reason as it
    stands (the "This gathering can't take a new note: …" frame retired); `unmatchedReason` = her unreachable
    sentence. Core red-on-old (the pre-fix file restored): 2 tests failed, 27 issues; green 20/2. App hover pins
    red/green above. **PROVISIONAL drafts (for the orchestrator):** finished "Finished — reopen it to add notes." ·
    no rule "No rule yet — give it one to add notes." · unreadable "Its rule can't be read — edit it to add notes." ·
    legacy date "Its rule needs an entry date, which a new note doesn't have." · legacy kind "Its rule needs a kind
    of note, which a new note doesn't have." Observation (pre-existing): a rule naming a LIVE tag of ANOTHER wing
    reads as dead in the gathering's wing, so it says "…which no longer exists.".
  - U1.4 **VX-250 (3) — FIXED** (6adfd7c6). Traced: the planner returned `.blocked(.unreachableTerm)` for every
    `.not` conjunct and every any-of with a non-atom option, so a rule a fresh note meets as it is greyed the door and
    refused the op. Fix: a fresh-note evaluator mirroring `ruleSQL` exactly (three-valued for the legacy NULLs;
    subtree `tagCovers` fed live paths by `Queries.gatheringMintOutcome`); NOT conjuncts and NOT options DEFERRED,
    then every conjunct checked against the note the plan makes (a door never enabled for a press the belt refuses);
    an any-of pick prefers an option keeping the NOTs true (`(#a OR #c) AND NOT #a` takes #c — an any-of pick is not
    a MUST). Still blocked: legacy date/kind terms, an empty any-of, an any-of with a nested group or legacy option.
    The `matchesRule` belt untouched. Core red-on-old by behavioural revert: 5 tests failed, 15 issues; the
    contradiction guards (her `#a AND NOT #a`, the subtree form, ★) green on both sides; restored 26/2 green.
    **PROVISIONAL P-VX381-U1-1:** an any-of with a NOT option the fresh note already meets is met with NO tag
    (`#a OR NOT #b` mints wearing nothing, receipt "Added to the gathering."); the alternative (take #a anyway)
    applies a tag nothing requires.
  - U1.5 **VX-240 — FIXED** (0b47c514 + 4c26f4a1). Traced: the scene's non-ready arm drew the stub for every
    non-`.ready` state, and the reopen roads keep the window open through `.opening`. Fix: `nonReadyFace` — `.opening`
    shows her "Opening your library…" (U+2026) beside a small spinner; every settled closed state keeps the stub (the
    window closes on those, VX-224). Pins (`SettingsLockCloseTests`): the pure face + a real bootstrap's adoption held
    on a gate in `.opening` (the spinner is an `NSProgressIndicator`, measured offscreen first; SwiftUI `Text` is not
    reachable through accessibility there, so the words ride the pure pin) — red on old, green on new.
  - U1.6 **VX-241 — FIXED** (2433b5ca). Traced: the chip's add picker offers archived gatherings
    (`MembershipChip.refresh` filters kind + lock only — 13i-e's open explicit adds), the op tags correctly, and the
    receipts claimed a showing the archived gathering's EMPTY assembly denies. Fix: `SmartCollectResult.
    gatheringArchived`, read INSIDE the op's transaction; `BookcaseCopy.collectReceipt` (the board) and
    `AddToBookCopy.collected` (the chip) speak the archived arm; a live gathering keeps each door's words. Pins: core
    `SmartCollectTests.anArchivedGatheringStillTagsAndReportsItsArchive` + app `GatheringCollectReceiptTests` (2) —
    red on old, green on new. **PROVISIONAL wording (for the orchestrator):** "Tagged #essays — the gathering shows it
    once it's unarchived." · already matching: "It already matches — the gathering shows it once it's unarchived."
  - **Observations for the orchestrator (not changed):** (1) the chip's LIVE-gathering receipts still say
    "collected"/"collects by filter" — a third voice for R98's receipt beside P-VX381-1's register (VX-216's sitting
    is the natural home). (2) MOBILE PARITY: the phone's `MobileMembership` lists archived gatherings and speaks the
    same overclaim — a VM ticket candidate (`gatheringArchived` now reaches it for free). (3) The MCP time-limit
    test's load flake above. (4) U2's VX-249 extends `SmartCollectResult` and `collectPostIntoSmartReading` — the
    new `gatheringArchived` field rides beside its star report.
- **U2 (VX-249 · VX-247 · VX-111):** IMPLEMENTER-CLOSED 2026-10-18 (the U2 implementer, one session; awaits the
  orchestrator's walk and the run's ladder). **NOT DONE, stated first:** the WALK (the orchestrator's acceptance act —
  the tree is walkable at the record's commit); the PHONE (R-VX381-A4: untouched — its ★-rule collect now succeeds
  with a receipt that names no star; VM-21 carries it); the canon deltas (AppSpec §9's undo list + the VX-246 sweep
  table — the closeout's, U2.2 below). No revert in flight; the tree is clean. Every row dispositioned: **VX-249
  FIXED · VX-247 FIXED · VX-111 FIXED**, each with its red-on-old pins below. The one stage window (claim
  `vx-381-u2-batch`, the coordinator's grant relayed, released at once): RUN 1 red-on-old on `dd-red` — "Test run
  with 18 tests in 4 suites failed … with 22 issues", the 7 failures EXACTLY the new app pins
  (`onlyBooksCountTowardTheNote` · `aBooklessNoteTwoGatheringsShowSaysNothing` ·
  `aTwoBookNoteAGatheringShowsCountsOnlyItsBooks` · `aOneBookNoteAGatheringShowsSaysNothing` ·
  `aStarSetCollectNamesTheStarOnBothDoors` · `anArchivedStarCollectNamesTheStarWithTheHonestTail` ·
  `theDeleteDoorIsUndoableThroughTheSessionsStack`), every other test in those suites green; RUN 2 on `dd-green`
  (725ad2db's sources) — "Test run with 132 tests in 17 suites passed", 0 skipped.
  - U2.1 **VX-249 — the collect door sets the star: FIXED** — core (171a17d4), receipts (36ade6d6). Traced: `collectPostIntoSmartReading`'s walk knew only tag conjuncts and all-tag any-of groups; a ★
    term fell through to the end probe, which fails for an unstarred note, so every ★-rule collect refused
    ("tagging alone can't satisfy its filter"). Fix: `GatheringMint.outcome` gains the note's STARTING state
    (`noteWears` · `noteStarred` · `noteMeetsLegacy` — defaults describe a fresh note, so every mint plan is
    unchanged; `alreadyMet` = positive evidence only); `Queries.gatheringCollectOutcome` feeds it for an existing
    note (`postMatchesRule` per rule tag — the one SQL, now shared with `Operations.matchesRule`); the op applies
    the plan's tags through `insertPostTag`, its star through `writeStar(…, enforcingCap: false)` (intake hears
    it), and the belt re-reads the star context; `SmartCollectResult.starred`. Receipts: the board's
    `collectReceipt` → `shownByMint(paths, starred:)` (tags-only arm IS `shownByTagging`); archived →
    `taggedWhileArchived(paths, starred:)`; the chip's star arm speaks the mint family (R-VX381-A5). **Core
    red-on-old VERIFIED** by behavioural revert (the pre-VX-249 walk with `starred: false`): "30 tests in 4 suites
    failed with 6 issues" — exactly the five new op pins (`aStarRuleCollectStarsTheNoteAndReportsIt` ·
    `aTagAndStarRuleTagsAndStarsInOneAct` · `theCollectsStarIsCapExempt` ·
    `theCollectsStarIsAnApplyingActALivingBookHears` · `theAnyOfPickKeepsTheRulesNot`) + StarContextTests'
    JUSTIFIED EDIT (its old "★ refuses" control now collects by starring); the guards (the unwind, a nested option,
    a NOT the note breaks) and the 4 pure planner pins green on both; restored green 30/4, and the wider set
    (GatheringMint · RuleWingScoping · Intake · Phase13icOutflow …) 114/10. App pins
    `GatheringCollectStarReceiptTests` (2): red-on-old VERIFIED (RUN 1, the deciders ignoring `starred`), green. **PROVISIONAL (P-VX381-U2-1):** R98 now
    refuses a rule whose any-of is met ONLY by a nested option carrying a NOT (`#x AND (#a OR (#b AND NOT #c))`,
    note wearing b) — the old walk skipped mixed groups and let its probe decide; the planner's `alreadyMet` takes
    positive evidence only, so it keeps the mint's conservative class (fresh-note plans byte-identical). An
    extreme corner (nested NOTs are authorable only in the rule editor). **PROVISIONAL (P-VX381-U2-2):** R98 now
    reads tag liveness in the GATHERING'S wing (the planner's `tagIsLive`), so a rule naming another wing's tag
    refuses by name instead of applying a cross-wing tag (wings isolate; U1's cross-wing hover observation's twin).
  - U2.2 **VX-247 — undo for tag delete: FIXED** — core (752fa49d), copy + door pin (58a1ecc8). Traced:
    `deleteTag` tombstoned the subtree and registered nothing, so ⌥⌘Z reached past the act. Fix: the delete
    records its pass (tag rows in path order + the one stamp the cascade trigger gave their applications); the
    inverse revives each still dead on that stamp — parents first; a dead parent or a dead wing leaves it dead
    (quiet: there is no road to bring those back, so a refusal would wedge the stack); a live same-path tag in the
    wing REFUSES `duplicateTagPath` (resolvable — rename hers, undo again; the entry stays) — with its
    `post_tag`/`block_tag` rows dead on the stamp, onto LIVE targets only, never beside a live twin; the redo
    re-tombstones what the undo revived through the delete's own subtree rule on ONE fresh stamp and hands that
    pass to the next undo; quiet halves retire the entry. Registered inside the op, so every door rides it
    (Settings ▸ Tags' trash + context row, the phone's tag manager; no MCP tag-delete tool exists). The confirm's
    "There is no undo for this." DROPPED on both platforms (R-VX381-A3). **Core red-on-old VERIFIED** (the
    registration call removed — the row work is byte-identical to the old op): "8 tests in 1 suite failed with 22
    issues"; restored green 8/8. App pin `TagAndFolderTests.theDeleteDoorIsUndoableThroughTheSessionsStack`:
    red-on-old VERIFIED (RUN 1: no registration + the old copy), green. **PROVISIONAL (P-VX381-U2-3):** the path-collision undo REFUSES (keeps the
    entry) rather than reviving beside or skipping quietly. **(P-VX381-U2-4):** the redo takes a child she made
    under a revived tag since the undo (the delete's subtree rule — no live tag left under a dead parent; the
    deleteBlock-cascade precedent: `performDeleteBlock`'s redo takes a take branched since the undo, and an
    application she made since rides the same trigger cascade), and the next undo brings it back on that stamp.
    The recorded alternative: a redo that finds the revived subtree GROWN is QUIET and retires (the strictest
    reading of "never writes over a change of hers"; the door would say "Nothing to redo — Delete Tag was already
    undone or changed since.") — one guard to add. **(P-VX381-U2-5):** an
    application whose NOTE (or block) died after the tag delete stays dead on the undo (no live row under a dead
    note — the sweep's invariant) — so a later Put back of that note returns it without that tag (its
    application died on the tag's stamp, not the note's); the restoreReading "left out — add it back by hand"
    corner's twin. **Canon delta for the closeout:** AppSpec §9's structural-undo list gains `deleteTag` (its
    "Excluded: … tags" means applications — `applyTag`/`removeTag` — which stay excluded); the VX-246 record's
    SWEEP TABLE (every registration's quiet-half answer) gains this site's row at the closeout — the inverse is
    quiet when no pass row is still dead on its stamp, the redo when no revived tag still stands.
  - U2.3 **VX-111 — the notice counts books only: FIXED** (725ad2db). Traced: `AppSession.noteMultiBookEdit`
    counted `Queries.readingsContaining` whole — the chip's list: every live book with a member row PLUS every
    gathering whose rule shows the note — so a bookless note two gatherings show said "This note is in 2 books…"
    (the masthead, counting `kind == .book`, said "in no book · 2 gatherings"). Fix: `MultiBookEditNote.memberBooks`
    (books only — archived books stay, membership is a fact), and the trigger counts, words and targets from it.
    Pins: `MultiBookEditNoteRuleTests.onlyBooksCountTowardTheNote` + `MultiBookEditNoteTriggerTests`' three
    (bookless in 2 gatherings → silent; 2 books + a gathering → "2 books"; 1 book + a gathering → silent) —
    red-on-old VERIFIED (RUN 1: `memberBooks` = identity, the trigger counting `readingsContaining` whole), green.
  - U2.4 **The Mac batch: DONE** (the results in the U2 line above). The app revert
    (from 725ad2db, every file committed — `ShelfViewModel.swift` collectReceipt/taggedWhileArchived ignoring
    `starred` · `MembershipChoice.swift` `collected` ignoring `starred` · `Operations+Tag.swift` no registration ·
    `TagDeletionCopy.swift` the old "no undo" sentence · `AppSession.swift` the notice counting `readingsContaining`
    whole · `MultiBookEditNote.swift` `memberBooks` = identity) was BUILT into `dd-red` (TEST BUILD SUCCEEDED) and the
    tree RESTORED clean before the window (`git status` empty, zero revert markers); the fixed tree was built in
    `dd-green` (725ad2db's sources). RUN 1 (red, `dd-red`) over the 4 pin-bearing suites: GatheringCollectStarReceiptTests ·
    TagAndFolderTests · MultiBookEditNoteRuleTests · MultiBookEditNoteTriggerTests. RUN 2 (green, `dd-green`) over
    the 17: GatheringCollectReceiptTests · GatheringCollectStarReceiptTests · VocabularySweepTests ·
    MembershipChoiceTests · ShelfModelTests · TimelineAndReadingsTests · AddToBookMintTests · TagAndFolderTests ·
    MultiBookEditNoteRuleTests · MultiBookEditNoteTriggerTests · DivergeDoorTests · DuplicateDoorsTests ·
    BindDoorTests · WingSwitcherTests · SpawnAndBindLimbTests · OutflowChooserTests · RuleEditorTests.
    **Core (headless), DONE:** full `swift test` — VariorumCoreTests "2923 tests in 340 suites passed" (U1's
    2903/337 + this unit's 20 tests in 3 suites), the 6-suite target 40/40; the 362-test MCP package's ONE red is
    U1's recorded load flake `MCPHarnessTimeLimitTests.aPeerThatNeverAnswers…` (20.1 s against its 15 s bound under
    full parallel load) — 3/3 green alone.
  - **For the walk (the orchestrator's):** VX-249 — drop an unstarred note on a ★-rule gathering's Bookcase row and
    pick one from the chip's add picker (both voices): the note stars, the receipt says "Starred — the gathering
    shows it now." (or "Tagged #x and starred — …"); an archived ★ gathering says "…once it's unarchived."; the 15-star
    limit never blocks it. VX-247 — Settings ▸ Tags: delete a tag with a sub-tag (the confirm no longer says "no
    undo"), then Edit ▸ "Undo Delete Tag" (⌥⌘Z) brings the subtree and the notes' tags back; "Redo Delete Tag" takes
    them again. VX-111 — a bookless note two gatherings show: first edit says nothing (the seen flag is
    `variorum.multiBookEditNoteSeen` in the Debug domain — clear it first); a note in two books still speaks once.
  - **Self-assessment (the implementer's):** the riskiest line is the planner generalisation — fresh-note plans
    are byte-identical by construction (every new input defaults to "wears nothing", and `alreadyMet` is false for
    a fresh note in every arm), proven by U1's GatheringMint pins passing untouched; the R98 corner it narrows is
    P-VX381-U2-1. The undo's exact-stamp reads assume the trigger copies the tag's `deleted_at` string verbatim (it
    does — `NEW.deleted_at`), and `InvariantSweepTests` (7 seeds × 250 random acts, which undo at random) now
    exercises the entry against the no-live-row-under-a-dead-parent invariants, green.
- **Ladder:** round 1 COMPLETE (`notes/plans/fixes/vx-381-ladder-r1.md` — findings + the orchestrator's
  DISPOSITIONS). **Walk:** NOT-STARTED. **Closeout:** NOT-STARTED.
- **Ladder round-1 FIX LEG (a fresh implementer, 2026-10-18 — scope = the r1 file's §DISPOSITIONS: F-2 · F-1 · F-3 +
  riders F-7 · F-8; nothing else):** IN-PROGRESS. No revert in flight.
  - F-2 (revived tags rebuild their paths from the live parent): FIXED (this commit). Mechanism (the reviewer's,
    re-traced): `renameTag` rewrites only LIVE descendants, so a child dead across its parent's rename kept the stale
    path and `revertTagDeletion` revived it as stored (`life/goals` under `home`); its collision check read that
    stale path too. Fix: each revived tag's path = its LIVE parent's current path + "/" + name (a root: its name),
    walked in the pass's delete-time path order (parents first, so a child reads its parent's rebuilt path), the
    live-unique check against the REBUILT path, the path written with the revival. Pins (`TagDeleteUndoTests`):
    `aTagRevivedUnderARenamedParentTakesTheParentsNewPath` (the reviewer's exact shape: `home/goals`, the `#home`
    gathering shows the note, the tag dies with a later delete of `home`) · `aRevivedChainRebuildsEveryPathParentsFirst`
    (a pass rooted below the renamed tag; the redo takes the whole chain) · `theCollisionCheckReadsTheRebuiltPath`
    (a `home/goals` made since refuses with the rebuilt path; rename hers, the undo lands). RED ON OLD on the pre-fix
    source: "11 tests in 1 suite failed with 11 issues" — exactly the three new pins (4 + 3 + 4); the eight shipped
    pins green on both sides. Green after: 11/11; InvariantSweep · TagReferenceOperations · RuleWingScoping ·
    SyncRepair 26/4.
  - F-1 (correlated EXISTS + the plan pin): FIXED (this commit). Mechanism (re-traced): the two revival UPDATEs
    guarded their targets with `post_id IN (SELECT id FROM container …)` / `block_id IN (SELECT id FROM block …)` —
    the measured old plan: `SEARCH post_tag USING INDEX idx_post_tag_tag` · `LIST SUBQUERY 1` · `SCAN container USING
    INDEX idx_container_touched` · `CREATE BLOOM FILTER` (the block twin: `SCAN block`), a whole-table walk per revived
    tag. Fix: the statements became constants (`Operations.revivePostTagApplicationsSQL` /
    `reviveBlockTagApplicationsSQL`, so the pin reads the shipped SQL) and the guards correlated `EXISTS (SELECT 1 FROM
    container c WHERE c.id = post_tag.post_id AND c.deleted_at IS NULL)` / the block twin — same rows. Pin
    `TagDeleteUndoTests.theApplicationRevivalsSeekTheirTargetsAndNeverScanACorpusTable` (EXPLAIN QUERY PLAN of both:
    no `LIST SUBQUERY`, no `SCAN` line, the target seeked by `sqlite_autoindex_<table>_1 (id=?)`). RED ON OLD (the
    constants holding the shipped SQL verbatim): 6 issues, 3 per statement; green after: 12/12 (the behavioural pins —
    live-target guard, exact rows — unchanged). `restoreContainer`/`restoreBlock`'s pre-existing twin untouched
    (VX-387's).
  - F-3 (the shared table's `duplicateTagPath` arm): LANDED (20894e80) — red/green PENDING the stage window. Sentence
    (PROVISIONAL, for the orchestrator): "A tag named “work” already exists — rename it, then try again." (act-less:
    the table can't know its door — the undo doors frame it "Undo failed: …", and the rule editor's make-a-tag door,
    `RuleEditorModel.createTag`, reaches the same table on a race, where "undo again" would be false). Pins: Mac
    `TagAndFolderTests.theUndoDoorSaysTheCollidingTagAndTheRoadNeverTheRawCase` (the real ⌥⌘Z door, then the rename
    road) · phone `MobileRefusalTableTests.theTagUndoCollisionSpeaksTheSharedSentence` (the arm is in
    `Shared/OpsRefusalTable.swift`, which the phone compiles).
  - F-7 (the archived receipt's empty arm): LANDED (b1d38659) — "Added — the gathering shows it once it's unarchived."
    (PROVISIONAL) — red/green PENDING the stage window. Pin `GatheringCollectStarReceiptTests.
    anArchivedCollectThatWoreNothingNeverClaimsATag`.
  - F-8: DONE (f2644865) — `GatheringNoteDoorCopy.cannot` deleted, its TWO callers (the hover in `help` and
    `BookStructureModel.newPostInGathering`'s refusal line) say the reason directly (byte-identical); `divergeTarget`'s
    doc and its twin in `AppSession.noteMultiBookEdit`'s doc corrected. No behaviour change, no pin owed.
  - **The RED TREE = dd3ba271** (pins present, F-3's arm and F-7's guard absent — no revert was needed); the GREEN
    TREE = f2644865. All four test products BUILT ("TEST BUILD SUCCEEDED" each), gitignored under
    `App/Variorum/DerivedData/`: `vx381-fix-red` · `vx381-fix-green` (Mac) · `vx381-fix-red-ios` · `vx381-fix-green-ios`
    (phone, `generic/platform=iOS Simulator`). The window is test-only (`test-without-building`), from `App/Variorum/`:
    - RUN 1 Mac RED (`vx381-fix-red`): TagAndFolderTests · GatheringCollectStarReceiptTests — EXPECTED: exactly the two
      new pins red.
    - RUN 2 Mac GREEN (`vx381-fix-green`), 18 suites: TagAndFolderTests · GatheringCollectReceiptTests ·
      GatheringCollectStarReceiptTests · OpsRefusalTableIntegrityTests · MCPWireRefusalSweepTests · VocabularySweepTests ·
      MultiBookEditNoteRuleTests · MultiBookEditNoteTriggerTests · DivergeDoorTests · ShelfModelTests · BindDoorTests ·
      OutflowChooserTests · RuleEditorTests · SpawnAndBindLimbTests · WingSwitcherTests · CapabilityRegistryTests ·
      BookArchiveFacesTests · TutorialBooksChapterTests.
    - RUN 3 phone RED (`vx381-fix-red-ios`, `platform=iOS Simulator,name=iPhone 17 Pro,OS=26.2`):
      MobileRefusalTableTests — EXPECTED: exactly the new pin red.
    - RUN 4 phone GREEN (`vx381-fix-green-ios`): MobileRefusalTableTests · MobileTagManagerTests · MobileUndoDoorTests.
  - **Core (headless) on the green tree, DONE:** full `swift test` — VariorumCoreTests "2927 tests in 340 suites passed"
    (U2's 2923/340 + this leg's four new pins), the 6-suite target 40/40; the 362-test MCP package's ONE red is U1's
    recorded load flake `MCPHarnessTimeLimitTests.aPeerThatNeverAnswers…` (20.5 s against its 15 s bound under full
    parallel load) — 3/3 green alone. (The coordinator's disk chore: U1/U2's superseded dd-red/dd-green trees and the
    reviewer's probe tree were removed by the orchestrator; this leg deleted nothing.)
  - The batch (via the orchestrator's relayed GO): READY, holding — the stage is held by vx-382's window; GO at its
    seam.
