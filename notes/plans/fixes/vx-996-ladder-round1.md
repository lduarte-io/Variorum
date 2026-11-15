# VX-996 — ladder round 1 (cold review, Opus)

**Scope check first.** The diff (`origin/main...vx-996-pre-push-guard`, 4 commits `3e728e581` · `7900952ff` · `a21eac1f8` ·
`034019b79`) touches only `Tools/githooks/`, `Tools/install-githooks`, `Tools/test-githooks` and one CLAUDE.md line. No
editor seam, no custody or keychain code, nothing under `Sources/VariorumCore/Sync/`, no product default's meaning. Fable's
mandatory scope does not apply.

**Anchor.** No plan or record file exists for VX-996; the anchor is the ticket ("A local pre-push hook on both Macs runs
gitleaks plus the sweep's token list (the list lives outside the repo …) over the outgoing diff and commit messages …";
pointer `notes/plans/fixes/vx-988-oss-fix-pass.md`), the four commit messages and the scanner's docstring.

**How each mechanism below was traced.** Each probe is a throwaway repo built the way `Tools/test-githooks` builds its own
(isolated `HOME` and git config, a bare remote, the guard copied from this branch and installed through
`Tools/install-githooks`, a test list `test-token lit:<sample>`), then one push. The probe steps are written out in each
finding so the implementer can turn each into a `Tools/test-githooks` case. Every probe below that "passes" is red on this
tree: the push went through.

---

## Findings

### [MAJOR] F1 · `Tools/githooks/prepush_guard.py:201-202` · a URL push excludes EVERY remote's refs, so history held by another remote (for example the private archive) publishes unscanned

**What's wrong.** When `argv[1]` is not a configured remote name, the exclusion is `--remotes` (all remote-tracking refs).
The premise, that anything any remote holds is already published, is false whenever a clone has a second remote that is
private. CLAUDE.md names that remote: the frozen pre-flip archive, whose history is unfiltered ("NEVER push a pre-flip
clone's branches anywhere"). A session that adds the archive as a remote to resolve a pre-flip SHA, fetches, and later
pushes by URL publishes the archive's commits with the guard reporting a clean push.

**Evidence (probe K).** The clone has `origin` (public, bare) and `archive` (second bare). Branch `prefilter` gets a commit
adding `unfiltered <sample>`, is pushed to `archive` with `--no-verify` (its own history), then `git fetch archive`.
- `git push origin prefilter:refs/heads/k1` → REFUSED, `old.md:1 col 12 [test-token]` (correct).
- `git push <public-url> prefilter:refs/heads/k2` → `pre-push guard: clean — 0 commits …`, rc 0, published.

**Pin.** That case in `Tools/test-githooks` (a second bare remote, a token commit pushed there with `--no-verify`, fetched,
then a URL push to the first remote) is red on this tree.

**Proposed fix.** On a URL push, exclude only the remote-tracking refs of remotes whose `url`/`pushurl` equals the pushed
URL (`argv[2]`), else only the stdin old shas. Either way, a remote that is not the push target never excludes anything. A
URL push to an unknown destination then scans everything reachable, which is the safe direction. Reword the docstring
(`:14-16`) to match.

### [MAJOR] F2 · `prepush_guard.py:55-63, 362-363, 432` · a `diff`/`binary` attribute (a committed `.gitattributes`, `.git/info/attributes`, or a global `core.attributesFile`) hides the content of every file it matches from BOTH scanners

**What's wrong.** `git log -p` (the guard's at `:362`, and gitleaks's own at `:432`) reads gitattributes from the worktree,
`$GIT_DIR/info/attributes` and `core.attributesFile`. A file marked `-diff` or `binary`, or `diff=<driver>` with
`diff.<driver>.binary=true`, prints as `Binary files … differ`. That gives no content items and no gitleaks lines, and the
push is reported "clean". `--no-textconv`/`--no-ext-diff` do not touch this. The claims at `:55-56` ("a user's diff/log
settings can neither reshape the patch …") and in `7900952ff` ("git's diff and log settings are pinned … so user config
cannot reshape the patch") are false for `core.attributesFile`. A branch's own `.gitattributes` reshapes the patch just as
a planted `.gitleaksignore` would, and the guard explicitly defends against that class (`:403-405`). This is also a likely
honest hole, not only an adversarial one: Xcode repos often carry `*.pbxproj binary` or `-diff` lines, and here
`project.pbxproj` holds the team id class.

**Evidence (probes A, A2, A3).** (A) Commit `.gitattributes` = `* -diff`, then a commit adding `leak <sample>` →
`clean — 2 commits`, rc 0. (A2) Same branch, a commit adding `export GITHUB_TOKEN=ghp_<36>` → `clean`, rc 0 (gitleaks is
blind too). (A3) No committed attributes, local `.git/info/attributes` = `*.md -diff`, token line in a `.md` → `clean`,
rc 0. (J) `GIT_ATTR_SOURCE=<empty tree>` restores the `+` line for the committed-file case but NOT for
`info/attributes`. `git log -p --text` restores all three.

**Pin.** Cases A and A3 in `Tools/test-githooks`, red on this tree.

**Proposed fix (options for the implementer).**
- (a) Pass `--text` to both `git log` runs. A true binary's NUL bytes then collide with the guard's `%x00` commit markers
  (`:363-366`), so the patch log needs a separator a blob cannot forge, for example one `git log -p` per commit, or
  `--format=` plus `git rev-list` driving per-commit `git show`. gitleaks would also read binary bytes, which is fine but
  noisier.
- (b) `GIT_ATTR_SOURCE` = the empty tree plus a pinned `core.attributesFile=/dev/null` in `GIT_PINS` (both ride `ENV` into
  gitleaks's git), plus a refusal when `$(git rev-parse --git-common-dir)/info/attributes` exists with a
  `diff`/`binary`/`-text` attribute.

Whichever is chosen, the docstring's "cannot reshape" sentence must be made true or removed. See F7 for the binary policy
itself.

### [MAJOR] F3 · `prepush_guard.py:403-407, 433, 441` · a `.gitleaksignore` at the worktree root IS honoured by both gitleaks runs, contrary to the code comment and the commit message

**What's wrong.** gitleaks loads `<source>/.gitleaksignore` in addition to the `--gitleaks-ignore-path` file.
`gitleaks git` gets `source = toplevel` (`:433`). `gitleaks stdin` resolves it against the cwd, which is the worktree root
because git runs hooks there. So a tracked or untracked `.gitleaksignore` at the root suppresses gitleaks findings. The
comment at `:403-405` ("a branch cannot excuse its own findings with a planted .gitleaksignore") and `7900952ff` ("Planted
.gitleaksignore files … are not honoured") are false. This matters beyond adversaries. Writing a `.gitleaksignore` is the
remedy gitleaks itself documents, so a session that meets a gitleaks refusal and obeys CLAUDE.md's "never bypassed" has an
unforbidden road that does exactly what `--no-verify` does. The fingerprints are in gitleaks's own report:
`commit:file:rule:line` for git mode, `:rule:line` for stdin.

**Evidence (probes B, I).** (B0) A commit adding `export GITHUB_TOKEN=ghp_<36>` → REFUSED `[gitleaks:github-pat]`. (B1)
Same push with an untracked `.gitleaksignore` at the root holding that finding's fingerprint (from
`gitleaks git … --log-opts -1 .`) → `clean`, rc 0. (I0) The token in a commit message → REFUSED. (I1) Same push, an
untracked root `.gitleaksignore` listing `:github-pat:1` … `:github-pat:40` → `clean`, rc 0. Control: the inline
`# gitleaks:allow` comment IS correctly ignored (`--ignore-gitleaks-allow` works; probe M refused).

**Pin.** Cases B1 and I1 in `Tools/test-githooks`, red on this tree.

**Proposed fix.** Run both gitleaks invocations from a directory that cannot hold a planted file. For example, `cwd=` a
fresh empty temp dir for stdin, and for git mode the same empty dir as `source` with `GIT_DIR`/`GIT_WORK_TREE` in the
child's env so gitleaks's `git -C <source> log` reads this repo. Or refuse outright while `<toplevel>/.gitleaksignore`
exists. Add a test for each.

### [MAJOR] F4 · `Tools/install-githooks:24-26, 89` · the guard silently disappears for every worktree whenever the main worktree checks out a commit without `Tools/githooks`

**What's wrong.** `core.hooksPath` is the main worktree's working-tree directory. When that directory is absent, git finds
no `pre-push` and pushes with no hook and no message. That happens when the main worktree is on an older commit, a bisect
step, a branch forked before VX-996 merged, or an orphan branch. This fails OPEN, against the docstring's own principle (`prepush_guard.py:25-26`, "a guard
that silently passes is worse than none") and against the new CLAUDE.md line "Every push runs the pre-push guard". The
convention that `~/dev/variorum` stays on main is the only thing standing between the clone and an unguarded push.

**Evidence (probe H).** Seed commit without `Tools/`, then the guard commit, install, then a second worktree. With the
main worktree at `git checkout <seed>`, the second worktree commits `leak <sample>` and pushes → no guard line at all,
`* [new branch] wtb -> wtb`, rc 0. (The first probe set hit the same thing by accident: an orphan branch built IN the main
worktree removed `Tools/githooks`, and its push printed nothing from the guard.)

**Pin.** That case in `Tools/test-githooks`, red on this tree.

**Proposed fix.** Point `core.hooksPath` at a stable directory the installer owns, for example
`$(git rev-parse --git-common-dir)/variorum-hooks/`, holding a fixed `pre-push` shim. The shim execs
`<main worktree>/Tools/githooks/pre-push` when present and REFUSES (with the bypass sentence) when it is missing. Every
worktree still runs main's reviewed scanner, and the absent case fails closed. `--check` should verify the shim.

### [MAJOR] F5 · `Tools/githooks/private-tokens.example:47-49, 54` · the example's PROVISIONAL identity entry pre-empts a pending author call and, copied as instructed, refuses every push of her own commits

**What's wrong.** `public-identity@identity` refuses any outgoing commit whose author or committer email is not a GitHub
noreply address. The `her-email` line says it "also catches it as a commit identity". Three of the last five commits on
`origin/main` (the post-flip commits made locally) carry a non-noreply author address. So once the example is copied and
filled per its own instructions, every push of a locally-made commit refuses until `user.email` changes on both Macs,
including CLAUDE.md's bout-start "board snapshot", which must be pushed at once. The commit-author address is her open
call: vx-988's open item 3, "The mailmap row — the commit-author metadata is VX-749's, her call on the target address." The
entry is marked PROVISIONAL but no `notes/QUESTIONS.md` entry exists (CLAUDE.md's PROVISIONAL rule), and the installer
NOTE (`install-githooks:56-59`) only reports the collision.

**Evidence.** `git log -5 --format='%ae | %ce' origin/main` shows a non-noreply address on 3 of 5. The example's regex
(`:49`) matches `<any-non-noreply>`. There is no test of a non-noreply identity.

**Disposition route.** This is not a ladder code fix. It needs a QUESTIONS entry naming the pending VX-749 call, and her
word on (a) whether the public commit identity is the noreply address and (b) whether the example ships the entry active,
commented, or absent. That word is needed before the CLAUDE.md line goes live at merge.

### [MINOR] F6 · `prepush_guard.py:57-63` · `log.showRoot=false` in user config hides a root commit's content from both scanners

**What's wrong.** `GIT_PINS` does not pin `log.showRoot`. With `log.showRoot=false`, `git log -p` omits the root commit's
patch. That commit is the first push to an empty remote or any orphan branch (`git checkout --orphan`), so its content goes
unscanned while its message and identity are still scanned. Again "user config cannot reshape the patch" does not hold.

**Evidence (probe D2).** An orphan branch built in a second worktree, root commit adding `leak <sample>`, global
`log.showRoot=false` → `clean — 1 commit`, rc 0.

**Pin.** That case, red on this tree. **Fix:** add `("log.showRoot", "true")` to `GIT_PINS`. It rides `ENV` into gitleaks's
git too.

### [MINOR] F7 · `prepush_guard.py:293-298` + `Tools/test-githooks:172-175` · binary blobs are never scanned, and case 12 pins that as policy; the sweep's own classes lived in binaries

**What's wrong.** "Binary files show no content and never block" is the implementer's policy, not a ruling, and the ticket
asks for the swept token classes to be scanned. vx-988 shows binaries carried those classes. R-oss-25 removed two 18l
screenshots, and the kept `Tools/Release/Variorum_Developer_ID.provisionprofile` carries the team id, signing cert and
profile UUID in plain bytes. A literal-class value inside an added binary blob publishes with "clean": PDF author metadata,
a binary plist, a re-issued profile, a store file. Pixel content is unscannable, but the private list's literals are cheap
to search in raw blob bytes (the added blobs are bounded by the outgoing set; keep globs apply as for content).

**Evidence (probe F).** A commit adding `meta.pdf` = `author: <sample>\0\n` → `clean`, rc 0. Case 12 asserts the same
with a token inside `img.bin`.

**Proposed route.** A QUESTIONS entry (scan added blobs' bytes for the private list's literals, yes or no). If yes, invert
case 12 as the pin and add the provisioning profile's path to the example's keep lines.

### [MINOR] F8 · process · no record file, an unlogged PROVISIONAL, a ticket with no project, and a CLAUDE.md line that is true only after the both-Macs install

- CLAUDE.md (Build workflow): "a fix that runs a ladder … still lands a repo record file
  (`notes/plans/fixes/vx-NNN-<slug>.md`)", opening with FOR A LATER READER. `notes/SessionResiliencyProtocol.md` asks for
  a LIVE STATUS from the first commit. Neither exists on the branch, so this round's anchor is the commit messages alone.
- The PROVISIONAL (F5) is not in `notes/QUESTIONS.md`.
- VX-996 has no project in Linear. CLAUDE.md says "every ticket carries a project or an explicit Parked state WITH a
  reason".
- The new CLAUDE.md line, "Every push runs the pre-push guard (…`Tools/install-githooks` once per clone)", is true only
  once the installer runs in each clone on both Macs. The ticket says "on both Macs". The shared cutover memory says the
  Air's `~/dev/variorum` is still the pre-flip clone pending its cutover, so the Air's install has to follow that cutover.
  Closeout should sequence it, or the line should say what holds until then.
- The line's "never bypassed — `git push --no-verify` is the author's call only" is a session rule derived from the
  ticket's "check-free by habit", not her words. Record its basis in the closeout's AppSpecRecord entry (the two-file rule),
  and note F3's unforbidden twin road.

### [NIT] N1 · `prepush_guard.py:283-286` · git's trailing tab on `---`/`+++` names containing a space lands in `path`

Git appends `\t` to those names when the path has a space. The `+++` path then carries it into the content items, so a
keep glob can never match a spaced path. The printed location carries a tab, and a new spaced file yields two path items
(with and without the tab). Probe E: `kept/a b.txt` holding `<sample>` with `keep test-token kept/*.txt` → REFUSED at
`kept/a b.txt\t:1`. It fails closed, so this is a NIT. **Fix:** `rstrip("\t")` the `+++` name before `strip_prefix`, plus
a spaced-path keep case.

### [NIT] N2 · `private-tokens.example` · the starter shapes over-match existing public lines, and the literal list misses some vx-988 classes

The `home-path` shape matches a fictional home-folder fixture (`Tests/VariorumMCPTests/MCPShimTests.swift:18-21`). The
`scratch-path` shape matches the already-placeholdered scratchpad form (the uid segment followed by `-<home>-…`) in 13
notes files. Every edit to those lines would refuse. (This record avoids spelling either form, so its own push passes the
starter shapes.) The real dashed scratch path is already caught by the `-Users-…-` shape, which makes
`scratch-path` redundant for real paths and over-strict for sanitized ones.

The literal section says vx-988's vocabulary "names the classes" but lacks `<provisioning-profile-uuid>`,
`<simulator-udid>`, `<notary-submission-id>`, `<key-proof-hash-prefix>`, `vmk1_<dev-key-prefix>` and `<test-account>`.
The author fills the live list, so this is a NIT.

### [NIT] N3 · `Tools/install-githooks:39` vs `prepush_guard.py:124-128` · the two starter tests disagree on a padded `!starter` line

The installer uses `grep -qx '!starter'` (an exact line). The guard strips the line first. ` !starter ` is the starter to
the guard but not to `--check`.

### [NIT] N4 · `prepush_guard.py:219-239, 440-443` · the stdin StartLine mapping assumes one line per item

A quoted path containing `\n` (git's C-quoting, undone by `unquote`) becomes a multi-line item. Every later gitleaks
finding is then attributed to the wrong item, and `flagged` may mask the wrong text and leave a flagged path printed. This
is an extreme edge. Fix: replace `\n` as `\r` already is (`:440`).

### [NIT] N5 · `prepush_guard.py:316-320` vs docstring `:8` · combined-diff lines present in one parent are scanned too

`"+" in prefix` accepts ` +`/`+ ` lines, which exist in one parent. The docstring says "the lines it adds beyond its
parents" (true only for `++`). The effect is stricter, not a hole: a later merge can re-flag a value the remote already
holds, for example one the author pushed with `--no-verify`. Align the wording, or require `+` in every column.

### Observation (outside this diff) · the home-path class is live at the public HEAD

The starter's `home-path` shape matches the real home folder at `Tools/WalkKit/castle-walk-lib.zsh:18, 27` and
`Tools/WalkKit/vx771-lock-drop-walk.zsh:17`. vx-988 assigns home paths to VX-751's verify rows. With the guard on, any
edit to those lines refuses, which is correct. The orchestrator may want VX-751 told.

---

## Clean bill (checked and found solid)

- **The pin is honest.** Running `3e728e581`'s own `Tools/test-githooks` against its stub prints `14 held, 17 FAILED`. All
  17 are the refusal and behaviour cases. The branch tip prints `ALL 31 CASES HELD` (about 6 s). The pass-shaped cases
  (the example never matching itself, binary, keep, built-on-published) are green on both sides by design; they guard over-strictness and the
  commit message says so.
- **The outgoing set for a NAMED remote** (`--remotes=<name>` plus the stdin olds) scans only what the remote lacks: test 6
  and probe K1. Deletions publish nothing (test 16). Force-push and new-branch shapes are bounded correctly.
- **Merges' own lines via `--cc`** (test 14). The annotated tag's message and tagger. Ref names and new, renamed and copied
  paths. Every outgoing commit's message and both identities.
- **Identities are read raw.** A planted `.mailmap` does not rewrite `%an <%ae>` (probe C1 still refused).
- **The inline `gitleaks:allow` is ignored** (probe M refused), as claimed.
- **The three gitleaks allowlists are load-bearing and narrow.** Under default rules, `generic-api-key` fires on
  `ProjectConfig.swift:44`, `UpdateChannelTests.swift:64`, `18l-u1-ladder-round2.md:43` and
  `phase-13r-distribution.md:1814`. With `Tools/githooks/gitleaks.toml` there are 0 findings. Each regex is anchored to the
  secret.
- **The scan never prints a value.** The REFUSED rows print commit, location, class and length only. A malformed list
  names the line number only. Gitleaks runs with `--redact` and its stderr is swallowed. An unexpected exception exits
  non-zero, so the push is refused.
- **Fail-closed:** a missing list, gitleaks or config, a malformed or empty-matching regex, or a non-zero gitleaks exit all
  refuse. `VARIORUM_GUARD_TEST_NO_GITLEAKS` can only tighten.
- **`GIT_PINS` ride `ENV` into gitleaks's git** (it inherits the env), and they append to any existing `GIT_CONFIG_COUNT`
  rather than replacing it.
- **The installer:** idempotent; refuses an existing non-sample hook (none in the real clone) and a foreign `hooksPath`;
  never touches global config. The test isolates `HOME`/`GIT_CONFIG_GLOBAL`/`GIT_CONFIG_NOSYSTEM`, so it never reads the
  real list.
- **The shim:** `python3 -I` (no PYTHON* env, no script-dir import), standard library only, Python 3.9-compatible syntax.
- **The CLAUDE.md line** is in place in Environment with one pointer (VX-996). Its wording carries no value.
