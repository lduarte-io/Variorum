# VX-999 — the release scripts read the signing profile from outside the repo

**Branch `vx-999-release-profile-path`, PR #5. Not merged: the merging session owns closeout.** Not done here: a real
archive, export, notarization or release (the author's attended act). Also not done: R1-5, the release.sh preflight
check, which was considered and left as is.

## FOR A LATER READER

**The mechanism.** `Tools/Release/archive-and-export.sh` and `verify-export.sh` read the pinned Developer ID
provisioning profile from `Tools/Release/Variorum_Developer_ID.provisionprofile`, beside the scripts. vx-988 had recorded
the binary as a kept load-bearing value. That KEEP was superseded at the public flip: the file was left out of the
published tree and its history. So on the public clone the path is absent, and the next release would stop at its first
profile check:
- archive-and-export's `security cms -D` refuses with "does not decode" (exit 4; release.sh exit 5);
- verify-export's byte-identical check FAILs.

**The fix, one pointer per piece.**
- `Tools/Release/profile-path.sh` (new, sourced by both scripts) is the one definition of the place:
  `~/.variorum/release/Variorum_Developer_ID.provisionprofile`. `VARIORUM_RELEASE_PROFILE` overrides it, for the test
  only. It also holds the missing-file sentence: where the file must be, that it is never committed, and where to copy
  it from ("Xcode's installed profiles, or … the private archive clone"). The sentence names no UUID.
- `archive-and-export.sh` (`6b9509fdf`): step 1 refuses with the sentence (exit 4) when the file is missing. It then
  decodes, compares and installs exactly as before. Its summary line names the place it read from.
- `verify-export.sh` (`6b9509fdf`, then R1-1 `e89aea155`): when the file is missing, section E's byte-identical check is
  one FAIL line carrying the sentence, and every other check still runs (exit 1). Exit 2 means usage only.
- `ExportOptions.plist`: the comment says where the file lives. `.gitignore` (R1-3 `6947ca9e0`) keeps every
  `*.provisionprofile` and `*.mobileprovision` out of the whole tree. Nothing needs one: every target signs Automatic.
- What is verified is unchanged:
  - the UUID, certificate, app-id and expiry agreement with `ExportOptions.plist` and the Keychain;
  - the installed copy is compared, and the script refuses rather than overwrites;
  - the embedded profile is byte-identical, and its UUID matches ExportOptions.

  The trust anchor is the committed UUID and certificate SHA-1 in `ExportOptions.plist`.
- Docs (`305ba3ef6`, reworded at R1-2): dated pointers sit beside the old lines in the 13r plan's U1 file list,
  vx-988's follow-up 2 and open item 6, and vx-996's open item 4 (closed). The original sentences stay.

**Rulings.** None new. The public record cites no ruling id for the trim, so the notes say "superseded at the public
flip" and cite none (the orchestrator's R1-2 disposition).

**Evidence.** The pin is `Tools/test-release-profile`. It runs both scripts in a throwaway tree with an isolated HOME and
stub tools, with no Xcode, signing, keychain or stage. A decoy sits at the old in-repo path.
- First build: 1 held, 12 FAILED on main's logic (`510461db8`, re-run by the round-1 reviewer); ALL 13 CASES HELD after.
- Each round-1 addition was red on the previous tip: R1-1 12/2, R1-3 14/2, R1-4 14/2.
- Final suite: **ALL 16 CASES HELD**.
- Against main's scripts the final suite gives 2 held, 14 FAILED. The two that hold are:
  - the bare rc 4 on a missing profile, which main reaches for the wrong reason;
  - "every other section still runs", which main also does. That case guards against the fix's own early stop.
- `bash -n` and `zsh -n` are clean on every touched script. shellcheck is not installed, so it was not run.
- The reviewer checked with `cmp` alone, printing nothing: on the Pro the outside copy is byte-identical to the private
  archive's old versioned copy and to Xcode's installed copy.

**Only an attended release can prove**, so the first one watches for:
- the real `security cms -D` decode from the outside place, with `archive-and-export.sh`'s line
  "signing inputs agree … read from ~/.variorum/release/…";
- step 2 saying "profile already installed";
- `verify.txt`, `verify-stapled.txt` and `verify-dmg.txt` each carrying "PASS  embedded profile is BYTE-IDENTICAL to the
  pinned profile …".

**Open items.**
1. The Air: whether it holds a copy at the outside place is unchecked. A release run there would refuse with the
   sentence.
2. R1-5, considered and left: release.sh's preflight does not check the profile, so a missing file surfaces as exit 5,
   seconds after the preflight, through archive-and-export's own refusal.
3. A forced `git add -f` still bypasses `.gitignore`, and the pre-push guard reads no binary (her vx-996 F7 ruling).

---

## LIVE STATUS

| Piece | State | Commit |
|---|---|---|
| pin (red on main's logic: 1 held / 12 FAILED) | DONE | `510461db8` |
| fix: the outside place, the shared definition, both scripts, ExportOptions comment, `.gitignore` | DONE (13/13) | `6b9509fdf` |
| docs: the 13r plan, vx-988, vx-996 corrections | DONE | `305ba3ef6` |
| cold review round 1 (Opus) | 0 BLOCKER · 0 MAJOR · 2 MINOR · 4 NIT — `vx-999-ladder-round1.md`, the only round | — |
| R1-1 verify-export: a FAIL line, every check runs | DONE (14/14) | `e89aea155` |
| R1-3 repo-wide ignore of both profile kinds | DONE (16/16) | `6947ca9e0` |
| R1-4 the sentence says where to copy from | DONE (16/16) | `7055fe84e` |
| R1-2 this record, the round-1 file, the notes reworded | DONE | this commit |

## Round 1 dispositions (the orchestrator's)

| Finding | Disposition | Commit | Pin |
|---|---|---|---|
| R1-1 [MINOR] verify-export's early stop broke "every check runs" | FIXED: section E's FAIL line carries the sentence; the stop and the dead guard removed; exit 2 = usage only | `e89aea155` | case 12 flipped + a new "every other section still runs" case (12/2 red on the prior tip) |
| R1-2 [MINOR] notes mark a ruled KEEP superseded without a ruling, and no record file | FIXED (text): this record; the notes say "superseded at the public flip: the file was left out of the published tree" and point here. No ruling id is cited, because none is verifiable in the public repo | this commit | — (text) |
| R1-3 [NIT] the ignore line covers one folder and one extension | FIXED: repo-wide `*.provisionprofile` + `*.mobileprovision` | `6947ca9e0` | two check-ignore cases (14/2 red on the prior rule) |
| R1-4 [NIT] the refusal says where, not where to get it | FIXED: "…; copy it from Xcode's installed profiles, or from the private archive clone (VX-999)", with no UUID and no path embedding one | `7055fe84e` | the sentence check requires the clause and no UUID-shaped text (14/2 red) |
| R1-5 [NIT] a missing profile reads as exit 5, not a preflight refusal | CONSIDERED, left as is: it costs seconds (step 1 precedes the archive), the exit-5 class for signing inputs is older than this branch, and a third consumer was out of this unit's scope | — | — |
| R1-6 [NIT] neighbouring lines still read "versioned" | LEFT VERBATIM: records are kept as written; the superseded note sits two bullets away | — | — |
