# VX-996 — ladder round 2 (cold review, Opus)

**Scope check first.** The diff (`origin/main...vx-996-pre-push-guard`, tip `98e778e21`, 15 commits) touches only
`Tools/githooks/`, `Tools/install-githooks`, `Tools/test-githooks`, two `Tools/WalkKit/*.zsh` defaults, one CLAUDE.md
line and the two record files. No editor seam, no custody or keychain code, nothing under `Sources/VariorumCore/Sync/`,
no product default's meaning. Fable's mandatory scope does not apply.

**Anchor.** `notes/plans/fixes/vx-996-ladder-round1.md` (round 1's findings) and `notes/plans/fixes/vx-996-pre-push-guard.md`
(the record: FOR A LATER READER, LIVE STATUS, the dispositions table).

**How each mechanism below was traced.** As in round 1. Each probe is a throwaway repo built the way `Tools/test-githooks`
builds its own: isolated `HOME` and git config, a bare remote, the guard copied from the branch tip and installed
through `Tools/install-githooks`, a test list `test-token lit:<sample>`. Then one push. "Red on the tip" means the push
went through on `98e778e21`. Each probe has a control that refuses today, so the trigger is the only difference. The
full-history scans ran the tip's `prepush_guard.py` read-only over this worktree with the shipped example as the list
and stdin naming a remote nothing answers to.

---

## Round 1's fixes, re-checked

| Finding | Re-check | Verdict |
|---|---|---|
| F1 URL push | Probe K re-run: a URL push of a second remote's token commit now REFUSES (`old.md:1 [test-token]`). Test 22's twin (a URL push to the remote's own URL skips what it holds) passes. | FIXED (but see R2-2: the fix's pushurl match opens a sibling) |
| F2 attributes | Probes A (`* -diff` committed), A2 (gitleaks under `* -diff`), A3 (`info/attributes`) all REFUSE. Test 23 covers the global attributes file and the NUL-past-8000 window. | FIXED |
| F3 `.gitleaksignore` | Probes B1 (untracked root ignore, content) and I1 (message) both REFUSE. gitleaks runs `stdin` with `cwd` = an empty temp dir that is also `--gitleaks-ignore-path` (`prepush_guard.py:581-582`). | FIXED |
| F4 guard vanishes | Probe H re-run with the main worktree on an orphan commit lacking `Tools/`: the linked worktree's push REFUSES with the shim's sentence. | FIXED |
| F5 identity | Ruled by the author and recorded. Test 26: a non-noreply identity refuses and names `git config user.email`. Both pass-shaped twins (history held by the remote, new noreply commits on top) are green. | RULED, built as ruled (but see R2-4 on reach) |
| F6 `log.showRoot` | Probe D2 (global `log.showRoot=false`, orphan root) REFUSES. | FIXED for config files (but see R2-1: `git -c` on the push still beats every pin) |
| F7 binaries | Documented as the author's call (open item 3); test 12 renamed. | OPEN as intended (see the Observation: the question's premise needs a correction) |
| F8 process | The record exists, with FOR A LATER READER and LIVE STATUS. The `--no-verify` sentence's basis is recorded. Activation is sequenced after merge. The Air cutover the record cites as done matches the shared memory note updated 2026-11-15. | FIXED (the Linear project is the orchestrator's) |
| N1 spaced path | Probe E: `kept/a b.txt` holding the sample with `keep test-token kept/*.txt` PASSES. | FIXED |
| N2 example over-match | The fixture's home and the placeholdered scratch form are spared (test 31). The case-blind dashed shape still over-matches honest public text (R2-3). | PARTLY FIXED |
| N3 `!starter` | The installer's ERE matches a padded line (test 32). | FIXED |
| N4 newline item | One stdin line per item (`:580`). Test 30 green. | FIXED |
| N5 merge columns | `prefix == "+" * cols` (`:392`). Test 29 green. | FIXED |

**Red on old, verified independently.** I exported the tip's `Tools/test-githooks` over the first build's
`Tools/githooks` and `Tools/install-githooks` (`034019b79`). Result: **39 held, 18 FAILED**, and the 18 are exactly the
round-1 pins (F1, F2 ×5, F3 ×3, F4 ×2, F5, F6, N1, N2, N3, N4, N5). Every pass-shaped twin stays green on both sides.
At the tip: **ALL 57 CASES HELD** (15 s).

---

## Findings

### [MINOR] R2-1 · `Tools/githooks/prepush_guard.py:21-22, 68-77, 88-95, 484-505` · what the guard reads still depends on log settings and local state, and nothing checks that the read covered the outgoing set, so the guard can say "clean — 0 commits" over a push it never read

**What's wrong.** The docstring (`:21-22`, "What is read never depends on the clone's attributes or its diff and log
settings. git's settings are pinned") and the record (`vx-996-pre-push-guard.md:17-18`) state a property that does not
hold. Three roads remain:
- **(a) `i18n.logOutputEncoding` is not pinned.** Under `UTF-16`, git re-encodes the whole formatted output, the
  per-run nonce marker included (raw bytes: `feff 0056 0058 0047 …`). `meta.split(mark)[1:]` (`:487`) and
  `patches.split(mark)[1:]` (`:500`) then find no records. `commits` stays 0, no identity, message, content or path
  item is made, and only the ref names are scanned. Nothing compares the parse to `git rev-list --count`, so the
  guard prints "clean — 0 commits" and returns 0 (`:665`).
- **(b) A `-c` on the push command beats every pin.** `git -c k=v push` hands the hook `GIT_CONFIG_PARAMETERS`, and git
  reads it after the `GIT_CONFIG_COUNT` entries `pinned_env` appends (`:88-95`). Last wins, so the pins lose. This
  defeats F6's fix and every other entry in `GIT_PINS`.
- **(c) Replace refs are honoured by the guard's `git log` but not by the push.** With `git replace <leaky> <clean>`,
  the guard reads the clean stand-in while pack-objects sends the original object.

**Evidence.**
- (P2d) A new branch with one commit adding `content <sample>`, plus global `i18n.logOutputEncoding UTF-16`: `clean —
  0 commits …`, rc 0, published. The control (the same shape on a fresh branch, no setting) REFUSED. P2c: the same
  with the sample in the author email: rc 0. P3: `git -c i18n.logOutputEncoding=UTF-16 push`: rc 0.
- (P1) An orphan root commit adding `root <sample>` in a second worktree, pushed with `git -c log.showRoot=false push
  -u origin orph`: `clean — 1 commit`, rc 0. The control (`push` without `-c`) REFUSED `root2.md:1 [test-token]`.
- (P4) Commit L adds `leak <sample>` and commit C (same parent) adds a clean line. After `git replace L C`, pushing
  L's branch gives `clean — 1 commit`, rc 0. The bare remote then holds L with the sample (`git --git-dir=remote.git
  cat-file -p L`).

**Why MINOR and not MAJOR.** Every trigger I found is deliberate: a UTF-16 log encoding, a `-c` on the push, a `git
replace`. No honest Variorum session sets any of them, and each is the same class round 1 graded MINOR for F6. The part
that is architectural is the missing read-back check. The guard's own principle (`:33-34`, "a guard that silently
passes is worse than none") is broken whenever any present or future output-shape setting breaks the marker split. If
the orchestrator weighs "clean over 0 of N commits" as a broken fail-closed invariant, MAJOR is defensible.

**Pins (each red on the tip, probed above).**
1. A global `i18n.logOutputEncoding UTF-16` plus a content token on a new branch: expect REFUSED.
2. An orphan root in a second worktree pushed with `git -c log.showRoot=false push`: expect REFUSED (test 27's shape,
   with `-c` in place of the global setting).
3. `git replace <leaky> <clean>` then push the leaky branch: expect REFUSED.

**Proposed fix.**
- Pin `("i18n.logOutputEncoding", "UTF-8")`.
- In `pinned_env`, drop `GIT_CONFIG_PARAMETERS` (the guard's read-only git needs nothing from the push's `-c`), or pass
  the pins as `-c` argv after it.
- Set `GIT_NO_REPLACE_OBJECTS=1` in `ENV`.
- The general one: when `revs` is not None, refuse unless both the meta record count and the patch record count equal
  `git rev-list --count <revs>`. That closes the whole class, including settings nobody has found yet.

Then the docstring's and the record's "never depends on" sentence is true.

### [MINOR] R2-2 · `prepush_guard.py:213-233` · a remote whose url and pushurl differ makes the history it FETCHED count as already held by where it PUSHES; F1's fix extends this to URL pushes by matching pushurl

**What's wrong.** A remote-tracking ref records what was fetched from a remote's `url`. It proves nothing about its
`pushurl`. Two roads follow:
- `published_exclusion` returns `--remotes=<name>` for any named remote (`:230-231`), whatever its pushurl.
- `remote_urls` (`:216-219`) adds `pushurl` and `get-url --push` to the set a URL push is matched against. This is new
  in F1's fix.

So a remote set up to fetch from a private archive and push to the public remote (a legitimate mirror configuration)
makes the archive's history unscanned, both by name and by the public URL. This is F1's class again. The by-name road
predates round 1; the by-URL road is new in its fix.

**Evidence (P5).** A second bare repo receives a token commit with `--no-verify`. Remote `mirror` has url = that repo
and pushurl = the test remote, and is fetched (`mirror/pre3` exists).
- `git push mirror pre3:refs/heads/p5a`: `clean — 0 commits`, rc 0.
- `git push <test-remote-url> pre3:refs/heads/p5b`: `clean — 0 commits`, rc 0. The remote now holds the token commit.
- Control: the same URL push with the pushurl unset REFUSED `a3.md:1 [test-token]`.

**Pin.** That case (by name and by URL), expect REFUSED, red on the tip. The existing F1 twin (a URL push to a remote's
own fetch URL skips what it holds) must stay green.

**Proposed fix.**
- Match a URL push only against fetch URLs (`remote.<name>.url`, and the same after `insteadOf`), never pushurl.
- For a named remote whose push URLs differ from its fetch URLs, exclude only the old ids (no `--remotes=<name>`).

Severity is MINOR because the configuration is unusual and none of this project's clones has it.

### [MINOR] R2-3 · `Tools/githooks/private-tokens.example:38-39` (with `prepush_guard.py:167, 173`) · the example's home-path shapes are case-blind, so honest public text at the tip trips them; the record's "only real matches" evidence is wrong

**What's wrong.** Every entry compiles with `re.IGNORECASE`. The two home shapes do not restore case, although a real
macOS home is always `/Users/…` and Claude's dashed folder form is always `-Users-…-`. The dashed shape therefore
matches any hyphenated `-users-<word>-`, which is common in heading slugs and setting names. The Pro's live list is
this example verbatim (its entries equal the example's; `!starter` present), so the over-match is live today.

**Evidence.**
- At the tip, `notes/plans/vx-266/design-proposal.html:19` (an anchor `href="#31-the-rules-what-users-are-told"`) and
  `:71` (the matching `<h3 id=…>`) match `-users-are-`. Any commit that re-adds or edits either line refuses
  `[home-path]`.
- The full-history scan (tip guard, example list, 12,381 commits, 79 s) also flags
  `Spikes/AuthPairingSpike/README.md:23` in `e1bd082b2c` (`allow-users-<…>-email`, a setting-name phrase) and the
  design proposal in `1a61cedc77` and `1ee57e9f01`. Those three are over-matches, not home folders.
- The record's evidence line (`vx-996-pre-push-guard.md:49-50`) says "The starter's only matches there are real", which
  is false for HEAD's history. Its "2,728 real commits … 13 s" does not match HEAD's 12,381. The docstring's "2,728 real
  commits took about six" (`:18-19`) matches neither.

**Pin.** In test 31's style, with the example as the list, a commit adding a heading slug of the
`what-users-are-told` shape (assembled at run time) expect PASS. It is red on the tip. Test 31's catch twin (a real
`/Users/jdoe` and a real dashed form) must stay green.

**Proposed fix.** Write the shapes as `re:(?-i:/Users/)(?!Shared\b|someone\b)[A-Za-z0-9._-]{4,}` and
`re:(?-i:-Users-)(?!someone-)[A-Za-z0-9._]+-`. The example already documents `(?-i:…)` at `:16`. Then correct the
record's evidence line and the docstring's timing sentence.

### [MINOR] R2-4 · `Tools/githooks/private-tokens.example:50-53` + `prepush_guard.py:653-658` · the identity entry reaches beyond the ruling, and the refusal tells a session to `--reset-author` a commit that may be someone else's

**What's wrong.** The author's ruling, as the record states it (`vx-996-pre-push-guard.md:36-38`): commits must not
carry her personal email, and existing history is left alone. The entry refuses any outgoing identity that is not a
GitHub noreply address. That includes a contributor's own public address on a commit fetched from their branch (the
repo is AGPL and public). On any identity finding, the refusal then instructs `git commit --amend --reset-author` /
`git rebase --exec '… --reset-author …'`. A session that obeys rewrites the contributor's authorship to hers. The
ruling is silent on other people's commits. That silence is a product question, not something the example should
decide.

**Evidence (P9).** A commit authored `Jane Contributor <jane@example.org>` in a clone whose `user.email` is noreply:
REFUSED `author identity [public-identity]`, followed by "Run `git config user.email …`, then re-make the refused
commits under it … `--reset-author` …".

**Disposition route.**
- A `notes/QUESTIONS.md` entry: does the identity rule cover commits authored by someone else, and if one arrives
  locally, is it kept, re-authored, or merged on GitHub only?
- Meanwhile the code can make the advice conditional on the flagged identity being this clone's own. That needs no
  ruling. Pin: P9's shape, where the refusal must not name `--reset-author` when the flagged email differs from
  `git config user.email`. It is red on the tip.

### [NIT] R2-5 · `prepush_guard.py:236-253, 468-478` · a pushed ref that names a blob or a tree publishes it unscanned with a clean verdict; a tag of a tag scans only the outer tag

`outgoing_revs` silently drops a local sha that does not peel to a commit (`:243-245`), and `collect_items` reads only
one tag level (`:469-478`). Probe P6: `git tag blobtag $(printf 'blob body <sample>\n' | git hash-object -w --stdin)`
then `git push origin blobtag` gives `clean — 0 commits`, rc 0, and the remote holds the blob. A tree ref (P6b) is the
same. This is deliberate plumbing only. **Pin:** that case, expect REFUSED. **Fix:** refuse any non-deletion update whose
object is neither a commit nor a tag chain ending at a commit, and walk the chain so that every tag in it is scanned.

### [NIT] R2-6 · `prepush_guard.py:485-491` · a 0x1f byte in an author name shifts the field split, so the real committer identity is scanned as message text

The meta format separates fields with `%x1f` and splits on its first three occurrences. git keeps an internal 0x1f in
an ident name (`author Ann^_Lee …` in the raw commit). The author item becomes `Ann`, the committer item becomes the
author's remainder, and the true committer identity falls into the body, so identity-scoped entries miss it. In probe P8,
author name `Ann\x1fLee` with committer `me@personal.example` gives `clean — 1 commit`, rc 0. The control (the same
commit with an ordinary author name) REFUSED `committer identity [public-identity]`. This is deliberate only. **Pin:**
P8, expect REFUSED. **Fix:** separate fields with the per-run nonce, as records already are. The same NIT covers the
printed locations: `:642` escapes only `\n` and `\t`, so a crafted path's other control bytes (ESC) reach the terminal
raw.

### [NIT] R2-7 · stale wording left by the F4 change

- `Tools/githooks/gitleaks.toml:3-4`: "core.hooksPath is the main worktree's Tools/githooks". It is now the installer's
  shim inside the git folder.
- The same sentence's "a branch cannot widen its own allowlist" holds only for pushes whose main worktree is on main.
  A branch checked out IN the main worktree runs its own copy. That is the convention CLAUDE.md already keeps, but the
  sentence states it as a property.

### Observation (outside this diff) · the provisioning profile F7 names is not in the public repo, and that changes how F7's question should be put to the author

`notes/plans/fixes/vx-988-oss-fix-pass.md:53-57` rules `Tools/Release/Variorum_Developer_ID.provisionprofile` KEEP ("stay
as they are"), and `Tools/Release/archive-and-export.sh:42` and `Tools/Release/verify-export.sh:31` still expect it at that
path. But it is not tracked at the tip, appears nowhere in this repo's history (`git log --all -- '*provisionprofile'`
is empty), and is not on disk in either worktree. So:
- the record's open item 3 (`vx-996-pre-push-guard.md:57-59`, from round 1's F7: "add the provisioning profile's path
  to the example's keep lines") rests on a premise that is false here;
- F7's question has a concrete honest road worth naming to her. A release session restoring the file the scripts
  expect would publish the team id, signing cert and profile UUID inside a true binary (CMS DER) the guard never
  reads, with a clean verdict.

Whether the file's absence is a deliberate post-ruling sweep is for the orchestrator to find out. The QUESTIONS entry
for F7 should be worded from what the repo holds now.

---

## Clean bill (checked and found solid)

- **Round 1's reproductions all refuse now**: K, A, A2, A3, B1, I1, D2 and H (re-run with a Tools-less main), plus E's
  pass. Red on old was verified independently: the tip's tests over the first build's guard give 39 held / 18 FAILED,
  exactly the round-1 pins, with the pass-shaped twins green on both. The tip gives ALL 57 CASES HELD.
- **gitleaks stdin's StartLine is global, not per read chunk** (8.30.1). A PAT at line 10, 500, 3,000 and 20,000 (up to
  889 KB of input) reports exactly that line, so the item mapping holds at scale. A PAT placed at offsets around 10 KB,
  100 KB and 1 MB chunk edges inside one long line was found 21 of 21 times.
- **The F2 recovery is attribute-free.** Binary-shown sections are classified by a NUL in the blob's first 8000 bytes.
  Text-by-content sections are re-read through a blob-to-blob `git diff --text --no-ext-diff --no-textconv`, where
  `--text` outranks any attribute that happens to match the sha used as a path. Probed: a MODIFIED file under a
  committed `* -diff` refuses at `notes/m.md:2`, the right line. Forced-text binaries are dropped. The
  per-run nonce (`secrets.token_hex(16)`) cannot be forged by a message or a blob. `core.bigFileThreshold` is also
  covered by the same recovery.
- **The F3 isolation.** `--config` is explicit (it outranks `GITLEAKS_CONFIG*` and any `.gitleaks.toml`). The cwd and
  the ignore path are both a fresh empty temp dir. `--ignore-gitleaks-allow`, `--redact`, `--exit-code 0` with
  non-zero treated as failure: all fail closed.
- **The shim (F4).** It is fixed text, compared byte for byte by `--check`. It runs `git worktree list`'s first entry,
  refuses with the bypass sentence when that worktree's `Tools/githooks/pre-push` is missing or not executable, and
  passes stdin through `exec`. The installer refuses before main carries the guard, refuses foreign hooks and a foreign
  `hooksPath`, and upgrades the first build's value in place.
- **F1 named-remote and URL matching** for the ordinary case: `remote_urls` sees `insteadOf`-rewritten forms. Git
  refuses remote names that are a subset of another (`origin/arch` is rejected), so the `--remotes=<name>` glob cannot
  swallow a second remote.
- **This project's real state.** The Pro's `~/dev/variorum` carries the noreply address as its local `user.email`, has
  no non-sample hooks, and holds the starter list. No repo tool commits under another identity or pushes or tags. The
  keep-line paths in the example all exist. No tracked file is UTF-16 text (the only NUL files are 77 PNGs and one PDF),
  so F7 as built hides no honest text.
- **The branch's own history under its own guard**: excluding `origin/main`, its 15 commits refuse only on the stub
  commit `3e728e581`'s old `TOKEN="<sample>"` line (`Tools/test-githooks:32`, gitleaks `generic-api-key`; the tip renamed
  it). The guard cannot be active in any clone before this merges (the installer refuses until main carries it), so
  this is moot. A rebase-and-repush after activation would meet it.
- **The WalkKit rider.** Both files pass `zsh -n`. The `${VAR:-$HOME/…}` defaults expand under the author's home, and
  `prod-read.sh` resolves. No `/Users/<name>` line remains under `Tools/` at the tip.
- **The CLAUDE.md line** sits in Environment with one pointer (VX-996), carries no value, and is true once activation
  runs after merge. The record sequences that.
- **No value is printed anywhere I drove it.** Every refusal above printed commit, place, class and length only.
