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
- **U2 (VX-249 · VX-247 · VX-111):** IN-PROGRESS 2026-10-18 (the U2 implementer, one session). No revert in flight.
  Order: core pins first (headless red → fix → green), then the app pins, then ONE stage window (RUN 1 red-on-old on
  a prebuilt behaviourally reverted tree, RUN 2 green) via the orchestrator's relayed GO.
  - U2.1 **VX-249 — the collect door sets the star:** NOT-STARTED. Design: `GatheringMint.outcome` gains the note's
    STARTING state (what it already wears, its star, its legacy values — all empty for a fresh note, so the mint's
    plans are unchanged); R98's walk becomes that planner (ONE authority); a planned star is written through
    `writeStar(…, enforcingCap: false)` in the op's transaction, the belt re-reads the star context; the result
    gains `starred`; the board and chip receipts name it in the mint's family.
  - U2.2 **VX-247 — undo for tag delete:** NOT-STARTED. Design: `deleteTag` registers ONE entry ("Delete Tag"); the
    inverse revives exactly the rows the last forward half tombstoned, while still dead on ITS stamp, plus their
    applications dead on that stamp (live targets only); the redo re-tombstones what the undo revived (with the
    delete's own subtree rule) on a fresh stamp and records it; quiet halves retire the entry.
  - U2.3 **VX-111 — the notice counts books only:** NOT-STARTED. Traced: `AppSession.noteMultiBookEdit` counts
    `Queries.readingsContaining` — books AND every gathering whose rule shows the note.
- **Ladder:** NOT-STARTED. **Walk:** NOT-STARTED. **Closeout:** NOT-STARTED.
