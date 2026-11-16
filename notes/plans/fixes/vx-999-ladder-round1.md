# VX-999 — ladder round 1 (cold review, Opus): findings

The review covers branch `vx-999-release-profile-path` against `origin/main` (PR #5): commits `510461db8` (pin),
`6b9509fdf` (fix) and `305ba3ef6` (docs). It ran `notes/REVIEW_PROMPT.md` verbatim. Nothing was built, archived, signed
or released, and no profile's contents were printed.

**Scope check (asked first).** The diff stays outside Fable's mandatory class. It touches no editor seam, nothing under
`Sources/VariorumCore/Sync/`, no custody or keychain code in the Castle sense (`Protection/`, `ProtectionKeychain`), and
no default's meaning. It is release tooling only. It touches the Keychain in one place, the codesigning-identity
lookup (`security find-identity`), and that code is unchanged. The keychain-access-groups checks in `verify-export.sh`
sections D and E are also unchanged.

**Tally:** 0 BLOCKER · 0 MAJOR · 2 MINOR · 4 NIT.

---

## Findings

**[MINOR] R1-1 · `Tools/Release/verify-export.sh:63` (with `:27`, `:28`, `:179`) · When the pinned profile is missing,
the whole drill now stops. Only ONE of its checks needs the profile, and the script is built so that every check runs.**
- What's wrong:
  - The script's own design line (`:28`) says "deliberately not -e: every check runs and reports; the verdict counts".
  - The new stop at `:63` exits 2 before any check, which goes against that line.
  - The pinned profile is read in one place only: section E's byte-identical `cmp` (`:179–183`).
  - Exit 2 now means two things: "usage error, or the pinned profile is missing" (`:27`).
  - The `[ -f "$PROFILE_PINNED" ] &&` guard at `:179` is now dead code.
- Evidence (the traced degradation):
  1. **Run standalone on a Mac without the copy** (the documented re-runnable use: any export, or another build via
     `--compare-with`), the script now reports none of its ~50 checks: seal, chain, entitlements, keychain groups,
     Sparkle road, Gatekeeper.
     - On main it ran all of them and FAILed one line.
     - The pin's case `verify-export: a missing profile stops it (rc 2) … before any check runs` asserts this behaviour
       on purpose.
  2. **Inside the pipeline, the stop's sentence is never shown.** Its callers print only grep-filtered lines:
     - `release.sh:222` greps `^(FAIL|VERDICT)|Gatekeeper|stapler`;
     - `release.sh:271` and `archive-and-export.sh:212` grep `^(PASS|FAIL|VERDICT)`.

     None of these patterns matches a `REFUSED:` line, so the author would see only "the STAPLED app failed
     verify-export.sh (<file>)". This is reachable only if the file disappears after `archive-and-export.sh`'s step 1
     checked it (archive, export and notarization run in between), so it is unlikely. But a FAIL line would have been
     shown.
- Proposed fix (the orchestrator's arbitration; a design call, not a bug-class finding, so no red-on-old pin is owed):
  - Drop the early exit.
  - In section E, when `release_profile_missing` is true, record `bad "<the same one sentence>"` instead of the cmp. The
    script then exits 1, every other check still reports, and both greps surface the sentence.
  - Exit 2 goes back to meaning usage only, and the `:179` guard goes.
  - The pin's case 12 flips to: rc 1, exactly one `FAIL` line carrying the sentence, and other `PASS`/`FAIL` lines
    present.

  If the stop is kept on purpose, the record should say why the "every check runs" rule does not apply here.

**[MINOR] R1-2 · `notes/plans/fixes/vx-988-oss-fix-pass.md:57–60` (also `:150–151`; `notes/plans/phase-13r-distribution.md:1421–1425`;
`notes/plans/fixes/vx-996-pre-push-guard.md:89–93`) · The notes mark an author-ruled KEEP as superseded without naming
the ruling that superseded it, and there is no repo record file for them to point at.**
- What's wrong: vx-988's follow-up 2 is headed "load-bearing values — KEEP, ruled", and it was her ruling. The new note
  explains the supersession only as a fact of the flip: "it was left out of the public repo and its history at the
  flip, so it did not stay".
  - A later reader checking the author-only line (CLAUDE.md: never change beyond recorded rulings) cannot tell whether a
    session overrode her KEEP, or whether she ruled again.
  - She did rule again: R-oss-50 (the VX-938 ship-vs-trim call) TRIMS the profile. That id is held on the private
    ledger, and the public repo does not cite it anywhere (`grep -rn R-oss-50 notes/` finds nothing).
  - All three notes point at "VX-999", a ticket. CLAUDE.md's build workflow says a fix that runs a ladder lands
    `notes/plans/fixes/vx-NNN-<slug>.md`, opening with FOR A LATER READER. No VX-999 record file exists on the branch
    yet, so a later reader following the pointer finds no repo record.
- Evidence: the three diffs in `305ba3ef6`. vx-988 itself says its record "carries ruling ids", and every other item in
  it is keyed R-oss-N.
- Proposed fix:
  - Cite the ruling in each note, e.g. "superseded by R-oss-50 (VX-938: the profile trims at the flip); VX-999 moved the
    scripts' read outside the repo".
  - Land `notes/plans/fixes/vx-999-<slug>.md` (FOR A LATER READER; this round's dispositions) and point the notes at it.

  This is text only, and the orchestrator's to place. If the record file is already planned for closeout, the second
  half is just a reminder.

**[NIT] R1-3 · `.gitignore:57` · The ignore pattern covers one folder and one extension.**
- The pre-push guard reads no binary anywhere in the tree (vx-996 F7, her ruling). A profile committed anywhere else
  would therefore publish unscanned, with a clean verdict.
- iOS profiles use `.mobileprovision`, and a development or ad hoc one carries device UDIDs, the kind of identifier the
  sweep removed.
- Nothing in the repo needs to commit a profile: every target is `CODE_SIGN_STYLE = Automatic`, and no profile is
  tracked or in history.
- Proposed: a repo-wide `*.provisionprofile` plus `*.mobileprovision`. This goes beyond the ticket's stated scope, so it
  is optional.

**[NIT] R1-4 · `Tools/Release/profile-path.sh:24` · The refusal names where the file must go, but not where to get it.**
- On any Mac that has run U1's road before, `archive-and-export.sh` step 2 has already installed a byte-identical copy
  at `~/Library/Developer/Xcode/UserData/Provisioning Profiles/<the UUID ExportOptions names>.provisionprofile`. On this
  Pro it is `cmp`-identical to the pinned copy.
- release.sh's VX-779 precedent is "the sentence carries its own remedy".
- Proposed: `archive-and-export.sh` could read `O_UUID` before the profile, and the refusal could then add "copy it from
  <installed path>" when that file exists, else "download 'Variorum Developer ID' from the developer portal".
- Wording only, optional.

**[NIT] R1-5 · `Tools/Release/release.sh:90–168` (preflight) and `:178` · A missing profile reads as a build failure, not
a preflight refusal.**
- The missing-profile refusal surfaces as release.sh exit 5 ("archive/export failed"), after the preflight's network and
  notary probes. It is not exit 3 ("preflight refused").
- The cost is seconds, because step 1 comes before the archive. The class is older than this branch: every
  signing-input disagreement maps to exit 5.
- Optional: release.sh sources `profile-path.sh` in the preflight and refuses there, as a third consumer of the "one
  definition".

**[NIT] R1-6 · `notes/plans/phase-13r-distribution.md:1404` and `:1432`; `notes/plans/fixes/vx-996-pre-push-guard.md:137` ·
A few lines next to the new notes still read the old way.**
- The 13r U1 record still says "the versioned file's UUID" and "byte-identical to the versioned copy". These sit two
  bullets from the one superseded note (`:1421`), and both were true when written.
- vx-996's round-2 dispositions table still reads "RECORDED for the release session (open item 4)", while open item 4
  now reads CLOSED.
- Leaving them is defensible, since records are kept verbatim. A two-word "(see VX-999)" on the table row would stop a
  table-first reader from reading the item as still open.

---

## Clean bill

- **The pin is red on main.** I re-ran `Tools/test-release-profile` myself against main's `Tools/Release` + `.gitignore`
  (`git archive origin/main` into a scratch git tree): **1 held, 12 FAILED**, exactly as the pin's commit claims. On the
  branch: **ALL 13 CASES HELD**, about 2 s, no stage needed.
- **Each case tells old from new for the right reason.**
  - The "installed copy differs" case needs the word "differs", which main's refusal (for the wrong reason, a UUID
    mismatch) lacks.
  - "One sentence" counts lines.
  - The decoy at the old in-repo path carries a UUID nothing names, and bytes no case embeds.
  - The `.gitignore` case runs `git check-ignore` with the global and system config and XDG neutralized, so a personal
    excludes file cannot make it pass.
- **The pin is isolated.**
  - Stubs on PATH for `security`, `xcodebuild`, `codesign`, `spctl`, `pgrep`, `git` and `xcode-select`. `HOME` and
    `TMPDIR` are isolated, `VARIORUM_RELEASE_PROFILE` is unset, and the fixtures are plain plists.
  - The furthest any run reaches is the stub's archive refusal (rc 5). `lsregister` and a real keychain are never
    reached, and no real profile is read.
- **No other reader of the old path.** I searched the scripts, the Swift tests (`ReleasePinsWiringTests` parses
  release.sh's command lines only; release.sh is unchanged), the Xcode project (all targets `CODE_SIGN_STYLE = Automatic`,
  no profile reference) and the CI workflows. `git log --all -- '*provisionprofile'` is empty, and nothing named
  `*.provisionprofile` or `*.mobileprovision` is tracked.
- **What is verified is unchanged.**
  - Step 1: the method, the UUID against ExportOptions, the app-id, expiry, the certificate inside the profile, and the
    Keychain identity.
  - Step 2: the installed copy is `cmp`'d and the script refuses rather than overwrites; install happens only when
    absent.
  - Section E: the byte-identical check, and the embedded UUID against ExportOptions.
  - The trust anchor moved from a committed file to the committed UUID and certificate SHA-1 in `ExportOptions.plist`. A
    substituted profile with any other UUID or certificate still refuses.
- **Shell mechanics.**
  - Sourced under `set -euo pipefail`. `if VAR="$(fn)"; then` correctly suspends `-e`.
  - `${VARIORUM_RELEASE_PROFILE:-…}` is safe under `-u` and treats an empty value as unset.
  - Every new path expansion is quoted (a HOME with spaces works). No `cd` in the main shell, so a relative override
    resolves.
  - Nothing beyond bash 3.2. `bash -n` is clean on all four scripts. `plutil -lint` passes on `ExportOptions.plist`
    (the new comment holds no `--`).
- **The override seam is harmless.** A stray `VARIORUM_RELEASE_PROFILE` can only point at a file that still has to pass
  every agreement check, and the summary line now names the path it read. It follows release.sh's
  `VARIORUM_RELEASES_DIR` precedent.
- **`.gitignore`.** `git check-ignore -v --no-index` matches line 57, case-insensitively too (`core.ignorecase=true`).
  vx-996's added sentence about `git add -f` is accurate.
- **Environment, read-only.** Checked by `cmp` alone, nothing printed. On this Pro, `~/.variorum/release/` holds the
  profile (mode 0600). It is byte-identical to the private archive's old versioned copy and to Xcode's installed copy
  under the UUID ExportOptions names. The next release here passes step 1 as before. A Mac without the copy refuses
  with the sentence, which is the intended behaviour.
- **The ticket's four asks are met:** the outside place, a plain refusal, the in-repo path ignored, and the
  byte-identical check kept.
- **Canon and public copy.**
  - Canon is correctly untouched: no canon line names the profile.
  - No identifier is added. The profile-UUID and certificate lines in `ExportOptions.plist` are unchanged, so no added
    line carries a value the guard's private list might name.
  - The ticket id in a tool refusal follows release.sh's `(VX-779)` precedent; the release-notes rule does not apply.
