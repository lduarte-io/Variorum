#!/usr/bin/env python3
"""Generate castle-key-map.html: self-contained diagrams of Variorum's keys per posture.

Every map shares one layout (You · This Mac · Apple · Variorum server). Chips carry
data-reach (who can open them) so the actor buttons can light them up. No external
resources; light and dark themes via CSS variables.
"""
import html
import sys

E = html.escape

# ---- layout ---------------------------------------------------------------------------
W, H = 1000, 370
COLS = {
    "you":    (10, 150),
    "mac":    (172, 470),
    "apple":  (654, 165),
    "server": (831, 165),
}
BOXES = {
    # id: (col, y, h, title)
    "you":      ("you", 40, 318, "Your head, paper, finger"),
    "keychain": ("mac", 40, 74, "This Mac's Keychain"),
    "folder":   ("mac", 124, 152, "Library folder"),
    "backups":  ("mac", 286, 72, "Backups folder"),
    "ikc":      ("apple", 40, 112, "iCloud Keychain"),
    "idrive":   ("apple", 162, 196, "iCloud Drive"),
    "vault":    ("server", 40, 192, "The vault (keys, locked)"),
    "rows":     ("server", 242, 116, "Synced writing"),
}
COL_TITLES = {"you": "You", "mac": "This Mac", "apple": "Apple (iCloud)", "server": "Variorum server"}

CHIP_H = 34


def slot(box, col_index, row_index, cols=None):
    """Return (x, y, w) for a chip slot inside a box."""
    col, by, bh, _ = BOXES[box]
    cx, cw = COLS[col]
    pad = 10
    if cols is None:
        cols = 3 if col == "mac" else 1
    gap = 8
    w = (cw - 2 * pad - gap * (cols - 1)) / cols
    x = cx + pad + col_index * (w + gap)
    y = by + 26 + row_index * (CHIP_H + 6)
    return x, y, w


def lock_icon(x, y, kind):
    # a small padlock: shackle + body
    return (f'<g class="lock k-{kind}" transform="translate({x:.1f},{y:.1f})">'
            f'<path d="M3 7 V4.5 a3.5 3.5 0 0 1 7 0 V7" fill="none" stroke-width="1.6"/>'
            f'<rect x="1" y="7" width="11" height="8" rx="1.8"/></g>')


def chip(box, ci, ri, text, sub="", kind="file", lockby=None, reach="", state="", cols=None, span=1):
    x, y, w = slot(box, ci, ri, cols)
    if span > 1:
        _, _, w1 = slot(box, 0, ri, cols)
        gap = 8
        w = w1 * span + gap * (span - 1)
    cls = f"chip k-{kind}" + (f" {state}" if state else "")
    parts = [f'<g class="{cls}" data-reach="{E(reach)}">']
    parts.append(f'<rect class="bg" x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{CHIP_H}" rx="7"/>')
    parts.append(f'<rect class="bar" x="{x:.1f}" y="{y:.1f}" width="5" height="{CHIP_H}" rx="2"/>')
    tx = x + 12
    if lockby:
        parts.append(lock_icon(x + 10, y + 9, lockby))
        tx = x + 28
    if sub:
        parts.append(f'<text class="t" x="{tx:.1f}" y="{y + 14:.1f}">{E(text)}</text>')
        parts.append(f'<text class="s" x="{tx:.1f}" y="{y + 27:.1f}">{E(sub)}</text>')
    else:
        parts.append(f'<text class="t" x="{tx:.1f}" y="{y + 21:.1f}">{E(text)}</text>')
    if state == "dead":
        parts.append(f'<line class="strike" x1="{x + 8:.1f}" y1="{y + CHIP_H / 2:.1f}" '
                     f'x2="{x + w - 8:.1f}" y2="{y + CHIP_H / 2:.1f}"/>')
    parts.append("</g>")
    return "".join(parts)


def note(box, ri, text, cls="nt"):
    col, by, bh, _ = BOXES[box]
    cx, cw = COLS[col]
    y = by + 26 + ri * (CHIP_H + 6) + 20
    return f'<text class="{cls}" x="{cx + 14:.1f}" y="{y:.1f}">{E(text)}</text>'


def svg_map(title, chips, notes=(), inactive=()):
    out = [f'<svg class="map" viewBox="0 0 {W} {H}" role="img" aria-label="{E(title)}">']
    for col, (cx, cw) in COLS.items():
        dim = " inactive" if col in inactive else ""
        out.append(f'<text class="colt{dim}" x="{cx + 4}" y="24">{E(COL_TITLES[col])}</text>')
    for bid, (col, by, bh, bt) in BOXES.items():
        cx, cw = COLS[col]
        dim = " inactive" if (col in inactive or bid in inactive) else ""
        out.append(f'<rect class="box{dim}" x="{cx}" y="{by}" width="{cw}" height="{bh}" rx="10"/>')
        out.append(f'<text class="boxt{dim}" x="{cx + 10}" y="{by + 17}">{E(bt)}</text>')
    out.extend(notes)
    out.extend(chips)
    out.append("</svg>")
    return "".join(out)


# ---- the people whose reach the buttons show ------------------------------------------
ACTORS = [
    ("login", "Someone who knows this Mac's login password"),
    ("apple", "Someone who gets into your Apple account"),
    ("server", "The Variorum server (or someone who breaks into it)"),
]

# reach shorthands
LA = "login apple"
L = "login"
A = "apple"
S = "server"


def you_chips(passphrase=True, words=True, finger=False, finger_used=False):
    c = []
    if passphrase:
        c.append(chip("you", 0, 0, "P · passphrase", "in your head" if passphrase is True else passphrase, kind="P"))
    if words:
        c.append(chip("you", 0, 1, "W · twelve words", "on paper" if words is True else words, kind="W"))
    if finger:
        c.append(chip("you", 0, 2, "Your finger", "Touch ID on this Mac", kind="touch"))
    return c


# ---- the maps -------------------------------------------------------------------------
MAPS = {}

# Standard, this Mac only (today)
MAPS["std-local"] = dict(
    title="Standard — this Mac only (today)",
    inactive=("server",),
    chips=you_chips(passphrase="if you set one", words="if you made them") + [
        chip("keychain", 0, 0, "L · silent copy", "opens without asking", kind="L", reach=L),
        chip("folder", 0, 0, "Library file", "encrypted with L", kind="file", reach=L),
        chip("folder", 1, 0, "L · locked with A", "key file", kind="L", lockby="A", reach=LA),
        chip("folder", 2, 0, "L · locked with P", "key file, if set", kind="L", lockby="P"),
        chip("folder", 0, 1, "L · locked with W", "key file, if set", kind="L", lockby="W"),
        chip("backups", 0, 0, "Backups", "each with its key file", kind="file", reach=L),
        chip("ikc", 0, 0, "A · Apple key", "one per Apple account", kind="A", reach=LA),
        chip("idrive", 0, 0, "Backups", "if you picked iCloud", kind="file", reach=LA),
    ],
    notes=[note("vault", 0, "not used — no sync"), note("folder", 2, "The key file holds locked copies only;", "nt"),
           note("folder", 2.45, "on its own it opens nothing.", "nt")],
    roads=[
        ("On this Mac", "the silent copy opens the library — nothing asked."),
        ("On a new Mac", "your Apple key (arrives through iCloud Keychain) opens the key file's Apple lock; or your passphrase or words."),
        ("If everything Apple is lost", "your passphrase or twelve words — if you set them."),
    ],
)

# Standard, synced (today)
MAPS["std-sync"] = dict(
    title="Standard — synced (today)",
    chips=you_chips() + [
        chip("keychain", 0, 0, "L · silent copy", "opens without asking", kind="L", reach=L),
        chip("keychain", 1, 0, "M + C · silent", "the sync keys", kind="M", reach=L),
        chip("folder", 0, 0, "Library file", "encrypted with L", kind="file", reach=L),
        chip("folder", 1, 0, "L · locked with A", "key file", kind="L", lockby="A", reach=LA),
        chip("folder", 2, 0, "L · locked with M", "key file", kind="L", lockby="M", reach=LA),
        chip("folder", 0, 1, "L · locked with P", "key file", kind="L", lockby="P"),
        chip("folder", 1, 1, "L · locked with W", "key file", kind="L", lockby="W"),
        chip("backups", 0, 0, "Backups", "each with its key file", kind="file", reach=L),
        chip("ikc", 0, 0, "A · Apple key", "one per Apple account", kind="A", reach=LA),
        chip("idrive", 0, 0, "Backups", "if you picked iCloud", kind="file", reach=LA),
        chip("vault", 0, 0, "M · locked with P", "", kind="M", lockby="P"),
        chip("vault", 0, 1, "M · locked with W", "", kind="M", lockby="W"),
        chip("vault", 0, 2, "M · locked with A", "the Apple copy", kind="M", lockby="A", reach=LA),
        chip("vault", 0, 3, "C · locked with M", "", kind="C", lockby="M", reach=LA),
        chip("rows", 0, 0, "Your writing", "encrypted with C", kind="file", reach=LA),
        chip("rows", 0, 1, "Some plain facts", "dates, tag shape, sizes", kind="plain", reach=S),
    ],
    roads=[
        ("On this Mac", "the silent copy — nothing asked."),
        ("On a new Mac", "sign in to iCloud and Variorum: the Apple key opens the vault's master, nothing typed."),
        ("The server", "holds only locked keys and encrypted writing — never a key that opens them."),
    ],
)

# Castle, this Mac only (today)
MAPS["castle-local"] = dict(
    title="Castle — this Mac only (today)",
    inactive=("server",),
    chips=you_chips(finger=True) + [
        chip("keychain", 0, 0, "L · Touch ID copy", "or none: Always ask", kind="touch"),
        chip("folder", 0, 0, "Library file", "encrypted with L", kind="file"),
        chip("folder", 1, 0, "L · locked with P", "key file", kind="L", lockby="P"),
        chip("folder", 2, 0, "L · locked with W", "key file", kind="L", lockby="W"),
        chip("folder", 0, 1, "Old key file", "from before Castle", kind="file", state="warn", reach=LA),
        chip("folder", 1, 1, "L0 · locked with A", "beside the library", kind="A", lockby="A", state="warn", reach=LA),
        chip("backups", 0, 0, "Castle-era backups", "locked with P and W", kind="file"),
        chip("backups", 1, 0, "Pre-Castle backups", "locked with A", kind="file", state="warn", reach=LA),
        chip("ikc", 0, 0, "A · Apple key", "never deleted", kind="A", state="warn", reach=LA),
        chip("ikc", 0, 1, "Keychain Access", "login password shows it", kind="plain", state="warn", reach=L),
        chip("idrive", 0, 0, "Pre-Castle backups", "locked with A", kind="file", state="warn", reach=LA),
        chip("idrive", 0, 1, "Castle-era backups", "locked with P and W", kind="file"),
    ],
    notes=[note("vault", 0, "not used — no sync")],
    roads=[
        ("On this Mac", "Touch ID (or your passphrase every time, with Always ask)."),
        ("On a new Mac", "your passphrase or twelve words."),
        ("The gap", "the Apple key is never deleted, so every copy from before Castle still opens through it — and the Mac's login password reveals it in Keychain Access."),
    ],
)

# Castle, synced (today)
MAPS["castle-sync"] = dict(
    title="Castle — synced (today)",
    chips=you_chips(finger=True) + [
        chip("keychain", 0, 0, "L · Touch ID copy", "or none: Always ask", kind="touch"),
        chip("keychain", 1, 0, "M+C · Touch ID copy", "the sync keys", kind="touch"),
        chip("folder", 0, 0, "Library file", "encrypted with L", kind="file"),
        chip("folder", 1, 0, "L · locked with P", "key file", kind="L", lockby="P"),
        chip("folder", 2, 0, "L · locked with W", "key file", kind="L", lockby="W"),
        chip("folder", 0, 1, "L · locked with M", "key file", kind="L", lockby="M"),
        chip("backups", 0, 0, "Castle-era backups", "locked with P, W, M", kind="file"),
        chip("backups", 1, 0, "Pre-Castle backups", "locked with A", kind="file", state="warn", reach=LA),
        chip("ikc", 0, 0, "A · Apple key", "never deleted", kind="A", state="warn", reach=LA),
        chip("ikc", 0, 1, "Keychain Access", "login password shows it", kind="plain", state="warn", reach=L),
        chip("idrive", 0, 0, "Pre-Castle backups", "locked with A", kind="file", state="warn", reach=LA),
        chip("idrive", 0, 1, "Castle-era backups", "locked with P, W, M", kind="file"),
        chip("vault", 0, 0, "M · locked with P", "the new master", kind="M", lockby="P"),
        chip("vault", 0, 1, "M · locked with W", "", kind="M", lockby="W"),
        chip("vault", 0, 2, "No Apple copy", "removed on entering", kind="A", state="dead"),
        chip("vault", 0, 3, "C · locked with M", "new sync key", kind="C", lockby="M"),
        chip("rows", 0, 0, "Your writing", "re-encrypted, new C", kind="file"),
        chip("rows", 0, 1, "Some plain facts", "dates, tag shape, sizes", kind="plain", reach=S),
    ],
    roads=[
        ("On this Mac", "Touch ID, or the passphrase."),
        ("On a new Mac", "sign in, then your passphrase or words once."),
        ("The gap", "the same as this-Mac-only: copies from before Castle still open through the Apple key."),
    ],
)

# The exposed state
MAPS["exposed"] = dict(
    title="“Only this Mac can open your work” (today's exposed state)",
    inactive=("server",),
    chips=[chip("you", 0, 0, "P · passphrase", "none set", kind="P", state="dead"),
           chip("you", 0, 1, "W · twelve words", "none made", kind="W", state="dead")] + [
        chip("keychain", 0, 0, "L · silent copy", "the only way in", kind="L", state="warn", reach=L),
        chip("folder", 0, 0, "Library file", "encrypted with L", kind="file", reach=L),
        chip("folder", 1, 0, "Key file", "holds no locked copy", kind="file", state="dead"),
        chip("backups", 0, 0, "Backups", "key files hold nothing", kind="file", state="warn", reach=L),
        chip("ikc", 0, 0, "No Apple key here", "iCloud Keychain off", kind="A", state="dead"),
    ],
    notes=[note("vault", 0, "not used — no sync")],
    roads=[
        ("On this Mac", "the silent copy is the only road."),
        ("If this Mac is lost", "nothing opens the library or any backup — not even you. (This is W-1's root.)"),
    ],
)

# NEW — Castle
MAPS["castle-new"] = dict(
    title="Castle — the new design",
    chips=you_chips(finger=True) + [
        chip("keychain", 0, 0, "L3 · Touch ID copy", "one item per key", kind="touch"),
        chip("keychain", 1, 0, "M+C · Touch ID copy", "if synced", kind="touch"),
        chip("keychain", 2, 0, "This Mac's memory", "sealed settings", kind="memory"),
        chip("folder", 0, 0, "Library file", "encrypted with L3", kind="file"),
        chip("folder", 1, 0, "L3 · locked with P", "the one key file", kind="L", lockby="P"),
        chip("folder", 2, 0, "L3 · locked with W", "", kind="L", lockby="W"),
        chip("folder", 0, 1, "L3 · locked with M", "if synced", kind="L", lockby="M"),
        chip("folder", 1, 1, "History: L2 L1 L0", "each locked with L3", kind="L", lockby="L", span=2),
        chip("folder", 0, 2, "Plans for long acts", "sealed with L3", kind="memory"),
        chip("backups", 0, 0, "Every backup", "its key file + history", kind="file"),
        chip("backups", 1, 0, "Old Apple locks", "dead — key deleted", kind="A", state="dead"),
        chip("ikc", 0, 0, "Apple key", "deleted everywhere", kind="A", state="dead"),
        chip("idrive", 0, 0, "Backups", "open only with P, W", kind="file"),
        chip("idrive", 0, 1, "or Touch ID", "through the history", kind="file"),
        chip("vault", 0, 0, "M · locked with P", "", kind="M", lockby="P"),
        chip("vault", 0, 1, "M · locked with W", "", kind="M", lockby="W"),
        chip("vault", 0, 2, "C · locked with M", "", kind="C", lockby="M"),
        chip("rows", 0, 0, "Your writing", "encrypted with C", kind="file"),
        chip("rows", 0, 1, "Some plain facts", "dates, tag shape, sizes", kind="plain", reach=S),
    ],
    roads=[
        ("On this Mac", "Touch ID (or the passphrase) opens the library — and, through the history, every older copy, nothing typed."),
        ("On a new Mac", "your passphrase or words; the newest backup's history opens every older one."),
        ("Lose the passphrase, the words and every Touch ID copy", "the library and its older copies are gone. That's the promise, said at the door — export a plain copy first if you want one."),
    ],
)

# NEW — Standard
MAPS["std-new"] = dict(
    title="Standard — the new design",
    chips=you_chips() + [
        chip("keychain", 0, 0, "L · silent copy", "one item per key", kind="L", reach=L),
        chip("keychain", 1, 0, "M + C · silent", "if synced", kind="M", reach=L),
        chip("keychain", 2, 0, "This Mac's memory", "sealed settings", kind="memory"),
        chip("folder", 0, 0, "Library file", "encrypted with L", kind="file", reach=L),
        chip("folder", 1, 0, "L · locked with A", "this library's Apple key", kind="L", lockby="A", reach=LA),
        chip("folder", 2, 0, "L · locked with P", "", kind="L", lockby="P"),
        chip("folder", 0, 1, "L · locked with W", "", kind="L", lockby="W"),
        chip("folder", 1, 1, "History: older keys", "each locked with L", kind="L", lockby="L", reach=LA, span=2),
        chip("backups", 0, 0, "Backups", "key file + history", kind="file", reach=L),
        chip("ikc", 0, 0, "A · Apple key", "named for this library", kind="A", reach=LA),
        chip("ikc", 0, 1, "A · account key", "if synced, own id", kind="A", reach=LA),
        chip("idrive", 0, 0, "Backups", "if you picked iCloud", kind="file", reach=LA),
        chip("vault", 0, 0, "M · locked with P", "", kind="M", lockby="P"),
        chip("vault", 0, 1, "M · locked with W", "", kind="M", lockby="W"),
        chip("vault", 0, 2, "M · locked with A", "the account's key", kind="M", lockby="A", reach=LA),
        chip("vault", 0, 3, "C · locked with M", "", kind="C", lockby="M", reach=LA),
        chip("rows", 0, 0, "Your writing", "encrypted with C", kind="file", reach=LA),
        chip("rows", 0, 1, "Some plain facts", "dates, tag shape, sizes", kind="plain", reach=S),
    ],
    roads=[
        ("On this Mac", "the silent copy — nothing asked."),
        ("On a new Mac", "your Apple account brings everything back, nothing typed."),
        ("What it means", "your Apple account — and anyone with this Mac's login password — can open the library and every copy Variorum keeps. Out of Castle means not safe, said plainly."),
    ],
)


# ---- the history chain ------------------------------------------------------------------
def history_svg():
    w, h = 1000, 150
    keys = [("L3", "today's key"), ("L2", "before Replace All Keys"), ("L1", "entered Castle"), ("L0", "the first key")]
    out = [f'<svg class="map" viewBox="0 0 {w} {h}" role="img" aria-label="the key history chain">']
    x0, gap, cw = 40, 50, 180
    for i, (k, sub) in enumerate(keys):
        x = x0 + i * (cw + gap)
        cls = "chip k-L" if i else "chip k-touch"
        out.append(f'<g class="{cls}"><rect class="bg" x="{x}" y="46" width="{cw}" height="44" rx="8"/>'
                   f'<rect class="bar" x="{x}" y="46" width="5" height="44" rx="2"/>'
                   f'<text class="t big" x="{x + 14}" y="68">{k}</text>'
                   f'<text class="s" x="{x + 14}" y="83">{E(sub)}</text></g>')
        if i < len(keys) - 1:
            ax = x + cw + 6
            out.append(f'<path class="arrow" d="M{ax} 68 H{ax + gap - 12}"/>'
                       f'<path class="arrowhead" d="M{ax + gap - 12} 63 L{ax + gap - 4} 68 L{ax + gap - 12} 73 Z"/>'
                       f'<text class="nt" x="{ax}" y="58">opens</text>')
    out.append('<text class="nt" x="40" y="118">Each newer key holds the one before it, locked. Whatever opens today’s key opens the past —</text>')
    out.append('<text class="nt" x="40" y="134">never the other way round: an old key opens nothing written after it.</text>')
    out.append("</svg>")
    return "".join(out)


# ---- page ---------------------------------------------------------------------------------
CSS = r"""
:root{--bg:#fbfaf7;--fg:#1d1c1a;--muted:#6b675f;--rule:#e3dfd6;--box:#f3f0ea;--chip:#ffffff;--accent:#2f6f62;
--k-L:#1f8a7a;--k-M:#7a52c4;--k-C:#4b5bd1;--k-A:#d17a1f;--k-P:#2f8f3a;--k-W:#24702d;--k-touch:#2f6fd1;--k-file:#8a857b;
--k-memory:#5f6b7a;--k-plain:#9a7b52;--warn:#c4362c;--warnbg:#fdeceb;--hl:#e0a400;--hlbg:#fff4c7}
@media (prefers-color-scheme: dark){:root:not([data-theme="light"]){--bg:#111;--fg:#e9e6df;--muted:#a19c92;--rule:#2d2b27;
--box:#191816;--chip:#1f1e1b;--accent:#7fc4b4;--k-L:#4fc1ae;--k-M:#a98be6;--k-C:#8b97f0;--k-A:#f0a050;--k-P:#6cc477;--k-W:#58ad63;
--k-touch:#6fa3f0;--k-file:#a39e94;--k-memory:#97a3b3;--k-plain:#c7a77a;--warn:#ef6b5f;--warnbg:#2b1715;--hl:#f2c94c;--hlbg:#2c2614}}
:root[data-theme="dark"]{--bg:#111;--fg:#e9e6df;--muted:#a19c92;--rule:#2d2b27;--box:#191816;--chip:#1f1e1b;--accent:#7fc4b4;
--k-L:#4fc1ae;--k-M:#a98be6;--k-C:#8b97f0;--k-A:#f0a050;--k-P:#6cc477;--k-W:#58ad63;--k-touch:#6fa3f0;--k-file:#a39e94;
--k-memory:#97a3b3;--k-plain:#c7a77a;--warn:#ef6b5f;--warnbg:#2b1715;--hl:#f2c94c;--hlbg:#2c2614}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.55 -apple-system,BlinkMacSystemFont,"Helvetica Neue",Helvetica,Arial,sans-serif}
main{max-width:1060px;margin:0 auto;padding:28px 16px 96px}
h1{font-size:30px;line-height:1.2;margin:0 0 6px;font-weight:650}
h2{font-size:22px;margin:46px 0 8px;padding-top:12px;border-top:1px solid var(--rule);font-weight:650}
h3{font-size:17.5px;margin:30px 0 6px;font-weight:650}
p,li{max-width:80ch}.lede{color:var(--muted);margin:0 0 14px}
.legend{display:grid;grid-template-columns:repeat(auto-fill,minmax(230px,1fr));gap:10px;margin:14px 0}
.card{background:var(--box);border:1px solid var(--rule);border-radius:10px;padding:10px 12px 10px 14px;position:relative}
.card:before{content:"";position:absolute;left:0;top:10px;bottom:10px;width:5px;border-radius:3px;background:var(--c)}
.card b{display:block;font-size:15px}.card span{color:var(--muted);font-size:14px}
.actors{position:sticky;top:0;z-index:5;background:var(--bg);padding:10px 0 8px;border-bottom:1px solid var(--rule);
display:flex;flex-wrap:wrap;gap:8px;align-items:center}
.actors .lab{font-size:13px;color:var(--muted);margin-right:4px}
.actors button{font:inherit;font-size:13.5px;border:1px solid var(--rule);background:var(--box);color:var(--fg);
border-radius:999px;padding:5px 12px;cursor:pointer}
.actors button[aria-pressed="true"]{background:var(--hlbg);border-color:var(--hl);font-weight:600}
figure{margin:12px 0 4px}svg.map{width:100%;height:auto;display:block}
.map .colt{font-size:13px;font-weight:700;fill:var(--fg);letter-spacing:.02em}
.map .box{fill:var(--box);stroke:var(--rule)}.map .boxt{font-size:11.5px;fill:var(--muted)}
.map .inactive{opacity:.45}
.map .chip .bg{fill:var(--chip);stroke:var(--c);stroke-width:1.2}
.map .chip .bar{fill:var(--c)}
.map .chip .t{font-size:12px;font-weight:650;fill:var(--fg)}.map .chip .t.big{font-size:15px}
.map .chip .s{font-size:10.5px;fill:var(--muted)}
.map .lock path{stroke:var(--lc)}.map .lock rect{fill:var(--lc)}
.map .chip.warn .bg{stroke:var(--warn);stroke-width:2;fill:var(--warnbg)}
.map .chip.dead{opacity:.55}.map .chip.dead .bg{stroke-dasharray:4 3}
.map .strike{stroke:var(--warn);stroke-width:1.6}
.map .nt{font-size:11px;fill:var(--muted)}
.map .arrow{stroke:var(--muted);stroke-width:1.6;fill:none}.map .arrowhead{fill:var(--muted)}
.k-L{--c:var(--k-L);--lc:var(--k-L)}.k-M{--c:var(--k-M);--lc:var(--k-M)}.k-C{--c:var(--k-C);--lc:var(--k-C)}
.k-A{--c:var(--k-A);--lc:var(--k-A)}.k-P{--c:var(--k-P);--lc:var(--k-P)}.k-W{--c:var(--k-W);--lc:var(--k-W)}
.k-touch{--c:var(--k-touch);--lc:var(--k-touch)}.k-file{--c:var(--k-file);--lc:var(--k-file)}
.k-memory{--c:var(--k-memory);--lc:var(--k-memory)}.k-plain{--c:var(--k-plain);--lc:var(--k-plain)}
.roads{margin:6px 0 0;padding-left:20px}.roads li{margin:3px 0}
.steps{counter-reset:s;list-style:none;padding:0;margin:10px 0}
.steps li{counter-increment:s;position:relative;padding:8px 12px 8px 44px;margin:6px 0;background:var(--box);
border:1px solid var(--rule);border-radius:10px}
.steps li:before{content:counter(s);position:absolute;left:12px;top:8px;width:22px;height:22px;border-radius:50%;
background:var(--accent);color:var(--bg);font-size:13px;font-weight:700;text-align:center;line-height:22px}
.pill{display:inline-block;border:1px solid var(--c);border-left-width:5px;border-radius:6px;padding:0 6px;font-size:13.5px;
background:var(--chip);white-space:nowrap}
.pill.dead{text-decoration:line-through;opacity:.7}
.warnbox{border:1px solid var(--warn);background:var(--warnbg);border-radius:10px;padding:10px 14px;margin:10px 0}
.okbox{border:1px solid var(--accent);border-radius:10px;padding:10px 14px;margin:10px 0}
table{border-collapse:collapse;width:100%;font-size:14px;margin:12px 0;display:block;overflow-x:auto}
th,td{border:1px solid var(--rule);padding:7px 9px;vertical-align:top;text-align:left}th{background:var(--box)}
.y{color:var(--warn);font-weight:700}.n{color:var(--accent);font-weight:700}
.compare{display:grid;grid-template-columns:1fr 1fr;gap:12px}
@media (max-width:760px){.compare{grid-template-columns:1fr}}
body[data-actor] .map .chip{opacity:.28;transition:opacity .15s}
"""

JS = r"""
(function(){
  var buttons=document.querySelectorAll('.actors button');
  function set(actor){
    if(actor){document.body.setAttribute('data-actor',actor);}else{document.body.removeAttribute('data-actor');}
    buttons.forEach(function(b){b.setAttribute('aria-pressed',String(b.dataset.actor===(actor||'')));});
  }
  var m=/actor=(\w+)/.exec(location.hash||'');if(m){set(m[1]);}
  buttons.forEach(function(b){b.addEventListener('click',function(){
    var a=b.dataset.actor; set(document.body.getAttribute('data-actor')===a||!a?null:a);});});
})();
"""


def actor_css():
    rules = []
    for key, _ in ACTORS:
        rules.append(f'body[data-actor="{key}"] .map .chip[data-reach~="{key}"]{{opacity:1}}')
        rules.append(f'body[data-actor="{key}"] .map .chip[data-reach~="{key}"] .bg'
                     f'{{stroke:var(--hl);stroke-width:3;fill:var(--hlbg)}}')
    return "\n".join(rules)


def map_section(key):
    m = MAPS[key]
    roads = "".join(f"<li><b>{E(a)}:</b> {E(b)}</li>" for a, b in m["roads"])
    return (f'<h3 id="{key}">{E(m["title"])}</h3><figure>'
            f'{svg_map(m["title"], m["chips"], m.get("notes", ()), m.get("inactive", ()))}</figure>'
            f'<ul class="roads">{roads}</ul>')


def pill(text, kind, dead=False):
    return f'<span class="pill k-{kind}{" dead" if dead else ""}">{E(text)}</span>'


def page():
    legend = [
        ("L — the library key", "Opens your library file. One per library file; replaced when you enter Castle or replace your keys.", "L"),
        ("P — your passphrase", "In your head. Opens a locked copy of L (and, synced, of the master).", "P"),
        ("W — your twelve words", "On paper. The same power as the passphrase — your way back if you forget it.", "W"),
        ("A — the Apple key", "Lives in iCloud Keychain. Standard's silent road: anyone with your Apple account has it.", "A"),
        ("M — the master key", "One per sync account. Opens the sync key and proves to the server that it's you.", "M"),
        ("C — the sync key", "Encrypts everything sent to the server. The server never holds it unlocked.", "C"),
        ("Touch ID copy", "This Mac's copy of a key, released only to your finger (Castle). Keychain Access can't read it.", "touch"),
        ("Silent copy", "This Mac's copy that opens without asking (Standard). Keychain Access reveals it with the login password.", "L"),
        ("Locked copy (a padlock)", "A key locked with another key. Whoever holds the second key gets the first. A key file is a set of these.", "file"),
        ("What this Mac remembers", "New design: which key is current, the mode, the account, your settings — sealed so edits are caught.", "memory"),
    ]
    legend_html = "".join(
        f'<div class="card" style="--c:var(--k-{k})"><b>{E(t)}</b><span>{E(d)}</span></div>' for t, d, k in legend)
    actors_html = ('<div class="actors"><span class="lab">Light up what this person can open:</span>'
                   + "".join(f'<button type="button" data-actor="{k}" aria-pressed="false">{E(t)}</button>'
                             for k, t in ACTORS)
                   + '<button type="button" data-actor="" aria-pressed="true">Nobody</button></div>')

    enter = [
        f"You type your passphrase and twelve words (they're set now if you have none). The screen says plainly: lose them and every Touch ID copy, and this library and its older copies are gone — export a plain copy first if you want one.",
        f"Synced only: a new master {pill('M', 'M')} and sync key {pill('C', 'C')} are made, your writing on the server is re-encrypted with the new {pill('C', 'C')}, and the vault is rewritten with no Apple copy.",
        f"A new library key {pill('L′', 'L')} is made, and it locks the old one — the old key joins the history.",
        f"The library file is re-encrypted with {pill('L′', 'L')}. The one key file now holds {pill('L′ · locked with P', 'P')} {pill('L′ · locked with W', 'W')} (and {pill('L′ · locked with M', 'M')} if synced) — no Apple lock.",
        f"{pill('L′', 'L')} goes into the {pill('Touch ID copy', 'touch')} (or nowhere, with Always ask); the {pill('silent copy', 'L', True)} is deleted.",
        f"A fresh backup is made under {pill('L′', 'L')}.",
        f"The {pill('Apple key', 'A', True)} is deleted from iCloud Keychain. That reaches every device, with no recovery — so every older copy's Apple lock is dead, wherever the copy is: iCloud Drive, Time Machine, a USB stick.",
        f"Synced: each of your other devices asks for your passphrase once, gets the new keys, re-encrypts its own library, and deletes its own Apple key too.",
    ]
    leave = [
        f"You confirm with Touch ID or the passphrase, after the plain warning: your Apple account — and anyone with this Mac's login password — will be able to open this library and every copy Variorum kept of it, including copies made while you were in Castle.",
        f"A fresh {pill('Apple key', 'A')} is made in iCloud Keychain, with a new id. Only this device makes it; your other devices wait for it to arrive.",
        f"The key file gains {pill('L · locked with A', 'A')}; synced, the vault gains {pill('M · locked with A', 'A')}.",
        f"{pill('L', 'L')} moves from the {pill('Touch ID copy', 'touch')} to a {pill('silent copy', 'L')}.",
        f"Your other devices follow without asking you anything; each adds its own Apple lock when the new key arrives.",
    ]
    follow = [
        f"Another of your devices entered Castle (or replaced the keys). This device notices the vault changed.",
        f"It asks for your passphrase or words — once.",
        f"It gets the new {pill('M', 'M')} and {pill('C', 'C')}, re-encrypts its own library with a new key, puts the old key in the history, and deletes its own Apple key.",
        f"Until you type it, this device still opens and you can write; it just doesn't sync, and a banner says why.",
    ]
    open_old = [
        f"Inside Variorum (already unlocked), you pick an older backup.",
        f"Its key is found through the history — today's key opens the older ones — so nothing is typed. (A backup from another Mac opens with your passphrase or words.)",
        f"The copy is re-encrypted with today's key straight into place; the library you had is kept with your older libraries.",
        f"Your library is back as it was then — in the mode it's in now. A Castle library stays in Castle.",
    ]
    steps = lambda items: '<ol class="steps">' + "".join(f"<li>{i}</li>" for i in items) + "</ol>"

    who_rows = [
        ("You, on your Mac", "opens, nothing asked", "Touch ID or passphrase", "opens, nothing asked", "Touch ID or passphrase"),
        ("You, on a new Mac, with your Apple account only", 'yes', 'the library no — older copies from before Castle yes', 'yes', 'no — needs your passphrase or words'),
        ("You, on a new Mac, with your passphrase or words", "yes", "yes", "yes", "yes"),
        ("Someone who knows this Mac's login password", '<span class="y">everything</span>', 'the library <span class="n">no</span> · pre-Castle copies <span class="y">yes</span> (Keychain Access reveals the Apple key)', '<span class="y">everything</span>', '<span class="n">nothing</span> (Markdown exports you made are plain text)'),
        ("Someone in your Apple account", 'your synced writing and any copy they can reach <span class="y">yes</span>', 'current <span class="n">no</span> · pre-Castle copies <span class="y">yes</span>', '<span class="y">everything Variorum keeps</span>', '<span class="n">nothing</span>'),
        ("The Variorum server", 'your writing <span class="n">no</span> · dates, tags\' shape, sizes yes', 'same', 'same', 'same'),
        ("Someone who steals one backup file", '<span class="n">no</span> (needs a key)', '<span class="n">no</span>', '<span class="n">no</span>', '<span class="n">no</span>'),
    ]
    who_html = ("<table><thead><tr><th>who</th><th>Standard today</th><th>Castle today</th><th>Standard, new</th>"
                "<th>Castle, new</th></tr></thead><tbody>"
                + "".join(f"<tr><td><b>{E(r[0])}</b></td>" + "".join(f"<td>{c}</td>" for c in r[1:]) + "</tr>"
                          for r in who_rows)
                + "</tbody></table>")

    body = f"""
<main>
<h1>Castle key map</h1>
<p class="lede">What each key is, where it lives, what it's locked with, and what the server holds — today, and in the
new design (your rulings of 2026-10-13: retire the Apple key on entering Castle; the key history under today's key).
A companion to <code>second-opinion.html</code>. Every name below is the design's; nothing here is built yet.</p>

<div class="okbox"><b>The whole idea in two lines.</b> In Castle, your Apple account opens nothing of this library —
not the library, not any copy Variorum ever made of it. In Standard, it opens your library and every copy Variorum made
of it. <i>In Castle = safe. Out of Castle = not safe.</i></div>

<h2 id="cast">The cast</h2>
<p>Every key is a random 256-bit number except your passphrase and words, which you hold. A <b>locked copy</b> is one key
locked with another; the padlock's colour says which key opens it. Nothing on the server — and nothing in a key file —
opens anything by itself.</p>
<div class="legend">{legend_html}</div>

<h2 id="how">How to read the maps</h2>
<p>Each map has the same four places: <b>you</b>, <b>this Mac</b> (its Keychain, the library's folder, the backups folder),
<b>Apple</b> (iCloud Keychain and iCloud Drive), and the <b>Variorum server</b>. Red outlines are today's gaps. Struck-out,
dashed chips are keys that don't exist or no longer open anything. Use the buttons to light up what each kind of
intruder could open — the rest fades.</p>
{actors_html}

<h2 id="today">Today</h2>
{map_section("std-local")}
{map_section("std-sync")}
{map_section("castle-local")}
{map_section("castle-sync")}
{map_section("exposed")}

<h2 id="new">The new design</h2>
<p>Three changes do most of the work: <b>the mode is recorded</b>, not guessed from where keys sit; <b>each key has its own
Keychain item</b>, so opening one copy never disturbs another; and <b>each library's older keys travel with it</b>, locked
under today's key. Your D3 ruling adds the fourth: <b>entering Castle deletes the Apple key</b>.</p>
{map_section("castle-new")}
{map_section("std-new")}
<h3 id="history">The key history</h3>
<figure>{history_svg()}</figure>
<p>This is what makes backups simple: a backup made under an older key opens through today's key, on your Mac, with
nothing typed — and on a new Mac, the newest backup's history opens every older backup once you type your passphrase or
words. It's also why W-1 disappears: the old key from the "only this Mac" days rides forward in the history.</p>

<h2 id="moves">Moving between them</h2>
<h3>Entering Castle (new design)</h3>{steps(enter)}
<h3>Leaving Castle (new design)</h3>{steps(leave)}
<h3>Another device follows (synced)</h3>{steps(follow)}
<h3>Opening an older backup</h3>
<div class="compare"><div class="warnbox"><b>Today (VX-209).</b> The backup's own Apple lock opens it silently; this
Mac's one Keychain slot for the library is overwritten with the backup's key; the Touch ID copy is deleted; the
library is now Standard. Bringing your Castle library back finds the silent slot and stays Standard.</div>
<div class="okbox"><b>New design.</b> {steps(open_old)}</div></div>
<h3>Signing in and out, other accounts</h3>
<p>The library records which account it belongs to; signing in or out never changes its mode. Signed in as a
different account, nothing syncs until you choose to move the library there (with that account's mode, asked
first). Your new writing always belongs to the library's account, never to whoever happens to be signed in.</p>

<h2 id="who">Who can open what</h2>
<p>Read across a row. "Copies" means backups, older libraries and Time Machine copies Variorum made. In the
rows about you, plain text: what you can do. In the rows about other people, <span class="y">red</span> means they can
open it and <span class="n">green</span> means they can't.</p>
{who_html}
<p class="lede">Leaving Castle: the Standard column applies from then on — including to copies made while you were in
Castle. Said plainly on the leave screen (your D2 ruling).</p>

<h2 id="changes">What changes from today, in one list</h2>
<ul>
<li>The <b>Apple key is deleted</b> when a library enters Castle, and every copy's Apple lock dies with it (VX-301).</li>
<li>Apple keys are <b>named by their own id</b> — one per library or sync account — and only one device ever makes each,
so two devices can't race to make the same one.</li>
<li><b>One key file per library</b>, carrying the history; no more "the newest file wins".</li>
<li><b>One Keychain item per key</b> (silent or Touch ID), never one slot shared by every copy of the library.</li>
<li>The <b>mode is recorded</b> (inside the library, where only its key can change it) and remembered by this Mac;
opening a copy never lowers it.</li>
<li>Plans for long acts and settings that could weaken protection are <b>sealed</b> with the library's key, so a planted or
edited file is caught.</li>
<li>Backups <b>belong to a library and a Mac</b>, so two Macs sharing an iCloud Drive folder never prune each other's (VX-302).</li>
</ul>
</main>"""
    return (f'<!doctype html><html lang="en"><head><meta charset="utf-8">'
            f'<meta name="viewport" content="width=device-width, initial-scale=1">'
            f'<title>Castle key map</title><style>{CSS}\n{actor_css()}</style></head>'
            f'<body>{body}<script>{JS}</script></body></html>')


if __name__ == "__main__":
    with open(sys.argv[1], "w", encoding="utf-8") as f:
        f.write(page())
    print("wrote", sys.argv[1])
