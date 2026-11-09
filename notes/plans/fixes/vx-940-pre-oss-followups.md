# VX-940 — Run: pre-OSS code follow-ups

**STATUS: OPEN — kicked off 2026-11-09 at her sitting (/architect-phase, the Pro; orchestrator variorum-91, running beside VX-926 under the two-Opus allowance — one implementer per run, never two in one worktree).**
Ticket: VX-940 · Branch: `vx-940-pre-oss-followups` · Worktree: `~/dev/variorum-vx-940` · PR: `VX-940: …` (merge commit, never squash).
Coordinator: nov7. **This is the wave's LAST umbrella before her pause** (her words at the sitting: "I'll be pausing code changes once this current wave is done (including the umbrella we're about to mint)"); VX-849 runs in this wave as its own umbrella ("I'm planning on running that, just not under the same umbrella. but it does belong to this wave.").

## FOR A LATER READER

*(Written at closeout. Until then: her rulings are §2; the batches §4; the ledger §6.)*

---

## 1. Kickoff, cast, preflight

- **Members (the sub-issue listing of VX-940):** VX-939 · VX-923 · VX-920 · VX-917 · VX-922 + VX-925 + VX-933 (one MCP-hygiene unit). Confirmed by her at the sitting's dialog ("Confirm all six"). VX-932 rides VX-926 instead; VX-919/VX-921 are seated in VX-849.
- **Cast:** her VX-926 ruling carries as the session's working default for this wave — **Opus implements, Opus reviews**; everything away-time rules PROVISIONALLY and bundles. **The STOP rule:** any diff line reaching `Sync/`, custody/keychain or the editor seam halts the run back to her (that class mandates Fable review). The MCP unit lives inside MCPSpec's contract (required reading for its implementer); R-825 binds; an answer-shape change returns to the orchestrator BEFORE building.
- **Preflight:** carried by this orchestrator session's same-day reads (CLAUDE.md + canon; the master plan + in-flight; QUESTIONS #268 incl. her sitting rulings; the resiliency protocol; MCPSpec IN FULL; the VX-912 B2/B3/B4 records). SurfaceContracts: VX-920 touches the History & Lineage face — its implementer reads SurfaceContracts' note-section lines for that surface; VX-923 is Settings copy (the Acknowledgments pane — no contract change, additive credits). No SyncSpec/TEXTKIT2/CastleRules seam in scope.
- **Stage:** nearly everything headless. App-suite runs (VX-920's pin; the merge gate) via nov7 (REQUEST/READY/GO/RELEASE); the VX-926 soak and this run's gate can share scheduling — nov7 arbitrates. The soak-tree rule binds this run's gate too.

## 2. Her rulings (the 2026-11-09 handoff sitting; QUESTIONS #268's addendum carries the full set)

- **R-940-1 (the mint + composition):** "you'll help me make a new umbrella ticket in linear to run now for the follow-ups that need to be done pre-oss" + the dialog pick "Confirm all six".
- **R-940-2 (the wave + pause):** VX-849 "does belong to this wave" as its own umbrella; code pauses after this wave INCLUDING this run; her her-hands pass follows.
- **R-940-3 (VX-939's substance, verbatim):** "i'm fine renaming the readme that ships within variorum as a note for users to 'letter' within the repo, so the code element of doing that you can ticket."
- **R-940-4 (VX-917's cadence, verbatim, from VX-912's sitting):** "I think it should be a check every major version switch or something, it's too onerous for every run."
- **A-940-1 (the orchestrator, on W1's P-940-W1-5):** the LETTER.md drift pin BUILDS — a headless core/app test comparing `LETTER.md`'s paragraphs with `read-me.txt`'s (and thereby the seeder literals through the existing pin), so the three-copies sync is mechanical rather than comments-kept-by-hand. Her standing basis ("do it right, won't regret in 3 years") decides it; test-only, no product behavior. W2 carries it as a rider. P-940-W1-1..4 stay bundled for her pass (the words are hers to judge). W1's BIP-39 "recovery phrase" role-line observation goes to VX-936 (her wording pass) with the CastleRules note — not changed here.

## 4. Batches (one acceptance unit each; a fresh opus-implementer per batch; §7 = the VX-926 record's §7 by reference, which binds the VX-912 record's §7)

### W1 — VX-939 + VX-923 (the repo face + the credits; one unit, two members)
1. **VX-939 — LETTER.md:** materialize her letter's text as a clean `LETTER.md` at the repo root; the README's pointer moves to it; the in-app seed road untouched (if the seed source and LETTER.md can honestly be ONE file, say so in the record — else two files with the sync noted). The letter's text today: `notes/plans/vx-105-letter-content/read-me.txt` (strip the capture-token header for the .md face; the words are HERS — byte-faithful, no editorial).
2. **VX-923 — the Acknowledgments credits:** Settings ▸ Acknowledgments gains Sparkle (MIT + its BSD-2/zlib/MIT parts) and the five LINKED Point-Free MIT libraries; BIP-39's license line corrected to MIT in `Vendor/BIP39/README.md` and `AcknowledgmentsCopy.bip39`. The VX-912 B3 record's dependency table is the source of truth for names/licenses. App copy — sentence case, no shouty caps; the pane's existing entry shape is the template. Pin: the pane's listing test (or the copy source's unit test) asserts the new entries; red-on-old.
Evidence: headless build + the copy tests; VX-939 is repo files only.

### W2 — VX-920 (the lineage face names Home)
The one-line fix shape from the VX-912 B2 record: `LineageFaceModel.place` resolves through `Queries.effectiveWingID` and names Home as the switcher names it (never "the wing “”"). Required reading: the B2 record's F-R1-1/ finding + SurfaceContracts' History & Lineage lines. Pin: a `LineageFaceModelTests` arm over `.otherWing(wingID: "")` asserting the Home wording — red-on-old by revert. The visual confirm rides the merge-gate window (one capture if cheap, else the pin carries it).

### W3 — VX-917 (the CI cold-build workflow)
`.github/workflows/` gains the cold-build check at HER cadence (R-940-4): triggered on release tags / manual dispatch — NEVER per-push; jobs: `swift build` + `swift test` on the core from a clean checkout (the BUILDING.md road); the workflow's own header comment states the toolchain-skew rule (AppSpec §15.6 — results count only when the runner's Xcode major matches the primary's) and that a failed run on a mismatched toolchain is informational. Inert-while-private posture like the B3 workflows where applicable. Evidence: `act`-style local validation isn't available — the YAML parses (a linter is a legal instrument), the trigger shape is pinned by inspection in the record, and the first live run is a flip-day check (noted on VX-937's checklist… append it there at closeout).

### W4 — the MCP-hygiene unit (VX-922 + VX-925 + VX-933)
Required reading: MCPSpec IN FULL; the VX-912 B4 record; the VX-926 U1 record (the HarnessWait.offPool pattern and the pool trace — VX-933 is its door-side sibling).
1. **VX-922:** fold `Queries.mcpResolvedWing` + `MCPReadTools.resolvedWing` onto the one `Queries.effectiveWingID` rule — byte-equivalence proven by the existing pins passing UNMODIFIED (the parity proof); no reach semantics change.
2. **VX-925:** `clientInfo.version` routed through VX-357's strip at the write (`admitMCPConnection`); pin: a NUL-bearing version stores stripped-and-counted; red-on-old.
3. **VX-933:** the door's blocking send gets a bound — a send timeout or the send taken off the pool (the offPool pattern door-side); the shape that changes NO wire answer is preferred; if every honest shape changes an observable behavior (a new close reason, a dropped-connection road), STOP and return the shape to the orchestrator (MCPSpec consequences). Pin: a stalled-reader client cannot pin pool threads — deterministic via a non-reading test client; red-on-old.
All headless (the MCP suites). The two-store catalog green whole is this unit's own gate.

### The ladder
One ladder over the run's whole diff: fresh `opus-reviewer` (her cast), REVIEW_PROMPT VERBATIM, zero framing; findings repo-first; same-model arbitration by the orchestrator against the spec; cap three rounds. The STOP rule re-checked over the final diff before the ladder.

### The gate
The whole Mac target + the phone target if `Shared/` changed (VX-920 is Mac app code; VX-923's copy may be shared — check) + the MCP whole target, on the final tree, via nov7, every run through `Tools/assert-tests-ran`. Coordinates with VX-926's soak windows — nov7 arbitrates the order; merges serialize.

## 6. LEDGER

| Row | What | Status |
|---|---|---|
| 0 | Kickoff: mint (VX-940), 7 members seated, worktree, in-flight row, her rulings | DONE (this commit) |
| W1 | VX-939 + VX-923 | **BUILT + PINNED, headless** — "## W1 record" (end of file): VX-939 `LETTER.md` landed (two files, sync noted — the seed reads compiled literals; `read-me.txt` is the pins' oracle, untouched); VX-923 the four Point-Free siblings + Sparkle credited (verbatim, generated and checked IDENTICAL), BIP-39 → MIT in both places; the pin red 19 on old / green 4/4 headless; **in-target runs PENDING the gate (Mac AND phone targets)**; authored sentences + P-940-W1-1..5 listed for her pass |
| W2 | VX-920 (+ the A-940-1 rider: the LETTER drift pin, Part of VX-939) | **IN PROGRESS** — "## W2 record" (end of file) |
| W3 | VX-917 | NOT STARTED |
| W4 | VX-922 + VX-925 + VX-933 | NOT STARTED |
| L | The ladder (opus-reviewer) | NOT STARTED |
| G | The gate (whole targets via nov7) | NOT STARTED |
| C | Closeout | NOT STARTED |

## 7. Environment traps

The VX-926 record's §7 binds by reference (which binds the VX-912 record's §7). This run adds: never two implementers in one worktree (this run and VX-926 run beside each other under the two-Opus allowance — each stays in its own worktree); the letter's words are hers byte-faithful; all public copy sentence-case, PROVISIONAL posture per the standing rulings.

## W1 record

**NOT DONE BY THIS IMPLEMENTER (first line, kept current):** no `xcodebuild` of any kind, no stage, no Debug launch, no walk or capture (the brief: headless only — `swift build`/`swift test` plus throwaway `swift`/`swiftc` instruments). So these in-target runs are **PENDING the run's gate**: the Mac copy suite (`AcknowledgmentsCopyTests`, the new pin included), the seeder pins (`LaunchFurnitureTests`, unmodified), and the phone sweep (`MobileNoRedirectSweepTests`, one exemption added). Each was proven headless in substance (below). **The gate must include the PHONE target:** `AcknowledgmentsCopy.swift` is `Shared/` and the phone test target changed. Also not done: nothing published; `notes/QUESTIONS.md` untouched (the merging session files the PROVISIONALs, the VX-912 B3 precedent); the offered drift pin not built; the BIP-39 notice's ROLE line ("…your recovery phrase…", a Castle-adjacent sentence) not touched, and CastleRules not read.

*Machinery: Opus implementer, fresh session, briefed by this file's §2/§4 W1/§7 (+ the VX-926 §7 and VX-912 §7 it binds), the resiliency protocol, the VX-912 B3 record (the dependency table, F-B3-1/F-B3-2, P4's options), the two tickets. No revert is in flight.*

### LIVE STATUS

| Piece | What | Status |
|---|---|---|
| P0 | This record + the ledger row | DONE (`6d2cc46db`) |
| P1 | VX-939 — `LETTER.md` at the repo root (her text, header stripped, byte-faithful); the README pointer moves to it; the one-file-or-two verdict | DONE (`ca0527736`) — TWO files, sync noted (verdict below); body byte-identical to `read-me.txt`'s, and equal to `ReadmeSeeder.paragraphs` (17/17) by a scratch compile of the literals; `read-me.txt` and the seeder's code untouched |
| P2 | VX-923 — the pin (red on the current tree) | DONE (`ef6918454`) — `AcknowledgmentsCopyTests.everyLinkedLibraryIsCreditedAndBIP39ReadsMIT` (Mac app target, `Phase13pSubstrateTests.swift`); **RED on the unfixed source, 19 issues, the three old tests green** (headless harness below); in-target run PENDING the gate |
| P3 | VX-923 — the credits (Sparkle + the Point-Free siblings) and the BIP-39 line (pane + `Vendor/BIP39/README.md`) | DONE (`f2bf3d002`) — the pin GREEN 4/4 on the fixed source; every new license text IDENTICAL to its file; the phone sweep's exemption proven byte-exact (green fixed, red both ways) — all headless; in-target runs PENDING the gate |
| P4 | Close: headless build + the copy tests + the seeder pins (PENDING the gate where in-target), authored sentences listed, PROVISIONALs | DONE (`c3fef7e62`) — `swift build` EXIT 0 on the final tree; StringsWorkbook 32/4 + RecoveryPhrase 13/1 green, none skipped; the in-target runs PENDING the gate (first line) |

### P1 — VX-939: `LETTER.md` (repo files only)

**What the seed road reads (the premise check).** The brief asked whether the in-app seed road reads `read-me.txt`. **It does not.** `ReadmeSeeder` mints from compiled Swift literals, `ReadmeSeeder.paragraphs` (`App/Variorum/Variorum/Features/Onboarding/BirthFurnitureSeeders.swift`, 17 strings). Nothing in the app opens a file. `read-me.txt` is the **test oracle**: `LaunchFurnitureTests.herReadmeFileParagraphs()` opens it by `#filePath`, asserts its first line starts `{t:"readmev5"}`, drops that line and splits the rest at blank lines. Then `aFreshLaunchSeedsHerReadmeByteForByteOneTakePerBlock` asserts `ReadmeSeeder.paragraphs == file` and the seeded blocks byte for byte, and two door pins reuse the same reader.

**Verdict: TWO files, not one. The sync obligation is noted on both sides.** Neither one-file road is honest here:
- *LETTER.md as the oracle* (retire `read-me.txt`) means editing the seeder's pins: the hard-coded path, plus the header assertion that LETTER.md can't satisfy, since its whole point is a stripped header. The brief requires those pins to pass UNMODIFIED.
- *LETTER.md as the seed source* (the app reads it at runtime) means bundling it as a resource and replacing the literals with a file read at birth. That adds a new failure mode at a fresh store's first launch and changes the seed road, which §4 W1 says to leave untouched. It also wouldn't make one file: the oracle would still be `read-me.txt`.

So there are three representations, all byte-equal today: the literals (what seeds), `read-me.txt` (what the pins check the literals against: her capture artifact, left untouched), and `LETTER.md` (the repo's face, which nothing reads).

**Built:**
- `LETTER.md` at the root: an HTML comment block (invisible on GitHub's render: what the file is, that the words are hers, and the three-way sync), then her text. The text is `tail -n +3` of `read-me.txt`, i.e. the header line `{t:"readmev5"} {#readme}` and its blank line dropped. It's a byte-level transform, never retyped. **No Markdown formatting was needed:** the file already has one paragraph per line with blank lines between, and its only Markdown-active bytes are `*and*` (block 3), her emphasis, which the app's markdown face renders the same way. Nothing is escaped, and there is no heading (a heading would be words that aren't hers).
- `README.md`: the letter section's link target only, `notes/plans/vx-105-letter-content/read-me.txt` → `LETTER.md`. Every other byte is unchanged.
- The sync notes: (1) `LETTER.md`'s comment block; (2) `ReadmeSeeder.paragraphs`' doc comment (one comment paragraph; `git diff` shows only `///` lines added, so the seeder's code is untouched); (3) the content package's `README.md` beside `read-me.txt`, one paragraph. **`read-me.txt` itself carries no note:** any added line becomes a paragraph to the oracle and reds the pins. That is the evidence it must stay byte-untouched.

**Evidence (headless):**
- `cmp` of LETTER.md's body (after its comment block) against `tail -n +3 read-me.txt`: **identical**, sha256 `77eee52c…cc46` on both sides.
- A scratch compile of the seeder's literal array: lines 129–283, sed-extracted from the source and run under `swift` beside both files with the test's own split rule. Results: `LETTER.md == ReadmeSeeder.paragraphs` **true**, 17/17. `read-me.txt == ReadmeSeeder.paragraphs` **true** (the app pin's own assertion, reproduced headlessly). The body starts on her first words.
- `git grep` over every test root (`Tests/`, both app test targets, `Tools/*/Tests`, `Sources/`): no test reads `README.md`, `LETTER.md` or the package README. The one reader of the package is `LaunchFurnitureTests:162` (`read-me.txt`).
- The seeder pins run IN-TARGET only at the gate (app suite → stage): PENDING there, unmodified. Nothing they read changed: `read-me.txt` and the literals are byte-untouched.

**Offered, not built (the orchestrator's call):** a headless DRIFT PIN, a core-package test that reads `LETTER.md` and `read-me.txt` by `#filePath` and asserts equal paragraphs. With the app pin, that would make the three-way sync mechanical rather than by hand. Not built because the brief named header comments and §4 says VX-939 is repo files only.

### P2 — VX-923: the pin, before the fix

**The pin:** `AcknowledgmentsCopyTests.everyLinkedLibraryIsCreditedAndBIP39ReadsMIT`, in the pane's own copy suite (`App/Variorum/VariorumTests/Phase13pSubstrateTests.swift`, the Mac app target). It asserts:
- the five Point-Free libraries, by the B3 table's package names, are in `shared` (both platforms). Each text starts `MIT License\n\n<its own copyright line>\n`, and the newline ends the line, so "Point-Free" never passes for "Point-Free, Inc.";
- Sparkle is in `all` on the Mac and absent from `shared`, and its text carries the MIT grant's first copyright line, the non-ASCII Lesiński line, `EXTERNAL LICENSES`, and the copyright line of each of the four external parts (bsdiff BSD-2, sais-lite MIT, ed25519 zlib, SUSignatureVerifier BSD-2);
- BIP-39's text says `MIT License` and quotes the BIP (`"This BIP falls under the MIT License."`), with no `BSD`, `PD/` or `public-domain` left;
- every name in `all` is unique (the pane's `ForEach` is keyed by name).

Notices are looked up BY NAME, so the pin compiles on the old tree and reds there by assertion, not by a missing symbol.

**How it runs headless (a throwaway instrument, never in the PR).** The suite is app-target code, and an in-target run is an `xcodebuild test` (the stage), which this batch may not do. So `scratchpad/w1-ackpin/run-pin.zsh` builds a scratch SwiftPM package. It copies a given edition of `AcknowledgmentsCopy.swift` in as a library, and the suite's text, `awk`-extracted from the given `Phase13pSubstrateTests.swift` from its `@Suite` line to its closing brace, in as the test target. The only lines it adds are `import Foundation` / `import Testing` / `@testable import AckCopy`. Then it runs `swift test`.

**Red on the unfixed source** (this commit's `AcknowledgmentsCopy.swift`, unchanged since `b637dc457`): `Test run with 4 tests in 1 suite failed … with 19 issues`, EXIT 1. The three existing tests pass. The new one carries exactly the expected 19: the four siblings × (missing + text), Sparkle missing + its seven lines, and BIP-39's three lines. swift-dependencies' row, Sparkle's not-in-shared row and the unique-names row pass on old, as they should.

### P3 — VX-923: the credits and the BIP-39 line

**Which five.** The ticket says "the five LINKED Point-Free MIT libraries". Per the B3 table, these are swift-dependencies (already credited) plus its four Point-Free siblings, each uncredited: **xctest-dynamic-overlay** (it ships the two modules IssueReporting and XCTestDynamicOverlay, which is why F-B3-2's module list reads as five), **swift-concurrency-extras**, **combine-schedulers**, **swift-clocks**. Four entries were added, so the pane now carries all five. Names are the table's package names, matching the existing "swift-dependencies" entry.

**Facts re-read here, not taken on trust.** Every checkout's `HEAD` equals its `Package.resolved` pin (1.14.1 `8dc1fbf2` · 1.11.0 `8f6abcf4` · 1.4.1 `5fa25342` · 1.2.0 `dcccb979` · 1.1.0 `72d749bf`). Each sibling's LICENSE differs from swift-dependencies' only in its copyright line, and two of them say "Point-Free" without ", Inc.". **Both platforms:** swift-dependencies' manifest links ConcurrencyExtras, IssueReporting and XCTestDynamicOverlay unconditionally, and Clocks and CombineSchedulers under the `Clocks` / `CombineSchedulers` traits. Its `.default(enabledTraits:)` turns those on, our `Package.swift` sets no traits on it, and no dependency is platform-conditioned (combine-schedulers' OpenCombine leg is Linux/Android only). So all four go in `shared`. **Sparkle** is the Xcode project's `exactVersion 2.10.0`, its checkout at `eef1a539a` (2.10.0), and the Mac app target's packageProductDependencies alone, so it goes in the Mac arm. **BIP-0039 at the pinned commit `e7263a4c`** (one `curl` of the raw document): header `License: MIT`; `==Copyright==` → "This BIP falls under the MIT License." The B3 table's reading holds.

**Built (`App/Variorum/Shared/AcknowledgmentsCopy.swift`):**
- The four Point-Free notices follow swift-dependencies in `shared`, each with its LICENSE as a plain `"""` literal (swift-dependencies' own form).
- `sparkle` has its own MARK section, with Sparkle's whole LICENSE (the MIT grant plus EXTERNAL LICENSES: bsdiff 4.3 BSD-2, sais-lite MIT, ed25519 zlib, SUSignatureVerifier BSD-2) as a raw `#"""` literal, the MCP family's form. That is "the pane's way" of saying MIT with BSD-2/zlib/MIT parts: the license file itself, verbatim, presents them that way.
- `all` on the Mac = `shared + [sparkle] + mcpFamily`, so the Apache text stays last, after the three notices that name it.
- BIP-39's text now quotes the BIP.
- The header's sources line names the new sources.
- The license literals were **generated from the files by script**, never typed (`scratchpad/w1-ackgen/`), and inserted at two unique anchors. The one deliberate difference: Sparkle's LICENSE line 37 ends in a space ("…the following conditions "). It was dropped, because this file carries no line-end whitespace anywhere (and Xcode's trim-on-save would strip it at the next edit). The words are untouched.

**`Vendor/BIP39/README.md`:** the license bullet now reads MIT, with the BIP's two statements quoted and one sentence saying what was corrected. **The phone's no-redirect sweep** (`MobileStructuralTests`) gets one exact-literal exemption: `"its new versions (Mac only)."` in `AcknowledgmentsCopy.swift`. It's the second piece of Sparkle's role, under its own why (`sparkleNotice`, the MCP family's reason shape). The sweep walks `Shared/`, and the literal names the Mac, but the phone never renders it: `all` there is `shared`.

**Evidence (all headless; throwaway instruments in the session scratchpad, never in the PR):**
- **The pin, green on the fix:** `run-pin.zsh` on the fixed `AcknowledgmentsCopy.swift` with the suite's own text gives `Test run with 4 tests in 1 suite passed`, EXIT 0, all four named "passed" (none skipped). Red on the unfixed source (P2): 19 issues.
- **Verbatim:** `swiftc -swift-version 6` compiles the REAL `AcknowledgmentsCopy.swift` with a checker that compares each notice's `text` to its license file (the trailing newline dropped). Results: swift-dependencies (sanity) · xctest-dynamic-overlay · swift-concurrency-extras · combine-schedulers · swift-clocks · Sparkle (line-end spaces stripped), **all IDENTICAL**. Sparkle against the raw file differs only by that one space. The file compiles with no warning. Mac list: 16 names (was 11). Phone list (`shared`): 10 (was 6).
- **The phone sweep, its own suite text** (`run-sweep.zsh`): the `MobileNoRedirectSweepTests` suite text, extracted, walks a scratch COPY of `App/Variorum/{VariorumMobile,Shared}`; only `#filePath` is re-pointed, one substitution. **(a)** the fixed copy with the new exemption: passed, EXIT 0. **(b)** the fixed copy with the OLD test text (no exemption): failed, `offenders.isEmpty`, naming exactly `AcknowledgmentsCopy.swift: "its new versions (Mac only)."`. **(c)** the OLD copy with the new exemption: failed, `misfits.isEmpty`, the entry "matched 0". So the exemption is necessary, byte-exact, and covers exactly one literal.
- No other walker reaches the new strings. `CopyRegisterPinTests` and its phone twin walk named Protection files, not this one. The other `Shared/` walkers police colours, refresh authority, the refusal table and doors, not copy words. No contract line (SurfaceContracts, AppSpec) or guide text enumerates the pane. The 2026-10-04 strings inventory (`notes/copy-pass/`) is a dated snapshot that StringsWorkbook pins byte for byte, and is left alone.

### P4 — close

**The suites, at the END, on the final tree (`f2bf3d002` + this record):**
- `swift build`: EXIT 0. The core package is unchanged by this batch; the run's first build gave the checkouts.
- `swift test --filter 'StringsWorkbookTests|RecoveryPhraseTests'`: EXIT 0, **32 tests / 4 suites** and **13 tests / 1 suite** passed, no skipped line. These are the two core suites nearest the touched files: the inventory pin and the BIP-39 resource pin.
- **The named in-target suites:** PENDING the gate, each proven headless above. `AcknowledgmentsCopyTests` (P2 red 19 → P3 green 4/4). `LaunchFurnitureTests`' seeder pins: UNMODIFIED, every file they read byte-untouched since kickoff, and their core assertion (`ReadmeSeeder.paragraphs == read-me.txt`'s paragraphs) reproduced true by the P1 scratch compile. The phone sweep: (a) green, (b)/(c) red.
- Untouched since kickoff (`git diff --quiet b637dc457`): `LaunchFurnitureTests.swift`, `read-me.txt`, `notes/copy-pass/all-user-facing-strings.md`. Zero non-comment lines changed in `BirthFurnitureSeeders.swift`.
- **The batch diff:** 9 files, +482/−13. **Captures: none.** The brief named no screens folder and made the batch headless; the pane's face is the gate window's to see if the orchestrator wants a look.
- **The STOP rule:** no line in `Sync/`, custody/keychain or the editor seam.

**Row dispositions:**

| Row | Disposition |
|---|---|
| VX-939 — LETTER.md | **DONE** (`ca0527736`): `LETTER.md` at the root, her words byte-identical to `read-me.txt`'s (header stripped) and equal to the seeder's literals; the README's pointer moved (its link target only). **One file or two: TWO**, with the evidence in P1. The seed reads compiled literals; `read-me.txt` is the pins' oracle and can't carry a note. The sync is noted in LETTER.md, the seeder's doc comment and the content package README. Repo files only; no pin applies (a doc move, not a bug class); the drift pin offered |
| VX-923 — the missing credits (F-B3-2) | **FIXED with its pin** (`ef6918454` pin, `f2bf3d002` fix): the four Point-Free siblings in `shared`, Sparkle's whole LICENSE in the Mac arm; red 19 on old → green 4/4 (headless harness); in-target PENDING the gate |
| VX-923 — BIP-39's license (F-B3-1) | **FIXED with its pin** (same commits): MIT in the pane and in `Vendor/BIP39/README.md`, in the BIP's own words at the pinned commit; the pin's three BIP-39 lines red on old, green on the fix |

**Every sentence I authored (not hers, not a license's), for her pass.** Her letter's words are not on this list: none was touched.
*App copy (renders in Settings ▸ Acknowledgments; the four Point-Free roles render on the phone's sheet too):*
1. xctest-dynamic-overlay's role: "Point-Free's issue-reporting library (IssueReporting and XCTestDynamicOverlay), which swift-dependencies builds on."
2. swift-concurrency-extras' role: "Point-Free's Swift concurrency helpers, which swift-dependencies builds on."
3. combine-schedulers' role: "Point-Free's schedulers for Combine, which swift-dependencies builds on."
4. swift-clocks' role: "Point-Free's clocks for Swift concurrency, which swift-dependencies builds on."
5. Sparkle's role (Mac only): "The software update framework — how the app checks for and installs its new versions (Mac only)."
6. BIP-39's notice text: "From the Bitcoin Improvement Proposals repository (BIP-0039), under the MIT License: "This BIP falls under the MIT License."" The opening clause is carried over from the old text, the quoted sentence is the BIP's, and "under the MIT License:" is mine. "Upstream: …" is unchanged.

*Repo text a stranger reads after the flip:*

7. `Vendor/BIP39/README.md`'s license bullet: "MIT. The BIP-0039 document at the pinned commit says so twice: its header reads `License: MIT`, and its Copyright section reads "This BIP falls under the MIT License." The wordlist is part of that BIP. (VX-923 corrected an earlier line here that said PD/BSD-2-Clause, which the document at this commit does not say.)"
8. `LETTER.md`'s comment block (hidden on GitHub's render, visible in the raw file): "This is the letter Variorum opens with: the first note in every new library, titled "readme". The words are Lillian's, byte for byte. Never edit, reword or re-punctuate them here." · "It is kept in step by hand. The app seeds its own copy of the same paragraphs (ReadmeSeeder.paragraphs, App/Variorum/Variorum/Features/Onboarding/BirthFurnitureSeeders.swift), and the app's tests pin that copy against notes/plans/vx-105-letter-content/read-me.txt. A change to her text changes all three in one commit."
9. `README.md`: no new sentence. Only the link target changed.

*Internal, listed for completeness:* the content package README's new paragraph; `ReadmeSeeder.paragraphs`' new doc-comment paragraph; `AcknowledgmentsCopy`'s comments (sources line, `all`/`shared` docs, the two MARK blurbs); the phone sweep's `sparkleNotice` why string; the new test's doc comment and messages.

**PROVISIONAL bundle (nothing here gates the core; filed into `notes/QUESTIONS.md` by the merging session):**
- **P-940-W1-1: BIP-39's notice carries the BIP's license STATEMENT, not a full MIT text.** (a) BUILT: the statement, quoted verbatim. The BIP names no copyright holder and carries no MIT text of its own, and the pane's rule is "copied VERBATIM … never from memory". (b) Append the standard MIT permission text. That's "the MIT text" F-B3-1's shape named, but it would come from a template, not from the source. (c) Additionally point "Upstream:" at the pinned commit rather than `master`.
- **P-940-W1-2: Sparkle's role says "(Mac only)"**, the MCP family's shape (four of its five roles). The cost is one exact-literal exemption in the phone's sweep, since the phone never renders it. Alternative: drop "(Mac only)", and no exemption is needed.
- **P-940-W1-3: the order.** The Point-Free siblings follow swift-dependencies; Sparkle sits between the shared notices and the MCP family, and the Apache text stays last. Alternative: alphabetical within each group, or Sparkle last.
- **P-940-W1-4: Sparkle's one line-end space dropped**, since the file carries no line-end whitespace and Xcode's trim-on-save would strip it anyway. Alternative: keep the byte, as `\u{20}` in a non-raw literal.
- **P-940-W1-5: VX-939's two files with hand sync.** Alternative: the offered headless drift pin, a core test reading `LETTER.md` and `read-me.txt`.

**For the orchestrator (observations, not built):**
- **The gate needs the PHONE target.** §4's "VX-923's copy may be shared — check" is answered: it is `Shared/`, and the phone test target changed.
- BIP-39's role line says "recovery phrase". The VX-912 B3 record found that canon's word is "twelve words". The line is untouched here: a Castle-adjacent sentence, CastleRules unread, outside this seam. It's a ticket candidate for her vocabulary call if wanted.
- The 2026-10-04 strings inventory stays a dated snapshot. The new strings are not in it, by design.

**Self-assessment (how I'd attack this diff, for the cold reviewer):**
- **(i) The headless harnesses are transcriptions in one respect:** each adds import lines, and the sweep's re-points `#filePath`. Everything else is the suites' own text, extracted by `awk` at run time from the files in the tree. The real in-target runs are the gate's. A difference in the app target's isolation defaults (`@testable import Variorum` under its build settings) is the one thing the harness can't see. The suite needs no actor: `AcknowledgmentsCopy` is `nonisolated` and the existing three tests in the suite share the shape.
- **(ii) "Both platforms" for the four siblings is read from manifests, not from a built iOS binary.** No iOS link was inspected (B3's symbol counts came from the Mac Debug build). The manifest chain has no platform condition, so the reading is safe, but it is a reading.
- **(iii) Sparkle's text is the LICENSE file only.** Sparkle's other bundled pieces (`Vendor/` in its checkout) aren't separately enumerated. The LICENSE's EXTERNAL LICENSES section is upstream's own statement of what it owes, and B3 judged the four parts from it.
- **(iv) LETTER.md's comment block is not her words but sits in her letter's file.** It's an HTML comment, so GitHub's rendered page shows only her text, but the raw file shows it. If she'd rather the file hold nothing but her words, the sync note can live only in the two other places.
- **(v) The BIP-39 notice is a sentence beside a Castle face** (the twelve words' wordlist). I changed only its license statement, which is provenance, not behavior, and left the role untouched. A reviewer who reads the license line as a CastleRules sentence should flag it.

## W2 record

**NOT DONE BY THIS IMPLEMENTER (first line, kept current):** no `xcodebuild` of any kind, no stage, no Debug launch, no walk or capture (the brief: headless only — `swift build`/`swift test` plus throwaway scratch instruments). So the in-target run of the VX-920 pin (`LineageFaceModelTests`, Mac app target) is **PENDING the run's gate**; it is proven headless in substance through a scratch harness (below). The visual confirm of the lineage face rides the merge-gate window (§4 W2).

*Machinery: Opus implementer, fresh session, briefed by this file's §2 (A-940-1)/§4 W2/§7 (+ the VX-926 §7 and the VX-912 §7 it binds — read on `origin/vx-926-test-flakes` and this branch), the resiliency protocol, the VX-912 B2 record's (vii) + the ladder round 1's F-R1-1, SurfaceContracts' History & lineage line, the ticket. No revert is in flight.*

### LIVE STATUS

| Piece | What | Status |
|---|---|---|
| P0 | This record + the ledger row | DONE (this commit) |
| P1 | VX-920 — the pin (`LineageFaceModelTests`, a pure arm over `.otherWing(wingID: "")`), red on the pre-fix tree by assertion | DONE (this commit) — `aHomeMemberSeenFromAnotherWingIsNamedHome`; compiles on old (calls only `LineageFaceCopy.place`); **RED on the pre-fix tree, 3 issues** (Home ×2, the dead wing), the live-wing arm green — headless harness (P1 section); in-target run PENDING the gate |
| P2 | VX-920 — the fix: one name resolution (`Queries.effectiveWingID` over the read's LIVE wing names; Home = `WingWords.home`, the switcher's one Home name) for the member's line AND its go-to button | DONE (this commit) — the pin GREEN on the fix (1 test, 7 expectations, EXIT 0, headless harness); **the behavioral revert R-920-A is NEXT** (named in the P2 section; the fix is committed first, so `git checkout --` of the face file is the safe restore); in-target run PENDING the gate |
| P3 | The rider (A-940-1, Part of VX-939) — the LETTER drift pin, a core test (`Tests/VariorumCoreTests`), green; a scratch mutation of `LETTER.md` turns it red; restored | NOT-STARTED |
| P4 | Close: headless build + the nearest suites, row dispositions, self-assessment | NOT-STARTED |

### P1 — VX-920: the mechanism and the pin, before the fix

**The mechanism (traced on this tip).** `Queries.lineageTree` projects every member's home wing through `effectiveWingSQL("home.wing_id")` (`LineageTree.swift:347`, VX-892): a Home note's `''`, and a note naming a dead or unknown wing, both arrive as `LineageHome.wingID == ""`. `LineageFamily.member` (`LineageFamily.swift:170-173`) crosses the fence when the face's note and the member's note differ in that wing (`Operations.lineageCrossesWing`), so a Home member seen from a note in a live wing becomes `.otherWing(wingID: "")` with the act `.goToWing("")`. The face's read (`LineageFaceModel.read`, `:168`) fetches names only for NON-EMPTY wing ids — Home has no `wing` row — so `wingNames[""]` is always nil. Two places then render the empty string: the member's line `LineageFaceCopy.place` → `WingCopy.lineageElsewhere(wingNames[wingID] ?? "")` (`:91`) gives `in another library — the wing “”`, and the row's go-to button `WingCopy.goTo(model.wingName(wingID))` (`LineageFaceView.swift:211`, `wingName` = `wingNames[id] ?? ""`, `:235`) gives `go to  ›`. The ladder's `:112-114` pointed at the `lineageElsewhere` sentence; the go-to label is the same empty name on the same row, so one resolution serves both.

**The contract checked (SurfaceContracts, History & lineage):** "another wing's member named with go-to only"; the wing switcher's line: "the lineage door under a cross-wing copy names the wing and at most offers go-to". Neither excepts Home, so WHEN the sentence shows is unchanged (whenever the fence crosses — Home is another library when the face's note lives in a non-Home wing); only the NAME changes.

**Home's one name:** `WingWords.home` (`App/Variorum/Shared/WingWords.swift:16` — "R-13ia-2: Home is virtual — this word is its only form"). The switcher's rows are `[Row(id: "", name: WingWords.home)] + wings` and its `name(of:)` resolves `''` and an unknown id to it (`WingsModel.swift:101-108`); the face's named twin, the Compare board's lineage line, names Home the same way (`Queries.wingName(db, id:, home: WingWords.home) ?? WingWords.home`, `CompareBoardView.swift:452`). No new string.

**The pin:** `LineageFaceModelTests.aHomeMemberSeenFromAnotherWingIsNamedHome` — pure (no store): a member built as `.otherWing(wingID: "")` beside a live wing's names; its line must equal `WingCopy.lineageElsewhere(WingWords.home)` and the literal `in another library — the wing “Home”`; a member naming an id no live wing carries (`"gone"`) reads as Home; a live wing keeps its name.

**How it runs headless (a throwaway instrument, never in the PR).** The suite is Mac app-target code; an in-target run is the stage's. `scratchpad/w2-vx940/run-pin.zsh <face file> <tests file> <label>` builds a scratch SwiftPM package that depends on THIS worktree's real VariorumCore (path dependency, the worktree's `Package.resolved` copied in) with the app target's settings (Swift 6, default MainActor isolation, approachable concurrency, member-import visibility). It compiles, extracted by `awk` from the given files: the face's copy code (`LineageFaceModel.swift` from the `LineageFaceCopy` doc comment to the line before `@MainActor`, i.e. `LineageFaceCopy` + the `WingCopy.lineageElsewhere` extension), the `WingCopy` enum (`WingsModel.swift`), `WingWords.swift` whole, and three collaborator lines grepped from their files (`CommitsFaceCopy.thisBlock`, `.commitsCount`, `BookArchiveCopy.word`); and the pin's function text from the given tests file, wrapped in one `@Suite`. The only added lines are imports and the wrapper. No diagnostic in the extracted sources.

**RED on the pre-fix tree** (the face file byte-equal to HEAD `181d65b44`, `git diff --quiet`; the pin from the working tree): `Test run with 1 test in 1 suite failed … with 3 issues`, EXIT 1 — the old line printed `"in another library — the wing “”"` for `""` AND for `"gone"`; the live-wing arm passed.

### P2 — VX-920: the fix

**Built (`App/Variorum/Variorum/Features/History/LineageFaceModel.swift`, app code only):**
- `LineageFaceCopy.wingName(_:wingNames:)` — the ONE name a member's wing speaks: `Queries.effectiveWingID(wingID, liveWingIDs: Set(wingNames.keys))`, then `WingWords.home` for `''`, else the live wing's name. The B2 shape (`wingID.isEmpty ? WingWords.home : …`) with the readers' rule named rather than re-spelled.
- `LineageFaceCopy.place`'s `.otherWing` line speaks it (`WingCopy.lineageElsewhere(wingName(…))`); the model's `wingName(_:)` — the row's go-to button, `WingCopy.goTo(model.wingName(wingID))` — delegates to it, so the line and the button can never name Home differently.
- The read's name query gains `deleted_at IS NULL`, so `wingNames` is exactly the LIVE wings' names the rule's `liveWingIDs` means. **A belt, not a behavior change:** the tree already projects every home's wing through `effectiveWingSQL` in the same read transaction, so every non-empty id that reaches this query is a live wing's today; the clause keeps the face's own rule honest if that projection ever moves. Not pinnable (no reachable state differs) — recorded, not claimed as a fix.
- `Read.wingNames`' doc comment says the above.
- `LineageFaceView.swift` is untouched (it already calls `model.place` and `model.wingName`).

**The pin extended** with the go-to button's name: `LineageFaceCopy.wingName("")` and `("gone")` → `WingWords.home`, `("studio")` → `"Studio"`. The function is new, so this arm's red-on-old is shown by the behavioral revert below (it would not compile on the old tree; the place arm, which does, was red in P1).

**GREEN on the fix:** `run-pin.zsh` on the fixed face file → `Test run with 1 test in 1 suite passed`, EXIT 0, the extracted test carrying all 7 expectations; no diagnostic in the extracted sources.

**The named behavioral revert R-920-A (NEXT — not yet applied at this commit):** in the working tree only, `LineageFaceCopy.wingName`'s body becomes the old expression `wingNames[wingID] ?? ""` (one line); run `run-pin.zsh`; expected RED on the Home and dead-wing arms of BOTH the line and the go-to name (5 issues), the live-wing arms green; restore by `git checkout -- App/Variorum/Variorum/Features/History/LineageFaceModel.swift` from this commit and verify by sha256.
