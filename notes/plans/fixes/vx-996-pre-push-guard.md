# VX-996 — the pre-push guard (record)

**STATUS: ladder round 1's fixes DONE — round 2 (a fresh reviewer) next.** Branch `vx-996-pre-push-guard`, PR #4,
worktree `~/dev/variorum-vx-996`. Not merged; not activated in any real clone.

## FOR A LATER READER

**The mechanism.** Since the 2026-11-11 flip every push publishes into public history, and nothing mechanical stopped a
session from pushing a swept identifier. The guard is a pre-push hook. Git hands it the remote's name and URL and one line
per pushed ref. It reads what the push would PUBLISH and nothing else:
- the lines each outgoing commit adds (a merge: lines new against all its parents);
- each message, author and committer identity;
- the paths of added, renamed or copied files;
- the pushed ref names, and an annotated tag's message and tagger.

"Outgoing" is `git rev-list <pushed shas> --not <the target's own refs> <old remote shas>`: a named remote's own
remote-tracking refs; on a push by URL, only the refs of remotes whose URL is that URL, else only the old ids. What it
reads never depends on attributes or diff/log settings, and true binaries (a NUL in a blob's first 8000 bytes, git's own
rule) are not read. gitleaks's default rules and the private token list (`~/.variorum/private-tokens.txt`, outside the
repo) both scan the same items. A match refuses, naming the commit, place and class, never the value. A missing list,
missing gitleaks, malformed entry or failing scanner refuses too.

**The fix as built.**
- `Tools/githooks/prepush_guard.py`: the scanner. `published_exclusion`/`outgoing_revs` compute the range. `collect_items`
  and `parse_patch` read the patch under a per-run nonce marker. `recover_binary_shown` applies the attribute-free binary
  rule. `gitleaks_findings` runs one `gitleaks stdin` from an empty private dir.
- `Tools/githooks/pre-push`: the shim into python.
- `Tools/githooks/gitleaks.toml`: the default rules plus the three ruled-public values.
- `Tools/githooks/private-tokens.example`: the list's format, class shapes and literal templates, no values.
- `Tools/install-githooks`: owns the fixed shim `<git-common-dir>/variorum-hooks/pre-push`. That shim runs the MAIN
  worktree's guard and refuses when it is missing. `--check` reports status.
- `Tools/test-githooks`: 57 cases, a throwaway remote, no stage.
- One CLAUDE.md Environment line.

**Rulings.**
- **F5 (the author, 2026-11-15):** commits must not carry her personal email. The repo-local commit email is her GitHub
  noreply address on both Macs, and existing history is LEFT ALONE: no rewrite of main or of pushed branch commits. So the
  example's `public-identity` entry stays, judging outgoing commits only.
- **The WalkKit rider:** her word, "we might as well fix it going forward".
- **"`--no-verify` is the author's call only"** (the guard's sentence and CLAUDE.md's line) is a session rule DERIVED
  from the ticket's "check-free by habit rather than by ritual". It is not her words. The closeout's AppSpecRecord entry
  should record that basis.

**Evidence.**
- First build: the stub gave 14 held / 17 FAILED; the scanner gave 31/31.
- Round 1's pins (`265938dd9`) on the first build's tip: 38 held / **17 FAILED**. The NUL-window pin on the F3 tip:
  46 held / 11 FAILED.
- End of round 1: **ALL 57 CASES HELD**.
- 2,728 real commits scan in 13 s. The starter's only matches there are real: one walk-library home-path line (fixed going
  forward by the rider) and the identities of four commits history already holds.

**Open items.**
1. **The real token list must be filled from the private ledger by the author**, on each Mac, and its `!starter` line
   deleted. The Pro's list is the starter (class shapes only), refreshed to this round's example.
2. **Activation:** run `Tools/install-githooks` once per clone on each Mac after merge. (The Air is cut over to the
   public clone and gitleaks is on both Macs, so that dependency is closed.)
3. **F7, a question for the author:** should the guard search the raw bytes of added binary blobs for the private list's
   literals? As built, true binaries are never read (test 12). If yes, invert test 12 as the pin and add the provisioning
   profile's path to the example's keep lines. The merging session logs it in `notes/QUESTIONS.md`.
4. **A recorded trade:** gitleaks rules keyed on a file's own name (a `.p12` file) do not fire, because stdin carries no
   path. The private list's path scope is the road for names.
5. **Process, outside this branch:**
   - VX-996 has no Linear project; it needs one or an explicit Parked reason (the orchestrator's).
   - The AppSpecRecord entry at closeout belongs to the merging session.

---

## LIVE STATUS

| Piece | State | Commit |
|---|---|---|
| first build: pin (stub), scanner, CLAUDE.md line, docstring | DONE — 14 held / 17 FAILED on the stub; 31/31 | `3e728e581` `7900952ff` `a21eac1f8` `034019b79` |
| round 1 (cold review, Opus) | IN — 5 MAJOR, 3 MINOR, 5 NIT; `vx-996-ladder-round1.md` beside this file | `db377d12c` |
| round-1 pins | DONE — red on the tip: 38 held / 17 FAILED | `265938dd9` |
| F6 | DONE | `16e88189d` |
| N1 · N4 · N5 | DONE | `9fb04b4d0` |
| F3 | DONE | `028b69205` |
| F2 (+ the NUL-window pin) | DONE | `4756fc20f` |
| F1 | DONE | `03f716854` |
| F4 · N3 | DONE | `aaf2928e8` |
| F5 · N2 | DONE | `dce79326f` |
| rider: WalkKit home paths → `$HOME` | DONE | `fdb066865` |
| F7 | DOCUMENTED — the author's call; test 12 renamed in the pins commit | `265938dd9` |
| F8: this record + PR description | DONE | (this commit) |
| final suite | ALL 57 CASES HELD | (this commit) |
| round 2 | PENDING — a fresh reviewer | — |

## Round 1 — findings and dispositions

The findings are `notes/plans/fixes/vx-996-ladder-round1.md` (the reviewer's, verbatim). The orchestrator ruled as
arbiter on 2026-11-15, with the author's own rulings on F5 and F7 relayed.

| Finding | Disposition | Commit | Pin (red on old → green) |
|---|---|---|---|
| **F1** a URL push excluded every remote's refs | FIXED: a URL excludes only the refs of remotes whose URL matches; otherwise only the old ids | `03f716854` | test 22 (and a pass-shaped twin) |
| **F2** `-diff`/`binary` attributes hid content from both scanners | FIXED: the reviewer's option (a), adapted (below) | `4756fc20f` | test 23 ×4, the NUL-window case; the forced-text case and test 12 are pass-shaped |
| **F3** a root `.gitleaksignore` silenced gitleaks | FIXED: gitleaks reads the guard's items on stdin from an empty private dir (its ignore path too); the false comment is corrected | `028b69205` (docstring in `4756fc20f`) | test 24 ×3 |
| **F4** the guard vanished when the main worktree lacked it | FIXED: the installer's fixed shim inside the git folder refuses when main's guard is missing | `aaf2928e8` | test 25, the installer's hooksPath case |
| **F5** the identity entry | RULED by the author: kept, "provisional" dropped; the refusal names `git config user.email <noreply>`; outgoing only | `dce79326f` | test 26 (and two pass-shaped twins) |
| **F6** `log.showRoot` unpinned | FIXED: pinned true | `16e88189d` | test 27 |
| **F7** binaries unscanned | DOCUMENTED: the author's call, behaviour left; the "policy" wording is gone from test 12 | `265938dd9` | — (open item 3) |
| **F8** no record; process | FIXED: this record; the reviewer's file is beside it; the process items are open item 5 | this commit | — |
| **N1** trailing tab on spaced paths | FIXED | `9fb04b4d0` | test 28 |
| **N2** the example's shapes over-match; six classes missing | FIXED: home shapes spare `Shared` and the fictional `someone`; scratch-path removed; an MCP setup-key shape; six literal templates | `dce79326f` | test 31 (spare red; catch green both) |
| **N3** `!starter` detected two ways | FIXED: the installer allows padding | `aaf2928e8` | test 32 |
| **N4** a stdin item holding a newline | FIXED: one line per item; printed locations escape `\n`/`\t` | `9fb04b4d0` | test 30 |
| **N5** combined lines in one parent counted | FIXED in code (`+` in every column), so the docstring is exact | `9fb04b4d0` | test 29 |
| Observation: the home-path class live at HEAD | FIXED going forward by the rider (her word) | `fdb066865` | the example's shape matched all three old lines, none now |

**F2, how it was built and why that option.** The reviewer offered:
- (a) `--text` with an unforgeable separator;
- (b) an empty attribute tree, a pinned `core.attributesFile=/dev/null` and a refusal while `info/attributes` exists.

**(a) is the more robust:** it ignores every attribute source, including ones git adds later, where (b) patches three
named sources one by one. It is adapted so true binaries stay unread, since F7 is hers.
- A section git shows as binary is classified by git's own content rule on its blob, with attributes ignored. When it is
  text by content, its added lines come from a blob-to-blob diff, which has no path and so no attributes.
- A section an attribute forces to text is dropped when its blob is binary.
- Every record of both logs starts with a fresh `VXGUARD<128-bit hex>` marker.

While pinning, a second hole surfaced that needs no attribute at all. A text file with a NUL past git's 8000-byte window
put that NUL into the patch, and it split the old `%x00` records, so the rest of the commit went unscanned. It is pinned
and fixed by the nonce.

**Note on the F3 commit:** its docstring edit did not land (the file had changed under it), so the commit's code shipped
with the old docstring for one commit. `4756fc20f` corrected it.

## First build (for reference)

The pin-first build (`3e728e581` stub → `7900952ff` scanner) is described in its commit messages and PR #4's earlier
description. Its claim that "git's diff and log settings are pinned … so user config cannot reshape the patch" was false
for attributes (F2) and `log.showRoot` (F6). Its claim that planted `.gitleaksignore` files are not honoured was false
(F3). Its first report called the starter's 11 scratch-path hits real instances; they were placeholdered forms (N2). All
of these are corrected above.
