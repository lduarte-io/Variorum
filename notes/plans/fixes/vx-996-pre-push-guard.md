# VX-996 — the pre-push guard (record)

**STATUS: ladder round 2 (the final round) fixes DONE — the orchestrator's line-by-line check next.** Branch
`vx-996-pre-push-guard`, PR #4, worktree `~/dev/variorum-vx-996`. Not merged; not activated in any real clone.

## FOR A LATER READER

**The mechanism.** Since the 2026-11-11 flip every push publishes into public history, and nothing mechanical stopped a
session from pushing a swept identifier. The guard is a pre-push hook. Git hands it the remote's name and URL and one line
per pushed ref. It reads what the push would PUBLISH and nothing else:
- the lines each outgoing commit adds (a merge: lines new against all its parents);
- each message, author and committer identity;
- the paths of added, renamed or copied files;
- the pushed ref names, and every tag in an annotated tag's chain (message and tagger).

"Outgoing" is `git rev-list <pushed shas> --not <the target's own refs> <old remote shas>`. A remote-tracking ref records
what was fetched, so it speaks only for the fetch URL:
- a named remote excludes its own refs only when it pushes where it fetches;
- a push by URL excludes the refs of remotes whose FETCH URL is that URL;
- anything else excludes only the old ids.

A ref whose object is not a commit (a blob, a tree, directly or through tags) is refused.

What it reads never depends on attributes, diff/log settings, a `-c` on the push or replace refs. On top of that, a
read-back check refuses unless both logs read exactly the commits `git rev-list` names. True binaries (a NUL in a blob's
first 8000 bytes, git's own rule) are not read.

gitleaks's default rules and the private token list (`~/.variorum/private-tokens.txt`, outside the repo) both scan the
same items. A match refuses, naming the commit, place and class, never the value; printed text escapes every control byte.
A missing list, missing gitleaks, malformed entry, failing scanner or incomplete read refuses too.

**The fix as built.**
- `Tools/githooks/prepush_guard.py`, the scanner:
  - `pinned_env`/`GIT_PINS`: the settings, `GIT_CONFIG_PARAMETERS` dropped, replace objects off.
  - `published_exclusion` (with `fetch_urls`/`push_urls`) and `outgoing_revs`: the range and the non-commit refusal.
  - `collect_items`: nonce-marked records and fields, the tag-chain walk, the read-back check.
  - `parse_patch` and `recover_binary_shown`: the attribute-free binary rule.
  - `gitleaks_findings`: one `gitleaks stdin` from an empty private dir.
  - `identity_split`: re-author advice for the clone's own address only.
  - `printable`: control-byte escaping.
- `Tools/githooks/pre-push`: the shim into python.
- `Tools/githooks/gitleaks.toml`: the default rules plus the three ruled-public values.
- `Tools/githooks/private-tokens.example`: the format, case-keeping class shapes and literal templates, no values.
- `Tools/install-githooks`: owns the fixed shim `<git-common-dir>/variorum-hooks/pre-push`. That shim runs the MAIN
  worktree's guard and refuses when it is missing. `--check` reports status.
- `Tools/test-githooks`: 69 cases, a throwaway remote, no stage. Two test seams exist, and each can only make the guard
  refuse.
- One CLAUDE.md Environment line.

**Rulings (the author's, relayed by the orchestrator).**
- **F5 (2026-11-15):** commits must not carry her personal email. The repo-local commit email is her GitHub noreply
  address on both Macs, and existing history is LEFT ALONE: no rewrite of main or of pushed branch commits. The example's
  `public-identity` entry stays, judging outgoing commits only.
- **F7 (2026-11-15), her answer:** binaries stay unscanned. Her words: "i don't think we need to scan binary files like
  screenshots necessarily? i'm open to changing my mind".
- **The WalkKit rider:** her word, "we might as well fix it going forward".
- **"`--no-verify` is the author's call only"** (the guard's sentence and CLAUDE.md's line) is a session rule DERIVED
  from the ticket's "check-free by habit rather than by ritual". It is not her words. The closeout's AppSpecRecord entry
  should record that basis.

**Evidence.**
- First build: the stub gave 14 held / 17 FAILED; the scanner gave 31/31.
- Round 1's pins on the first build's tip gave 38 held / 17 FAILED (the reviewer's independent re-run: 39 / 18); the
  round ended at 57/57.
- Round 2's pins (`1d6f0d34f`) on round 1's tip gave **57 held / 12 FAILED**. The round ends at **ALL 69 CASES HELD**.
- With the encoding pin removed, the UTF-16 push still refuses, through the read-back check alone ("it read 0 and 0 of 1").
- On the Pro, one to five commits take about 0.2 s, and the whole history (12,385 commits) takes 76 s.
- The starter list over that whole history matches:
  - the three old WalkKit home-path lines (fixed going forward by the rider);
  - the stub commit's renamed test fixture (gitleaks);
  - a fictional home path in round 2's findings file, a real-shaped name, so the shape is working;
  - the identities of four commits history already holds.
- Round 1's evidence line ("2,728 real commits … 13 s … only real matches") was wrong in two ways. That range was
  `HEAD~300..HEAD` and not the history. And the case-blind dashed shape also matched a design proposal's heading slug at
  HEAD and a deleted spike README in history (R2-3 fixed it).

**Open items.**
1. **The real token list must be filled from the private ledger by the author**, on each Mac, and its `!starter` line
   deleted. The Pro's list is the starter (class shapes only), refreshed to this round's example.
2. **Activation:** run `Tools/install-githooks` once per clone on each Mac after merge.
3. **R2-4, a question for the author:** the ruling covers her own address; other contributors' commits are unruled. As
   built, a contributor's non-noreply identity still refuses (the class), but the refusal says only that it is not this
   clone's own and whether it publishes is her call, with no re-author advice. Should such a commit be kept, re-authored,
   or merged on GitHub only? The merging session logs it in `notes/QUESTIONS.md`.
4. **For whichever release session restores the provisioning profile** (the reviewer's observation). The release
   scripts (`Tools/Release/archive-and-export.sh`, `verify-export.sh`) expect
   `Tools/Release/Variorum_Developer_ID.provisionprofile`. vx-988 ruled it KEEP, yet it is in neither the tip nor this
   repo's history. Restored, it would publish the team id, signing cert and profile UUID inside a true binary the guard
   never reads, with a clean verdict. That session must check it by hand.
5. **A recorded trade:** gitleaks rules keyed on a file's own name (a `.p12` file) do not fire, because stdin carries no
   path. The private list's path scope is the road for names.
6. **Process, outside this branch:**
   - VX-996 has no Linear project; it needs one or an explicit Parked reason (the orchestrator's).
   - The AppSpecRecord entry at closeout belongs to the merging session.

---

## LIVE STATUS

| Piece | State | Commit |
|---|---|---|
| first build: pin (stub), scanner, CLAUDE.md line, docstring | DONE — 14 held / 17 FAILED on the stub; 31/31 | `3e728e581` `7900952ff` `a21eac1f8` `034019b79` |
| round 1 (cold review, Opus) | DONE — 5 MAJOR, 3 MINOR, 5 NIT; `vx-996-ladder-round1.md` | `db377d12c` |
| round-1 pins and fixes (F1–F6, N1–N5, rider) | DONE — 38/17 red → 57/57 | `265938dd9` … `fdb066865` |
| round 2 (cold review, Opus — the final round) | DONE — 4 MINOR, 3 NIT, no MAJOR; every round-1 fix held; `vx-996-ladder-round2.md` | `b72a1e909` |
| round-2 pins | DONE — red on the tip: 57 held / 12 FAILED | `1d6f0d34f` |
| R2-1 | DONE | `4c8073ce5` |
| R2-2 | DONE | `8dc9edf95` |
| R2-3 | DONE | `472a424fe` |
| R2-4 | DONE (the open question: item 3) | `465b4a38f` |
| R2-5 | DONE | `ca2ae2c3e` |
| R2-6 | DONE | `78df9e3bc` |
| R2-7 | DONE | `ff9cf8937` |
| F7 answered (wording) | DONE | `44ec45705` |
| this record + PR description | DONE | (this commit) |
| final suite | ALL 69 CASES HELD | (this commit) |
| the orchestrator's line-by-line check of round 2's fixes | PENDING | — |

## Round 2 — findings and dispositions

The findings are `notes/plans/fixes/vx-996-ladder-round2.md` (the reviewer's, verbatim). The orchestrator ruled every one
FIX on 2026-11-15, each pinned red on the tip first.

| Finding | Disposition | Commit | Pin (red on the tip → green) |
|---|---|---|---|
| **R2-1** log settings, a `-c` on the push and replace refs could make the guard read less than it sends; nothing checked the read | FIXED: `i18n.logOutputEncoding` pinned; `GIT_CONFIG_PARAMETERS` dropped; `GIT_NO_REPLACE_OBJECTS=1`; the read-back check (sha sets and counts of both logs equal `git rev-list`'s) refuses "the guard could not read every outgoing commit" | `4c8073ce5` | test 33 ×4 (UTF-16, `-c log.showRoot=false`, replace, the count check via a refuse-only seam) |
| **R2-2** a remote whose pushurl differs counted its fetched history as published | FIXED: URL pushes match fetch URLs only; a named remote that pushes elsewhere excludes only the old ids | `8dc9edf95` | test 34 ×2 (by name, by URL); F1's twin green on both |
| **R2-3** case-blind home shapes over-matched; wrong evidence lines | FIXED: `(?-i:/Users/)` and `(?-i:-Users-)`; the evidence and docstring timing state what was measured | `472a424fe` | test 35 (a lower-case slug passes); test 31's twins green on both |
| **R2-4** the refusal advised `--reset-author` for anyone's commit | FIXED: advice only when the flagged address is the clone's own `user.email`; otherwise "not this clone's own … the author's call"; the open question is item 3 | `465b4a38f` | test 36 (a contributor's refusal never says `--reset-author`); test 26 (own address) green on both |
| **R2-5** a ref naming a blob or tree published unscanned; tag-of-tag read one level | FIXED: a non-commit target refuses; the tag walk scans every tag in the chain | `ca2ae2c3e` | test 39 ×2 |
| **R2-6** a 0x1f in an author name shifted the fields; control bytes printed raw | FIXED: fields split on a per-run nonce; `printable()` escapes every C0, DEL and C1 byte | `78df9e3bc` | tests 37, 38 |
| **R2-7** stale wording in `gitleaks.toml` | FIXED (text) | `ff9cf8937` | — |
| Observation: the provisioning profile | RECORDED for the release session (open item 4) | this commit | — |
| F7 | ANSWERED by the author: binaries stay unscanned | `44ec45705` (wording) | test 12 green as built |

## Round 1 — findings and dispositions

The findings are `notes/plans/fixes/vx-996-ladder-round1.md` (the reviewer's, verbatim). The orchestrator ruled as
arbiter on 2026-11-15, with the author's own rulings on F5 and F7 relayed.

| Finding | Disposition | Commit | Pin (red on old → green) |
|---|---|---|---|
| **F1** a URL push excluded every remote's refs | FIXED (narrowed further by R2-2) | `03f716854` | test 22 (and a pass-shaped twin) |
| **F2** `-diff`/`binary` attributes hid content from both scanners | FIXED: the reviewer's option (a), adapted (below) | `4756fc20f` | test 23 ×4, the NUL-window case; the forced-text case and test 12 are pass-shaped |
| **F3** a root `.gitleaksignore` silenced gitleaks | FIXED: gitleaks reads the guard's items on stdin from an empty private dir (its ignore path too) | `028b69205` (docstring in `4756fc20f`) | test 24 ×3 |
| **F4** the guard vanished when the main worktree lacked it | FIXED: the installer's fixed shim inside the git folder refuses when main's guard is missing | `aaf2928e8` | test 25, the installer's hooksPath case |
| **F5** the identity entry | RULED by the author: kept, "provisional" dropped; outgoing only (advice narrowed by R2-4) | `dce79326f` | test 26 (and two pass-shaped twins) |
| **F6** `log.showRoot` unpinned | FIXED: pinned true (made unbeatable by R2-1) | `16e88189d` | test 27 |
| **F7** binaries unscanned | ANSWERED in round 2: binaries stay unscanned | `265938dd9`, `44ec45705` | — |
| **F8** no record; process | FIXED: this record; the process items are open item 6 | `98e778e21` | — |
| **N1** trailing tab on spaced paths | FIXED | `9fb04b4d0` | test 28 |
| **N2** the example's shapes over-match; six classes missing | FIXED (case kept by R2-3) | `dce79326f` | test 31 |
| **N3** `!starter` detected two ways | FIXED | `aaf2928e8` | test 32 |
| **N4** a stdin item holding a newline | FIXED | `9fb04b4d0` | test 30 |
| **N5** combined lines in one parent counted | FIXED in code (`+` in every column) | `9fb04b4d0` | test 29 |
| Observation: the home-path class live at HEAD | FIXED going forward by the rider (her word) | `fdb066865` | the example's shape matched all three old lines, none now |

**F2, how it was built and why that option.** The reviewer offered:
- (a) `--text` with an unforgeable separator;
- (b) an empty attribute tree, a pinned `core.attributesFile=/dev/null` and a refusal while `info/attributes` exists.

**(a) is the more robust:** it ignores every attribute source, where (b) patches three named sources one by one. It is
adapted so true binaries stay unread (F7).
- A section git shows as binary is classified by git's own content rule on its blob, with attributes ignored. When it is
  text by content, its added lines come from a blob-to-blob diff, which has no path and so no attributes.
- A section an attribute forces to text is dropped when its blob is binary.
- Every record carries a fresh `VXGUARD<128-bit hex>` marker. Since R2-6, every field carries a fresh `VXFIELD<hex>`
  marker too.

While pinning, a second hole surfaced that needs no attribute at all. A text file with a NUL past git's 8000-byte window
split the old `%x00` records. It is pinned and fixed by the nonce.

**Note on the F3 commit:** its docstring edit did not land (the file had changed under it), so the commit's code shipped
with the old docstring for one commit. `4756fc20f` corrected it.

## First build (for reference)

The pin-first build (`3e728e581` stub → `7900952ff` scanner) is described in its commit messages. Several of its claims
were false and are corrected above:
- "user config cannot reshape the patch" (F2, F6, R2-1);
- planted `.gitleaksignore` files are not honoured (F3);
- the starter's scratch-path hits were real instances (N2).
