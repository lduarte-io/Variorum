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

PENDING reproduction. The expected roads (SwiftPM's best-effort strategy): originHash MATCHES →
the lockfile is used AS a lockfile (checkouts are moved to the pins); originHash MISMATCHES →
"resolve and update": the CURRENT CHECKOUT STATE of that build's SourcePackages is kept if it
satisfies the requirements (the lockfile's pins are not compared to it), missing packages are
resolved with the lockfile's pins as PREFERENCES, and the lockfile is then re-written from the
resulting state with the new (path-dependent) originHash.

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
