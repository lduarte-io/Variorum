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
tests for the changed types when in doubt). A Mac `xcodebuild test` run REQUIRES a held `Tools/stage` claim —
claim before, release after; if the stage is contended, report to the orchestrator instead of waiting silently.
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
tests for both op changes; then ONE Mac batch over every suite exercising the changed source files (held stage
claim, as U1). LIVE STATUS flips per piece. The environment traps bind verbatim.

## LADDER (after U2 — one ladder over the run's combined diff)

Fresh `opus-reviewer` at xhigh per round, `notes/REVIEW_PROMPT.md` VERBATIM, zero framing, over the combined
diff vs the merge base. Findings land here repo-first before any fix session sees them; fixes by a fresh
implementer with red-on-old pins; round 2 re-reviews the fixes; a new BLOCKER/MAJOR earns round 3; hard cap
three. Same-model ladder: the orchestrator arbitrates against the spec. Every finding gets a written
disposition here.

## LIVE STATUS

- **Kickoff (2026-10-18):** DONE — worktree seated, in-flight row flipped (`23608d43`), tickets In Progress,
  briefs written, P-VX381-1 ruled. Coordinator announce: PENDING.
- **U1 (VX-194 · VX-250 · VX-240 · VX-241):** NOT-STARTED — brief above is settled.
- **U2 (VX-249 · VX-247 · VX-111):** NOT-STARTED — brief above is settled; runs after U1.
- **Ladder:** NOT-STARTED. **Walk:** NOT-STARTED. **Closeout:** NOT-STARTED.
