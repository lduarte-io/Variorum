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
