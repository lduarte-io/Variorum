# VX-781 follow-up: the build-ergonomics survey (for P-781-3)

Owed by QUESTIONS #260, which holds P-781-3 for this research. Her ask: *"i've seen a company write a whole blog post about how they had to change their xcode build process because multiple people coudln't work on something. do research for me - there might be tools that making builds not be so painful, i'm conflicted on this because i don't want sessions to have to deal with constant probelms"*.

Researched 2026-11-05 (research agent, read-only; no build, no config change). The marks used below: **[verified]** means I read it in the primary source named; **[measured]** means I counted it in this repo, read-only; **[inference]** means my reasoning, not something a source states.

---

## 1. TL;DR for the author

- **The posts you remember** (DoorDash 2023, Lightricks 2022, Fundrise 2022, Airbnb 2024) are about many people editing Xcode's project file at once and colliding on merge conflicts. Their fixes: generate the project from a short text file (XcodeGen, Tuist), a merge helper (Kintsugi), or a whole new build system (Bazel).
- **Variorum already has Apple's own fix for that problem.** It's called "buildable folders" (Xcode 16 and later): adding a file never touches the project file. Since Sept 1 the project file changed 26 times, mostly version bumps at releases. Only one of those changes was a file-list change. Tuist's own founder writes that if conflicts are your only complaint, project generation "might be overkill".
- **None of those tools fixes the friction we actually have, which is the lockfile.** Tuist and XcodeGen keep a lockfile too. Adopting either one would mean rewiring every build script, walk and the release road. Not worth it here.
- **The false alarm comes from Swift itself.** A bookkeeping line in the lockfile (`originHash`) includes the folder path of the local package, so every worktree computes a different value. That is in Swift's source code. It isn't documented anywhere, and no one upstream has reported it. Code changes now open in Swift's package manager (not yet merged) would make that line get rewritten more often, not less.
- **For P-781-3 I recommend (b), versions-equal.** The guard passes when every pin matches (name, version and exact commit). It prints a one-line note when only bookkeeping changed, and fails on any real pin change. A floated SQLCipher still fails, exactly as it does today. The release road stays strict on every byte anyway, because release.sh refuses any uncommitted change.
- **Why not the other two:** strict (a) makes sessions trip over harmless changes, and if Swift's open change lands it trips in every worktree. Normalize (c) behaves like (b) but still raises false alarms on harmless formatting changes.

---

## 2. The landscape

**What this repo looks like** [measured, read-only, 2026-11-05]:

- `project.pbxproj` is `objectVersion = 77` with **8 `PBXFileSystemSynchronizedRootGroup` entries** (buildable folders) and only 8 `PBXFileReference` entries, all of them products and similar items, not source files.
- **26 commits touched `project.pbxproj` since 2026-09-01.**
  - 15 changed only `MARKETING_VERSION`, at releases, and 1 was a merge.
  - The other 10: VX-781's package references (2), the MCP shim target, the build-number phase, Sparkle, one shared test-support file reference, and four one-line entitlement or Info.plist settings.
  - Only that one test file reference was a file-list change.
- **7 commits touched the two `Package.resolved` files** in the same window.
- The pain is therefore not file-list merge conflicts. It is lockfile bytes changing under parallel worktrees.

### The blog-post class

**What the companies said** [verified]:

- **DoorDash, "How DoorDash uses XcodeGen to eliminate project merge conflicts"** (Md Al Mamun and Michael Thole, 2023-05-31). This is probably the post you remember. They faced "frequent merge conflicts" from a "constantly scaling team" during a big refactor, and moved to XcodeGen, which generates the project from a YAML spec. The post also says: *"For a small team, continuous Xcode project modifications might not be a common occurrence… they will likely remain untroubled by merge conflict issues."* (Read through the Wayback snapshot, because the live page blocks automated reads.)
- **Lightricks, "Kintsugi: Automatically Solving Git Conflicts in Xcode Project Files"** (Ben Yohay, March 2022). They built a git merge driver for `.pbxproj` files. I could not open the post itself (403, and there is no archive copy), so its content comes from the Kintsugi README and a search summary.
- **Fundrise, "How Fundrise Freed Itself from Xcode Project Purgatory"** (Mark Anderson, 2022-09-12). They first tried `*.pbxproj merge=union`, which *"would occasionally break the project file, sometimes beyond repair"*. Then they moved to Tuist.
- **Airbnb, "Migrating Our iOS Build System from Buck to Bazel"** (Qing Yang and Andy Bartholomew, 2024-02-01). This is the large-org end of the spectrum: a company-wide move to one build system across backend, web and iOS.

### Each tool, verdict for this repo

The repo is one author plus parallel AI sessions, SwiftPM only, one `.xcodeproj`, and low churn in the project file.

| Tool / practice | Pain it solves | Adoption cost / risk | Verdict here |
|---|---|---|---|
| **Xcode 16+ buildable folders** (synchronized groups) | Apple's release notes: *"Minimize project file changes, and avoid version control conflicts with buildable folder references… Buildable folders only record the folder path into the project file without enumerating the contained files."* [verified] | Low. Tuist's blog calls it *"a low-effort, high-return investment"*. | **Already adopted** (objectVersion 77, 8 synchronized roots). Nothing more to do. |
| **XcodeGen** (YAML spec, project generated, `.xcodeproj` can leave git) | README: *"remove your `.xcodeproj` from git, which means no more merge conflicts!"* [verified]. Actively maintained (2.46.0, July 2026). | High for us. Every `xcodebuild` script, WalkKit, release.sh, CLAUDE.md's commands and the VX-781 belt (15 project package references) would move into a spec plus a generate step. It's also a new tool dependency, which is your call. It keeps Xcode's own package integration, so the same workspace lockfile and the same path-dependent `originHash` remain [inference: a generated project's `packages:` entries are ordinary Xcode package references]. | **No.** It solves a problem we don't have and leaves the one we do. |
| **Tuist** (Swift-manifest project generation, plus caching and modularization) | Generation, as above. Its own package integration also makes resolution an explicit step: *"the resolution of dependencies is its own command. This gives control to the users over when they'd like dependencies to be resolved"* [verified, Tuist docs]. | Highest. It means generation, a new project model, a new resolver path and new commands everywhere. It still uses a `Package.resolved` (its docs recommend `tuist install --force-resolved-versions` on CI) [verified]. Its founder: *"If conflicts are your only gripe, project generation might be overkill"* [verified]. | **No.** The explicit-resolve idea is good. We can get most of it with an existing `xcodebuild` flag (§3c) and without a restructure. |
| **Bazel / Buck2** (with `rules_apple`, `rules_xcodeproj`) | Hermetic, cached builds and monorepo scale. Users are Airbnb, Lyft, Spotify, Square and Slack [verified, rules_xcodeproj README]. | Very high. You maintain a parallel build system and a generated Xcode project, and package dependencies are re-expressed in Bazel. | **No.** It's built for large organizations. Nothing in our pain profile calls for it. |
| **Kintsugi** (git merge driver for `.pbxproj`, Ruby gem) | Auto-resolves pbxproj merge conflicts. README goal: *"succeed 99.9% of the time"* [verified]. Active (v0.7.10, 2026-09-03). | Low to medium. It needs a Ruby gem on both Macs, plus one `.gitattributes` line and a driver install on each Mac. | **Not now.** Our pbxproj conflicts are rare, mostly version bumps by one release session at a time. Worth remembering if parallel efforts start adding targets often. It does nothing for `Package.resolved`. |
| **mergepbx** (Python merge script) | Same as Kintsugi. | Unmaintained: last push 2017-12-22 [verified]. | **No.** |
| **`*.pbxproj merge=union`** | A naive auto-merge. | Corrupts the project file at times (Fundrise's experience) [verified]. | **No.** |
| **Splitting into several projects in an `.xcworkspace`** | Spreads the project file out. A side effect: the repo package could be opened as a root package, which is P-781-2's option (C). | A project restructure, already declined at P-781-2. | **No.** One side note in §3. |
| **Committing `Package.resolved`** | Same dependency versions everywhere. | None. | **Keep doing it.** Apple: *"Commit this file in Git to ensure that everyone is using the same version of a package dependency"* [verified]. SwiftPM: the file pins versions only for the top-level project, and *"if the package is being resolved as a dependency from another package, its own `Package.resolved` file is ignored"* [verified]. That is the documented form of VX-781's E10 finding, and it is why the app needs its own belt. Libraries often ignore the file; apps commit it (the Swift Forums debate since 2018). |
| **`-disableAutomaticPackageResolution` / `-onlyUsePackageVersionsFromResolvedFile`** | Builds use exactly the lockfile and never re-resolve. Apple's CI guidance: *"If your CI pipeline uses the xcodebuild command directly, also pass the -disableAutomaticPackageResolution flag"* [verified]. On Xcode 27.1 both flags carry identical help text [verified, `xcodebuild -help`]. | Small, scripts only. On the belt, an out-of-date file fails the build (exit 74, VX-781 E8b) instead of healing it. There is no Xcode-app equivalent; it's command line only, per the Swift Forums thread. The defaults keys `IDEDisableAutomaticPackageResolution` and `IDEPackageOnlyUseVersionsFromResolvedFile` are undocumented. | **Optional complement**, see §3c. It isn't needed for P-781-3. |
| **`-clonedSourcePackagesDirPath` / `-packageCachePath`** | Share or redirect package clones, for CI caching. | Sharing one clone directory across parallel worktrees invites concurrent writers [inference]. | **No.** Per-worktree DerivedData stays the safe default. |

---

## 3. The originHash question

### (a) What it is and where it came from [verified]

- **Origin:** SwiftPM PR #6698 (merged 2023-08-08) introduced lockfile format **v3**, which is v2 plus `originHash`. It is written when the tools version is above 5.9, so Swift 5.10 and later.
- **Purpose, in the PR's words:** *"compute a hash of the source for the package.resolved file and use it to decide if dependency resolution is required."*
- **The code** is `computeResolvedFileOriginHash` in `Sources/Workspace/Workspace+Dependencies.swift`. It is byte-for-byte the same on `release/5.10` and on `main` as of today.
- **What it hashes:** sha256 of (each root package's manifest **text**) + (each root-level dependency's `locationString`).
- **What `locationString` is for a local package:** for a `.fileSystem` dependency it is `settings.path.pathString`, an **absolute path**.
  - From the command line, a root package has no root-level dependencies, because its dependencies live inside the manifest text. So the CLI lockfile's hash is just `sha256(Package.swift)`. That matches VX-781's T-1.
  - In an Xcode project, the project's package references, including the local `../..`, are the root-level dependencies. So the repo's absolute path goes into the hash. That matches VX-781's T-2, which reproduced two committed hashes from two checkout paths.
- **Xcode is closed source**, so "Xcode passes the local package as a root dependency" is not readable upstream. The T-2 reproduction proves it for Xcode 27.1.

### (b) When it causes a write [verified in SwiftPM source]

- **Default ("best effort") resolution:** a hash mismatch sends SwiftPM down the "resolve and update" path. That path only writes the file if the pins differ. `saveResolvedFile` compares the pin count and each pin's state, and returns early otherwise; its own comment says *"we want to avoid re-writing the resolved files unless absolutely necessary"*.
- **So today an originHash-only rewrite needs some other trigger.** Examples: the file was missing when a resolve ran (the Apple forum's branch-switch report), or an explicit resolve or update ran.
- **That agrees with VX-781's measurement:** Xcode 27.1 never rewrote the file during builds on a clean tree.
- **Lock-file mode** (`-onlyUsePackageVersionsFromResolvedFile`, `--force-resolved-versions`) **never reads the hash and never writes the file.** That path, `_resolveBasedOnResolvedVersionsFile`, has no `saveResolvedFile` call.

### (c) Is the path-dependence documented or reported upstream?

**No.** That is a finding, not a gap in the search.

- I searched swiftlang/swift-package-manager issues and PRs for `originHash` (7 hits), for "Package.resolved" with "worktree", and for "absolute path", plus the Swift Forums (one `originHash` thread) and the Apple Developer Forums.
- None of them reports that an Xcode project's local package puts its absolute path into the hash, or that the value differs per checkout or worktree.
- The one Apple Developer Forums answer on `originHash` (2024-06, a user, not an Apple engineer) describes it as *"little more than a SHA-256 checksum of your own Package.swift"* and says local packages contribute their manifest contents. For Xcode projects that is imprecise: the source shows a root-level dependency contributes its *location string*, not its contents.

### (d) What upstream is doing [verified, all open and unmerged as of 2026-11-05, all against `main`]

Nothing removes the path. The open work goes the other way:

- **Issue #7644** (2024-06, open): "V3 `originHash` should update more eagerly".
- **PR #10718** (2026-10-21), "Refresh the origin hash in Package.resolved when no pin changes". It writes the file whenever the stored hash differs, even with identical pins. Its own trade-off note says manifest-only changes "may now produce a `Package.resolved` diff".
  - **[inference, from the code path]** If this ships in a future Xcode, every resolve in every worktree except the one whose path wrote the committed hash would rewrite the workspace lockfile's `originHash`. That is the strict guard's worst case, made routine.
- **PR #10698** (2026-10-17), "Include evaluated root dependencies in the resolved file origin hash". It also appends **each root manifest's absolute path** to the hash.
  - **[inference]** That would make even the CLI `Package.resolved` path-dependent per worktree. Combined with #10718, `swift build` and `swift test` in any worktree would rewrite the root lockfile too.
- **PR #10753** (2026-10-30, with issue #10752), "Include local package manifests in the resolved file origin hash". It adds more inputs. A maintainer triggered CI on 2026-11-03.
- **Timing [inference]:** Xcode 27.1 ships Swift 6.4 [verified, `swift --version`]. Anything merged to `main` now would reach us only through a future Xcode, at a time nobody can predict.

### (e) Sanctioned workarounds

There is no upstream fix and no documented knob for the hash. The options:

1. **Compare pins, not bytes, in our own guard**: P-781-3 (b) or (c). This is entirely ours to choose, and it is the direct answer.
2. **Make builds unable to write the lockfile:** pass `-onlyUsePackageVersionsFromResolvedFile` (or `-disableAutomaticPackageResolution`, which Apple documents for CI) on every scripted `xcodebuild`.
   - Lock-file mode neither reads `originHash` nor writes the file [verified in source; VX-781 E5/E8 measured the same on Xcode 27.1].
   - That removes the most common writer in a session's world: build and test commands.
   - Remaining writers: the Xcode app itself and explicit `-resolvePackageDependencies`.
   - Trade-off: during a deliberate pin move (author-only since P-781-4), the scripted build fails until the lockfile is updated. That is arguably right.
   - Optional, your call. It isn't needed for P-781-3.
3. **Considered, not recommended:**
   - A git clean filter (`.gitattributes` `filter=`) that hides originHash-only diffs from `git status`. It needs per-Mac config, it is invisible behaviour, and it silently does nothing on a Mac that lacks the config.
   - Committing the lockfile without `originHash`. SwiftPM treats a missing hash as "resolve and update", and #10718 would write it back.
   - Restructuring to an `.xcworkspace` with the repo package as a root package. **[inference]** That might make the hash path-independent today, because a root package contributes manifest text rather than its path. PR #10698 would undo that, and the restructure was already declined at P-781-2.

---

## 4. P-781-3 recommendation

**Pick (b), versions-equal.** Today's no-argument `Tools/verify-pins` already computes exactly this: its `compare()` checks identity, version and revision. Only the extra byte-equality check (lines 190–193) makes it shape (a). Under (b), that check becomes a one-line NOTE with exit 0, and every pin-level difference stays exit 1. For example:

> `NOTE <file>: differs from HEAD only in bookkeeping (pins identical) — harmless; restore with git checkout -- before committing, never commit it.`

### Why (b) keeps the safety property

The guarantee is that a silently floated SQLCipher can never ship. Under (b) it rests on:

- **Revision equality.** A pin's `revision` is the exact git commit, so equal identity plus revision means the same source tree, including the binary target's checksum declared in that commit's manifest.
- **The belt.** An upgraded lockfile now fails closed or heals (VX-781 E8b).
- **PinBeltTests** on every `swift test`. It already compares pins, not bytes.
- **release.sh's clean-tree refusal** (`Tools/Release/release.sh`, the `git status --porcelain` check). It stays byte-strict at the one moment that ships.
- **VX-852's post-archive `verify-pins <DerivedData>`**, once wired. It is pins-based already.

None of these depend on the guard's no-argument mode being byte-strict.

### The friction each shape produces for parallel sessions

The scenarios:

- **F1, today:** a resolve writes the workspace lockfile in a worktree whose path differs from the one that committed it. Pins are identical; only `originHash` changes. Writers: `xcodebuild -resolvePackageDependencies`, the Xcode app opening the project, a resolve after the file briefly went missing (checkout, rebase or branch switch), and VX-770's still-unexplained second writer (`xcodebuild test` and simulator runs were never sampled).
- **F2, future:** SwiftPM #10718 ships in a future Xcode. Then **every** resolve in every non-matching worktree rewrites `originHash`. That means the first build in essentially every worktree.
- **F3, future:** #10698 together with #10718. The CLI root lockfile also rewrites per worktree, on `swift build` and `swift test`. Comment-only edits to `Package.swift` (VX-781 R2-4 made one) change its hash too.
- **F4, occasional:** the file is rewritten with equal pins but different spelling or format. Examples: a `.git` suffix or casing flip on a location, which real teams hit (Swift Forums 2024); pin order or whitespace from a newer toolchain; a format `version` bump.
- **F5, the real danger:** a version or revision changes, a pin is added or removed, or the file is missing.

| Scenario | (a) strict, any byte | (b) versions-equal | (c) normalize, all but originHash |
|---|---|---|---|
| F1 | **Fails.** The session must stop and `git checkout --`. The word "DRIFT" plus P-781-4's author-only rule may lead a careful session to halt and escalate to you [inference]. | Passes, with a NOTE. | Passes. |
| F2 | **Fails in every worktree after its first build. Constant.** This is the "constant problems" case. | Passes, with a NOTE. | Passes. |
| F3 | **Fails** after `swift test` in any worktree. | Passes, with a NOTE. | Passes until a future bookkeeping field appears beside `originHash`. Then (c) re-creates the false alarm, because it hard-codes today's field name. |
| F4 | **Fails** everywhere until someone commits a normalized file. | Passes, with a NOTE. | **Fails** everywhere until someone commits a normalized file. |
| F5 | Fails. | **Fails**, naming each pin. | Fails. |
| What it uniquely catches | Byte changes that don't change any built code. | (none) | Format or spelling changes that don't change any built code. |

**(b)'s residual cost, stated honestly:**

- A session can still **commit** a bookkeeping-only change, for example by staging everything. That puts noise in a PR diff. It is harmless, and the next writer flips it again.
- Mitigations: the NOTE's wording, the standing pathspec-adds rule, and review of the diff.
- It never touches what ships. The release road refuses a dirty tree regardless.

**Size of the change [inference]:** (b) is the smallest. It downgrades one existing `if` to a NOTE and updates its docstring line. (c) needs a normalizer, which is more code tied to today's file format.

---

## 5. Sources

**SwiftPM / Apple, primary:**

- https://github.com/swiftlang/swift-package-manager/blob/main/Sources/Workspace/Workspace%2BDependencies.swift: `computeResolvedFileOriginHash` (manifest text + root-dependency `locationString`), the best-effort hash check, lock-file mode (no hash, no write), and `PackageDependency.locationString` (absolute path for `.fileSystem`).
- https://github.com/swiftlang/swift-package-manager/blob/release/5.10/Sources/Workspace/Workspace%2BDependencies.swift: the same function, unchanged since 5.10.
- https://github.com/swiftlang/swift-package-manager/blob/main/Sources/Workspace/Workspace%2BResolvedPackages.swift: `saveResolvedFile` writes only when pins differ ("avoid re-writing the resolved files unless absolutely necessary").
- https://github.com/swiftlang/swift-package-manager/pull/6698: introduced v3 and `originHash` (merged 2023-08-08).
- https://github.com/swiftlang/swift-package-manager/issues/7644: "V3 `originHash` should update more eagerly" (open, 2024).
- https://github.com/swiftlang/swift-package-manager/pull/10718: refresh `originHash` when no pin changes (open, 2026-10-21; it states the diff trade-off).
- https://github.com/swiftlang/swift-package-manager/pull/10698: adds root-manifest absolute paths and evaluated dependencies to the hash (open, 2026-10-17).
- https://github.com/swiftlang/swift-package-manager/pull/10753 and https://github.com/swiftlang/swift-package-manager/issues/10752: add local package manifests to the hash (open, 2026-10-30).
- https://github.com/swiftlang/swift-package-manager/issues/10586: the hash misses evaluated conditional dependencies (open).
- https://github.com/swiftlang/swift-package-manager/blob/main/Sources/PackageManagerDocs/Documentation.docc/ResolvingPackageVersions.md: Package.resolved pins only the top-level project, and a dependency's own lockfile is ignored.
- https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app: "Commit this file in Git to ensure that everyone is using the same version" (read through the page's JSON).
- https://developer.apple.com/documentation/xcode/building-swift-packages-or-apps-that-use-them-in-continuous-integration-workflows: commit Package.resolved; pass `-disableAutomaticPackageResolution` in CI.
- https://developer.apple.com/documentation/xcode-release-notes/xcode-16-release-notes: buildable folders "minimize project file changes, and avoid version control conflicts".
- `xcodebuild -help` on Xcode 27.1 (27A9275), run locally: the package-resolution flags and their help text.

**Forums:**

- https://forums.swift.org/t/package-resolved-versions/86664: v3 = v2 + `originHash`, PR #6698, written for tools versions above 5.9.
- https://developer.apple.com/forums/thread/755995: "What is the purpose of `originHash`" (2024; a user's source reading; no Apple answer).
- https://developer.apple.com/forums/thread/756965: Package.resolved rewritten on branch switch while Xcode is open (Xcode 15.3/15.4); the DTS reply; "appears to be resolved in Xcode 16".
- https://developer.apple.com/forums/thread/699342: an Apple Developer Tools Engineer on committing the lockfile and the CI flag.
- https://forums.swift.org/t/xcode-automatically-updating-package-resolved/41900: Xcode rewrites (2020–2024), `.git`-suffix flips, no Xcode-app equivalent of the CLI flag.
- https://forums.swift.org/t/package-resolved-should-go-in-the-gitignore/14699: the commit-or-ignore debate (2018 onward); apps commit it.

**The blog-post class and the tools:**

- https://careersatdoordash.com/blog/how-doordash-uses-xcodegen-to-eliminate-project-merge-conflicts/: DoorDash and XcodeGen (2023-05-31; read through the Wayback snapshot `web.archive.org/web/20250905224406/…`).
- https://medium.com/lightricks-tech-blog/kintsugi-automatically-solving-git-conflicts-in-xcode-project-files-6b9f955cef5c: Lightricks' Kintsugi post (2022; not opened directly, 403).
- https://medium.com/fundrise-engineering/how-fundrise-freed-itself-from-xcode-project-purgatory-8378810277f9: Fundrise, `merge=union` then Tuist (2022-09-12; read through Wayback, 2023-01-06 snapshot).
- https://medium.com/airbnb-engineering/migrating-our-ios-build-system-from-buck-to-bazel-ddd6f3f25aa3: Airbnb, Buck to Bazel (2024-02-01; read through Wayback).
- https://tuist.dev/blog/2025/03/21/git-conflicts: Tuist, "Strategies to avoid merge conflicts in Xcode Projects" (read from its source, `tuist/tuist` `server/priv/marketing/blog/2025/03/21/git-conflicts.md`): "overkill" if conflicts are the only gripe; buildable folders are low-effort and high-return.
- https://github.com/tuist/tuist/blob/main/server/priv/docs/en/guides/features/projects/dependencies.md: Tuist's explicit `tuist install` resolution.
- https://github.com/tuist/tuist/blob/main/server/priv/docs/en/guides/features/projects/best-practices.md: Tuist still uses `Package.resolved`, with `--force-resolved-versions` on CI.
- https://github.com/yonaskolb/XcodeGen: README ("remove your .xcodeproj from git… no more merge conflicts"); 2.46.0 (2026-07-16).
- https://github.com/Lightricks/Kintsugi: a merge driver for `.pbxproj`, "99.9%" goal, v0.7.10 (2026-09-03).
- https://github.com/simonwagner/mergepbx: last push 2017-12-22.
- https://github.com/MobileNativeFoundation/rules_xcodeproj: Bazel's Xcode project generator; its adopters are large organizations.

**This repo (read-only):**

- `notes/plans/fixes/vx-781-lockfile-pins.md` (FOR A LATER READER, T-1/T-2/T-3, E5/E8/E8b, the PROVISIONAL ledger)
- `Tools/verify-pins` (lines 190–193 are the byte check)
- `Tools/Release/release.sh` (the clean-tree refusal)
- `Tests/VariorumCoreTests/PinBeltTests.swift`
- `App/Variorum/Variorum.xcodeproj/project.pbxproj` (objectVersion 77, 8 synchronized roots)
- `git log --since=2026-09-01` over the project file and the two lockfiles
