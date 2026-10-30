# VX-105 — her finished readme seeds (replaces the 13s placeholder)

**STATUS: BUILDING (kicked off 2026-10-30, /architect-phase on the Pro; branch `vx-105-readme-letter`, worktree `~/dev/variorum-vx-105`). The 13b constitution (P-1…P-9, `.claude/skills/architect-phase/SKILL.md`) binds by reference. No `Sync/`, no custody, no editor seam — opus-reviewer qualifies for the ladder.**

## What this is

Her finished readme text — ONE letter-shaped note (the ticket's old "readme + letter" language converged during her edit passes; the package README in `notes/plans/vx-105-letter-content/` records it) — replaces the 13s placeholder `readme` in the fresh-store seed, whole. The letter does not exist as a separate note. R-13s-28 binds absolutely: her text lands byte-exact, never edited, reworded or re-punctuated.

**The content package (this branch, commit 46990b911):** `notes/plans/vx-105-letter-content/read-me.txt` (the text) + `README.md` (her verbatim dispositions + the per-block SHA-256 manifest from her store). **The manifest wins over the file:** the orchestrator verified at kickoff that the .txt DROPPED the trailing spaces her store carries — 13 of the 17 blocks end with ONE trailing space (all but blocks 2, 12, 16, 17). The seeder's literals carry the store's bytes (trailing spaces included); the pin is per-block SHA-256 equality against the manifest's 17 values.

## The rulings

**From the VX-105 Linear thread + the package README (2026-10-29, settled late 10-29/early 10-30):**
- Title **`readme`** (her word 00:15 10-30: "i will change the name to readme" — supersedes "read me"). `ReadmeSeeder.title` is already "readme"; the tour's end card stays true unchanged.
- Her text replaces the placeholder `readme` WHOLE — the five draft blocks (from her unfinished "Lillian's Start Here" field-guide intro, R-13s-39) and their takes, and the four Castle Start Here passages, all stop seeding as readme content. Her "Lillian's Start Here" draft stops shipping anywhere. **The field guide is untouched:** its first lesson "start here" is the app's own text, and its protection chapter's key lesson BUILDS FROM `ReadmeSeeder.startHerePassages` (`TutorialSeeder.swift:2502`) — those four passages survive as GUIDE content (keep the constant, guide-reachable; only the readme stops carrying them).
- Standalone: no tags, no book memberships (her disposition 3: the Oct 29 spec wins; VX-635's older Welcome-shelf shape superseded — **close VX-635 at closeout**).
- Born **starred**. (Consequence, accepted: the seeded "starred notes" gathering assembles it — a gathering holds nothing, so "no memberships" holds.)
- Sign-off is the text itself (blocks 16–17).
- Sherlock door casing: lowercase (R-13s-38's one-casing idiom); her Title Case quote inside the readme text stands unchanged (her disposition 2: "it's fine for them to be different").
- Every block holds exactly one take — no alternates ride.

**From her kickoff + the 2026-10-30 sitting (AskUserQuestion, this session):**
- **R-105-1 — her real store:** YES — mint the exact seeded shape into her real store via the proven headless road (`adding-content-to-her-real-store` memory: StoreUnlock + ops-only, A1 safety copy first, zero-instance window). Her working note "readmev5" (readme / letter book, v^2) stays untouched.
- **R-105-2 — mobile:** the phone seeds nothing (the recorded BirthFurnitureSeeders MOBILE PARITY posture stands); the readme reaches a phone by sync; the fold engine stays inert on the title. MOBILE PARITY line: nothing mobile-visible.
- **R-105-3 — the 4:44 stamp's reach:** "Created 4:44, edited at birth" — the note's created/worn date reads **October 29, 2026, 4:44 am** (the seeding device's LOCAL 4:44 — every reader sees 4:44 am; PROVISIONAL reading, recorded); the last-edited stamps (`last_touched_at`, `last_major_revision_at`) are the seed moment, and the readme still seeds LAST — so it tops the Library's default edited-newest sort (R-13s-29 preserved alongside the dated-note ruling).
- **R-105-4 — per-book restore doors, the sample-library label retired (her words verbatim):** *"well they should be able to restore sherlock, jeyll and hyde, the prince, etc. each individual. the sample library is too confusing we don't need that."* So: Help ▸ "Restore the Sample Library" (which already restores exactly the Sherlock book) is RETITLED **Restore “the adventures of sherlock holmes”** (lowercase, the prince/jekyll idiom, `SampleLibrarySeeder.bookName`); jekyll, prince and the classics gathering keep their existing doors; no door is added or removed, no second door kept. Encryption Explained stays gone and unrestorable (R-13s-37, not reopened).

**R-105-5 — the guide's first chapter interweaves her Start Here draft (her mid-turn word, 2026-10-30, verbatim):** *"I would say that you should interweave the relevant parts of 'Lillian's Start Here' that are important / good into the first chapter of the field guide. if the first chapter of the field guide has stuff that 'Lillian's Start Here' is missing, then go ahead and keep the field guide portion. we need to make sure that the voice sounds good and that it makes sense holistically so you have a lot of freedom to edit that as you see fit, but I didn't even know lillian's start here was going into new apps so I didn't realize we have to handle that."* The source is `notes/plans/13s-start-here-reference.md` (its first half; the unfinished annoyances half stays out — placeholder "xyz" fixes, not "important / good"). The editing freedom is HERS-GRANTED for this chapter — an explicit, recorded exception to R-13s-28's never-edit rule, scoped to the guide's first lesson only. Consequence: a guide content change stales her real store's seeded guide — the closeout re-seeds it via the product door behind the A1 rail. The four Castle passages are NOT part of this interweave: they stay in the protection chapter (the shared constant), and the orchestrator's recommendation to her is that chapter placement stands for launch (the new readme's own privacy block + the band card + the protection chapter cover the new user; no duplication into chapter 1).

## U1 BRIEF (one implementer session, one acceptance unit)

Seat: worktree `<home>/dev/variorum-vx-105`, branch `vx-105-readme-letter` (`git status -sb` first; expect clean; pull --ff-only). Read IN FULL before touching code: this file; `notes/plans/vx-105-letter-content/README.md` + `read-me.txt`; `App/Variorum/Variorum/Features/Onboarding/BirthFurnitureSeeders.swift`; the readme pins (`App/Variorum/VariorumTests/LaunchFurnitureTests.swift` readme section, `App/Variorum/VariorumTests/Protection/ReadmeStartHerePlanTests.swift`, `App/Variorum/VariorumTests/Protection/TutorialNewRoadChapterTests.swift`, `App/Variorum/VariorumTests/TutorialFurnitureFoldTests.swift`); `App/Variorum/Variorum/Registry/ShellActions.swift` restore-door region (~500–620) + the registry/menu/palette homes of `.restoreSampleLibrary`; `TutorialSeeder.swift:2502`'s key-lesson use of `startHerePassages`. The resiliency protocol binds (`notes/SessionResiliencyProtocol.md`): commit per piece, push after each, LIVE STATUS in the "## U1 RECORD" below from the first commit, foreground waits only, no subagents.

Pieces, in order (one commit each at least):

1. **The seeder content swap.** `ReadmeSeeder` seeds her 17 blocks byte-exact: the `read-me.txt` paragraphs (header line `{t:"readmev5"} {#readme}` dropped; blank-line splits) WITH the trailing single space restored on every block except 2, 12, 16, 17 (1-based; the manifest's SHA-256s are the truth — verify your literals against all 17 before committing). No takes (`takes` map empty/removed). Title stays `readme`; bookless, Home wing, no tags. KEEP `startHerePassages` available to the guide (`TutorialSeeder`'s key lesson and `ReadmeStartHerePlanTests` pin them against the VX-307 plan text) — move or re-home the constant if that reads cleaner, but the guide's lesson text must not change by a byte; `herBlocks` (the old five draft blocks) leave the seed entirely (delete or demote to a test-only fixture — your call, say which). The seeder still seeds LAST, still honors the live/tombstone reads, still logs one line, still registers no undo.
2. **Born starred + the stamps (R-105-3).** The mint sets the note starred through the one star road inside the same seed act. Stamps: `created_at` (and whatever feeds the worn/created display — verify via `DisplayTitle.note`) = 2026-10-29 04:44 in the seeding device's local calendar; `last_touched_at` / `last_major_revision_at` / `updated_at` = the seed moment. The Prince's injected-clock machinery is the precedent for a fixed-date mint; the split-stamp finish is this seeder's own (one transaction, exact rows — state in the record exactly which columns carry which stamp and why). `entry_date` stays NULL (importPost's shape; the worn date must come from created_at — verify, and if the Library's date facet needs entry_date instead, say so in the record BEFORE building it that way).
3. **The Sherlock door retitle (R-105-4).** `.restoreSampleLibrary`'s rendered label becomes `Restore “the adventures of sherlock holmes”` interpolating `SampleLibrarySeeder.bookName` (the Jekyll door's exact idiom — grep every home: Help menu, the capability registry, the palette, any ⌘K/dictionary row). The act is unchanged (`restoreSeededBook(.sherlock)`). Grep rendered copy AND the guide/tour content for "Restore the Sample Library" / "Sample Library" — update rendered chrome; if any GUIDE LESSON text names the door, change it and FLAG it in the record (a guide content change stales her real store's seeded guide → the closeout re-seeds it behind the A1 rail). Sentence case, no new caps.
4. **Pins.** Rework the readme pins to the new truth, red-on-old per changed fact: (a) the seed-shape pin — 17 blocks, each block's stored text's SHA-256 equal to the manifest value (transcribe the 17 hex values into the test from `notes/plans/vx-105-letter-content/README.md`), one take per block, title/bookless/untagged/Home; (b) starred at birth; (c) the stamps pin — created reads 2026-10-29 04:44 local, touched/major = seed time, seeded last and tops the edited sort; (d) the door pin — the registry/menu renders the new Sherlock title and nothing renders "Restore the Sample Library"; (e) `ReadmeStartHerePlanTests` re-anchored: the four passages' byte-pins stay (they are the GUIDE's text now) but no longer assert readme membership; (f) `TutorialNewRoadChapterTests` / `TutorialFurnitureFoldTests` / `LaunchFurnitureTests` reworked to the new seed (the "nothing seeds after the readme" pin stays). Headless `swift test` what's reachable; Mac suites are WRITTEN now and RUN at the orchestrator's stage window — end your turn reporting READY-FOR-STAGE with the exact `-only-testing` TYPE names (suite types, never file names).
5. **The first-chapter interweave (R-105-5).** Replace the "start here" lesson's blocks (`TutorialSeeder.swift` ~line 618) with the architect's drafted weave below — her draft's personal welcome and interactive takes moment joined to the existing lesson's vision, safety, companions and closer blocks. The lesson gains REAL TAKES on two blocks (the `take(on:_:)` helper at ~line 610). The draft's bracketed BUILD-VERIFY flags are chrome names you must resolve against the real code BEFORE locking the copy — say each resolution in the record; adjust ONLY those chrome words, nothing else without flagging it:
   - Block 1 (hers, verbatim): "Welcome to Variorum! I'm Lillian, the developer behind this app, and I'm excited that you've downloaded it."
   - Block 2 (existing beliefs block, its leading "Welcome. " dropped since block 1 now welcomes): "Variorum is built on a few beliefs about writing. …" (rest byte-identical).
   - Block 3 (existing, byte-identical): "This book is Variorum teaching itself with itself. …"
   - Block 4 (existing, byte-identical): "Everything in this book is safe to play with. …"
   - Block 5 (hers, verbatim): "I built Variorum with a simple goal: to be able to create multiple different versions of a block of text. I call these versions takes, borrowing from the film world. The icon to the right of this block is the take icon - click on it." — TAKE 1: "You found it! :D" (verbatim). TAKE 2: her draft's "Now click on Open Takes mode in the top bar of this modal" [BUILD-VERIFY: name the REAL road from the take panel to Takes mode in today's chrome; keep her sentence's shape].
   - Block 6 (hers): "While Write is meant to behave like a simple and elegant editor, Takes is where complexity thrives. Click on \u{201C}expand all\u{201D} at the top of Takes." [BUILD-VERIFY: the expand-all control's real name and home].
   - Block 7 (hers, verbatim): "This is the point at which you might be thinking \"cool, but so what?\", unless you're a writer that understands the pain of reworking a particular paragraph to the point of madness. If that isn't you, some of the best use cases I've found for it are in the takes of this paragraph." — TAKE 1: her shortcuts take with the chord spellings matched to the guide's idiom ("…you can also get to Takes with \u{2318}2. Check out all the shortcuts at \u{2318}/.") [BUILD-VERIFY ⌘2 is Takes]. TAKE 2: her style take [BUILD-VERIFY: the fan-style control's real name on the Takes masthead; keep "margin grid" only if that style name is real].
   - Block 8 (existing, byte-identical): "Two companions to know from the start. …"
   - Block 9 (existing closer, her closer's idea folded): "The chapters of this book are listed on the left, each an interactive guide. Read in order, or jump to what itches. When something in a lesson doesn't behave as the words promise, that is a bug in the app, not in you."
   Update the lesson's pins (TutorialWalkTests / any start-here content pin) to the new truth; the chapter now carries fanned blocks, so verify nothing pins "no takes in the welcome chapter". FLAG in the record that guide content changed (the closeout re-seed).
6. **The record.** Fill "## U1 RECORD" below: LIVE STATUS per piece, the stamp-column table, the door-copy grep list (and whether guide content changed), the BUILD-VERIFY resolutions, PROVISIONALs with alternatives, the stage commands.

FENCES: no `xcodebuild test` at your seat (stage window only); no walks, no app launches, no `/Applications` touch, no Release builds; nothing under `Sources/VariorumCore/Sync/`; her text byte-exact (R-13s-28 — if any literal disagrees with the manifest, STOP and report, never "fix" her words); no attribution trailers; sentence case in rendered strings, no em dashes in rendered strings, no emoji.

## U1 RECORD

**What this unit did NOT do (first line, per the contract):** no Mac suite was RUN (stage window only — the suites are
WRITTEN and compile under `build-for-testing`); no walk, no app launch, no `/Applications` touch, no real-store mint
(R-105-1 is the closeout's); nothing under `Sources/VariorumCore/Sync/`. PENDING items are marked as such below.

### LIVE STATUS (implementer, Opus — one session)

- **Piece 1 — the seeder content swap:** DONE (`99231c04b`).
  `ReadmeSeeder.paragraphs` = her 17 blocks, literals generated from `read-me.txt` with the trailing space restored per
  the manifest, then the literals AS WRITTEN IN THE SEEDER SOURCE extracted, compiled with `swift` and hashed:
  **GREEN — all 17 SHA-256 == the manifest's 17 values** (13 blocks end with one space; 2, 12, 16, 17 do not). No
  takes (the `takes` map is deleted). Minted through `createPost` + `newBlock` per block, NOT `importPost`: bulk
  segmentation trims every piece's trailing whitespace (`SegmentationRules.bulkSegments` → `trimmedPiece`), which would
  have taken 13 of her bytes. `herBlocks` DELETED (not demoted — her draft's useful parts move into the guide's first
  lesson at piece 5; the frozen reference file keeps the draft as history). `startHerePassages` RE-HOMED byte for byte
  to `TutorialSeeder.startHerePassages` (a script compared the old and new declarations: BYTE-IDENTICAL MOVE); the key
  lesson reads it from there, so the guide's lesson text is unchanged by a byte. Test files touched compile-only
  (marked in place); their real rework is piece 4.
- **Piece 2 — born starred + the stamps (R-105-3):** DONE (this commit — hash at the next). The split stamp is landed
  by OPERATIONS ALONE, no row ever re-stamped: `createPost` runs under `withDependencies { $0.date = .constant(4:44) }`
  (the Sherlock/Prince fixed-clock precedent, scoped to the one mint), then the 17 `newBlock`s run on the ambient clock
  and their own touch + churn stamp the edited columns; then `setStarred(.post(id), true)` — the one star write — in the
  same runner turn. See the stamp table and **S-1 (the star meets the fold — a structural surprise, ARCHITECT'S
  RULING NEEDED)** below.
- **Piece 3 — the Sherlock door retitle (R-105-4):** NOT-STARTED.
- **Piece 4 — the pins:** NOT-STARTED.
- **Piece 5 — the first-chapter interweave (R-105-5):** NOT-STARTED.
- **Piece 6 — this record's closing sections:** IN-PROGRESS (LIVE STATUS kept from the first commit).

Compile evidence so far: `xcodebuild -scheme Variorum -destination 'platform=macOS' build-for-testing` (compile-only —
app AND test target, nothing run) EXIT 0 after piece 1 and after piece 2.

### The stamp-column table (R-105-3 — "created 4:44, edited at birth")

| Row | Column | Carries | Why |
|-----|--------|---------|-----|
| `container` (the readme) | `created_at` | **2026-10-29 04:44:00.000 in the seeding device's local zone** (Gregorian, `TimeZone.current`), stored as that instant in UTC by the canonical formatter | The created face everywhere: `Queries.noteStamps.createdAt` (the masthead's created flip), the Library's `created` sort and row stamp (`LibrarySortFace.rowStamp(.createdAt)` reads `hit.createdAt`). Minted under the 4:44 clock by `createPost`. PROVISIONAL reading (R-105-3's): every reader sees 4:44 am on her own clock, so the UTC instant differs by zone (Los Angeles 11:44Z, Tokyo the 28th 19:44Z). |
| `container` | `last_touched_at` | the seed moment (the last block's mint) | `newBlock`'s `registerTextChange` touch — the Library's DEFAULT sort (`.lastTouched`, edited newest first) reads it; seeded last, so the readme tops it (R-13s-29). Also the masthead's edited face (`noteStamps.editedAt`). |
| `container` | `last_major_revision_at` | the seed moment (the first block's churn crossing — `baseline_length` 0, so block 1 crosses at once) | `newBlock`'s churn; the timeline's sort. |
| `container` | `updated_at` | the seed moment (the last block's mint) | `registerTextChange` writes it with the touch. (`createPost` first wrote 4:44 here; the text's landing supersedes it — "edited at birth".) |
| `container` | `entry_date` | NULL | `importPost`'s shape kept. VERIFIED the worn date needs no `entry_date`: the readme is TITLED, so `DisplayTitle.note` never reaches its date chain; the Library's day filter is "edited on this day" (`last_touched_at` ∪ savepoints), not `entry_date`; and the furniture fold reads a set `entry_date` as HER engagement. |
| `block`, `variant`, `container_block` (17 each) | `created_at`, `updated_at` | the seed moment, per block | The words were set down at the device's birth; only the note's own `created_at` carries her moment. No face reads these for the readme today (no savepoints, one take each). |
| `setting` `'starred'` | (no stamp column) | the readme's `post:` key appended | Born starred through `setStarred` — the one star write (VX-643: no cap). |

The ALTERNATIVE (not built): mint every row under the 4:44 clock (the Prince's whole-scope shape), then re-stamp
`last_touched_at` / `last_major_revision_at` / `updated_at` to the seed moment. Rejected because no public operation
moves `last_major_revision_at` without a text change or a MANUAL commit (a manual savepoint is fold engagement and a
visible "commit" in her history), so it would need a raw row write — the operations-as-API rule's one forbidden road.
Recorded property, unchanged in kind from the old seeder: the mint is 19 transactions in ONE serialized runner turn
(the guide's own shape; the old readme's takes pass was likewise separate transactions) — `importPost`'s single
transaction is unavailable because it trims her bytes.

### S-1 — STRUCTURAL SURPRISE: the born star reads as HER ENGAGEMENT in the furniture fold (architect's ruling needed)

**Traced mechanism.** `SeededFurnitureClassifier.noteVerdict` (`Sources/VariorumCore/Sync/SeededFurnitureDedupe.swift`,
the note grain) returns `.engaged` whenever the synced `'starred'` list contains the note's id (*"HER STAR is engagement
on every grain"* — 13s U1b ladder round 1, MAJOR-1, #186(a)). The readme is now born starred, so EVERY fresh mint reads
`.engaged`, never `.foldable`. Consequence: two fresh Macs, each seeded signed-out, later joined to one account keep
TWO readmes forever (R-13s-5's release constraint — "every seeded object of the final set folds on sign-in" — no
longer holds for the readme). Worse, the `'starred'` setting is one server-wins CAS row, so after the pair meets one
device's star list wins: one readme starred, one not, and the unstarred one is still not foldable alone. The
REAL-SEED drift guard `TutorialFurnitureFoldTests.theRealReadmeAndExampleSnippetAreFoldableAndTwoMintsAgree` WILL READ
RED at the stage window by construction (the readme arm) — it is the net doing its job, and it is left standing until
the ruling. Gatherings already have the answer's shape (`Gathering.bornStarred`: the seed's own flag is identity, the
flag OFF the seed's value is engagement); `ReservedContainer` has no such field.

**Options (the architect rules; nothing beyond the ruled star is built):**
- **(A) A Sync/ unit (Fable work, its own ticket):** `ReservedContainer` gains `bornStarred`; the note grain reads the
  star as IDENTITY when it equals the seed's value and folds the pair, RE-POINTING the star list to the keeper (the
  gatherings' `designationKey` re-point precedent) so the server-wins list collision cannot strand the survivor
  unstarred. Spec-defensible (BLOCKER-1: seed-authored state rides the identity), but `Sync/` and outside this unit.
- **(B) Accept for launch, record the residual (RECOMMENDED for this unit):** the double-readme case needs two fresh
  Macs, each seeded signed-out, joined later to one account (her letter places the paid sync option with the mobile
  release); both copies stay live and visible, either deletable (the LaunchFurniture header's "RESIDUAL, NAMED"
  class). The drift guard's readme arm flips to assert `.engaged` WITH this reason, and (A) is ticketed for the
  sync launch. One-line pin change; the example-snippet arm stays the net.
- **(C) Not born starred** — contradicts her ruling; listed only to be ruled out.

## The ladder

(fresh opus-reviewer per round; findings land here before any fix session sees them)

## Closeout checklist (the orchestrator's)

- Stage window via oct29coordinator (REQUEST→READY→GO): the Mac suites (the readme/launch/tutorial/registry suites + full VariorumTests), then the fresh-birth reset walkthrough (the VX-633 road: clear the THREE seed marks in the DEBUG defaults domain deliberately; md5 the five dev-slot files before, restore byte-exact after; watch for an orphaned `variorum-restore-hold.json` — VX-697).
- Walkthrough asserts: her 17 blocks byte-exact on the page, starred, standalone, created Oct 29 4:44 am, tops the Library; the old placeholder content gone; Help shows the four per-book doors and no "Restore the Sample Library"; the Sherlock door restores the book.
- Her real store: the headless mint (R-105-1) behind the A1 rail at a zero-instance window; the guide RE-SEED is now certain (R-105-5 changes the first chapter) — the product door behind the A1 rail, same window.
- Canon deltas (two-file rule): SurfaceContracts "The app" seed-set line (readme = her letter text, 17 blocks, starred, dated; sherlock door named; sample-library label retired) + keyboard/doors lines if touched; AppSpecRecord dated entry with her words; QUESTIONS #234's P-VX306-W-1 noted superseded-in-part (the passages' readme home ended; the guide home stands).
- VX-105 Done rides the PR merge ("VX-105: …", merge commit); **VX-635 closed as superseded** (her disposition 3); in-flight row retired; worktree + branch deleted; canon-size line in the handoff.
- Release: Release build, DMG + appcast to stargazing.tech (the cross-repo road) — notes DRAFTED FOR HER IN CHAT first (never a meta line in the file, VX-708); /Applications refresh at a zero-instance window (A1 first).
- MOBILE PARITY: nothing mobile-visible (R-105-2).
