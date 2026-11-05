# VX-779 — the stale MARKETING_VERSION pair (plain Release builds read 0.10.4)

## FOR A LATER READER

**The mechanism, as settled.** The house rule (R-13r-6's adjudicated reading, `notes/plans/phase-13r-distribution.md:934`) is that the repo's MARKETING_VERSION bumps with each release, the bump commit first in the release run. Fourteen bump commits did exactly that, each touching only the Mac app pair (Debug + Release); the last was `1a0082ea9` (0.10.4). The bump was then skipped for five releases (0.10.5 → 1.0.1), which shipped correct versions anyway because `release.sh` passes `MARKETING_VERSION=<--version>` as an xcodebuild command-line override (`archive-and-export.sh:66`) and never writes the project. So a plain Release build from main read 0.10.4 against the installed 1.0.1. The other ten configurations' "1.0" is the Xcode template default from target creation, never read (test bundles resolve `Bundle.main` to the host; the mobile app versions on the VM board). The build number is the commit count by design (R-13r-6/7, `StampBuildNumber.sh`), deliberately not pinned to a release.

**The fix, as built** (branch `vx-779-marketing-version`, PR #219):
- The Mac pair → 1.0.1 (the latest released version), commit `443ed03d2`.
- `Tools/Release/version-guard.sh` (commit `f8a593693`): headless (plutil → jq), requires every configuration of the Variorum target to carry the expected version; default expectation = the newest `ReleaseNotes-<v>.md`; sourceable as `mac_marketing_version_mismatch`.
- `release.sh` preflight (commit `abb495fa0`): release mode refuses unless the project already carries `--version` — re-enforcing bump-first. **Consequence for every future release: the bump commit (pair → the new version, with that release's notes file) must land before `release.sh` runs.** Walk mode unchanged.
- Three VariorumTests pins reshaped (the pre-1.0 line pins the 13r ladder's N3 predicted would go red at 1.0; nobody folded them at 1.0): `theMarketingVersionIsTheFriendsBetasLine` → `theMarketingVersionIsTheLaunchedLine` (major ≥ 1); the stamp-phase test finds the pair by bundle id; `SupportDraftTests`' prefix check → major ≥ 1.

**Pin.** `version-guard.sh` exits 1 on origin/main's tree ("Debug reads '0.10.4', Release reads '0.10.4'") and 0 on the branch; `xcodebuild -showBuildSettings` reads 0.10.4 before, 1.0.1 after. Red-on-old verified by implementer and reviewer independently.

**Her rulings.** "what is VX-779? we should fix this" (2026-11-04, the handoff walkthrough). The release.sh preflight change was flagged to her as droppable; not objected.

**Open items.** The three reshaped test pins still need one stage-held run (`-only-testing:VariorumTests/VersionSchemeTests -only-testing:VariorumTests/SupportDraftTests`) before merge — owed in the VX-837 release window. VX-837's checklist carries the 1.1 bump step.

---

## Ladder round 1 (Opus implementer · Opus cold reviewer · orchestrator arbitrating — same-model)

No BLOCKER, no MAJOR.

| Finding | Summary | Disposition |
|---|---|---|
| MINOR-1 | The reshaped pins catch this instance (pre-1.0 line), not the class (project lagging the newest release); only the guard script catches the class and nothing runs it; the comment at VersionSchemeTests.swift:85-86 overstates it as enforcement. | ACCEPTED, fix (a): add one VersionSchemeTests test — the host's `CFBundleShortVersionString` equals the numerically newest `ReleaseNotes-<v>.md` (read via `#filePath` as `WhatsNewTests.noReleaseNotesFileCarriesProcessText` does). Legitimate states never red: the notes file and the bump land in one commit by rule. Reword the :85-86 comment to match. |
| NIT-1 | release.sh's refusal appends the "set MARKETING_VERSION…" fix-it clause even when the guard's reason was a read failure (missing jq, plutil failure, not-exactly-one target) — advice that cures none of those. | ACCEPTED: distinct read-failure path — the reason text carries its own remedy; still fails closed. |
| NIT-2 | VX-837's run checklist lacked the now-required 1.1 bump step. | DONE (orchestrator): VX-837's description now leads the run with the bump commit. |
| NIT-3 | No record file despite a ladder round. | DONE: this file. |

Round 1's clean bill covered: the pbxproj diff is exactly the pair; the bump-history story verified in git; spec alignment (R-13r-6/7, the vx-488 M4 fold); the guard executed red-on-old on main's tree and under release.sh's real shell conditions; the pins replayed over 16 configurations; no other pre-1.0 pin in App/Tools/Sources/Tests.

Round 2: the fixes applied for MINOR-1(a) and NIT-1, re-verified (see the closing note below when it lands).
