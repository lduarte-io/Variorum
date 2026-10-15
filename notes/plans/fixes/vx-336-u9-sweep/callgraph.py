#!/usr/bin/env python3
"""U9's sweep helper (VX-362): a name-based OVER-approximate call graph of
VariorumCore, rooted at every call VariorumMCP makes, reporting which
OperationError cases a wire road can reach. Over-approximation is the point:
a case it calls UNREACHABLE is unreachable for any real call graph (modulo
the parser), so that column is a proof; REACHABLE is a candidate list.

usage: callgraph.py <repo> [--why CASE]
"""
import os, re, sys, json
from collections import defaultdict

repo = sys.argv[1]
why = sys.argv[sys.argv.index('--why') + 1] if '--why' in sys.argv else None

core = os.path.join(repo, 'Sources/VariorumCore')
mcp = os.path.join(repo, 'Sources/VariorumMCP')

err_src = open(os.path.join(core, 'Operations/OperationError.swift')).read()
cases = re.findall(r'^    case ([a-zA-Z]+)', err_src, re.M)
case_set = set(cases)

FUNC_RE = re.compile(r'\bfunc\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?:<[^>]*>)?\s*\(')
INIT_RE = re.compile(r'\binit\s*\??\s*\(')
CALL_RE = re.compile(r'(?<![A-Za-z0-9_])([A-Za-z_][A-Za-z0-9_]*)\s*\(')
# a static/computed property used as a road (e.g. `Queries.x` without parens) is rare; ignore
CASE_RE = re.compile(r'OperationError\.([a-zA-Z]+)')
# `throw .x(` inside an OperationError-typed context
BARE_RE = re.compile(r'throw\s+\.([a-zA-Z]+)')

KEYWORDS = set('if guard while for switch return throw try catch func init case let var in where '
               'self super Self as is do repeat defer await async throws rethrows'.split())


def strip_comments_and_strings(text):
    out = []
    i, n = 0, len(text)
    while i < n:
        c = text[i]
        if text.startswith('//', i):
            j = text.find('\n', i)
            j = n if j < 0 else j
            out.append(' ' * (j - i)); i = j
        elif text.startswith('/*', i):
            j = text.find('*/', i + 2)
            j = n if j < 0 else j + 2
            out.append(re.sub(r'[^\n]', ' ', text[i:j])); i = j
        elif text.startswith('"""', i):
            j = text.find('"""', i + 3)
            j = n if j < 0 else j + 3
            out.append(re.sub(r'[^\n]', ' ', text[i:j])); i = j
        elif c == '"':
            j = i + 1
            while j < n and text[j] != '"' and text[j] != '\n':
                if text[j] == '\\':
                    j += 1
                j += 1
            j = min(n, j + 1)
            out.append(' ' * (j - i)); i = j
        else:
            out.append(c); i += 1
    return ''.join(out)


def functions(path):
    raw = open(path).read()
    text = strip_comments_and_strings(raw)
    found = []
    for m in list(FUNC_RE.finditer(text)) + [(mm, 'init') for mm in INIT_RE.finditer(text)]:
        if isinstance(m, tuple):
            m, name = m
        else:
            name = m.group(1)
        # body: first '{' after the signature, matched
        k = text.find('{', m.end())
        if k < 0:
            continue
        # a protocol requirement has no body before the next decl; accept
        depth, j = 0, k
        while j < len(text):
            if text[j] == '{':
                depth += 1
            elif text[j] == '}':
                depth -= 1
                if depth == 0:
                    break
            j += 1
        body = text[k:j + 1]
        # case usage reads the RAW (comments stripped, strings stripped) body
        line = text.count('\n', 0, m.start()) + 1
        found.append((name, body, f'{os.path.relpath(path, repo)}:{line}'))
    return found


graph = defaultdict(set)      # name -> callee names
throws = defaultdict(set)     # name -> cases
where = defaultdict(list)     # name -> locations
for root, _, files in os.walk(core):
    for f in files:
        if not f.endswith('.swift'):
            continue
        p = os.path.join(root, f)
        for name, body, loc in functions(p):
            where[name].append(loc)
            for c in CALL_RE.findall(body):
                if c not in KEYWORDS:
                    graph[name].add(c)
            for c in CASE_RE.findall(body):
                if c in case_set:
                    throws[name].add(c)
            for c in BARE_RE.findall(body):
                if c in case_set:
                    throws[name].add(c)

# roots: every call made anywhere in VariorumMCP
roots = set()
for root, _, files in os.walk(mcp):
    for f in files:
        if f.endswith('.swift'):
            t = strip_comments_and_strings(open(os.path.join(root, f)).read())
            roots.update(c for c in CALL_RE.findall(t) if c not in KEYWORDS)

reach = {}
parent = {}
stack = [r for r in roots if r in graph]
for r in stack:
    parent[r] = None
seen = set(stack)
while stack:
    f = stack.pop()
    for g in graph.get(f, ()):
        if g in graph and g not in seen:
            seen.add(g); parent[g] = f; stack.append(g)

reachable_cases = defaultdict(list)
for f in seen:
    for c in throws.get(f, ()):
        reachable_cases[c].append(f)

if why:
    for f in sorted(reachable_cases.get(why, [])):
        chain = [f]
        while parent.get(chain[-1]):
            chain.append(parent[chain[-1]])
        print(f'{why}: thrown in {f} ({where[f][0]}) <- ' + ' <- '.join(chain[1:]))
    sys.exit(0)

out = {'reachable': {c: sorted(reachable_cases[c]) for c in cases if c in reachable_cases},
       'unreachable': [c for c in cases if c not in reachable_cases],
       'thrown_nowhere': [c for c in cases if not any(c in throws[f] for f in throws)],
       'roots_in_core': len([r for r in roots if r in graph]), 'functions_reached': len(seen)}
print(json.dumps(out, indent=1))
