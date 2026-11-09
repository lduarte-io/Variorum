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
| W2 | VX-920 (+ the A-940-1 rider: the LETTER drift pin, Part of VX-939) | **BUILT + PINNED, headless** — "## W2 record" (end of file): VX-920 the lineage face names Home `WingWords.home` (the switcher's one Home name) on the member's line AND its go-to button, through `Queries.effectiveWingID` over the read's live wing names; the pin red 3 on old / green / R-920-A red exactly 5 (headless harness); **its in-target run PENDING the gate (Mac target; no `Shared/` line changed)**. The rider: `LetterDriftTests` (core, headless) green, red under two scratch mutations, the three sync notes corrected to name it; P-940-W2-1..3 listed for her pass |
| W3 | VX-917 | **BUILT + PINNED, headless** — "## W3 record" (end of file): `.github/workflows/cold-build-check.yml` runs on a published release or a hand dispatch only (R-940-4), inert while private, an anonymous FULL clone, BUILDING.md's three commands on GitHub's `xcode-27` image graded against `PRIMARY_XCODE_MAJOR` (AppSpec §15.6: a mismatch reports and passes); `ColdBuildCadenceTests` (core, headless) red with the workflow absent, green, M-917-A..E red; **the first live run is owed at the flip** (the record's VX-937 line, for the closeout); the release road publishes no GitHub Release today (P-940-W3-1); P-940-W3-1..6 listed for her pass |
| W4 | VX-922 + VX-925 + VX-933 | **IN PROGRESS** — "## W4 record" (end of file) |
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

**NOT DONE BY THIS IMPLEMENTER (first line, kept current):** no `xcodebuild` of any kind, no stage, no Debug launch, no walk or capture (the brief: headless only — `swift build`/`swift test` plus throwaway scratch instruments); `notes/QUESTIONS.md` untouched (P-940-W2-1..3 for the merging session). So the in-target run of the VX-920 pin (`LineageFaceModelTests`, Mac app target) is **PENDING the run's gate**; it is proven headless in substance through a scratch harness (below). The visual confirm of the lineage face rides the merge-gate window (§4 W2).

*Machinery: Opus implementer, fresh session, briefed by this file's §2 (A-940-1)/§4 W2/§7 (+ the VX-926 §7 and the VX-912 §7 it binds — read on `origin/vx-926-test-flakes` and this branch), the resiliency protocol, the VX-912 B2 record's (vii) + the ladder round 1's F-R1-1, SurfaceContracts' History & lineage line, the ticket. No revert is in flight.*

### LIVE STATUS

| Piece | What | Status |
|---|---|---|
| P0 | This record + the ledger row | DONE (`181d65b44`) |
| P1 | VX-920 — the pin (`LineageFaceModelTests`, a pure arm over `.otherWing(wingID: "")`), red on the pre-fix tree by assertion | DONE (`6c4f5afcd`) — `aHomeMemberSeenFromAnotherWingIsNamedHome`; compiles on old (calls only `LineageFaceCopy.place`); **RED on the pre-fix tree, 3 issues** (Home ×2, the dead wing), the live-wing arm green — headless harness (P1 section); in-target run PENDING the gate |
| P2 | VX-920 — the fix: one name resolution (`Queries.effectiveWingID` over the read's LIVE wing names; Home = `WingWords.home`, the switcher's one Home name) for the member's line AND its go-to button | DONE (`0b54188f4`; the revert's record `1443eef2e`) — the pin GREEN on the fix (1 test, 7 expectations, EXIT 0, headless harness); **R-920-A RED, exactly the named 5 issues**, restored byte-identical (sha `797642aa…`), green again; in-target run PENDING the gate |
| P3 | The rider (A-940-1, Part of VX-939) — the LETTER drift pin, a core test (`Tests/VariorumCoreTests`), green; a scratch mutation of `LETTER.md` turns it red; restored | DONE (`ba5f89d38`) — `LetterDriftTests` GREEN headless (`swift test`, 1 test, EXIT 0); the three "by hand / nothing reads it" sync notes corrected to name the pin (comment lines only; her words byte-identical, sha `77eee52c…`); the scratch mutations (record `518ec9696`): **M-939-A RED** (2 issues — the two paragraphs the mutation touched, named), **M-939-B RED** (the count, 18 vs 17); LETTER.md restored byte-identical (sha `f201b198…`), green again |
| P4 | Close: headless build + the nearest suites, row dispositions, self-assessment | DONE (this commit) — `swift build` EXIT 0 on the final tree; the nearest core suites 44 tests / 9 suites green, no skipped line; the VX-920 pin's in-target run PENDING the gate (first line) |

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

**The named behavioral revert R-920-A — RUN AND RESTORED (no revert in flight):** in the working tree only, `LineageFaceCopy.wingName`'s body became the old expression `wingNames[wingID] ?? ""` (`git diff --stat`: 1 file, +1/−2). `run-pin.zsh` → **RED, `… failed … with 5 issues`, EXIT 1** — exactly the named five: the line for `""` (×2) and `"gone"`, the go-to name for `""` and `"gone"`; both live-wing arms green. Restored by `git checkout --` from `0b54188f4`; sha256 `797642aa…bf1e` before the revert and after the restore; `git status` clean; the pin GREEN again on the restored file (EXIT 0).

### P3 — the rider (A-940-1): the LETTER drift pin

**Where it lives, and why there.** `Tests/VariorumCoreTests/LetterDriftTests.swift`, the core package's test target. The brief's first choice was beside `LaunchFurnitureTests` (the answer-key pin's home). That target CAN read repo files (it opens `read-me.txt` by `#filePath`), but it is the Mac app's test target: every run of it is an `xcodebuild test` under the stage, and the rider is to be a HEADLESS test. The core target is the honest headless home and has the precedent: `PinBeltTests` and `UndoLabelVocabularyTests` already read repo-root files by `#filePath` the same way. So it runs on every `swift test` — any contributor's, and W3's cold-build workflow's — not only at a gate.

**What it asserts** (`letterMarkdownCarriesTheAnswerKeysParagraphsExactly`): `read-me.txt`'s line 1 is a capture-token header (`{t:"…`) and line 2 is blank; its paragraphs are taken by the answer key's OWN rule (`LaunchFurnitureTests.herReadmeFileParagraphs`: the header line dropped, the rest trimmed of end newlines, split at `\n\n`). `LETTER.md` opens on `<!--\n`, its one comment closes at the first `\n-->\n`, no second `<!--` sits in the body, and the body's paragraphs by the same rule must equal the answer key's: the same count, then paragraph by paragraph (each mismatch names its paragraph number and the three-copies rule). A non-vacuity guard: the answer key has more than one paragraph. Since `LaunchFurnitureTests` asserts `ReadmeSeeder.paragraphs == ` the answer key, the three copies now agree by two pins. The existing pins are UNMODIFIED (`git diff --quiet b637dc457` over `LaunchFurnitureTests.swift` and `read-me.txt`).

**The sync notes corrected (they had become false).** W1's three notes said the repo face was kept "BY HAND (no pin reads it)" / "nothing reads `LETTER.md`". With the pin they were wrong, so each now names it: `LETTER.md`'s comment block (its second paragraph: "It is one of three copies kept in step … and Tests/VariorumCoreTests/LetterDriftTests.swift pins this file against the same."), `ReadmeSeeder.paragraphs`' doc comment (comment lines only — `git diff` shows zero non-`///` lines), and the content package README's paragraph, which also gains the blank line W1's insert lacked (its paragraph had been running into "**Verification:**" as one rendered paragraph). Her words are untouched: LETTER.md's body after the comment is `cmp`-identical to `tail -n +3 read-me.txt`, sha256 `77eee52c…` (W1's recorded hash).

**GREEN:** `swift test --filter LetterDriftTests` → `Test run with 1 test in 1 suite passed`, EXIT 0, no skipped line; again after the notes' correction (the pin reads past the comment).

**The named scratch mutations — RUN AND RESTORED (working tree only, never committed; no mutation in flight).** Each restored by `git checkout -- LETTER.md` from `ba5f89d38`; LETTER.md's sha256 `f201b198…b3f` before and after each; `git status` clean; the pin GREEN again after both (EXIT 0).
- **M-939-A:** `sed 's/four months/four weeks/'` on LETTER.md → **RED, 2 issues, EXIT 1**: "paragraph 1 … differs" and "paragraph 12 … differs". My expectation said paragraph 1 alone; the phrase occurs in paragraphs 1 AND 12, and `sed` replaces the first match per line (each paragraph is one line), so the mutation touched exactly those two, and the pin named exactly those two (`git diff --stat`: 2 lines changed). The pin's report was right; the prediction was imprecise.
- **M-939-B:** one paragraph appended (`printf '\nA paragraph that is not hers.\n' >>`) → **RED, 1 issue, EXIT 1**: `face.count == answerKey.count` → `18` vs `17`.

### P4 — close

**The suites, at the END, on the final tree (`518ec9696` + this record):**
- `swift build`: EXIT 0.
- `swift test --filter 'LetterDriftTests|LineageFamilyTests|LineageTreeTests|LineageBringBackTests|DanglingWingRuleTests|DanglingWingReadersTests|PinBeltTests|UndoLabelVocabularyTests'`: EXIT 0, **44 tests / 9 suites passed**, no skipped line — the drift pin; the lineage family, tree and bring-back suites (the fence and projection the face reads); the VX-892 dangling-wing rule and readers (the rule the face now calls); the two sibling repo-file readers.
- **The VX-920 pin in-target** (`LineageFaceModelTests`, Mac app target): PENDING the gate. Proven headless: P1 red 3 on old, P2 green 7 expectations, R-920-A red exactly 5, green after restore — the face file and the pin byte-unchanged since `0b54188f4`, so that last green run is on the final bytes. No other test reads the changed name (`git grep` over both app test targets and `Tests/`: `lineageElsewhere`/`.wingName(`/`goTo(` only in this suite; the existing `anotherWingsMemberIsNamedAndGoesToItsWing` keeps its live-wing expectation, unchanged behavior).
- **The gate's targets for W2:** the Mac target. No `Shared/` line changed in W2 (`WingWords` is only read), and `BirthFurnitureSeeders.swift` changed in comment lines only.
- **The batch diff** (`ba31b292a..HEAD`): 7 files, +184/−16. **The STOP rule:** no line in `Sync/`, custody/keychain, Protection or the editor seam (`LineageFaceModel` is a face — "P3: nothing here is an editor").
- **Captures: none.** The brief made the batch headless; the visual confirm of the lineage face's Home line rides the merge-gate window (§4 W2: "one capture if cheap, else the pin carries it"). The state to stage for it: a note in a non-Home wing with a lineage relative in a Home note (extract a sentence, move the extracted block to a Home note) — the family's row should read "in another library — the wing “Home”" with "go to Home ›".

**Row dispositions:**

| Row | Disposition |
|---|---|
| VX-920 — the lineage face names Home as “” (the VX-912 ladder's F-R1-1; B2's (vii)) | **FIXED with its pin** (`6c4f5afcd` pin, `0b54188f4` fix, `1443eef2e` the revert's record): `LineageFaceCopy.wingName` — `Queries.effectiveWingID` over the read's live wing names, Home = `WingWords.home` — speaks the member's line and its go-to button; red 3 on old → green → R-920-A red 5 → green (headless harness); in-target PENDING the gate. The read's live-wing clause is a belt with no reachable differing state (recorded in P2, not claimed as a fix) |
| The rider (A-940-1, Part of VX-939) — the LETTER drift pin | **BUILT** (`ba5f89d38`; mutations `518ec9696`): `Tests/VariorumCoreTests/LetterDriftTests.swift`, headless; green; M-939-A and M-939-B red, restored byte-identical. Test-only, no product behavior. The existing pins UNMODIFIED. The three sync notes corrected to name it (they had become false) |

**Every sentence I authored or changed in rendering, for her pass.** Her letter's words are untouched (LETTER.md's body sha `77eee52c…`, W1's).
*App copy (renders on the Mac's lineage face):*
1. No new sentence. The existing PROVISIONAL (#264) lines now carry Home's name where they carried nothing: "in another library — the wing “Home”" (the member's line, its header and its hover) and "go to Home ›" (its button). The Compare board's twin already reads "a version of this note lives in another library — the wing “Home”" for Home.

*Repo text a stranger reads after the flip:*

2. `LETTER.md`'s comment block, its second paragraph (hidden on GitHub's render, visible in the raw file; supersedes the W1 list's item 8 for that paragraph): "It is one of three copies kept in step. The app seeds its own copy of the same paragraphs (ReadmeSeeder.paragraphs, App/Variorum/Variorum/Features/Onboarding/BirthFurnitureSeeders.swift); the app's tests pin that copy against notes/plans/vx-105-letter-content/read-me.txt, and Tests/VariorumCoreTests/LetterDriftTests.swift pins this file against the same. A change to her text changes all three in one commit."
3. The content package README's LETTER.md paragraph, its last two sentences: "Kept in step by two pins against THIS file: `LaunchFurnitureTests` pins `ReadmeSeeder.paragraphs` (the app suite), and `LetterDriftTests` pins `LETTER.md`'s paragraphs (the core suite — A-940-1, the W2 record). A change to her text changes this file, the seeder's literals and `LETTER.md` in one commit."

*Internal, listed for completeness:* `ReadmeSeeder.paragraphs`' doc-comment sentence (names the drift pin); `LineageFaceCopy.wingName`'s and `Read.wingNames`' doc comments; the two new tests' doc comments and messages.

**PROVISIONAL bundle (nothing here gates the core; the merging session files them into `notes/QUESTIONS.md`, the W1 precedent):**
- **P-940-W2-1: Home's words on the lineage face.** (a) BUILT: the standing sentence with Home's one name — "in another library — the wing “Home”" / "go to Home ›" — the Compare board twin's exact shape and the switcher's word. (b) A Home-specific line without the quotes ("in another library — Home"). (c) "in the Home wing" (dropping "another library" for Home). (b) and (c) would part the face from its Compare twin.
- **P-940-W2-2: the drift pin's home.** (a) BUILT: the core target (headless, runs on every `swift test` and in W3's cold-build workflow). (b) The app target beside `LaunchFurnitureTests` (one suite holds all three copies' checks, but it runs only under the stage).
- **P-940-W2-3: LETTER.md's comment names the pin** (words in item 2). Alternative: the comment says only "kept in step; see notes/plans/vx-105-letter-content/README.md", keeping the mechanism out of her letter's file (W1's self-assessment (iv) asked the same question about the comment block as a whole).

**For the orchestrator (observations, not built):**
- `Read.wingNames`' read and `Queries.wingName(db, id:, home:)` are two spellings of "a wing's display name" (the Compare board, Tags, WingFollow use the latter). Folding the face's read onto `Queries.wingName` would make one spelling; it changes no output today. Not done: outside a one-line fix, and the face's batch read (one query over the family's wings) is the cheaper shape. A ticket candidate if wanted.
- The go-to act for Home switches to `''` (`session.wing.switchTo("")`), already the switcher's road; untouched.

**Self-assessment (how I'd attack this diff, for the cold reviewer):**
- **(i) The headless harness is a transcription in two respects:** it adds imports and a wrapping `@Suite`, and it grep-extracts three collaborator lines (`CommitsFaceCopy.thisBlock`, `.commitsCount`, `BookArchiveCopy.word`) into stub enums. Everything else is the tree's own text, extracted at run time, compiled against the real VariorumCore with the app target's isolation settings. The in-target run is the gate's; `@testable import Variorum`'s build settings are the one thing the harness approximates (mirrored, not inherited).
- **(ii) The go-to button is pinned through `LineageFaceCopy.wingName`, not through the model's `wingName(_:)`** (constructing a model needs an `AppSession`, which the harness cannot compile). The model method is a one-line delegation (`LineageFaceModel.swift`), read by eye.
- **(iii) `wingNames[wing, default: WingWords.home]` has an unreachable default** — `effectiveWingID` returns a non-empty id only when the id IS a key. It keeps the function total without a force-unwrap; a reviewer may prefer `!`.
- **(iv) The live-wing clause on the read is unpinnable by construction** (the tree already projects effective wings in the same transaction). If the reviewer reads it as unrequested scope, it can go; the face's rule then leans on the tree's projection for "live", which is today's truth.
- **(v) The drift pin's comment rule is "one leading comment, closed at the first `\n-->\n`, no `<!--` after it".** A future editor who adds a second comment, or puts the comment anywhere but the top, reds the pin by design, with a message saying why.
- **(vi) The LETTER.md comment edit touches a file of her letter** (the comment only; the body byte-identical by `cmp` and sha). A reviewer who reads any LETTER.md edit as her words' territory should flag it; P-940-W2-3 offers the lighter road.

## W3 record

**NOT DONE BY THIS IMPLEMENTER (first line, kept current):** **no live run of the workflow** — none is possible before the flip (the repository is private and the job is inert there by design; the public repository will be a fresh filtered one), so the acceptance unit's USE evidence is owed at the flip (the flip-day line below, for VX-937). Also not done: no `xcodebuild` of any kind, no stage, no Debug launch, no walk or capture (the brief: headless only); the workflow's `swift build` / `swift test` / app-build steps not re-run on a fresh clone here (they are BUILDING.md's commands verbatim, proven cold by the VX-912 B3 record's P3); the two existing workflows untouched; `notes/QUESTIONS.md` untouched (the merging session files P-940-W3-1..6, the W1/W2 precedent); VX-937 NOT edited (the closeout appends the line); no release-road change (P-940-W3-1).

*Machinery: Opus implementer, fresh session, briefed by this file's §2 (R-940-4)/§4 W3/§7 (+ the VX-926 §7 and the VX-912 §7 it binds), the resiliency protocol, the VX-917 ticket (no comments), BUILDING.md, the VX-912 B3 record's P2/P3 (the two workflows' posture; the cold-clone road and its two gaps), the two existing workflows, `App/Variorum/StampBuildNumber.sh`, VX-937's text. One Sonnet lookup subagent, read-only, for GitHub's external facts (below). No mutation is in flight.*

### LIVE STATUS

| Piece | What | Status |
|---|---|---|
| P0 | This record + the ledger row | DONE (`67c609bc3`) |
| P1 | The cadence pin, red with the workflow absent | DONE (`fd2258657`) — `Tests/VariorumCoreTests/ColdBuildCadenceTests.swift`, two tests; **RED with the workflow absent** (2 tests / 1 suite, 2 issues, EXIT 1) |
| P2 | `.github/workflows/cold-build-check.yml`; the YAML parsed; the pin green; the scratch mutations | DONE (`50697a99a`; the mutations' record in this commit) — PyYAML parse OK; every step script `bash -n` clean; the toolchain, summary and clone scripts run locally; the pin GREEN; **M-917-A..E each RED on exactly its assertion**, restored byte-identical (sha256 `e86bf35f…`), tree clean |
| P3 | Close: headless build + the pin + the nearest repo-file suites, dispositions, the flip-day line, PROVISIONALs, self-assessment | DONE (this commit) — `swift build` EXIT 0; `ColdBuildCadenceTests\|LetterDriftTests\|PinBeltTests\|UndoLabelVocabularyTests` 9 tests / 4 suites passed, no skipped line |

### The premise check (re-read before any line)

- **Her cadence (R-940-4, verbatim):** "I think it should be a check every major version switch or something, it's too onerous for every run." The ticket's trigger words: "RELEASE tags / manual dispatch, never per-push". The brief's reading, built: `release` (types `[published]`) + `workflow_dispatch`, nothing else.
- **The release road publishes NO GitHub Release today, so the release trigger cannot fire yet.** `Tools/Release/*.sh` contain no `git tag`, `gh release` or `git push`; `git tag` holds two archive tags only (`archive/fragments-bridge-2026-09-04`, `archive/mobile-2026-10`); a release goes to R2 plus the site's appcast. So until a GitHub Release is published on the public repository, the check runs only when started by hand. Not a change this batch may make (the release road is hers): **P-940-W3-1**.
- **The cold road the workflow automates** (BUILDING.md; proven by the VX-912 B3 record's P3 from fresh clones): `swift build` + `swift test` at the root; the Mac app `xcodebuild -scheme Variorum -configuration Debug -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build` from `App/Variorum`. Its two gaps are carried: a FULL clone (`StampBuildNumber.sh` refuses unless `git rev-parse --is-shallow-repository` prints `false`, R-13r-6) and signing off (GAP 1, the provisioning-profile entitlement).
- **The house style** (the two B3 workflows): a header saying what it does and "What this never does"; `permissions: {}` at the top; inert while private through the event's own `repository.private`; no `uses:` (no action, so no new dependency and nothing to pin); no event text in any `run:` line (values ride `env:`).

### The external facts (one Sonnet lookup, read-only, 2026-11-08; sources as it returned them)

- **Runners:** `macos-latest` is macOS 26 arm64 (default Xcode 26.6; no Xcode 27 on any `macos-*` image). GitHub's **`xcode-27`** label is macOS 27 arm64, a STANDARD runner, GA per the changelog entry "Xcode 27 runner image generally available" (2026-10-15; the runner-images README badge still says Preview), **default Xcode 27.1 (27A9275), the primary's exact build** (it also carries 27.0 and a 27.2 release candidate). Sources: `github.com/actions/runner-images` (README; `images/macos/xcode-27-arm64-Readme.md`); `github.blog/changelog/2026-10-16-xcode-27-runner-image-generally-available/`; `docs.github.com/en/actions/reference/runners/github-hosted-runners`.
- **`repository.private` is in both payloads:** the octokit webhook schemas require `repository` for `workflow_dispatch` and `release.published`, and `common/repository.schema.json` requires the boolean `private`. A job-level `if:` sees the `github` context. (docs.github.com does not state it in prose; inferred from the schemas. The first live run is the proof.)
- **Step-level `continue-on-error` takes an expression with the `steps` context** (the Contexts page's availability table: `github, needs, strategy, matrix, job, runner, env, vars, secrets, steps, inputs`).
- **`release: published`** fires for releases AND pre-releases (and for a draft when it is published); `GITHUB_SHA` = the release's tagged commit, `GITHUB_REF` = `refs/tags/<tag>`; a release created by a workflow's default `GITHUB_TOKEN` does NOT start it (a person's release or a personal token's does). `workflow_dispatch` needs the file on the default branch.
- **Cost:** standard GitHub-hosted runners are free on public repositories; larger ones (`-large`/`-xlarge`) are billed even there; on a private repository macOS bills at about $0.062 a minute.

### P1 — the cadence pin

`Tests/VariorumCoreTests/ColdBuildCadenceTests.swift`, the core test target: the honest headless home, with the precedent (`PinBeltTests`, `LetterDriftTests`, `UndoLabelVocabularyTests` read repo files by `#filePath`), so it runs on every `swift test`, the workflow's own included. Foundation has no YAML parser, so the read is textual and deliberately strict:
- **`theTriggersAreAPublishedReleaseAndAHandDispatchAndNothingElse`:** exactly one top-level `on` key, in block form (the line is `on:` with nothing after it; an inline or flow-style list would hide a trigger from a line read); the block's direct keys (indentation-agnostic, quotes stripped) are exactly `release` + `workflow_dispatch`; `release` names `types` once and they are exactly `[published]` (flow or block-list form read; a trailing comment cut).
- **`theWorkflowGradesARunAgainstTheXcodeBuildingMdNames`:** `PRIMARY_XCODE_MAJOR` declared once; BUILDING.md's "built and tested with Xcode NN.N" stated once; the two equal; and any `runs-on: xcode-NN` names the same NN. (Her cadence is the brief's pin. This second test keeps the skew verdict from going stale when she moves Xcode, which would otherwise grade runs against a toolchain the project no longer uses. Same suite, same file pair, a few lines.)

**RED with the workflow absent** (a design row, a new workflow, so the honest red-on-old is the absent file, then the mutations below): `swift test --filter ColdBuildCadenceTests` → `Test run with 2 tests in 1 suite failed … with 2 issues` (file not found), EXIT 1; re-run on the final pin text with the workflow held aside inside the worktree (renamed, never moved out): the same result.

### P2 — the workflow

**Built (`.github/workflows/cold-build-check.yml`):**
- **Triggers:** `release: types: [published]` + `workflow_dispatch:`. `permissions: {}`; `defaults.run.shell: bash` (no profile, `-eo pipefail`).
- **`PRIMARY_XCODE_MAJOR: "27"`** at the workflow level (BUILDING.md's Xcode; the pin ties them). `runs-on` cannot read `env`, so the runner label repeats the major, and the pin ties that too.
- **The job** `cold-build`: `if: github.event.repository.private == false` (inert while private, the house guard); `runs-on: xcode-27`; `timeout-minutes: 120`.
- **Steps, in order:** (1) **Toolchain**: `xcodebuild -version`, `swift --version`, `sw_vers` FIRST, then the major read from `xcodebuild -version`'s first line; on a match `counts=true`, else `counts=false` plus a `::warning` annotation; the verdict sentence printed and written to the job summary. (2) **Clone, with the full history**: `git clone "$GITHUB_SERVER_URL/$GITHUB_REPOSITORY.git"` anonymously (no token exists: `permissions: {}` and no checkout action; `GIT_TERMINAL_PROMPT=0` so it can never hang), a detached checkout of `$GITHUB_SHA`, one line printing the commit, the commit count and `shallow: false`. (3) **Core package, swift build** · (4) **Core package, swift test** · (5) **Mac app, unsigned build** (BUILDING.md's command verbatim, in `App/Variorum`): each `if: !cancelled() && steps.clone.outcome == 'success'` (every step reports, whatever an earlier one did) and `continue-on-error: steps.toolchain.outputs.counts != 'true'` (on a mismatch a red is reported and the run passes; on a match it fails the run: AppSpec §15.6 "where the rule applies"). (6) **Summary**: a table of the four outcomes plus one sentence saying whether a failure is a broken build or information; the outcomes ride `env:`.
- **Never:** no `uses:`, no secret, no token, no `${{` in any `run:` line; the release's name and notes never reach the shell (only `$GITHUB_SHA`, a hex id from the runner's default environment, is read).

**Evidence (headless; throwaway instruments in the session scratchpad `w3-vx940/`, never in the PR):**
- **Parse:** PyYAML 6.0.3 (`python3 -I parse.py`): top-level keys `name, on, permissions, env, defaults, jobs` (PyYAML reads the bare `on` as YAML 1.1's `True`, GitHub reads it as `on`; the script accounts for it); `on` = `{"release": {"types": ["published"]}, "workflow_dispatch": null}`; `permissions` = `{}`; the job's `if`, `runs-on`, `timeout-minutes`; every step's `if` / `continue-on-error` / `working-directory` / `env` as intended; **no `${{` in any `run:` and no `uses:`** → `PARSE OK`. No `actionlint` or `yamllint` on this machine (not installed; not added).
- **`bash -n`** on each of the six extracted `run:` scripts: all clean (no `shellcheck` installed).
- **The toolchain script, run here** under the workflow's shell flags: with `PRIMARY_XCODE_MAJOR=27` it prints `Xcode 27.1` / `Build version 27A9275`, `counts=true`, "…so this run's results count."; with `=28`, `counts=false`, the `::warning title=Toolchain::…` line, "…A failure below is information about this toolchain, not a broken build." Both EXIT 0.
- **The summary script, run here** (a mismatch with a failed test and a skipped app build): the table and the information sentence, EXIT 0.
- **The clone script, run here** against a `file://` stand-in for GitHub (a symlink `srv/lduarte-io/Variorum.git` → this worktree; `GIT_CONFIG_GLOBAL=/dev/null`, `GIT_CONFIG_NOSYSTEM=1`): `Commit fd2258657e01…, 11859 commits, shallow: false.`, EXIT 0, at exactly the SHA handed in. The clone was deleted after.
- **The pin GREEN:** `Test run with 2 tests in 1 suite passed`, EXIT 0, no skipped line.

**The named scratch mutations, RUN AND RESTORED** (working tree only, on the committed `50697a99a`; each restored by `git checkout --`; sha256 `e86bf35f…` before and after each; `git diff --quiet` clean at the end; the pin green again after):

| Mutation | What | Result |
|---|---|---|
| M-917-A | `push: branches: [main]` added to the `on:` block | **RED, 1 issue**: the trigger set, "…the `on:` block reads ["release", "workflow_dispatch", "push"]" |
| M-917-B | the block replaced by `on: [push, workflow_dispatch]` | **RED, 3 issues**: not block form; the trigger set; no `release:` |
| M-917-C | `PRIMARY_XCODE_MAJOR: "26"` | **RED, 2 issues**: off BUILDING.md's 27; off the `xcode-27` runner |
| M-917-D | `types: [published, created]` | **RED, 1 issue**: the release types |
| M-917-E | a quoted `"schedule":` key with a block-list cron added | **RED, 1 issue**: the trigger set |

### P3 — close

**The suites, at the END, on the final tree (`50697a99a` + this record; the workflow and the pin byte-unchanged since):** `swift build` EXIT 0; `swift test --filter 'ColdBuildCadenceTests|LetterDriftTests|PinBeltTests|UndoLabelVocabularyTests'` EXIT 0, **9 tests / 4 suites passed**, no skipped line (the new pin and the three sibling repo-file readers). The whole core suite is the run's gate's; nothing else in the package changed (the diff is one workflow, one test file and this record).

**The batch diff** (`67c609bc3^..HEAD`): 3 files: `.github/workflows/cold-build-check.yml` (new), `Tests/VariorumCoreTests/ColdBuildCadenceTests.swift` (new), this record. **The STOP rule:** no line in `Sync/`, custody/keychain, Protection or the editor seam. **The gate's targets for W3:** none beyond the core package (no app or `Shared/` line). **Captures: none** (no face; headless).

**The flip-day line, for the closeout to append to VX-937 (beside item 3's live checks); WORDS OFFERED, not filed:** "(4) The cold-build check: with Actions ON, start it once by hand (Actions ▸ Cold build check ▸ Run workflow, on main). Expect the Toolchain step to read Xcode 27.x and say the results count; the clone line to say `shallow: false`; swift build, swift test and the unsigned Mac app build green (a lone MCP socket-timing red is re-run on its own first, per BUILDING.md). This first run is also the proof of three GitHub facts read from docs and schemas, not observed: the private guard on a dispatch, the expression-valued `continue-on-error`, and the `xcode-27` label. Then decide whether a release will publish a GitHub Release here (P-940-W3-1): until one does, the release trigger never fires."

**Row disposition:**

| Row | Disposition |
|---|---|
| VX-917 — the public-repo CI cold-build check at her cadence | **BUILT + PINNED, headless** (`fd2258657` pin, `50697a99a` workflow, this commit the mutations' record): a published release or a hand dispatch only; inert while private; an anonymous full clone; BUILDING.md's three commands on `xcode-27`, graded against `PRIMARY_XCODE_MAJOR` per AppSpec §15.6; the pin red with the workflow absent, green on it, M-917-A..E each red. A design row (no bug class, so no red-on-old by revert). **The USE evidence, the first live run, is owed at the flip** (the line above, for VX-937) |

**Every sentence I authored, for her pass** (all stranger-facing after the flip; her one quoted sentence is hers, byte-faithful):
1. The header comment, whole (first person, the two existing workflows' register): what it does ("Builds Variorum the way BUILDING.md tells anyone to: … It checks that the steps on that page still work for someone who isn't me."); when it runs ("…when a release is published here, and when it's started by hand (Actions, then "Cold build check", then "Run workflow"). Never on a push or a pull request. A full cold build is too heavy for every change; as I put it when I set this up, "…" Every release is a version switch, and starting it by hand covers any other time."); how to read a result (the skew rule in plain words, pointing at `notes/AppSpec.md`, §15, item 6); the MCP socket-timing note; "What this never does" (three bullets).
2. The env comment ("The major version of the Xcode that Variorum is built and tested with (BUILDING.md). … keeps this, the runner below and BUILDING.md in step.") and the runner comment ("GitHub's Xcode 27 image (macOS 27, Apple silicon). It's a standard runner, so it costs nothing on a public repository.").
3. The two verdict sentences the Actions page shows: "This runner has Xcode NN, the major version Variorum is built and tested with, so this run's results count." · "This runner has Xcode NN, but Variorum is built and tested with Xcode NN. A failure below is information about this toolchain, not a broken build."
4. The summary's two sentences ("A failure here is a broken build." · "A failure here is information about this runner's toolchain, not a broken build.") and the step names ("Toolchain", "Clone, with the full history", "Core package, swift build", "Core package, swift test", "Mac app, unsigned build", "Summary").
5. The clone's line: "Commit <sha>, <n> commits, shallow: false."

*Internal:* the pin's doc comment and messages.

**PROVISIONAL bundle (nothing here gates the core; the merging session files them into `notes/QUESTIONS.md`):**
- **P-940-W3-1: the release trigger has nothing to fire on yet.** The release road publishes no GitHub Release and makes no tag. (a) BUILT: `release: published` + dispatch, the gap stated; she starts it by hand at each version switch until a GitHub Release exists. (b) The release road gains a step that publishes a GitHub Release on the public repository (a `release.sh` change, hers; it must be her `gh` or a personal token, since a release made by a workflow's default token does not start this workflow). (c) A tag trigger (`push: tags: [v*]`): excluded by her "never per-push" and the brief, and it would still need a tag the road doesn't make.
- **P-940-W3-2: inert while private.** (a) BUILT: the house guard; landing it changes nothing today, and a private macOS run would bill (about $0.062 a minute). (b) Let a hand dispatch run on the private repository for a pre-flip trial, billed. The public repository is to be a FRESH filtered one (`notes/plans/open-source-readiness.md` §4 item 2: "never flip the private repo public"), so (b) would test a different repository.
- **P-940-W3-3: the runner.** (a) BUILT: `xcode-27`, the only GitHub image carrying Xcode 27, its default the primary's exact 27.1 build; a standard runner, free on a public repo. (b) `macos-latest` (macOS 26, Xcode 26.6): every run graded a mismatch, so never a gate. (c) `xcode-27-xlarge`: faster, billed even when public.
- **P-940-W3-4: a mismatch passes the run; on a match any red fails it.** (a) BUILT (the brief's reading of §15.6). (b) Never fail the run (always informational). (c) An automatic re-run of a red MCP socket-timing suite before it counts (BUILDING.md's advice made mechanical; more machinery; today the header tells the reader to re-run it by hand).
- **P-940-W3-5: the header's voice**: first person, quoting her sentence. Alternative: third person ("the maintainer chose …"), or her sentence paraphrased.
- **P-940-W3-6: the iOS simulator build is not a step** (BUILDING.md's third road; the brief named the Mac app). Alternative: a fourth build step, `VariorumMobile` for `generic/platform=iOS Simulator`.

**For the orchestrator (observations, not built):**
- The closeout's VX-937 line is above, worded for her checklist.
- BUILDING.md says "Other Xcode versions are untested"; the workflow's mismatch reading agrees with it. No BUILDING.md line changed; a sentence pointing strangers at the check (or not) is her call at the doc pass.

**Self-assessment (how I'd attack this diff, for the cold reviewer):**
- **(i) Nothing here has run on GitHub.** Three load-bearing behaviours are read from documentation and schemas, not observed: `github.event.repository.private` present on a dispatch (octokit's schema requires it), an expression-valued step `continue-on-error` reading `steps` (the Contexts table lists it), and the `xcode-27` label (GA by the changelog, "Preview" by the README badge). If the label were retired, a GitHub-hosted job with no matching runner waits in the queue rather than failing fast; `timeout-minutes` does not cover queueing.
- **(ii) The skew verdict reads only `xcodebuild -version`'s first line** ("Xcode 27.1" → 27). A beta or release-candidate default would still read its major; an unreadable line grades as a mismatch (informational), the safe side.
- **(iii) Every build step runs after a counted failure** (`!cancelled()`), so one broken `swift build` also reds `swift test` and the app build: three reds for one break, deliberately, so each step answers its own question.
- **(iv) The clone checks out `$GITHUB_SHA` from a plain full clone** (all branches and tags). A release whose tag sits on a commit no branch reaches is still fetched through the tags: believed from git's clone behaviour, not proven on GitHub.
- **(v) The pin is a strict text read, not a YAML parser.** YAML features it doesn't model (anchors and merge keys inside `on:`, a second document in the file) are read as keys or not at all; every case I could build reds rather than passes (M-917-B, -E). A reviewer who finds a spelling of a push trigger the read passes has found a real hole.
- **(vi) `PRIMARY_XCODE_MAJOR` and `runs-on: xcode-27` repeat one number** because `runs-on` cannot read `env`; the pin ties both to BUILDING.md.
- **(vii) `timeout-minutes: 120` is a margin, not a measurement:** the B3 cold road took about a minute to build the core and 2.5 minutes for the app on her M3; a 3-core runner is slower, and `swift test` is the long pole.

## W4 record

**NOT DONE BY THIS IMPLEMENTER (first line, kept current):** no `xcodebuild` of any kind, no stage, no Debug launch, no walk or capture (the brief: headless only — `swift build`/`swift test` plus throwaway scratch instruments; the door is wire-only, so its use-shaped evidence is the wire itself driven headlessly — the two-store catalog and the MCP target); `notes/QUESTIONS.md` untouched (the PROVISIONALs below are for the merging session, the W1–W3 precedent); nothing on Linear changed.

*Machinery: Opus implementer, fresh session, briefed by this file's §4 W4/§7 (+ the VX-926 record's §7 read on `origin/vx-926-test-flakes`, and the VX-912 §7 it binds), `notes/MCPSpec.md` IN FULL, the resiliency protocol, the VX-912 B2 record (`effectiveWingID`; its finding (ix)) and B4 record (the NUL seams; F-B4-2), the VX-926 U1 record (read on `origin/vx-926-test-flakes` — the pool trace, `HarnessWait.offPool`, F-U1-2), the three tickets (no comments on any). The harness in THIS tree is the PRE-U1 harness (vx-926 is not merged to main). No revert is in flight.*

### LIVE STATUS

| Piece | What | Status |
|---|---|---|
| P0 | This record + the ledger row | DONE (this commit) |
| P1 | VX-922 — `Queries.mcpResolvedWing` + `MCPReadTools.resolvedWing` folded onto `Queries.effectiveWingSQL`; the parity proof (every existing pin UNMODIFIED, green) | NOT-STARTED — design: both call sites name `Queries.effectiveWingSQL` directly; nothing outside their files names either (no forward needed); the doc lines that named the copies corrected |
| P2 | VX-925 — the pin, red on the pre-fix tree | NOT-STARTED |
| P3 | VX-925 — `clientInfo.version` through `StoredText.stripped` at the admission's writes; the behavioural revert | NOT-STARTED |
| P4 | VX-933 — the pins (a stalled reader cannot pin the cooperative pool), red on the pre-fix tree | NOT-STARTED |
| P5 | VX-933 — the fix (the shape that changes no wire-observable behaviour, or the STOP); the behavioural reverts | NOT-STARTED |
| P6 | Close: the two-store catalog whole + the MCP target + the nearest core suites, dispositions, PROVISIONALs, U1-overlap list, self-assessment | NOT-STARTED |
