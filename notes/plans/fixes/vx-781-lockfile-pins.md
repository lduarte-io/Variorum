# VX-781 — the Package.resolved rewriter: the mechanism traced, the committed pins belted

Branch `vx-781-lockfile-pins` (worktree `~/dev/variorum-vx-781`), cut from main at 68b3d9c53.
Ticket VX-781 (High · Bug · Confirmed · Tests & tooling), born at VX-770's closeout (R-770-T1).
Implementer: opus-implementer, 2026-11-04 (single-ticket effort; build infrastructure; no Sync/,
no custody, no editor seam, no `xcodebuild test`).

## FOR A LATER READER

PENDING — written at the close.

## LIVE STATUS (flipped per piece, in the same commit as the piece)

| Piece | Status |
|---|---|
| (a) TRACE the mechanism | IN-PROGRESS — the originHash finding is made (below, T-1..T-3); reproductions next |
| (b) RELEASE-RISK VERDICT | NOT-STARTED |
| (c) THE BELT (manifest pins + `Tools/verify-pins`) | NOT-STARTED |
| (d) THE PIN (red-on-old / green-on-new recipe, revert-verified) | NOT-STARTED |
| (e) VERIFY (`swift build` + `swift test`; one Debug `xcodebuild build`; resolved pins recorded) | NOT-STARTED |
| (f) THE RECORD's FOR A LATER READER | NOT-STARTED |

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

### RELEASE-EXPOSURE — did 1.0 (10632) or 1.0.1 (10682) ship floated pins? **NO — both shipped the committed set** (evidence, decisive, read-only)

1. **No upgraded set was ever committed, on any ref.** `git log --all` over both lockfiles: the
   workspace lockfile last changed at 2f6a92c09 (2026-10-09), the root one at 147637736
   (2026-10-09); nothing since, on any local or remote-tracking ref. Both release commits
   (1.0 = 53493f1ca, 1.0.1 = f2477b563) carry the old committed pins.
2. **Both releases were clean-tree, fresh-DerivedData builds.** Their retained provenance
   (`~/Library/Developer/Variorum/Releases/<v>/RELEASE-INFO.txt`) records `dirty files: 0`,
   Xcode 27.1 (27A9275), the commit above; `release.sh` line 89–90 refuses a dirty tree, and
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
