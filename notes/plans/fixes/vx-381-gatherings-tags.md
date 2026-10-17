# VX-381 — Run: Gatherings & tags (VX-284 part A)

**STATUS: AWAITING KICKOFF — written 2026-10-17 at her VX-284 split sitting; the run ticket exists (VX-381, Todo),
its branch and worktree are minted by ITS orchestrator at kickoff.** Members (sub-issues of VX-381): **VX-250 ·
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

## LIVE STATUS

*(The orchestrator fills this at kickoff.)*
