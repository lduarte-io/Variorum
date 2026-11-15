#!/usr/bin/env python3
"""Variorum's pre-push guard (VX-996): refuse a push that would publish a swept token.

Git runs Tools/githooks/pre-push before every push from a clone whose core.hooksPath points here
(Tools/install-githooks); the shim execs this file with git's arguments (the remote's name and URL)
and the push's ref lines on stdin. What the push would PUBLISH is scanned, and nothing else:

  content   every line the outgoing commits add (a merge: the lines new against all its parents, --cc)
  message   each outgoing commit's message, and an annotated tag's message
  identity  each outgoing commit's author and committer, and a tag's tagger
  path      the paths of files the outgoing commits add, rename or copy
  ref       the pushed ref names

"Outgoing" is every commit reachable from a pushed sha and from no ref of the remote being pushed to:
`git rev-list <pushed shas> --not --remotes=<remote> <the remote's old shas>`. A push by URL excludes
the refs of the remotes whose URL is that URL and no others, so another remote's history (a private
archive) is never treated as published; a URL no remote answers to excludes only the old ids. A new
branch scans only what the remote does not already hold; a deletion publishes nothing. Cost follows the outgoing set: a few commits take well
under a second, 2,728 real commits took about six; only a first push to an empty remote reads it all.

What is read never depends on the clone's attributes or its diff and log settings. git's settings are
pinned (GIT_PINS). A file git shows as binary because of an attribute (a committed .gitattributes,
$GIT_DIR/info/attributes, a global attributes file) is read when its blob is text by git's own content
rule, and a file an attribute forces to text is dropped when its blob is binary by that rule. True
binaries (a NUL byte in the blob's first 8000 bytes) are not read: an open question for the author.

Two scanners read that same set of items. gitleaks runs its generic secret rules (with gitleaks.toml's
ruled public values allowed) as one `gitleaks stdin` call over every item, from an empty private
directory, so no .gitleaksignore in the clone is ever read; inline gitleaks:allow comments are
ignored. The PRIVATE TOKEN LIST, ~/.variorum/private-tokens.txt, holds literals and regexes that never
enter the repo (format: private-tokens.example). A match refuses the push, naming the commit, the
place and the class; a matched value is never printed, and printed paths and ref names are masked.
A missing list, a missing gitleaks, a malformed list entry or a failing scanner refuses too: a guard
that silently passes is worse than none. `git push --no-verify` skips the guard; that is the author's
call only. The one test seam can only make the guard stricter (VARIORUM_GUARD_TEST_NO_GITLEAKS=1 acts
as if gitleaks were absent). Python 3.9+ (macOS's /usr/bin/python3); standard library only.
"""

import fnmatch
import json
import os
import re
import secrets
import shutil
import subprocess
import sys
import tempfile

HERE = os.path.dirname(os.path.abspath(__file__))
LIST_PATH = os.path.join(os.path.expanduser("~"), ".variorum", "private-tokens.txt")
LIST_SHOWN = "~/.variorum/private-tokens.txt"
EXAMPLE = "Tools/githooks/private-tokens.example"
GITLEAKS_CONFIG = os.path.join(HERE, "gitleaks.toml")
GITLEAKS_FALLBACKS = ("/opt/homebrew/bin/gitleaks", "/usr/local/bin/gitleaks")
SCOPES = ("content", "message", "identity", "path", "ref")
CLASS_NAME = re.compile(r"^[A-Za-z0-9_.-]+$")
ZERO_SHA = re.compile(r"^0+$")
HUNK = re.compile(r"^(@{2,}) (?:-\S+ )+\+(\d+)(?:,\d+)? @{2,}")
MASK = "‹masked›"
MAX_SHOWN = 40
TAG = "pre-push guard"
BYPASS = ("`git push --no-verify` skips this guard — that is the author's call only, "
          "never a session's.")

# Config pinned for every git this guard runs, so a user's diff/log settings can neither reshape the
# patch it parses nor inject text into it (attributes are a separate road: collect_items).
GIT_PINS = (
    ("core.quotePath", "false"),
    ("diff.noprefix", "false"),
    ("diff.mnemonicPrefix", "false"),
    ("log.showSignature", "false"),
    ("log.showRoot", "true"),   # a root commit's patch (an orphan branch, a first push) is read too
    ("color.ui", "false"),
)


class Refusal(Exception):
    """A reason to refuse the push that is not a match (the guard cannot do its job)."""


def say(line=""):
    print(line, file=sys.stderr)


def pinned_env():
    env = dict(os.environ)
    base = int(env.get("GIT_CONFIG_COUNT", "0") or 0)
    for i, (key, value) in enumerate(GIT_PINS):
        env["GIT_CONFIG_KEY_%d" % (base + i)] = key
        env["GIT_CONFIG_VALUE_%d" % (base + i)] = value
    env["GIT_CONFIG_COUNT"] = str(base + len(GIT_PINS))
    return env


ENV = pinned_env()


def git(*args, check=True):
    proc = subprocess.run(["git", *args], stdout=subprocess.PIPE, stderr=subprocess.PIPE, env=ENV)
    if check and proc.returncode != 0:
        tail = proc.stderr.decode("utf-8", "replace").strip().splitlines()[-1:] or ["(no message)"]
        raise Refusal("git %s failed (%s)" % (args[0], tail[0]))
    return proc.stdout.decode("utf-8", "replace")


# ---------------------------------------------------------------------------------------------
# The private list

class Entry:
    __slots__ = ("cls", "scopes", "rx")

    def __init__(self, cls, scopes, rx):
        self.cls, self.scopes, self.rx = cls, scopes, rx


def load_private_list(path):
    """Returns (entries, keeps, starter). Never echoes a line's text in an error."""
    if not os.path.isfile(path):
        raise Refusal(
            "the private token list is missing: %s. Start it from %s (mkdir -p ~/.variorum && "
            "cp %s %s), fill it from the private ledger, and push again — it never enters the "
            "repo, and until it exists every push is refused." % (LIST_SHOWN, EXAMPLE, EXAMPLE, LIST_SHOWN))
    entries, keeps, starter = [], [], False
    try:
        with open(path, encoding="utf-8") as fh:
            lines = fh.read().splitlines()
    except (OSError, UnicodeDecodeError) as err:
        raise Refusal("the private token list (%s) cannot be read (%s)." % (LIST_SHOWN, type(err).__name__))

    def bad(n, why):
        return Refusal("the private token list (%s) has a malformed entry at line %d: %s. Fix that "
                       "line (its text is not printed here)." % (LIST_SHOWN, n, why))

    for n, raw in enumerate(lines, 1):
        s = raw.strip()
        if not s or s.startswith("#"):
            continue
        if s == "!starter":
            starter = True
            continue
        parts = s.split(None, 1)
        if len(parts) != 2:
            raise bad(n, "expected '<class> lit:<text>', '<class> re:<regex>' or 'keep <class> <glob>'")
        head, rest = parts
        if head == "keep":
            kparts = rest.split(None, 1)
            if len(kparts) != 2 or not CLASS_NAME.match(kparts[0]):
                raise bad(n, "a keep line is 'keep <class> <path-glob>'")
            keeps.append((kparts[0], kparts[1].strip()))
            continue
        cls, _, scope_text = head.partition("@")
        if not CLASS_NAME.match(cls):
            raise bad(n, "the class name may hold only letters, digits, '.', '_' and '-'")
        scopes = SCOPES
        if scope_text:
            scopes = tuple(x for x in scope_text.split(",") if x)
            unknown = [x for x in scopes if x not in SCOPES]
            if unknown or not scopes:
                raise bad(n, "a scope is one or more of %s" % ", ".join(SCOPES))
        if rest.startswith("lit:"):
            text = rest[4:].strip()
            if not text:
                raise bad(n, "the literal is empty")
            rx = re.compile(re.escape(text), re.IGNORECASE)
        elif rest.startswith("re:"):
            text = rest[3:].strip()
            if not text:
                raise bad(n, "the regex is empty")
            try:
                rx = re.compile(text, re.IGNORECASE)
            except re.error as err:
                raise bad(n, "the regex does not compile (%s at position %s)" % (err.msg, err.pos))
            if rx.search("") is not None:
                raise bad(n, "the regex matches the empty string, so it would match everything")
        else:
            raise bad(n, "the pattern must start with lit: or re:")
        entries.append(Entry(cls, scopes, rx))
    return entries, keeps, starter


def kept(cls, path, keeps):
    return path is not None and any(k == cls and fnmatch.fnmatch(path, g) for k, g in keeps)


# ---------------------------------------------------------------------------------------------
# What the push would publish

class Item:
    """One scanned string, and where it lives (never its text, in anything printed)."""
    __slots__ = ("scope", "commit", "where", "path", "text", "merge")

    def __init__(self, scope, commit, where, text, path=None, merge=False):
        self.scope, self.commit, self.where, self.text, self.path, self.merge = (
            scope, commit, where, text, path, merge)


def read_updates(stream):
    updates = []
    for line in stream.read().splitlines():
        parts = line.split()
        if len(parts) == 4:
            updates.append(tuple(parts))
    return updates


def object_type(sha):
    return git("cat-file", "-t", sha, check=False).strip()


def remote_urls(name):
    """Every URL a remote answers to: its configured url and pushurl, and the same after insteadOf."""
    urls = set()
    for args in (("config", "--get-all", "remote.%s.url" % name),
                 ("config", "--get-all", "remote.%s.pushurl" % name),
                 ("remote", "get-url", "--all", name),
                 ("remote", "get-url", "--push", "--all", name)):
        urls.update(u.strip().rstrip("/") for u in git(*args, check=False).split("\n") if u.strip())
    return urls


def published_exclusion(remote, url):
    """The refs whose history the push target already holds. A NAMED remote: its own
    remote-tracking refs. A push by URL: the refs of every remote whose URL is that URL, and none
    other — another remote's history (a private archive, say) is never treated as published, so a
    URL nothing here answers to excludes only the old ids git passes in (outgoing_revs)."""
    remotes = git("remote").split()
    if remote in remotes:
        return ["--remotes=%s" % remote]
    target = (url or remote).strip().rstrip("/")
    return ["--remotes=%s" % name for name in remotes if target in remote_urls(name)]


def outgoing_revs(remote, url, updates):
    """The rev-list arguments naming every commit this push would publish (None: no commits)."""
    exclude = published_exclusion(remote, url)
    tips, olds = [], []
    for _local_ref, local_sha, _remote_ref, remote_sha in updates:
        if ZERO_SHA.match(local_sha):
            continue  # a deletion publishes nothing
        peeled = git("rev-parse", "--verify", "-q", local_sha + "^{commit}", check=False).strip()
        if peeled:
            tips.append(peeled)
        if not ZERO_SHA.match(remote_sha) and object_type(remote_sha):
            old = git("rev-parse", "--verify", "-q", remote_sha + "^{commit}", check=False).strip()
            if old:
                olds.append(old)
    if not tips:
        return None
    published = exclude + olds
    return tips + (["--not"] + published if published else [])


def unquote(s):
    """Undo git's C-style path quoting ("a\\tb", octal escapes)."""
    if len(s) < 2 or s[0] != '"' or s[-1] != '"':
        return s
    body, out, i = s[1:-1], bytearray(), 0
    simple = {"a": b"\a", "b": b"\b", "t": b"\t", "n": b"\n", "v": b"\v", "f": b"\f", "r": b"\r",
              '"': b'"', "\\": b"\\"}
    while i < len(body):
        c = body[i]
        if c == "\\" and i + 1 < len(body):
            nxt = body[i + 1]
            if nxt in "01234567" and re.match(r"[0-7]{3}", body[i + 1:i + 4]):
                out.append(int(body[i + 1:i + 4], 8))
                i += 4
                continue
            out += simple.get(nxt, nxt.encode("utf-8"))
            i += 2
            continue
        out += c.encode("utf-8")
        i += 1
    return out.decode("utf-8", "replace")


def strip_prefix(p, prefix):
    return p[len(prefix):] if p.startswith(prefix) else p


def header_path(rest):
    """The path in a 'diff --git a/P b/P' header when both sides agree (else None)."""
    if rest.startswith('"'):
        m = re.match(r'^("(?:[^"\\]|\\.)*") ', rest)
        return strip_prefix(unquote(m.group(1)), "a/") if m else None
    if (len(rest) - 5) % 2:
        return None
    n = (len(rest) - 5) // 2
    a, b = rest[2:2 + n], rest[2 + n + 3:]
    return a if a == b and rest.startswith("a/") and rest[2 + n:2 + n + 3] == " b/" else None


INDEX_LINE = re.compile(r"^index ([0-9a-f]+(?:,[0-9a-f]+)*)\.\.([0-9a-f]+)")
BINARY_HEAD = 8000   # git's own content test: a NUL byte in a blob's first 8000 bytes means binary


class Section:
    """One file of one commit's patch, while it is parsed."""
    __slots__ = ("header_path", "path", "new_file", "binary", "nul", "old_ids", "new_id", "items")

    def __init__(self, header_path):
        self.header_path, self.path, self.new_file = header_path, None, False
        self.binary, self.nul, self.old_ids, self.new_id, self.items = False, False, [], None, []


def parse_patch(commit, patch):
    """Content items, path items and the binary-shown sections of one commit's patch (-U0; --cc for
    merges). A section git printed as "Binary files … differ" carries no lines here: collect_items
    decides from the blob itself whether it is truly binary, attributes ignored."""
    items, paths, binaries = [], [], []
    sec = None
    line_no = None   # None: in a file header; else the next result line's number
    cols = 1
    merge = False

    def add_path(p):
        if p and p not in paths:
            paths.append(p)

    def close():
        if sec is None:
            return
        where = sec.path or sec.header_path
        if sec.new_file:
            add_path(where)
        if sec.binary:
            binaries.append((commit, where, sec.old_ids, sec.new_id, merge, None))
        elif sec.nul and sec.new_id:
            # printed as text yet holding a NUL: an attribute forced it; its blob decides
            binaries.append((commit, where, None, sec.new_id, merge, sec.items))
        else:
            items.extend(sec.items)

    for line in patch.split("\n"):
        if line.startswith("diff --git ") or line.startswith("diff --cc ") or line.startswith("diff --combined "):
            close()
            line_no, cols = None, 1
            if line.startswith("diff --git "):
                sec = Section(header_path(line[len("diff --git "):]))
            else:
                merge = True
                sec = Section(unquote(line.split(" ", 2)[2]))
            continue
        if sec is None:
            continue
        if line_no is None:
            if line.startswith("+++ "):
                # git appends a TAB to a ---/+++ name that holds a space (and leaves it unquoted)
                p = line[4:]
                if p.endswith("\t"):
                    p = p[:-1]
                if p != "/dev/null":
                    sec.path = strip_prefix(unquote(p), "b/")
            elif line.startswith("new file mode"):
                sec.new_file = True
            elif line.startswith("index "):
                m = INDEX_LINE.match(line)
                if m:
                    sec.old_ids, sec.new_id = m.group(1).split(","), m.group(2)
            elif line.startswith("rename to ") or line.startswith("copy to "):
                sec.path = unquote(line.split(" ", 2)[2])
                add_path(sec.path)
            elif line.startswith("Binary files "):
                sec.binary = True
                m = re.match(r"^Binary files (.*) and (.*) differ$", line)
                if m and m.group(2) != "/dev/null":
                    sec.path = sec.path or strip_prefix(unquote(m.group(2)), "b/")
            if line.startswith("@@"):
                m = HUNK.match(line)
                if m:
                    cols, line_no = len(m.group(1)) - 1, int(m.group(2))
                    if sec.path is None:
                        sec.path = sec.header_path
            continue
        if line.startswith("@@"):
            m = HUNK.match(line)
            if m:
                cols, line_no = len(m.group(1)) - 1, int(m.group(2))
            continue
        if line.startswith("\\"):
            continue  # "\ No newline at end of file"
        if "\0" in line:
            sec.nul = True
        prefix = line[:cols]
        if "-" in prefix:
            continue  # a removed line is not in the result
        # A line counts as ADDED only when it is new against every parent: one '+' per column. In a
        # merge's combined diff a ' +' / '+ ' line already sits in one parent, which is either an
        # outgoing commit (scanned there) or history the remote holds (never re-judged).
        if prefix == "+" * cols:
            where = "%s:%d" % (sec.path or "?", line_no)
            sec.items.append(Item("content", commit, where, line[cols:], path=sec.path, merge=merge))
        line_no += 1
    close()
    for p in paths:
        items.append(Item("path", commit, "file path " + p, p, path=p))
    return items, binaries


def blob_head(blob_id):
    """The first bytes of a blob — enough for git's binary test, never the whole of a large file."""
    proc = subprocess.Popen(["git", "cat-file", "blob", blob_id], stdout=subprocess.PIPE,
                            stderr=subprocess.DEVNULL, env=ENV)
    head = proc.stdout.read(BINARY_HEAD)
    proc.stdout.close()
    proc.wait()
    return head


def added_from_blobs(old_id, new_id):
    """(line number, text) for each line new_id adds over old_id — a blob-to-blob diff, which has no
    path and therefore no attributes; a missing old blob means every line is added."""
    if old_id is None or ZERO_SHA.match(old_id):
        text = git("cat-file", "blob", new_id)
        lines = text.split("\n")
        if lines and lines[-1] == "":
            lines.pop()
        return list(enumerate(lines, 1))
    out = git("diff", "--no-color", "--no-ext-diff", "--no-textconv", "--text", "-U0", old_id, new_id)
    added, line_no = [], None
    for line in out.split("\n"):
        if line.startswith("@@"):
            m = HUNK.match(line)
            line_no = int(m.group(2)) if m else None
            continue
        if line_no is None or line.startswith("\\"):
            continue
        if line.startswith("+"):
            added.append((line_no, line[1:]))
            line_no += 1
        elif not line.startswith("-"):
            line_no += 1
    return added


def recover_binary_shown(binaries):
    """Attributes never decide what is read. A section git showed as binary (a -diff or binary
    attribute from a committed .gitattributes, $GIT_DIR/info/attributes or a global attributes
    file) is read when its blob is text by git's own content rule; a section an attribute forced to
    text is dropped when its blob is binary by that rule. True binaries are not read (F7: binary
    blobs are an open question for the author)."""
    items = []
    for commit, path, old_ids, new_id, merge, shown_as_text in binaries:
        if not new_id or ZERO_SHA.match(new_id):
            continue
        is_binary = b"\0" in blob_head(new_id)
        if shown_as_text is not None:   # an attribute forced it to text: keep it unless binary
            if not is_binary:
                items.extend(shown_as_text)
            continue
        if is_binary:
            continue
        # Shown as binary, text by content. A merge reads its whole result (stricter than its own lines).
        old = old_ids[0] if (old_ids and not merge and len(old_ids) == 1) else None
        for n, text in added_from_blobs(old, new_id):
            items.append(Item("content", commit, "%s:%d" % (path or "?", n), text, path=path, merge=merge))
    return items


def collect_items(revs, updates):
    items = []
    for local_ref, _local_sha, remote_ref, _remote_sha in updates:
        for ref in {local_ref, remote_ref}:
            if ref and ref != "(delete)":
                items.append(Item("ref", None, "ref name " + ref, ref))
    for _local_ref, local_sha, _remote_ref, _remote_sha in updates:
        if ZERO_SHA.match(local_sha) or object_type(local_sha) != "tag":
            continue
        raw = git("cat-file", "tag", local_sha)
        head, _, message = raw.partition("\n\n")
        for hl in head.splitlines():
            if hl.startswith("tagger "):
                ident = re.sub(r" \d+ [+-]\d{4}$", "", hl[len("tagger "):])
                items.append(Item("identity", local_sha, "tagger identity", ident))
        for n, ml in enumerate(message.splitlines(), 1):
            items.append(Item("message", local_sha, "tag message, line %d" % n, ml))
    if revs is None:
        return items, 0
    # Each record starts with a marker carrying a fresh random nonce: no message or blob byte
    # sequence can forge a record boundary (a NUL can sit in a message, or in a file an attribute
    # forces to text).
    mark = "VXGUARD%s " % secrets.token_hex(16)
    meta = git("log", "--no-color", "--format=" + mark + "%H%x1f%an <%ae>%x1f%cn <%ce>%x1f%B", *revs)
    commits = 0
    for rec in meta.split(mark)[1:]:
        fields = rec.split("\x1f", 3)
        if len(fields) != 4:
            raise Refusal("the commit log could not be read field by field")
        sha, author, committer, body = fields
        commits += 1
        items.append(Item("identity", sha, "author identity", author))
        items.append(Item("identity", sha, "committer identity", committer))
        for n, ml in enumerate(body.rstrip("\n").split("\n"), 1):
            items.append(Item("message", sha, "commit message, line %d" % n, ml))
    patches = git("log", "--no-color", "--no-ext-diff", "--no-textconv", "--full-index", "--src-prefix=a/",
                  "--dst-prefix=b/", "-U0", "-p", "--cc", "--format=" + mark + "%H", *revs)
    binaries = []
    for rec in patches.split(mark)[1:]:
        sha, _, patch = rec.partition("\n")
        found, shown_binary = parse_patch(sha.strip(), patch)
        items.extend(found)
        binaries.extend(shown_binary)
    items.extend(recover_binary_shown(binaries))
    return items, commits


# ---------------------------------------------------------------------------------------------
# The scanners

def private_findings(items, entries, keeps):
    found = []
    for it in items:
        for e in entries:
            if it.scope not in e.scopes:
                continue
            m = e.rx.search(it.text)
            if m is None:
                continue
            if it.scope == "content" and kept(e.cls, it.path, keeps):
                continue
            col = (" col %d" % (m.start() + 1)) if it.scope in ("content", "message") else ""
            found.append((it.commit, it.where + col, e.cls, len(m.group(0)), it.scope))
    return found


def find_gitleaks():
    if os.environ.get("VARIORUM_GUARD_TEST_NO_GITLEAKS") == "1":
        return None
    found = shutil.which("gitleaks")
    if found:
        return found
    for candidate in GITLEAKS_FALLBACKS:
        if os.access(candidate, os.X_OK):
            return candidate
    return None


def gitleaks_flags(ignore_dir):
    # --exit-code 0: findings come back in the JSON report; a non-zero exit is a failed scan.
    # --ignore-gitleaks-allow: an inline gitleaks:allow comment excuses nothing. The ignore path is
    # the caller's empty private dir, so no .gitleaksignore is read (see gitleaks_findings).
    return ["--no-banner", "--redact", "--no-color", "--report-format", "json", "--report-path", "-",
            "--config", GITLEAKS_CONFIG, "--gitleaks-ignore-path", ignore_dir, "--ignore-gitleaks-allow",
            "--exit-code", "0", "--log-level", "error"]


def run_gitleaks(argv, stdin_text, cwd):
    proc = subprocess.run(argv, input=stdin_text.encode("utf-8"), stdout=subprocess.PIPE,
                          stderr=subprocess.PIPE, env=ENV, cwd=cwd)
    if proc.returncode != 0:
        raise Refusal("gitleaks failed (exit %d) \u2014 the push cannot be checked." % proc.returncode)
    out = proc.stdout.decode("utf-8", "replace").strip()
    if not out:
        return []
    try:
        report = json.loads(out)
    except ValueError:
        raise Refusal("gitleaks gave a report this guard cannot read \u2014 the push cannot be checked.")
    return report if isinstance(report, list) else []


def gitleaks_findings(gl, items):
    """Returns (findings, flagged) — flagged: path and ref-name strings gitleaks matched, which the
    report must never print.

    gitleaks reads exactly what the private list reads — every item, one stdin line each — and never
    the clone itself: it runs `gitleaks stdin` from a fresh empty private directory that is also its
    ignore path. So no .gitleaksignore (untracked at the worktree root, committed, or anywhere else),
    no attribute and no log setting of the pushing clone reaches it, and every finding maps back to
    its commit and place by StartLine. (gitleaks rules keyed on a file's own name, such as a .p12
    file, need a path; stdin carries none, so those rules do not fire — the guard's private list and
    its path scope are the road for names.)"""
    found, flagged = [], set()
    if not items:
        return found, flagged
    # One stdin line per item, always: a newline inside an item (a path git quoted with \n) would
    # shift every later finding onto the wrong item.
    text = "\n".join(it.text.replace("\r", " ").replace("\n", " ") for it in items) + "\n"
    with tempfile.TemporaryDirectory(prefix="vx996-gitleaks-") as empty:
        report = run_gitleaks([gl, "stdin", *gitleaks_flags(empty)], text, empty)
    for f in report:
        rule = "gitleaks:%s" % f.get("RuleID", "?")
        try:
            it = items[int(f.get("StartLine", 0)) - 1]
        except (ValueError, IndexError):
            found.append((None, "(scanned text)", rule, None, None))
            continue
        if it.scope in ("path", "ref"):
            flagged.add(it.text)
        found.append((it.commit, it.where, rule, None, it.scope))
    return found, flagged


# ---------------------------------------------------------------------------------------------

def masker(entries, flagged):
    """Masks every private-list match, and every path or ref name gitleaks flagged, in a location."""
    longest_first = sorted(flagged, key=len, reverse=True)

    def mask(s):
        for text in longest_first:
            s = s.replace(text, MASK)
        for e in entries:
            s = e.rx.sub(MASK, s)
        return s
    return mask


def main(argv):
    remote = argv[1] if len(argv) > 1 else "origin"
    url = argv[2] if len(argv) > 2 else remote
    updates = read_updates(sys.stdin)
    if not updates:
        return 0
    try:
        entries, keeps, starter = load_private_list(LIST_PATH)
        gl = find_gitleaks()
        if gl is None:
            raise Refusal("gitleaks is not installed on this Mac, so the push cannot be checked for "
                          "secrets. Installing it is the author's call (brew install gitleaks).")
        if not os.path.isfile(GITLEAKS_CONFIG):
            raise Refusal("the guard's gitleaks config is missing (%s)." % GITLEAKS_CONFIG)
        revs = outgoing_revs(remote, url, updates)
        items, commits = collect_items(revs, updates)
        leaks, flagged = gitleaks_findings(gl, items)
        found = private_findings(items, entries, keeps) + leaks
    except Refusal as why:
        say("%s: REFUSED — %s" % (TAG, why))
        say(BYPASS)
        return 1

    mask = masker(entries, flagged)
    if found:
        seen, rows = set(), []
        for commit, where, cls, length, _scope in found:
            key = (commit, where, cls)
            if key in seen:
                continue
            seen.add(key)
            rows.append((commit, mask(where).replace("\n", "\\n").replace("\t", "\\t"), cls, length))
        say("%s: REFUSED — this push would publish %d match%s (VX-996). Nothing was pushed."
            % (TAG, len(rows), "" if len(rows) == 1 else "es"))
        for commit, where, cls, length in rows[:MAX_SHOWN]:
            size = "" if length is None else "  (%d chars)" % length
            say("  %-10s  %s  [%s]%s" % ((commit or "-")[:10], where, cls, size))
        if len(rows) > MAX_SHOWN:
            say("  … and %d more" % (len(rows) - MAX_SHOWN))
        say("Rewrite the outgoing commits locally so the value never publishes (amend the commit, or "
            "reset and recommit), then push again. A ruled load-bearing value gets a keep line in %s."
            % LIST_SHOWN)
        say(BYPASS)
        return 1
    note = ""
    if starter:
        note = (" — NOTE: the private list is still the starter (class shapes only); fill it "
                "from the private ledger and delete its !starter line")
    say("%s: clean — %d commit%s, messages, identities, paths and ref names scanned (gitleaks + "
        "the private list)%s." % (TAG, commits, "" if commits == 1 else "s", note))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
