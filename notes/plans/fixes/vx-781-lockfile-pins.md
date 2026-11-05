# VX-781 — the Package.resolved rewriter: the mechanism traced, the committed pins belted

Branch `vx-781-lockfile-pins` (worktree `~/dev/variorum-vx-781`), cut from main at 68b3d9c53.
Ticket VX-781 (High · Bug · Confirmed · Tests & tooling), born at VX-770's closeout (R-770-T1).
Implementer: opus-implementer, 2026-11-04 (single-ticket effort; build infrastructure; no Sync/,
no custody, no editor seam, no `xcodebuild test`).

## FOR A LATER READER

**NOT DONE (first line):** the FIRST trigger of VX-770's spontaneous rewrites was not reproduced.
Every clean-input `xcodebuild` I ran (resolve, reused DerivedData, the exactness flag, a full
build) left the lockfile byte-clean, and the only road to an upgraded file I reproduced is a
resolution that runs WITHOUT the pins. The belt makes that road land the committed set, so the
trigger no longer decides what ships. **The ticket's sharpest datum stays unexplained (R1-3):**
VX-770's gatef rewrote the file "under a build that itself resolved committed pins". A resolution
that landed the committed set cannot write an upgraded file, so a SECOND writer existed: another
process, or another resolution path. The actions VX-770 ran around its rewrites were `xcodebuild
test` and iOS-simulator destinations. I sampled the lockfile through macOS `build` (E7, E12) and
generic-iOS `build`, both pre-belt (R1-3's sample) and on the belt (R1-11): no change in any of
them. `xcodebuild test` and simulator destinations were NEVER sampled (stage-gated). No `xcodebuild
test` ran (no stage claim); release.sh is untouched (a wiring PROPOSAL only, below).

**The mechanism as settled.** (1) Without its pins, the manifests' ranges float: the GRDB fork's own
`SQLCipher.swift from: "4.11.0"`, Package.swift's `swift-dependencies from: "1.9.0"`, and the
transitive ranges of swift-dependencies and the MCP SDK. A pin-free resolution lands SQLCipher
**4.20.0**, swift-dependencies 1.17.2, swift-syntax 604.0.0, swift-issue-reporting 2.1.2 and 8 more
(E2, C1). (2) **Pre-belt**, once such a file sits in the tree every later build ADOPTS it, the
exactness flags included, because they enforce THE FILE (E8 = VX-770's gate/gate2). **On the belt
this road is CLOSED in both graphs (E8b, R1-2):** an upgraded file now contradicts the exact
declarations. The strict modes FAIL CLOSED (Xcode `-onlyUsePackageVersionsFromResolvedFile` exit 74;
`swift package --only-use-versions-from-resolved-file` exit 1; both say "an out-of-date resolved
file was detected"). The plain modes HEAL the file back to the committed set, even in a DerivedData
already holding upgraded checkouts. (3) With a clean lockfile,
Xcode 27.1 SEEDS the resolver with the pins: a fresh DerivedData (E1, E7), a reused upgraded one
(E3, the checkouts are moved back) and `-disableAutomaticPackageResolution` (E5) all land the
committed set and never rewrite. (4) Side facts: the workspace lockfile's originHash is
`sha256(root URLs + the checkout's ABSOLUTE PATH)` (committed from `~/dev/variorum-vx-124`, so it
mismatches in every checkout), and the root lockfile's originHash is `sha256(Package.swift)`. A
mismatch changes nothing observable (T-3).

**THE NON-OBVIOUS FACT a future session will trip over (E10):** in the Xcode workspace the
repo-root package is a LOCAL PACKAGE DEPENDENCY, not the root, so SwiftPM PRUNES its unused
`.package` declarations. Exact pins added only to Package.swift do NOTHING for the app: E10 floated
SQLCipher to 4.20.0 with them in place. The app graph's root is the PROJECT, so its belt is
project-level package references.

**The belt as built:** Package.swift exact pins for every remote package, the CLI's belt (eda25f273,
620cc9019) · the same versions as 12 exact `XCRemoteSwiftPackageReference` entries in
project.pbxproj, the app's belt (620cc9019) · the root lockfile reconciled to the shipping set
(P-781-1) · **`Tests/VariorumCoreTests/PinBeltTests.swift` = the every-run static guard of all four
places (R1-1, 95fcc3c4e; red-on-old on 68b3d9c53, red on a deleted reference and on one-sided
bumps)** · `Tools/verify-pins` = the resolved-state guard (fef4800f8, 60cfbd44e) ·
`Tools/pins-belt-check` = the deep, networked proof (0d7fd8019, 60cfbd44e). Upgrading a pin
deliberately: the numbered procedure below.

**RELEASE-RISK VERDICT:** a clean checkout + fresh `-derivedDataPath` resolves the committed pins
(E1, E7, and the 1.1 release road's own build, which the coordinator confirmed). The two risk roads
were a dirty/upgraded lockfile in the tree and any pin-free resolution. The belt closes BOTH: a
pin-free resolution lands the committed set, and an upgraded file fails closed or heals (E8b). The
guards in place are the belt itself, PinBeltTests in every `swift test`, and release.sh's
clean-tree refusal (release.sh:103–104). If wired (the proposal below; not applied), `Tools/verify-pins
"<OUT>/DerivedData"` after the archive adds a check of what the archive actually resolved. **RELEASE-EXPOSURE: 1.0 and 1.0.1 shipped the committed set.** The retained SQLCipher
dSYM UUIDs `17E38CF7…`/`F0784571…` equal the 4.18.0 xcframework's, and both builds were
`dirty files: 0`.

**Evidence lines:** PinBeltTests red-on-old (a 68b3d9c53 export + the test): `✘ Test run with 3 tests
in 1 suite failed after 0.002 seconds with 4 issues`; green on HEAD `✔ Test run with 3 tests in 1
suite passed` · `pins-belt-check: BELT DOES NOT HOLD at 68b3d9c53` (Xcode + CLI DRIFT ×12,
`sqlcipher.swift: committed 4.18.0 (f879fff) -> resolved 4.20.0 (e7415c5)`), exit 1 · `BELT HOLDS
at f8d2ced67` (the merged tree; 16 + 15 pins), exit 0 · merged-tree Debug build `** BUILD
SUCCEEDED **`, `verify-pins … vx781-merged …: 16 pins match`, built SQLCipher UUID = 4.18.0's ·
`** TEST BUILD SUCCEEDED **` · core `3646 tests in 491 suites passed … 5 known issues`,
StringsWorkbook `32 tests in 4 suites passed`, MCP 549/100 with the three socket-timing tests red
only under load (`16 tests in 3 suites passed` alone; VX-353/VX-685 track one of them). The
reconciled CLI pins make the VX-180 family trip more often (THE MCP A/B; pre-existing on the old
pins too) ·
the phone scheme on the belt `** BUILD SUCCEEDED **`, verify-pins 16 · the round-1 core re-run in
ROUND 1 FIX LEG.

**Open items:** P-781-1/-2/-3/-4 for QUESTIONS (below) · born-ticket candidates (an upgrade helper,
the release.sh hook, the MCP socket-road timing bounds incl. the ConcurrencyExtras 1.4.1 rate
change) · the stray default DerivedData
from my `xcodebuild -list` (the coordinator's sweep) · VX-770's first trigger and second writer
(mooted, not found; `test` and simulator destinations never sampled).

## LIVE STATUS (flipped per piece, in the same commit as the piece)

| Piece | Status |
|---|---|
| (a) TRACE the mechanism | DONE — T-1..T-4, E1–E8, E10–E11, C1–C3 (9e9bd78bd → 0d7fd8019). The first spontaneous trigger is NOT reproduced (stated as the record's first line) |
| (b) RELEASE-RISK VERDICT + RELEASE-EXPOSURE | DONE — sent mid-run (cb0424554); restated in FOR A LATER READER |
| (c) THE BELT (manifest pins + project refs + `Tools/verify-pins`) | DONE — eda25f273 (Package.swift), 620cc9019 (project.pbxproj), fef4800f8 (verify-pins) |
| (d) THE PIN (red-on-old / green-on-new recipe, revert-verified) | DONE — `Tools/pins-belt-check` (0d7fd8019): red 68b3d9c53 + eda25f273, green fef4800f8 + f8d2ced67 |
| (e) VERIFY on the merged tree (f8d2ced67) | DONE — core suite, Debug build + verify-pins, build-for-testing (VERIFY — the merged tree, below) |
| (f) THE RECORD's FOR A LATER READER | DONE (6a14ec72c), kept current through round 1 |
| LADDER ROUND 1 (opus-reviewer, 11 findings) | ALL AGREED + FIXED — findings 76eec95c2; R1-1 PinBeltTests 95fcc3c4e; R1-5/7/8/9 60cfbd44e; R1-6 dfded4cb9; record fixes 2439c6b73; MCP A/B 965d555ba. Core re-run 3649/492 passed |

## Evidence base read (this session, never delegated)

CLAUDE.md + the auto-loaded canon; `notes/SessionResiliencyProtocol.md`;
`notes/plans/fixes/vx-770-takes-compare-window.md` — FOR A LATER READER, THE MERGE-IN + the
Package.resolved disposition, THE FINAL WINDOW SHEET (pins discipline), THE W2 CYCLE's verdicts
(the pins notes), THE FINAL WINDOW — CLOSED (the gatef rewrite-on-build line).

## THE TRACE — the working record (every observation, in order)

### T-1. Three lockfiles; the two that matter disagree, and BOTH carry a stale originHash

- `Package.resolved` (repo root; `swift build`/`swift test`) and
  `App/Variorum/Variorum.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`
  (the Xcode workspace's — the one VX-770 saw rewritten). `Spikes/DesignCorpusSeeder/Package.resolved`
  is out of scope.
- Pin drift between them (committed state): root has swift-concurrency-extras 1.4.0 and
  xctest-dynamic-overlay 1.10.1; the workspace has 1.4.1 and 1.11.0; the workspace adds Sparkle.
- **The CLI root lockfile's originHash is `sha256(Package.swift bytes)`** — proven against
  history: at 147637736 `sha256(Package.swift)` = `f245d0b8…` = the root originHash written in
  that commit; at b28852d03 `a01a1fb0…` = `a01a1fb0…`. Package.swift changed after the last root
  lockfile write (c3e39ec2f 10-09, c3d939c9e + a51a76adc 10-22, VX-329), so today the root
  originHash (`f245d0b8…`) ≠ `sha256(Package.swift)` (`a8471237…`): STALE.

### T-2. The Xcode workspace's originHash is a hash of the CHECKOUT'S ABSOLUTE PATH

The project's root has no manifest of its own (it is an .xcodeproj); its root DEPENDENCIES are
the remote Sparkle reference and the local package `../..`, and SwiftPM's origin hash is
`sha256(concatenated root-manifest contents + each root dependency's location string)`. A local
package's location string is its ABSOLUTE PATH. Proven by reproduction of two committed values:

- `sha256("https://github.com/sparkle-project/Sparkle" + "<home>/dev/variorum")`
  = `4ae749e5ea7c4959…` = the workspace originHash committed at 0d2f7d78b (13r, written from the
  main checkout).
- `sha256("https://github.com/sparkle-project/Sparkle" + "<home>/dev/variorum-vx-124")`
  = `5cfb26392f0f829a…` = the workspace originHash committed TODAY (2f6a92c09, 13n-b, written from
  the `variorum-vx-124` worktree, which no longer exists).

**Consequence: in every checkout except one at `~/dev/variorum-vx-124`, the committed workspace
lockfile's originHash MISMATCHES** — `~/dev/variorum` (main, the release's usual road),
`~/dev/variorum-vx-770`, `-vx-779`, `-vx-781` alike. No content edit can make the committed
hash right for every path; it is right for exactly one directory.

### T-3. What SwiftPM does with a mismatched originHash (the resolver's road, from its source behaviour — to be confirmed by reproduction below)

The hypothesis written before reproducing (from memory of SwiftPM's best-effort strategy):
originHash MATCHES → the lockfile is used AS a lockfile; originHash MISMATCHES → "resolve and
update", where a build's EXISTING checkouts would be kept if they satisfy the requirements and
the lockfile re-written from them. **Settled by reproduction, and the second half is FALSE on
Xcode 27.1:** a mismatched originHash changes nothing observable. With a clean lockfile, missing
packages resolve to the pins (E1), a reused DerivedData's upgraded checkouts are moved BACK to
the pins (E3), and the file is never rewritten while the resolved pins equal the stored ones (E1,
E3, E5, E7). The stale originHash is real (T-1, T-2) but it is NOT the rewrite trigger.

### T-4. Where the upgrade can come from — the floating requirements

- `Package.swift`: swift-dependencies `from: "1.9.0"` (1.17.2 satisfies).
- The GRDB fork `v7.11.1+sqlcipher.1`'s own manifest (read from the global cache's bare mirror,
  read-only): `.package(url: "https://github.com/sqlcipher/SQLCipher.swift.git", from: "4.11.0")`
  — **SQLCipher floats through the fork's range**; 4.19.0 and 4.20.0 exist upstream.
- swift-dependencies 1.14.1 → `xctest-dynamic-overlay from: "1.4.0"`, swift-syntax
  `"509.0.0"..<"605.0.0"`; swift-dependencies 1.17.2 (tools 6.4) → `swift-issue-reporting
  from: "2.1.0"` (the renamed xctest-dynamic-overlay, a NEW package identity — hence the extra
  package in the upgrade set), same swift-syntax range (604 satisfies).
- Sparkle is `exactVersion 2.10.0` in project.pbxproj (cannot float); swift-sdk and the GRDB fork
  are `exact:` in Package.swift.
- Newer in-range versions exist upstream tonight for nearly every transitive package (read from
  my private cache's mirrors): combine-schedulers 1.2.2 · eventsource 1.6.0 · SQLCipher.swift
  4.20.0 · swift-clocks 1.1.1 · swift-collections 1.7.5 · swift-concurrency-extras 1.4.3 ·
  swift-dependencies 1.17.2 · swift-log 1.17.0 · swift-nio 2.105.0 · swift-syntax 604.0.0 ·
  xctest-dynamic-overlay 1.13.1 (Sparkle 2.10.1 too, but Sparkle is exact). Only swift-atomics
  1.3.1 and swift-system 1.8.1 are already the newest. So a pin-free resolution would move far
  more than the four packages VX-770 named; whether VX-770's dirty file moved the others too is
  UNVERIFIABLE (it was discarded unread past the four names).

### Isolation used for every xcodebuild run below

`-derivedDataPath`, `-clonedSourcePackagesDirPath` and `-packageCachePath` all inside
`App/Variorum/DerivedData/` (gitignored). **`-packageCachePath` redirects SwiftPM's
repositories/artifacts/prebuilts but NOT its manifest cache**: E1 added entries to
`~/Library/Caches/org.swift.swiftpm/manifests/manifest.db` (+ `ManifestLoading/*.dia`). Disclosed
to the orchestrator the same turn; RULED option (a): additive manifest-cache writes are allowed
(identical keys/values to what any resolve of the same versions writes); purge/reset of anything
shared stays forbidden. Relative paths to `xcodebuild -resolvePackageDependencies` silently
resolve NOTHING (exit 0, "resolved source packages:" empty, lockfile untouched) — absolute paths
only.

### E1 — fresh DerivedData + fresh clone dir, CLEAN committed lockfile (21:39, 1 m 11 s)

`xcodebuild -resolvePackageDependencies -project Variorum.xcodeproj -scheme Variorum
-derivedDataPath <wt>/App/Variorum/DerivedData/vx781-e1 -clonedSourcePackagesDirPath …/vx781-e1-spm
-packageCachePath …/vx781-pkgcache` (log `App/Variorum/DerivedData/logs/e1-resolve.log`).
- Before: `git status --porcelain` empty. After: **empty — the lockfile byte-untouched, its
  stale originHash `5cfb2639…` still in place.**
- Resolved (`vx781-e1-spm/workspace-state.json`): EXACTLY the committed workspace set —
  sqlcipher.swift 4.18.0 · swift-dependencies 1.14.1 · swift-syntax 602.0.0 ·
  xctest-dynamic-overlay 1.11.0 · swift-concurrency-extras 1.4.1 · … · no swift-issue-reporting;
  the swift-syntax 602.0.0 prebuilt downloaded (`swiftlang-6.4.0.34.1-macosx27.0`).
- Reading: with a mismatched originHash and NO checkouts, the missing packages are resolved with
  the lockfile's pins as preferred versions (every pin satisfies its requirement, so every pin is
  chosen), and the resolved file is NOT rewritten when the resolved pins equal the stored pins
  (the originHash alone never triggers a write).
- Read-only side observation: the RELEASE session's default DerivedData
  (`~/Library/Developer/Xcode/DerivedData/Variorum-dpoup…`, 20:53, fileSystem root
  `variorum-vx-779`) resolved the same committed set.

### E2 — the FORCED RE-RESOLUTION, old manifests: lockfile REMOVED, fresh DD (21:48, 37 s) — RED shape

`rm` of the workspace lockfile only, then E1's invocation into `vx781-e2` / `vx781-e2-spm` (log
`e2-resolve.log`; the written file kept as `DerivedData/logs/e2-lockfile-after.json`). Resolved and
WRITTEN (lockfile pins vs committed):

| package | committed | E2 (no pins) |
|---|---|---|
| sqlcipher.swift | 4.18.0 | **4.20.0** |
| swift-dependencies | 1.14.1 | **1.17.2** |
| swift-syntax | 602.0.0 | **604.0.0** |
| swift-issue-reporting | — | **2.1.2 (new identity)** |
| xctest-dynamic-overlay | 1.11.0 | **gone** |
| combine-schedulers | 1.2.0 | 1.2.2 |
| eventsource | 1.5.1 | 1.6.0 |
| swift-clocks | 1.1.0 | 1.1.1 |
| swift-collections | 1.7.2 | 1.7.5 |
| swift-concurrency-extras | 1.4.1 | 1.4.3 |
| swift-log | 1.16.1 | 1.17.0 |
| swift-nio | 2.104.0 | 2.105.0 |
| grdb.swift · sparkle · swift-sdk · swift-atomics · swift-system | — | unchanged (exact or newest) |

New originHash `eef317c7…` = `sha256("https://github.com/sparkle-project/Sparkle" +
"<home>/dev/variorum-vx-781")` — T-2's formula confirmed on a write. This is VX-770's
upgrade set (its four headline names plus everything else in range): **without the pins, the
manifests' requirements alone land the upgraded set.**

### E3 — CLEAN lockfile restored, E2's UPGRADED DD REUSED (21:50) — the "state wins" theory REFUTED

`git checkout --` of the lockfile (the only change was E2's artifact), then the same invocation
into `vx781-e2`/`vx781-e2-spm`. **The lockfile stayed byte-clean; the checkouts were MOVED BACK to
the committed pins** (workspace-state: sqlcipher 4.18.0 · swift-dependencies 1.14.1 · swift-syntax
602.0.0 · xctest-dynamic-overlay 1.11.0). So on Xcode 27.1 a mismatched originHash does NOT let a
reused DerivedData's checkouts win over a clean lockfile — T-3's expected "resolve-and-update keeps
the current checkouts" road does not happen through `xcodebuild`. The reused-DD road is CLOSED as
a rewrite source while the lockfile is clean.

### E5 — fresh DD, CLEAN lockfile, `-disableAutomaticPackageResolution`

Committed set (4.18.0 / 1.14.1 / 602.0.0 / xctest-dynamic-overlay 1.11.0); lockfile byte-clean;
no error or warning about the stale originHash. The flag holds the line on clean input.

### E7 — a real Debug BUILD on the clean lockfile, fresh DD, lockfile sampled every second

`xcodebuild build -scheme Variorum -configuration Debug -destination 'platform=macOS'` into
`vx781-e7` (log `e7-build.log`, `** BUILD SUCCEEDED **`, ~90 s on the shared compilation cache).
The lockfile hash never changed during the build (sampler log `e7-lockhash.log`); resolved the
committed set. A build action on clean input does not rewrite either.

### E8 — the UPGRADED lockfile in the tree + fresh DD + `-onlyUsePackageVersionsFromResolvedFile` — ADOPTED

E2's written file copied over the committed one, then a fresh DD with the exactness flag: the
lockfile untouched (it already said 4.20.0) and the build state = **sqlcipher 4.20.0 ·
swift-dependencies 1.17.2 · swift-issue-reporting 2.1.2 · swift-syntax 604.0.0**. The exactness
flags enforce THE FILE, whatever it says. This is VX-770's gate/gate2 result (both carried the
flags and "upgraded"), reproduced: the flags are not broken — their INPUT was an upgraded file.
Restored by `git checkout --` (the only change was the copied artifact).

### C1 — the CLI side, OLD manifest: root lockfile removed, isolated resolve — RED

`swift package --scratch-path …/vx781-cli-old --cache-path …/vx781-cli-cache --config-path
…/vx781-cli-config --security-path …/vx781-cli-security --manifest-cache local resolve` (every
path inside `App/Variorum/DerivedData/`; nothing shared written). Landed the same upgraded set as
E2 (4.20.0 / 1.17.2 / 604.0.0 / swift-issue-reporting 2.1.2, xctest-dynamic-overlay gone,
swift-nio 2.105.0, …); new originHash `a8471237…` = `sha256(Package.swift)` (T-1's formula
confirmed on a write). Restored.

### THE BELT, first form — exact top-level pins in Package.swift (eda25f273)

All thirteen floating remote packages declared `exact:` at the committed versions (constraints
only, no target links them), swift-dependencies `from: "1.9.0"` → `exact: "1.14.1"`. The root
lockfile re-resolved to match: originHash refreshed to `sha256(Package.swift)` = `38e9243c…`
(so the CLI now takes its lockfile road), and its two drifted pins reconciled to the workspace's
shipping versions (PROVISIONAL P-781-1 below).

- **C2 — CLI, NEW manifest, root lockfile removed: GREEN.** The written root lockfile's 15 pins
  equal the committed WORKSPACE lockfile's 15 non-Sparkle pins ENTRY FOR ENTRY (identity, kind,
  location, revision, version — compared as JSON). The only warning is SQLCipher.swift's own
  manifest deprecation (`'v4' is deprecated: watchOS 9.0`), present at 4.18.0 regardless.
- **E10 — xcodebuild, NEW manifest, workspace lockfile removed, fresh DD: RED. THE FIRST FORM
  DOES NOT HOLD UNDER XCODE.** Only swift-dependencies stayed at 1.14.1; everything else floated
  exactly as in E2 (SQLCipher **4.20.0**, swift-syntax 604.0.0, swift-nio 2.105.0, …, plus
  swift-issue-reporting 2.1.2 BESIDE xctest-dynamic-overlay 1.13.1). **Why:** in the Xcode
  workspace the repo-root package is NOT the root. It is a LOCAL PACKAGE DEPENDENCY of the
  project, and SwiftPM's target-based resolution prunes a dependency package's declared
  dependencies down to the ones its used products need. A constraint-only `.package` that no
  target uses is dropped, so only swift-dependencies (which targets use) kept its exact pin. For
  the CLI the same package IS the root, where every declared dependency counts, and that is why C2
  is green. **The load-bearing design fact:** the Xcode graph's ROOT is the project
  (`project.pbxproj`'s package references, today Sparkle and `../..`). So the belt for the app
  must live there as project-level exact package references. Package.swift keeps its pins as the
  CLI's belt. Restored by `git checkout --`.

### THE BELT, second form — exact PROJECT-LEVEL package references (620cc9019)

The twelve transitive packages are declared in `project.pbxproj` as `XCRemoteSwiftPackageReference`
entries with `kind = exactVersion` at the committed versions (IDs `E1F781000000000000000001` …
`…0C`, listed in the project's `packageReferences` after Sparkle; NO `XCSwiftPackageProductDependency`
— no target links anything new). swift-dependencies needs no project entry: its Package.swift
requirement is direct and used, so it already counts for Xcode (E10 kept it at 1.14.1). GRDB and
the MCP SDK are `exact:` direct requirements and are referenced nowhere else, so they cannot float.
Package.swift's comment names both places. The root lockfile's originHash was refreshed to the
new manifest bytes by a forced re-resolve (C3: the pins were identical to eda25f273's).

- **E11 — xcodebuild, workspace lockfile REMOVED, fresh DD, on the project-level belt: GREEN.**
  The written lockfile's 16 pins equal the committed file's ENTRY FOR ENTRY. Only the originHash
  differs (`087cc552…`: this path, plus the twelve new root URLs in the hash).

### THE PIN — `Tools/pins-belt-check [<rev>]` (red-on-old, green-on-new, revert-verified by rev)

The scripted recipe: `git archive <rev>` into a gitignored work dir
(`App/Variorum/DerivedData/pins-belt-check/<sha>-<UTC>/`). It DELETES both lockfiles, resolves
each graph from scratch (a fresh-DD `xcodebuild -resolvePackageDependencies`, and an isolated
`swift package resolve`), then runs `Tools/verify-pins --against <rev's own committed workspace
lockfile>` on both resolved states. Exit 0 = the belt holds, 1 = drift.

| rev | what it is | Xcode graph | CLI graph | exit |
|---|---|---|---|---|
| `68b3d9c53` | pre-fix (this branch's base = main's code) | **DRIFT ×12** — sqlcipher.swift 4.18.0 → **4.20.0**, swift-dependencies 1.14.1 → 1.17.2, swift-syntax 602.0.0 → 604.0.0, EXTRA swift-issue-reporting 2.1.2, MISSING xctest-dynamic-overlay, + 7 more | **DRIFT ×12** (same set) | **1** |
| `eda25f273` | the first form alone (Package.swift pins) | **DRIFT ×11** (only swift-dependencies held) | OK, 15 pins | **1** |
| `fef4800f8` | the full belt | **OK — 16 pins match** | **OK — 15 pins match** | **0** |

The exact output lines, `68b3d9c53`: `pins-belt-check: BELT DOES NOT HOLD at 68b3d9c53 — a
pin-free resolution floats (drift above)` / `EXIT=1`. `fef4800f8`: `OK …/spm/workspace-state.json:
16 pins match the committed set` · `OK …/cli/workspace-state.json: 15 pins match the committed set`
· `pins-belt-check: BELT HOLDS at fef4800f8 — a pin-free resolution lands the committed set in
both graphs` / `EXIT=0`. The middle row is what proves that BOTH halves of the belt bear load:
the project-level references hold the app's graph, and Package.swift holds the CLI's graph and
swift-dependencies.

### `Tools/verify-pins` — the guard (fef4800f8)

**One-line usage:** `Tools/verify-pins "<OUT>/DerivedData"` after a build (or any
`workspace-state.json`, SourcePackages dir or Package.resolved). Run it with no argument BEFORE a
build: it checks the working tree's two lockfiles. Exit 0 = every pin matches the workspace
lockfile AS COMMITTED (git `HEAD`, or `--ref <rev>` / `--against <file>`); 1 = drift, each pin
named DRIFT/EXTRA/MISSING with versions and revisions; 2 = usage/unreadable input. The originHash
is ignored (T-2). `--cli` is for the repo-root graph, where the Xcode project's own Sparkle is not
expected (derived, not hard-coded: project references whose URL Package.swift never names).
Exercised: the clean tree passes (16 + 15 pins); E1's state passes; E8's state and E2's written
file each show DRIFT ×12 and exit 1; tree mode exits 1 with the upgraded file in the tree, with the
lockfile missing ("a build would resolve WITHOUT pins"), and with E11's originHash-only rewrite
(bytes differ, pins equal: flagged because a dirty file is what a build adopts; release.sh refuses
a dirty tree for the same reason); bad path or option exits 2. Python 3.9 stdlib only
(`/usr/bin/python3` 3.9.6).

### VERIFY — the pre-merge core runs (0d7fd8019; superseded by the merged-tree runs below)

- `swift build` (isolated caches, scratch `vx781-core`): **`Build complete! (40.85 sec)`**. The
  belt's cost: SwiftPM warns `dependency '<x>' is not used by any target` for 7 of the
  constraint-only lines (sqlcipher.swift, swift-atomics, swift-clocks, swift-concurrency-extras,
  swift-nio, swift-system, xctest-dynamic-overlay). These are expected and accepted (the brief
  priced this); no target links anything new.
- `swift test` — the FIRST attempt was KILLED mid-run by my own TaskStop of a polling shell (the
  harness had moved it to the background; stopping that shell took its process group, the test
  run included). Log kept as `core-test-KILLED-by-taskstop.log`; cited for nothing. Re-run
  detached in its own session:
  - VariorumCoreTests: **`Test run with 3646 tests in 491 suites passed after 254.213 seconds
    with 5 known issues.`** (gated suites print `skipped`: VX-670, 13o U3, VX-497, VX-653/654, 13o
    fork measurements — the env-gated measurement suites.)
  - StringsWorkbookTests: **`Test run with 32 tests in 4 suites passed after 29.431 seconds.`**
  - VariorumMCPTests: `Test run with 549 tests in 100 suites failed after 50.993 seconds with 3
    issues` — `MCPHarnessTimeLimitTests.aPeerThatNeverAnswersInitializeFailsTheConnectNamedAndBounded`
    (`ContinuousClock.now - started < .seconds(15)`, took 38.7 s), `MCPPreInitializeWindowTests.
    aBareOpeningIsAnsweredBeforeTheReadBlocks`, `MCPDiscoverProbeServerTests.
    claudeCodesPipelinedProbeIsAnsweredAndItsInitializeServes`. All three are socket timing under
    the parallel whole-suite load, and the first one failed in the killed run too. VX-736's record
    names "three load-timing flakes, each green alone" for this same suite. The isolation re-run
    is owed on the merged tree (below).

### RELEASE-EXPOSURE — did 1.0 (10632) or 1.0.1 (10682) ship floated pins? **NO — both shipped the committed set** (evidence, decisive, read-only)

1. **No upgraded set was ever committed, on any ref.** `git log --all` over both lockfiles: the
   workspace lockfile last changed at 2f6a92c09 (2026-10-09), the root one at 147637736
   (2026-10-09); nothing since, on any local or remote-tracking ref. Both release commits
   (1.0 = 53493f1ca, 1.0.1 = f2477b563) carry the old committed pins.
2. **Both releases were clean-tree, fresh-DerivedData builds.** Their retained provenance
   (`~/Library/Developer/Variorum/Releases/<v>/RELEASE-INFO.txt`) records `dirty files: 0`,
   Xcode 27.1 (27A9275), the commit above; `release.sh` refuses a dirty tree (lines 89–90 at the
time; 103–104 since VX-779's merge), and
   `archive-and-export.sh` archives with `-derivedDataPath "${OUT}/DerivedData"` in a fresh OUT —
   E1's exact shape, which resolves the committed set (and see the WHY below).
3. **The shipped binaries say so directly.** The retained `SQLCipher.framework.dSYM` of BOTH
   releases has UUIDs `17E38CF7-60B8-38A5-9B06-612BADC730EA` (x86_64) /
   `F0784571-EBF5-36BB-93B9-061EF615F641` (arm64) — byte-identical to the binary of the
   **SQLCipher.swift 4.18.0** xcframework E1 downloaded, and to `/Applications/Variorum.app`'s
   (1.0.1) `SQLCipher.framework`. **SQLCipher 4.18.0 shipped, exactly.** The
   `Variorum.app.dSYM` of both releases names `SourcePackages/checkouts/xctest-dynamic-overlay`
   (144 strings) and NEVER `swift-issue-reporting`; swift-dependencies switched to
   swift-issue-reporting at 1.17.1 (read from the tags' manifests: 1.14.1–1.17.0 use
   xctest-dynamic-overlay), so the shipped swift-dependencies is ≤ 1.17.0 by the binary alone and
   1.14.1 by items 1–2 + the WHY (the file sets of 1.14.1–1.17.0 are identical, so the dSYM cannot
   split that range further). swift-syntax never ships (macro-time only).

**THE LOAD-BEARING WHY (why a fresh-DD resolve lands the committed pins rather than
network-latest-in-range):** the resolver is SEEDED with the lockfile's pins as preferred versions.
In SwiftPM's PubGrub, a package's best version is its pinned version whenever the current
requirement contains it and the repository still lists that tag; only otherwise does it take the
highest version in range. The evidence that this, and not a stale cache, did it: E1 ran on a
private package cache that DID NOT EXIST before the run (`vx781-pkgcache`, created by E1 from the
network) — its fetched mirrors list SQLCipher.swift 4.20.0, swift-dependencies 1.17.2, swift-syntax
604.0.0 — and E1 still chose 4.18.0 / 1.14.1 / 602.0.0. The red-side counterpart (E2 below: the
same fresh shape with the lockfile REMOVED) is what shows the network-latest set when the pins are
absent. So the guarantee is "a clean committed lockfile + no pre-existing checkouts ⇒ the pinned
set", and it holds without any cache luck. What it does NOT cover is a reused checkout state or a
dirty lockfile (the roads below), and that is what the belt closes.

### INCIDENT — a stray `swift package --help` ran in the MAIN checkout (21:44; stopped)

Subagent Bash calls reset their cwd to the session's primary directory, which is
`~/dev/variorum` (MAIN), not this worktree. One call without a leading `cd` ran `swift package
--help`, and on Swift 6.4 that LOADS THE PACKAGE GRAPH (to list plugin commands), so it resolved
the root package into main's gitignored `.build/` (checkouts, repositories, artifacts,
workspace-state.json, .lock — all stamped 21:44; `.build/index-build`, 20:59, pre-existed and is
not mine). Stopped with TaskStop about 40 s in. **Main's tracked tree untouched:** `git status
--porcelain` empty, root `Package.resolved` mtime still Oct 10. Its state resolved the committed
ROOT set (swift-concurrency-extras 1.4.0, xctest-dynamic-overlay 1.10.1, sqlcipher 4.18.0, …),
which is harmless. The gitignored artifacts were LEFT IN PLACE (deleting files in main would be a
second touch); reported to the orchestrator. From here on every Bash call starts with `cd
<home>/dev/variorum-vx-781`.

### THE MERGE — origin/main into the branch (f8d2ced67, at the orchestrator's word, at a clean seam)

Main through 1524ed90f (which includes f3771c146, the 1.1 version bump, and #219, VX-779) merged
by git's ort strategy with NO conflict. The one intersecting file was
`App/Variorum/Variorum.xcodeproj/project.pbxproj`: main changed the `MARKETING_VERSION` lines
(1.1); the belt adds the twelve package references and their `packageReferences` lines. These are
different hunks, so git combined them automatically. `plutil -lint` reports OK. Package.swift and
both lockfiles were untouched by main. Tools/Release/{release.sh,version-guard.sh},
VersionSchemeTests and SupportDraftTests do not intersect this diff. **Disclosure:** the parse
check was a plain `xcodebuild -list`, and `-list` RESOLVES PACKAGES. So it created a default
DerivedData for this worktree's path
(`~/Library/Developer/Xcode/DerivedData/Variorum-bjpkqprpxpdypegopbzojczgvdli`; it resolved the
committed pins) and ran additive `git fetch`es into the shared repository mirrors of
`~/Library/Caches/org.swift.swiftpm`. Nothing was purged or reset, and no other session's
DerivedData was touched. Left in place at the orchestrator's ruling (the coordinator's cleanup
sweep). Every later xcodebuild carried all three isolation flags.

### VERIFY — the merged tree (f8d2ced67): the canonical evidence

- **The pin, merged:** `Tools/pins-belt-check HEAD` → `OK …/spm/workspace-state.json: 16 pins match
  the committed set` · `OK …/cli/workspace-state.json: 15 pins match the committed set` ·
  `pins-belt-check: BELT HOLDS at f8d2ced67 — a pin-free resolution lands the committed set in both
  graphs`, exit 0.
- **Core suite** (`swift test`, isolated caches, detached in its own session, log
  `core-test-merged.log`):
  - VariorumCoreTests **`Test run with 3646 tests in 491 suites passed after 247.606 seconds with
    5 known issues.`** (the env-gated measurement suites print `skipped`, as before.)
  - StringsWorkbookTests **`Test run with 32 tests in 4 suites passed after 29.429 seconds.`**
  - VariorumMCPTests `Test run with 549 tests in 100 suites failed after 49.136 seconds with 3
    issues`: the SAME three socket-timing tests as the pre-merge run, under whole-suite load.
    Alone (`--filter "MCPHarnessTimeLimitTests|MCPPreInitializeWindowTests|
    MCPDiscoverProbeServerTests"`): **`Test run with 16 tests in 3 suites passed after 2.254
    seconds.`** The load-timing class: MCPHarnessTimeLimitTests' overrun is ticketed (VX-353,
    VX-685, "green in isolation"). MCPPreInitializeWindowTests and MCPDiscoverProbeServerTests have
    NO ticket, which makes them a born-ticket candidate (Test-only · Tests & tooling · Low). The CLI graph's only pin change in this diff is
    swift-concurrency-extras 1.4.0→1.4.1 and xctest-dynamic-overlay 1.10.1→1.11.0, the versions the
    app has always run its tests on. No socket or timing code moved.
- **The app, Debug** (`xcodebuild build -scheme Variorum -configuration Debug -destination
  'platform=macOS' -derivedDataPath …/vx781-merged -packageCachePath …/vx781-pkgcache`; no clone
  dir, so SourcePackages lands inside the DerivedData exactly as on the release road):
  **`** BUILD SUCCEEDED **`**. The workspace lockfile hash was sampled every second through the
  build and never changed (`e12-lockhash.log`). **`Tools/verify-pins
  App/Variorum/DerivedData/vx781-merged` → `OK …/vx781-merged/SourcePackages/workspace-state.json:
  16 pins match the committed set`, exit 0.** The resolved pins (workspace-state): combine-schedulers
  1.2.0 · eventsource 1.5.1 · grdb.swift 7.11.1+sqlcipher.1 · sparkle 2.10.0 · **sqlcipher.swift
  4.18.0** · swift-atomics 1.3.1 · swift-clocks 1.1.0 · swift-collections 1.7.2 ·
  swift-concurrency-extras 1.4.1 · **swift-dependencies 1.14.1** · swift-log 1.16.1 · swift-nio
  2.104.0 · swift-sdk 0.12.1 · **swift-syntax 602.0.0** · swift-system 1.8.1 ·
  xctest-dynamic-overlay 1.11.0, and no swift-issue-reporting. The built app's
  `Contents/Frameworks` holds only Sparkle.framework and SQLCipher.framework (the belt links
  nothing). Its SQLCipher UUIDs `17E38CF7…`/`F0784571…` equal the 4.18.0 xcframework's and the
  shipped 1.0/1.0.1's. The tree guard after the build: `Tools/verify-pins` OK (16 + 15). Xcode
  emitted no package warning for the constraint-only references.
- **`xcodebuild build-for-testing`** (same DerivedData; compiles the test bundles, runs nothing):
  **`** TEST BUILD SUCCEEDED **`**.
- **NOT run:** any `xcodebuild test` (needs a stage claim; the app's pins and code are unchanged by
  this diff, so the brief's gate did not call for one, and the orchestrator may request a window if
  the ladder wants one).
- Corroboration from the coordinator (not my run): the 1.1 (11006) release road's fresh clean-tree,
  fresh-DerivedData build confirmed the committed pins.

## UPGRADING A PIN DELIBERATELY (the road the belt leaves open — the author's call, every time)

The belt's cost is that a dependency version now lives in up to FOUR places that must agree. Every
upgrade is deliberate, so this is the whole road, in order:

1. **Decide.** Name the package and the new version; every move is deliberate. A NEW package
   identity entering the graph (e.g. swift-issue-reporting, which swift-dependencies ≥ 1.17.1
   brings) is a new third-party dependency, which is author-only (CLAUDE.md). If it is linked, its
   licence notice joins Settings ▸ Acknowledgments (`AcknowledgmentsCopy`). Whether bumping an
   EXISTING pin is author-only too is unruled (P-781-4). Until she rules, treat a crypto pin
   (SQLCipher, the GRDB fork) as hers.
2. **Edit the declarations, the same version in each place the package appears:**
   a. `Package.swift`: its `exact:` line. This is the CLI's belt, and for the direct dependencies
      (the GRDB fork, swift-dependencies, the MCP SDK) the app's belt too.
   b. `App/Variorum/Variorum.xcodeproj/project.pbxproj`: the matching `XCRemoteSwiftPackageReference`
      (`kind = exactVersion; version = …;`). This is the app's belt for the twelve transitive
      packages and the only home of Sparkle. Edit it by hand or through Xcode's Package
      Dependencies pane, keeping "Exact Version".
   c. If the upgrade CHANGES THE TRANSITIVE SET (identities added or dropped, as with
      swift-dependencies 1.17.x: swift-issue-reporting in, xctest-dynamic-overlay out), add or
      remove the exact lines in BOTH files to match, each version chosen deliberately.
3. **Re-resolve BOTH lockfiles, in the same commit:**
   a. root: `rm Package.resolved && swift package resolve`
   b. workspace: `rm App/Variorum/Variorum.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`,
      then from `App/Variorum/`: `xcodebuild -resolvePackageDependencies -project Variorum.xcodeproj
      -scheme Variorum -derivedDataPath <fresh dir> -clonedSourcePackagesDirPath <fresh dir>
      -packageCachePath <dir>` (all three inside the worktree's gitignored DerivedData).
   Removing the files is SAFE only because of the belt: a pin-free resolution lands exactly the
   declared set. Anything you left floating shows up in step 4.
4. **Verify, after committing:** `swift test --filter PinBeltTests` (milliseconds, no network)
   must pass, `Tools/verify-pins` (no argument) must say OK for both lockfiles, and
   `Tools/pins-belt-check HEAD` must exit 0. **These are the roads that go RED until everything
   agrees.** A package bumped in only one of Package.swift / project.pbxproj does NOT fail
   resolution. Xcode prunes Package.swift's line and the CLI never reads the project, so the app and
   the CLI silently get DIFFERENT versions. That mismatch is caught by PinBeltTests on every `swift
   test` (its (2) or (3) goes red, as probes D2/D3 showed), by verify-pins (the root lockfile vs the
   committed workspace set) and by pins-belt-check (the CLI graph DRIFTs). A
   lockfile not re-resolved shows as DRIFT, or as a byte-dirty workspace lockfile after the next
   build (the tree guard).
5. **The usual gate** on the new set (core suite, app suites under a stage claim, a walk if behaviour
   can change), with the upgrade recorded in the effort's record. Like a schema change, the
   dependency change is its own commit ahead of any code that uses it.

**Born-ticket candidate (not built):** `Tools/upgrade-pin <identity> <version>`. It would edit both
declarations (and say when the transitive set changes), re-resolve both lockfiles in isolated dirs,
and run verify-pins + pins-belt-check: steps 2–4 as one command, so the belt never gets worked
around out of frustration. Suggested: Improvement · Tests & tooling · Low.

## THE release.sh WIRING — a PROPOSAL only (release.sh untouched; the release road is hers)

Two verification-only hooks, no change to the publish flow:

```diff
 # ------------------------------------------------------------------ 0. preflight  (after the clean-tree refusal, release.sh:104)
+# VX-781: the pins guard over the lockfiles a build is about to read (the workspace file is already
+# covered by the clean-tree refusal; this also proves the root lockfile agrees with it).
+"${REPO}/Tools/verify-pins" > /dev/null || refuse "the package pins drift from the committed set — run Tools/verify-pins (VX-781)"

 # ------------------------------------------------------------------ 1–2. stamp + archive + export  (after `[ "$AE" -eq 0 ] || …`, release.sh:171)
+# VX-781: the archive's RESOLVED graph is the committed one — read from its own SourcePackages,
+# before anything is notarized; the result rides beside RELEASE-INFO.txt.
+"${REPO}/Tools/verify-pins" "${BUILD_DIR}/DerivedData" > "${BUILD_DIR}/verify-pins.txt" \
+  || { cat "${BUILD_DIR}/verify-pins.txt" >&2; echo "REFUSED: the archive resolved packages other than the committed pins (VX-781)" >&2; exit 5; }
```

The second hook is the one that matters: it reads what the archive ACTUALLY built against, so it
catches every road (a pin-free resolution, an adopted dirty file) that a pre-build check cannot
see. It is cheap (no network, no xcodebuild). `archive-and-export.sh` writes its DerivedData at
`${OUT}/build.noindex/DerivedData` = `${BUILD_DIR}/DerivedData`, where `verify-pins` finds
`SourcePackages/workspace-state.json`. Retaining `verify-pins.txt` into `Releases/<v>/` would make
it release provenance like the dSYMs. Its wiring is the coordinator's/author's call. Born-ticket
candidate if wanted: Improvement · Tests & tooling · Medium.

## PROVISIONAL calls (for notes/QUESTIONS.md at the merge — I did not edit the shared ledger)

- **P-781-1 — the two committed lockfiles disagreed** (root: swift-concurrency-extras 1.4.0,
  xctest-dynamic-overlay 1.10.1; workspace: 1.4.1, 1.11.0, shipping since 2026-08-03's
  57d749299). **Built (A):** exact-pin the WORKSPACE (shipping) versions; the CLI's root lockfile
  moves 1.4.0→1.4.1 and 1.10.1→1.11.0, which are versions the app already ships, so nothing new
  enters any graph. (B) Closed ranges `"1.4.0"..."1.4.1"` / `"1.10.1"..."1.11.0"` keep both files
  byte-stable, but a pin-free CLI resolution would then land the top of each range, so the CLI half
  of the belt holds only by luck of the range. (C) Pin the APP DOWN to 1.4.0 / 1.10.1, which changes
  what ships. (A) is the most defensible: one committed set, the shipping one.
- **P-781-2 — where the app's belt lives.** **Built (A):** twelve exact project-level package
  references in project.pbxproj. They are VISIBLE in Xcode's Package Dependencies list, with no
  product dependency. (B) Package.swift pins only, plus the verify-pins guards: E10 proves a
  pin-free resolution then floats SQLCipher to 4.20.0, so the guards would refuse builds instead of
  preventing the float. (C) Restructure to an .xcworkspace that opens the repo package as a ROOT
  package (root packages are not pruned), so Package.swift alone would belt both graphs. That means
  every build, script and walk switches to `-workspace`, which is a project restructure and not
  this ticket's to make. (A) is the only place Xcode reads as root today.
- **P-781-3 — the tree guard flags an originHash-only byte change** of the workspace lockfile (pins
  equal), e.g. after a pin-free re-resolution on a new path. **Built (A):** flag it (exit 1), the
  same stance as release.sh's clean-tree refusal: a dirty file is what a build adopts. (B) Pass when
  pins are equal (less noise; the post-build check still guards). (A) is conservative and
  consistent with the release road.

- **P-781-4 — is moving an EXISTING pin's version author-only?** CLAUDE.md makes adding a
  third-party dependency author-only; it says nothing about bumping one. (A) A bump is author-only,
  like an add; the crypto pin (SQLCipher) makes this the safe reading. (B) Any session may bump
  within an existing identity through the UPGRADING road, recorded in its effort. (C) Bumps are
  author-only for the crypto and sync-adjacent pins (SQLCipher, the GRDB fork), free for the rest.
  **Built:** nothing is decided in code. Package.swift and UPGRADING step 1 now state only the
  canon (a new identity is author-only) and point here; the record advises treating a crypto pin as
  hers until she rules. Queued at the orchestrator's note for her ratification at the merge.

## Machinery honesty

No session death. Three slips, all disclosed the same turn: (1) the stray `swift package --help` in
the MAIN checkout's gitignored `.build` (INCIDENT above). Its cause: subagent Bash calls reset to
the session's primary directory, which is main. (2) My own TaskStop of a polling shell killed the
first `swift test` mid-run (the harness had moved the poll to the background; the stop took the
whole process group). That run is cited for nothing; every later long run was launched detached in
its own session and polled in under-180-second foreground calls. (3) The plain `xcodebuild -list`
parse check (THE MERGE above). Shared-cache writes, all additive and ruled acceptable by the
orchestrator: manifest-cache entries (E1 onward; `-packageCachePath` does not redirect them) and
`-list`'s repository-mirror fetches. Nothing shared was ever purged or reset. The global
DerivedData dirs and the other worktrees were only read.

**Worktree hygiene at the close:** the superseded experiment dirs (E1–E11 DerivedData + clone dirs,
the CLI scratch dirs, the pin runs' exported trees and build dirs) were deleted. All of them were
inside this worktree's gitignored `App/Variorum/DerivedData/`: 20 GB → 5.9 GB. KEPT for the
ladder: `logs/` (every invocation's log and the E2/E8/E10/E11 written lockfiles), each pin run's
`xcode-workspace-state.json` + `cli-workspace-state.json` + resolve logs under `pins-belt-check/`,
`vx781-merged/` (the merged-tree Debug + build-for-testing DerivedData that verify-pins read),
`vx781-core/` (the core suite's scratch), and the private package/CLI caches.

## LADDER ROUND 1 — findings (opus-reviewer, relayed verbatim by the orchestrator) + the implementer's dispositions

Landed repo-first, BEFORE any fix. Same-model ladder: the orchestrator arbitrates disputes. **Every
finding is AGREED; none disputed.** The fixes follow in "ROUND 1 FIX LEG".

| # | Sev | Finding (the reviewer's words, condensed) | Disposition |
|---|---|---|---|
| R1-1 | MAJOR | *Nothing automatic guards the belt.* It spans four places that must agree (Package.swift, 12 pbxproj `exactVersion` refs, two lockfiles). `verify-pins` compares lockfiles only; `pins-belt-check` is the only declaration check, manual, networked, ~1 GB/run, and red only when upstream has a newer in-range tag. Deleting `E1F78100000000000000000B` (swift-atomics, already upstream's newest) leaves both tools green, and the line disappears silently. A one-sided bump is likewise caught only if someone runs a tool. **Pin:** a hermetic static test in the core suite (VersionSchemeTests' `#filePath` precedent): (1) every root-lockfile pin has an `exact:` Package.swift line at its version; (2) every workspace-lockfile pin is an `exactVersion` project reference at its version or a used direct `exact:` dependency; (3) root pins = workspace pins minus project-only refs. RED on 68b3d9c53, GREEN on HEAD, no network. | **AGREE.** The mechanism is right: verify-pins reads only lockfiles, so a deleted declaration is invisible until upstream moves. Fix: `Tests/VariorumCoreTests/PinBeltTests.swift`, red-on-old on a 68b3d9c53 export carrying the new test, plus the two degradations the finding names (the deleted swift-atomics ref; a one-sided bump), each red. `pins-belt-check` stays as the deep, networked proof. |
| R1-2 | MINOR | *The record understates the belt:* for the CLI graph it also closes the upgraded-file road. Measured by the reviewer: C1's upgraded root lockfile + `--only-use-versions-from-resolved-file` fails CLOSED (`error: an out-of-date resolved file was detected … not allowed when automatic dependency resolution is disabled`); plain `resolve` HEALS to the committed set. Xcode half unmeasured. Re-run E8 on the belt (with and without the flag), then restate mechanism (2) and the verdict as pre-belt / post-belt. | **AGREE.** E8 ran only pre-belt, so "every later build ADOPTS it" is a pre-belt fact. Fix: E8b, both graphs, both modes, on a HEAD export (my worktree stays clean); restate. |
| R1-3 | MINOR | *The ticket's sharpest datum is never addressed:* the gatef rewrite happened "under a build that itself resolved committed pins", so a second writer must exist (another process or resolution path). VX-770's rewrites happened around `xcodebuild test` and iOS-simulator destinations; E7/E12 sampled only macOS `build`, and E13 ran unsampled. One sentence in NOT DONE. | **AGREE.** Fix: the sentence. Plus one sampled iOS-destination build on the PRE-belt tree (a 68b3d9c53 export) and the phone build on the belt (R1-11), both with the lockfile sampler. `xcodebuild test` stays unsampled (stage-gated) and is said so. |
| R1-4 | MINOR | The RELEASE-RISK verdict reads as if both guards are in place; the post-archive verify-pins is an unapplied proposal. Say "…and, if wired (proposal below)…". | **AGREE.** Wording fix. |
| R1-5 | MINOR | `pins-belt-check` leaves its whole work dir (~600 MB+) after every run, and UPGRADING step 4 sends every upgrade there. An exit trap keeping `*-resolve.log` + both workspace-state copies and removing `tree/ dd/ spm/ cli/`; optionally `--keep` and `.noindex` on `$BASE`. | **AGREE.** Fix all three; evidence = the work dir's size after a run. |
| R1-6 | NIT | "Moving any version is a deliberate upgrade and the author's call" asserts a governance rule CLAUDE.md does not hold: adding a dependency is author-only, bumping is unaddressed. Log P-781-4 or reword. | **AGREE, both halves** (the orchestrator's note): reword Package.swift + UPGRADING step 1 to the canon-accurate statement, AND queue P-781-4. |
| R1-7 | NIT | `verify-pins`' `load_state` decides the format by FILENAME; the kept renamed copies (`xcode-workspace-state.json`) exit 2. Detect by content. | **AGREE.** Fix + exercise on the kept copies. |
| R1-8 | NIT | The `--cli` skip set comes from the WORKING tree even under `--ref`/`--against`; the URL test is a raw substring. | **AGREE.** Fix: derive project-only from the pbxproj + Package.swift AT the reference revision (`--ref`; the working tree under `--against`, documented), by identity, not substring. |
| R1-9 | NIT | The no-argument mode byte-checks the workspace lockfile but only pin-compares the root lockfile, which `swift build` adopts the same way. | **AGREE.** Fix: the same byte check on the root lockfile. |
| R1-10 | NIT | Line references stale after the merge (dirty-tree refusal now release.sh:103–104, `AE` check :174); cite VX-685/VX-353 for the MCP flakes. | **AGREE.** VX-353 and VX-685 (read from main's `notes/TICKETS.md`) cover MCPHarnessTimeLimitTests only. The other two flaking suites (MCPPreInitializeWindowTests, MCPDiscoverProbeServerTests) have NO ticket, so they become a born-ticket candidate. |
| R1-11 | NIT, SPEC. | The phone scheme was not built on the belt. A headless `-scheme VariorumMobile -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build` needs no stage. | **AGREE.** Fix: that build on the merged belt tree, isolated, lockfile sampled, then verify-pins on its DerivedData. |

## ROUND 1 FIX LEG (implementer) — every agreed finding, with its evidence

- **R1-1 (MAJOR) — FIXED, red-on-old.** `Tests/VariorumCoreTests/PinBeltTests.swift` (95fcc3c4e):
  three tests over the four files, read by `#filePath`. No network, no build, ~2 ms.
  - (1) Every root-lockfile pin has an `exact:` Package.swift line at its version, and no
    Package.swift requirement floats.
  - (2) Every workspace-lockfile pin is an `exactVersion` project reference at its version, or a
    direct `exact:` requirement that a target USES (`.product(…, package:)`). Every project
    reference must be `exactVersion`, and every reference block must parse.
  - (3) The root pins equal the workspace pins (identity, location, version, revision), minus the
    project-only references (project identities Package.swift never names, which is Sparkle).

  Evidence:
  - **GREEN on HEAD:** `✔ Test run with 3 tests in 1 suite passed after 0.002 seconds.`
  - **RED-ON-OLD:** a `git archive 68b3d9c53` export with ONLY the new test file added, built
    fresh: `✘ Test run with 3 tests in 1 suite failed after 0.002 seconds with 4 issues`.
    - (1) `Package.swift requirements that FLOAT …: ["https://github.com/pointfreeco/swift-dependencies.git — from: \"1.9.0\""]`
      and `the CLI belt is broken: ["combine-schedulers 1.2.0 (dcccb97): no exact: line in Package.swift", …]`.
    - (2) `the app belt is broken: ["combine-schedulers 1.2.0 (dcccb97): no exact project reference, and not a used direct exact requirement — Xcode would let it float", … "sqlcipher.swift 4.18.0 (f879fff): …", …]`.
    - (3) `the lockfiles disagree …: ["swift-concurrency-extras: root 1.4.0 (a90e2e4) ≠ workspace 1.4.1 (5fa2534)", "xctest-dynamic-overlay: root 1.10.1 (401bf70) ≠ workspace 1.11.0 (8f6abcf)"]`.
  - **The finding's own degradations, probed on HEAD.** The working tree was committed first;
    each probe edited only the named files and was restored by `git checkout --`.
    - **D1, the swift-atomics reference deleted:** RED, (2) `["swift-atomics 1.3.1 (0442cb5): no
      exact project reference, and not a used direct exact requirement — Xcode would let it
      float"]`. verify-pins and pins-belt-check could not see this one.
    - **D2, a one-sided bump (the project's swift-log → 1.17.0 only):** RED, (2) `["swift-log:
      project reference exactVersion 1.17.0 ≠ workspace lockfile 1.16.1 (4038b6a)"]`.
    - **D3, the project + workspace lockfile bumped, the root not:** RED, (3) `["swift-log: root
      1.16.1 (4038b6a) ≠ workspace 1.17.0 (e3da040)"]`.
  - `pins-belt-check` stays as the networked proof.
- **R1-2 (MINOR) — FIXED (measured, then restated).** E8b, on a HEAD (60cfbd44e) export carrying
  BOTH upgraded lockfiles (E2's and C1's), every directory isolated:
  - **(a)** Xcode, fresh DerivedData, `-onlyUsePackageVersionsFromResolvedFile`: **exit 74**,
    `an out-of-date resolved file was detected at …/Package.resolved, which is not allowed when
    automatic dependency resolution is disabled`. FAILS CLOSED, and the lockfile is unchanged.
    (Its clone dir was left holding upgraded checkouts, fetched before the refusal; no build can
    proceed from a failed resolve, and (e) shows they heal.)
  - **(b)** Xcode, fresh DerivedData, plain: exit 0. The state AND the rewritten lockfile:
    `verify-pins` **16 pins match**. The file HEALED.
  - **(c)** CLI strict (`--only-use-versions-from-resolved-file`): **exit 1**, the same
    out-of-date error, root lockfile unchanged. This reproduces the reviewer's measurement.
  - **(d)** CLI plain: exit 0, state + rewritten root lockfile **15 pins match**. Healed.
  - **(e)** Xcode, the upgraded file again, REUSING (a)'s DerivedData (upgraded checkouts), plain:
    exit 0, **16 pins match**. Healed.

  Mechanism (2) and the RELEASE-RISK verdict in FOR A LATER READER are now split pre-belt /
  post-belt.
- **R1-3 (MINOR) — FIXED (the sentence) + two sampled builds.** NOT DONE now names the gatef datum
  (a second writer), and names `xcodebuild test` and simulator destinations as never sampled.
  - Pre-belt sample: a 68b3d9c53 export, `-scheme VariorumMobile -destination
    'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build`, isolated, both lockfiles hashed every
    second: `** BUILD SUCCEEDED **`, **no change** (`prephone-lockhash.log`), and `verify-pins
    --ref 68b3d9c53` OK, 16 pins.
  - The belt sample is R1-11.
- **R1-4 (MINOR) — FIXED.** The verdict now separates the guards in place (the belt, PinBeltTests,
  release.sh:103–104) from the proposal ("if wired … not applied").
- **R1-5 (MINOR) — FIXED** (60cfbd44e). An EXIT trap keeps the two resolve logs, the committed
  lockfile and both resolved states, and removes `tree/ dd/ spm/ cli/ cli-config/ cli-security/`.
  It is guarded by a `case` on `$BASE/*`. `--keep` keeps everything, and the base is
  `pins-belt-check.noindex`. Evidence: `Tools/pins-belt-check HEAD` → `BELT HOLDS at 60cfbd44e`,
  exit 0, and the run's dir afterwards holds five files, **48K**. The old 600 MB+ trees are gone.
  It now verifies with `--ref <rev>`, so the rev's own project and manifest decide project-only
  (R1-8's point carried into the script).
- **R1-6 (NIT) — FIXED, both halves** (dfded4cb9). Package.swift and UPGRADING step 1 now say only
  the canon: moves are deliberate, and a new identity is author-only (CLAUDE.md). They point at
  **P-781-4**, queued in the PROVISIONAL list for her ratification. The root lockfile's originHash
  was refreshed by a forced re-resolve (C4, pins identical).
- **R1-7 (NIT) — FIXED** (60cfbd44e). The format is now decided by content (`pins` vs
  `object.dependencies`). The kept `xcode-workspace-state.json` / `cli-workspace-state.json` copies
  now read: OK 16 / OK 15 on f8d2ced67's, DRIFT ×12 on 68b3d9c53's. A non-JSON input exits 2
  ("not JSON").
- **R1-8 (NIT) — FIXED** (60cfbd44e). The project-only set is parsed by IDENTITY from the
  pbxproj's `repositoryURL`s minus Package.swift's `.package(url:` identities. It is read at `--ref`
  (git show), or from the working tree under `--against` (documented). `--ref 68b3d9c53 --cli` on
  68b3d9c53's CLI state reports DRIFT ×12 against that rev's own lockfile.
- **R1-9 (NIT) — FIXED** (60cfbd44e). The no-argument guard byte-checks `Package.resolved` too. An
  originHash-only edit of the root lockfile now reports `DRIFT Package.resolved: the working-tree
  file differs from HEAD`, exit 1. The clean tree passes.
- **R1-10 (NIT) — FIXED.** Line references are re-read on f8d2ced67 AND on origin/main: the
  dirty-tree refusal is release.sh:103–104 and the `AE` check is **:171** on both (the finding said
  :174; :171 is what the file holds). The MCP flakes cite VX-353/VX-685 for
  MCPHarnessTimeLimitTests. The other two suites have no ticket, so they are a born-ticket
  candidate.
- **R1-11 (NIT) — FIXED.** On the merged belt tree: `-scheme VariorumMobile -destination
  'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build` with `-derivedDataPath …/vx781-phone
  -packageCachePath …`, both lockfiles hashed every second: **`** BUILD SUCCEEDED **`**, no change
  (`phone-lockhash.log`), `Tools/verify-pins App/Variorum/DerivedData/vx781-phone` → **OK 16 pins**.

**Suite re-runs (code changed: a new core test, tool scripts, Package.swift comment):**
- Core `swift test` on dfded4cb9: VariorumCoreTests **`Test run with 3649 tests in 492 suites passed
  after 247.183 seconds with 5 known issues.`** (= 3646/491 + PinBeltTests' 3 tests / 1 suite).
- StringsWorkbookTests **`32 tests in 4 suites passed`**.
- VariorumMCPTests in the whole run: `549 tests in 100 suites failed … with 12 issues`, all socket
  and timing tests. The machine was otherwise idle; the only CPU consumer was this run's own
  `swiftpm-testing-helper` at ~1000 %. The MCP target ALONE: `549 tests … failed … with 6 issues`
  (VX-180's pre-initialize probe, VX-394's stop roads, VX-132's harness bound).

**THE MCP A/B — an observation I found myself (not a reviewer finding), for the orchestrator.**
P-781-1 moves the CLI graph's swift-concurrency-extras 1.4.0→1.4.1 and xctest-dynamic-overlay
1.10.1→1.11.0. These are the versions the APP has shipped since 2026-08-03, but VariorumMCPTests
only ever runs in the CLI graph. So I sampled the MCP target alone (`swift test --filter
VariorumMCPTests`, 549 tests / 100 suites), on 68b3d9c53 exports and on the belt, with the failing
suites tallied (logs `mcp-*.log`, `core-test*.log`):

| tree · CLI pins | runs: issues (failing suites) |
|---|---|
| 68b3d9c53 · its own (1.4.0 / 1.10.1) | 1 (VX-132) · 1 (VX-132) · **3 (VX-132, VX-180 probe, VX-394)** · whole-suite run: 1 (VX-132) |
| 68b3d9c53 · xctest-dynamic-overlay 1.11.0 only | 1 (VX-132) |
| 68b3d9c53 · swift-concurrency-extras 1.4.1 only | 2 (VX-132, VX-180 probe) · 2 (same) |
| 68b3d9c53 · both (= the belt's set) | 2 (VX-132, VX-180 probe) · 1 (VX-132) |
| the belt, fresh export | 2 (VX-132, VX-180 window) · 2 (VX-132, VX-180) |
| the belt, the worktree's long-used scratch | 6 · 8 · 4 · 2 (VX-132, VX-180, and VX-184/394/400/548/762 socket suites) |
| the belt, whole-suite runs | 3 · 3 · 12 (the same socket families) |

**Reading.**
- Every failing test is a socket-road timing test: a 5 s `SO_RCVTIMEO` read returning nothing, or
  the 15 s wall-clock bound.
- VX-132's bound (MCPHarnessTimeLimitTests, VX-353/VX-685) fails in EVERY sample on both sides.
- The VX-180 family ALSO fails on 68b3d9c53's own pins (its third sample), so it is a pre-existing
  flake class, not a new failure. The samples suggest it trips MORE OFTEN with
  swift-concurrency-extras 1.4.1, the likely lever (2/2 with it alone; its 1.4.1 diff is "Enable
  upcoming features", swift-format and a trait alignment). The suites pass alone: `16 tests in 3
  suites passed`, on the belt.
- The worktree scratch's 6/8/4 clustered with a busy machine (Spotlight indexing the fresh
  exports, builds just finished). The scratch itself later gave 2, like a fresh export.

**Disposition (PROVISIONAL, inside P-781-1; for the orchestrator to rule).** Kept (A): the CLI now
tests the MCP server against the dependency versions the shipping app runs, which is the truer
gate. If concurrency-extras 1.4.1 makes the socket road slower, the shipped app already has that.
Born-ticket candidate (Test-only · Tests & tooling · Medium): "the MCP socket-road suites'
5 s receive bounds trip under parallel load; more often on the shipping ConcurrencyExtras 1.4.1;
find whether it is test timing or a real latency in the pre-initialize road". The alternatives
are P-781-1's (B)/(C): B would hold the CLI at the old pair, C would pin the app down. That would
make the CLI test something other than what ships, or change what ships.
