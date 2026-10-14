#!/usr/bin/env python3
"""Castle key maps — two self-contained pages from one source.

  python3 -I castle-key-map.gen.py full   <out.html>   # today and the new design, for understanding
  python3 -I castle-key-map.gen.py target <out.html>   # ONLY the system the VX-266 plan builds — the acceptance artifact
  python3 -I castle-key-map.gen.py cycle  <out.html>   # the key cycle alone: into Castle and back, as a flow chart

The binding text is notes/plans/vx-266-castle-backups-prelaunch.md (revised at her round-3 rulings, 2026-10-14 —
the anchor keeps the secrets of its day; the release switch — then for the late extra read of round 3: a follower's
anchor under the secret typed at its follow; the leave marked in the vault by the account key's id with no wrap; sync
keys held by what they reach; every own Apple key retired at entering Castle; the key doors' sentences; the Touch ID
re-arm only on an item that exists; the release switch as VX-329): every word here follows its §1, §3 and §4.1.

Every map shares one layout (You · This Mac · Apple · Variorum server). Chip text is HTML
inside the SVG (foreignObject), so key names can be letters or icons (the toggle at the top).
Chips carry data-reach (who can open them) for the "who can open" buttons; "you" is added to
every chip that isn't dead. No external resources; light and dark themes.
"""
import html
import re
import sys

E = html.escape

# ---- layout ---------------------------------------------------------------------------
W, H = 1000, 370
COLS = {"you": (10, 150), "mac": (172, 470), "apple": (654, 165), "server": (831, 165)}
BOXES = {
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
LAYOUT = {"boxes": BOXES, "h": H}   # swapped while the new design's maps and the animation's frames are drawn
CHIP_H = 34

# The new design's maps need room for the anchor, the family tree and this Mac's section (a fourth folder row)
# and for two or three Apple keys (a third iCloud Keychain row).
TH = 410
TBOXES = {
    "you":      ("you", 40, 358, "Your head, paper, finger"),
    "keychain": ("mac", 40, 74, "This Mac's Keychain"),
    "folder":   ("mac", 124, 192, "Library folder"),
    "backups":  ("mac", 326, 72, "Backups folder"),
    "ikc":      ("apple", 40, 152, "iCloud Keychain"),
    "idrive":   ("apple", 202, 196, "iCloud Drive"),
    "vault":    ("server", 40, 192, "The vault (keys, locked)"),
    "rows":     ("server", 242, 156, "Synced writing"),
}


def under(boxes, h, fn, *args):
    """Run fn with another layout in force (chips read the layout when they're made)."""
    old = LAYOUT["boxes"], LAYOUT["h"]
    LAYOUT["boxes"], LAYOUT["h"] = boxes, h
    try:
        return fn(*args)
    finally:
        LAYOUT["boxes"], LAYOUT["h"] = old

# ---- glyphs: letters or icons --------------------------------------------------------------
KEY_NAMES = {"L": "library key", "P": "passphrase", "W": "twelve words", "A": "Apple key",
             "M": "master key", "C": "sync key", "touch": "Touch ID"}
TOKEN_RE = re.compile(r"\{(touch|L|M|C|A|P|W)([^}]*)\}")

ICONS = {
    "L": '<path d="M3 2.5h8.5a1.5 1.5 0 0 1 1.5 1.5v9.5H4.5A1.5 1.5 0 0 1 3 12V2.5z"/>'
         '<path d="M3 12a1.5 1.5 0 0 1 1.5-1.5H13"/><path d="M6 5.5h4.5"/>',
    "P": '<path d="M2.5 4a2 2 0 0 1 2-2h7a2 2 0 0 1 2 2v5a2 2 0 0 1-2 2H7.2L4.5 13.5V11a2 2 0 0 1-2-2z"/>'
         '<circle cx="5.6" cy="6.5" r=".9" class="dot"/><circle cx="8" cy="6.5" r=".9" class="dot"/>'
         '<circle cx="10.4" cy="6.5" r=".9" class="dot"/>',
    "W": '<path d="M4 1.5h5.5l3 3v10H4z"/><path d="M9.5 1.5v3h3"/><path d="M6 7.5h4.5M6 10h4.5M6 12.5h3"/>',
    "A": '<path d="M4.6 12.5h7.3a2.9 2.9 0 0 0 .3-5.8 4 4 0 0 0-7.7-1A3.4 3.4 0 0 0 4.6 12.5z"/>',
    "M": '<path d="M2.5 12.5h11"/><path d="M3.2 12.5 2 5l3.6 3.2L8 3.2l2.4 5L14 5l-1.2 7.5"/>',
    "C": '<path d="M12.8 6.2A5 5 0 0 0 3.6 5"/><path d="M3.2 9.8a5 5 0 0 0 9.2 1.2"/>'
         '<path d="M13 2.6v3.8H9.2"/><path d="M3 13.4V9.6h3.8"/>',
    "touch": '<path d="M4.2 13.2c-.9-1.4-1.4-3-1.4-4.8a5.2 5.2 0 0 1 10.4 0c0 .9-.1 1.7-.3 2.5"/>'
             '<path d="M6.3 14.2c-.7-1.5-1.1-3.2-1.1-4.9a2.8 2.8 0 0 1 5.6 0c0 1.9-.4 3.6-1.1 5"/>'
             '<path d="M8 8.6c0 2-.3 3.9-1 5.5"/>',
}


def icon_defs():
    syms = "".join(f'<symbol id="i-{k}" viewBox="0 0 16 16">{v}</symbol>' for k, v in ICONS.items())
    return f'<svg width="0" height="0" style="position:absolute" aria-hidden="true">{syms}</svg>'


def rich(text):
    """Escape text, turning {L} {L3} {A} {touch} tokens into letter-or-icon glyphs."""
    out, pos = [], 0
    for m in TOKEN_RE.finditer(text):
        out.append(E(text[pos:m.start()]))
        k, suf = m.group(1), m.group(2)
        if k == "touch":
            out.append(f'<span class="g k-touch always" title="{E(KEY_NAMES[k])}"><span class="ico">'
                       f'<svg viewBox="0 0 16 16"><use href="#i-touch"/></svg></span></span>')
            pos = m.end()
            continue
        letter = k
        out.append(f'<span class="g k-{k}" title="{E(KEY_NAMES[k])}"><span class="ltr">{E(letter + suf)}</span>'
                   f'<span class="ico"><svg viewBox="0 0 16 16"><use href="#i-{k}"/></svg>'
                   f'{"<small>" + E(suf) + "</small>" if suf else ""}</span></span>')
        pos = m.end()
    out.append(E(text[pos:]))
    return "".join(out)


# ---- chips ------------------------------------------------------------------------------
def slot(box, ci, ri, cols=None):
    col, by, bh, _ = LAYOUT["boxes"][box]
    cx, cw = COLS[col]
    pad, gap = 10, 8
    if cols is None:
        cols = 3 if col == "mac" else 1
    w = (cw - 2 * pad - gap * (cols - 1)) / cols
    return cx + pad + ci * (w + gap), by + 26 + ri * (CHIP_H + 6), w


def lock_icon(x, y, kind):
    return (f'<g class="lock k-{kind}" transform="translate({x:.1f},{y:.1f})">'
            f'<path d="M3 7 V4.5 a3.5 3.5 0 0 1 7 0 V7" fill="none" stroke-width="1.6"/>'
            f'<rect x="1" y="7" width="11" height="8" rx="1.8"/></g>')


def chip(box, ci, ri, text, sub="", kind="file", lockby=None, reach="", state="", span=1):
    x, y, w = slot(box, ci, ri)
    if span > 1:
        w = w * span + 8 * (span - 1)
    dead = "dead" in state.split()
    full_reach = (reach + ("" if dead else " you")).strip()
    parts = [f'<g class="chip k-{kind}{(" " + state) if state else ""}" data-reach="{E(full_reach)}">',
             f'<rect class="bg" x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{CHIP_H}" rx="7"/>',
             f'<rect class="bar" x="{x:.1f}" y="{y:.1f}" width="5" height="{CHIP_H}" rx="2"/>']
    fx = x + 11
    if lockby:
        parts.append(lock_icon(x + 10, y + 9, lockby))
        fx = x + 27
    sub_html = f'<div class="s">{rich(sub)}</div>' if sub else ""
    parts.append(f'<foreignObject x="{fx:.1f}" y="{y:.1f}" width="{x + w - fx - 3:.1f}" height="{CHIP_H}">'
                 f'<div xmlns="http://www.w3.org/1999/xhtml" class="cc"><div class="t">{rich(text)}</div>'
                 f'{sub_html}</div></foreignObject>')
    if dead:
        parts.append(f'<line class="strike" x1="{x + 8:.1f}" y1="{y + CHIP_H / 2:.1f}" '
                     f'x2="{x + w - 8:.1f}" y2="{y + CHIP_H / 2:.1f}"/>')
    parts.append("</g>")
    return "".join(parts)


def note(box, ri, text):
    col, by, _, _ = LAYOUT["boxes"][box]
    cx, _ = COLS[col]
    return f'<text class="nt" x="{cx + 14:.1f}" y="{by + 26 + ri * (CHIP_H + 6) + 20:.1f}">{E(text)}</text>'


def svg_map(title, chips, notes=(), inactive=()):
    out = [f'<svg class="map" viewBox="0 0 {W} {LAYOUT["h"]}" role="img" aria-label="{E(title)}">']
    for col, (cx, _) in COLS.items():
        dim = " inactive" if col in inactive else ""
        out.append(f'<text class="colt{dim}" x="{cx + 4}" y="24">{E(COL_TITLES[col])}</text>')
    for bid, (col, by, bh, bt) in LAYOUT["boxes"].items():
        cx, cw = COLS[col]
        dim = " inactive" if (col in inactive or bid in inactive) else ""
        out.append(f'<rect class="box{dim}" x="{cx}" y="{by}" width="{cw}" height="{bh}" rx="10"/>'
                   f'<text class="boxt{dim}" x="{cx + 10}" y="{by + 17}">{E(bt)}</text>')
    out.extend(notes)
    out.extend(chips)
    out.append("</svg>")
    return "".join(out)


L_, A_, S_ = "login", "apple", "server"
LA = "login apple"


def you(p="in your head", w="on paper", finger=False, dead_pw=False):
    st = "dead" if dead_pw else ""
    c = [chip("you", 0, 0, "{P} · passphrase", p, kind="P", state=st),
         chip("you", 0, 1, "{W} · twelve words", w, kind="W", state=st)]
    if finger:
        c.append(chip("you", 0, 2, "{touch} · your finger", "on this Mac", kind="touch"))
    return c


# ---- today's maps (the full page) ------------------------------------------------------------
TODAY = {
    "std-local": dict(title="Standard — this Mac only (today)", inactive=("server",), chips=you(
        p="if you set one", w="if you made them") + [
        chip("keychain", 0, 0, "{L} · silent copy", "opens without asking", "L", reach=L_),
        chip("folder", 0, 0, "Library file", "encrypted with {L}", reach=L_),
        chip("folder", 1, 0, "{L} · locked with {A}", "key file", "L", lockby="A", reach=LA),
        chip("folder", 2, 0, "{L} · locked with {P}", "key file, if set", "L", lockby="P"),
        chip("folder", 0, 1, "{L} · locked with {W}", "key file, if set", "L", lockby="W"),
        chip("backups", 0, 0, "Backups", "each with its key file", reach=L_),
        chip("ikc", 0, 0, "{A} · Apple key", "one per Apple account", "A", reach=LA),
        chip("idrive", 0, 0, "Backups", "if you picked iCloud", reach=LA)],
        notes=[note("vault", 0, "not used — no sync")],
        roads=[("On this Mac", "the silent copy opens the library — nothing asked."),
               ("On a new Mac", "your Apple key (through iCloud Keychain) opens the key file's Apple lock; or your passphrase or words."),
               ("If everything Apple is lost", "your passphrase or twelve words — if you set them.")]),
    "std-sync": dict(title="Standard — synced (today)", chips=you() + [
        chip("keychain", 0, 0, "{L} · silent copy", "opens without asking", "L", reach=L_),
        chip("keychain", 1, 0, "{M} + {C} · silent", "the sync keys", "M", reach=L_),
        chip("folder", 0, 0, "Library file", "encrypted with {L}", reach=L_),
        chip("folder", 1, 0, "{L} · locked with {A}", "key file", "L", lockby="A", reach=LA),
        chip("folder", 2, 0, "{L} · locked with {M}", "key file", "L", lockby="M", reach=LA),
        chip("folder", 0, 1, "{L} · locked with {P}", "key file", "L", lockby="P"),
        chip("folder", 1, 1, "{L} · locked with {W}", "key file", "L", lockby="W"),
        chip("backups", 0, 0, "Backups", "each with its key file", reach=L_),
        chip("ikc", 0, 0, "{A} · Apple key", "one per Apple account", "A", reach=LA),
        chip("idrive", 0, 0, "Backups", "if you picked iCloud", reach=LA),
        chip("vault", 0, 0, "{M} · locked with {P}", "", "M", lockby="P"),
        chip("vault", 0, 1, "{M} · locked with {W}", "", "M", lockby="W"),
        chip("vault", 0, 2, "{M} · locked with {A}", "the Apple copy", "M", lockby="A", reach=LA),
        chip("vault", 0, 3, "{C} · locked with {M}", "", "C", lockby="M", reach=LA),
        chip("rows", 0, 0, "Your writing", "encrypted with {C}", reach=LA),
        chip("rows", 0, 1, "Some plain facts", "dates, tag shape, sizes", "plain", reach=S_)],
        roads=[("On this Mac", "the silent copy — nothing asked."),
               ("On a new Mac", "sign in to iCloud and Variorum: the Apple key opens the vault's master, nothing typed."),
               ("The server", "holds only locked keys and encrypted writing — never a key that opens them.")]),
    "castle-local": dict(title="Castle — this Mac only (today)", inactive=("server",), chips=you(finger=True) + [
        chip("keychain", 0, 0, "{L} · Touch ID copy", "or none: Always ask", "touch"),
        chip("folder", 0, 0, "Library file", "encrypted with {L}"),
        chip("folder", 1, 0, "{L} · locked with {P}", "key file", "L", lockby="P"),
        chip("folder", 2, 0, "{L} · locked with {W}", "key file", "L", lockby="W"),
        chip("folder", 0, 1, "Old key file", "from before Castle", state="warn", reach=LA),
        chip("folder", 1, 1, "{L0} · locked with {A}", "beside the library", "A", lockby="A", state="warn", reach=LA),
        chip("backups", 0, 0, "Castle-era backups", "locked with {P} and {W}"),
        chip("backups", 1, 0, "Pre-Castle backups", "locked with {A}", state="warn", reach=LA),
        chip("ikc", 0, 0, "{A} · Apple key", "never deleted", "A", state="warn", reach=LA),
        chip("ikc", 0, 1, "Keychain Access", "login password shows it", "plain", state="warn", reach=L_),
        chip("idrive", 0, 0, "Pre-Castle backups", "locked with {A}", state="warn", reach=LA),
        chip("idrive", 0, 1, "Castle-era backups", "locked with {P} and {W}")],
        notes=[note("vault", 0, "not used — no sync")],
        roads=[("On this Mac", "Touch ID (or your passphrase every time, with Always ask)."),
               ("On a new Mac", "your passphrase or twelve words."),
               ("The gap", "the Apple key is never deleted, so every copy from before Castle still opens through it — and the Mac's login password reveals it in Keychain Access.")]),
    "castle-sync": dict(title="Castle — synced (today)", chips=you(finger=True) + [
        chip("keychain", 0, 0, "{L} · Touch ID copy", "or none: Always ask", "touch"),
        chip("keychain", 1, 0, "{M}+{C} · Touch ID copy", "the sync keys", "touch"),
        chip("folder", 0, 0, "Library file", "encrypted with {L}"),
        chip("folder", 1, 0, "{L} · locked with {P}", "key file", "L", lockby="P"),
        chip("folder", 2, 0, "{L} · locked with {W}", "key file", "L", lockby="W"),
        chip("folder", 0, 1, "{L} · locked with {M}", "key file", "L", lockby="M"),
        chip("backups", 0, 0, "Castle-era backups", "locked with {P}, {W}, {M}"),
        chip("backups", 1, 0, "Pre-Castle backups", "locked with {A}", state="warn", reach=LA),
        chip("ikc", 0, 0, "{A} · Apple key", "never deleted", "A", state="warn", reach=LA),
        chip("ikc", 0, 1, "Keychain Access", "login password shows it", "plain", state="warn", reach=L_),
        chip("idrive", 0, 0, "Pre-Castle backups", "locked with {A}", state="warn", reach=LA),
        chip("idrive", 0, 1, "Castle-era backups", "locked with {P}, {W}, {M}"),
        chip("vault", 0, 0, "{M} · locked with {P}", "the new master", "M", lockby="P"),
        chip("vault", 0, 1, "{M} · locked with {W}", "", "M", lockby="W"),
        chip("vault", 0, 2, "No Apple copy", "removed on entering", "A", state="dead"),
        chip("vault", 0, 3, "{C} · locked with {M}", "new sync key", "C", lockby="M"),
        chip("rows", 0, 0, "Your writing", "re-encrypted, new {C}"),
        chip("rows", 0, 1, "Some plain facts", "dates, tag shape, sizes", "plain", reach=S_)],
        roads=[("On this Mac", "Touch ID, or the passphrase."),
               ("On a new Mac", "sign in, then your passphrase or words once."),
               ("The gap", "the same as this-Mac-only: copies from before Castle still open through the Apple key.")]),
    "exposed": dict(title="“Only this Mac can open your work” (today's exposed state)", inactive=("server",),
                    chips=you(p="none set", w="none made", dead_pw=True) + [
        chip("keychain", 0, 0, "{L} · silent copy", "the only way in", "L", state="warn", reach=L_),
        chip("folder", 0, 0, "Library file", "encrypted with {L}", reach=L_),
        chip("folder", 1, 0, "Key file", "holds no locked copy", state="dead"),
        chip("backups", 0, 0, "Backups", "key files hold nothing", state="warn", reach=L_),
        chip("ikc", 0, 0, "No Apple key here", "iCloud Keychain off", "A", state="dead")],
        notes=[note("vault", 0, "not used — no sync")],
        roads=[("On this Mac", "the silent copy is the only road."),
               ("If this Mac is lost", "nothing opens the library or any backup — not even you. (W-1's root.)")]),
}


# ---- the new design: four target maps (local and synced, Castle and Standard) ----------------
# Drawn in the TBOXES layout. A key is born Castle or Standard and keeps that kind for life: a Castle key only
# ever has a Touch ID item (or none, under Always ask); a Standard key only a silent item and an Apple lock.
def castle_target(synced):
    c = you(finger=True) + [
        chip("keychain", 0, 0, "{L} · Touch ID item", "or none: Always ask", "touch"),
        chip("keychain", 2, 0, "This Mac's memory", "second home: facts, tree", "memory"),
        chip("folder", 0, 0, "Library file", "encrypted with {L}"),
        chip("folder", 1, 0, "{L} · locked with {P}", "the one key file", "L", lockby="P"),
        chip("folder", 2, 0, "{L} · locked with {W}", "the one key file", "L", lockby="W"),
        chip("folder", 1, 1, "History: every older key", "each locked with {L} · the anchor folded in", "L",
             lockby="L", span=2),
        chip("folder", 0, 2, "Record: Castle", "the library's own facts", "memory"),
        chip("folder", 1, 2, "Family tree", "every key · two homes", "memory"),
        chip("folder", 2, 2, "This Mac's section", "its facts' first home", "memory"),
        chip("folder", 0, 3, "Plans for long acts", "sealed, named by the act", "memory"),
        chip("backups", 0, 0, "This Mac's backups", "key file + history"),
        chip("backups", 1, 0, "Old Apple locks", "dead — key retired", "A", state="dead"),
        chip("ikc", 0, 0, "{A} · all this Mac's own", "retired · deleted on sight", "A", state="dead"),
        chip("idrive", 0, 0, "Backups", "{P}, {W}, or the history"),
        chip("idrive", 0, 1, "Markdown export", "off · plain if turned on", "plain"),
    ]
    if synced:
        c += [chip("keychain", 1, 0, "{M}+{C} · Touch ID item", "the sync keys", "touch"),
              chip("folder", 0, 1, "{L} · locked with {M}", "the one key file", "L", lockby="M"),
              chip("folder", 1, 3, "{M} · locked with {W}", "copied from the vault", "M", lockby="W"),
              chip("ikc", 0, 1, "{A} · the account's", "gone with its rotation", "A", state="dead"),
              chip("vault", 0, 0, "{M} · locked with {P}", "", "M", lockby="P"),
              chip("vault", 0, 1, "{M} · locked with {W}", "", "M", lockby="W"),
              chip("vault", 0, 2, "No Apple copy", "removed by the rotation", "A", state="dead"),
              chip("vault", 0, 3, "{C} · locked with {M}", "", "C", lockby="M"),
              chip("rows", 0, 0, "Your writing", "encrypted with {C}"),
              chip("rows", 0, 1, "Some plain facts", "dates, tag shape, sizes", "plain", reach=S_)]
    return c


def std_target(synced):
    c = you(p="in your head, if set", w="on paper, if made") + [
        chip("keychain", 0, 0, "{L} · silent item", "opens without asking", "L", reach=L_),
        chip("keychain", 2, 0, "This Mac's memory", "second home: facts, tree", "memory"),
        chip("folder", 0, 0, "Library file", "encrypted with {L}", reach=L_),
        chip("folder", 1, 0, "{L} · locked with {A}", "this Mac's own {A}", "L", lockby="A", reach=LA),
        chip("folder", 2, 0, "{L} · locked with {P}", "if set", "L", lockby="P"),
        chip("folder", 0, 1, "{L} · locked with {W}", "if made", "L", lockby="W"),
        chip("folder", 1, 1, "History: older keys", "each locked with {L}", "L", lockby="L", reach=LA,
             span=1 if synced else 2),
        chip("folder", 0, 2, "Castle anchor", "the leave day's {P} or {W}", "P", lockby="P",
             span=1 if synced else 2),
        chip("folder", 0, 3, "Record: Standard", "the library's own facts", "memory"),
        chip("folder", 1, 3, "Family tree", "every key · two homes", "memory"),
        chip("folder", 2, 3, "This Mac's section", "its facts' first home", "memory"),
        chip("backups", 0, 0, "Since Standard", "key file + history", reach=L_),
        chip("backups", 1, 0, "Before a leave", "that day's {P} or {W}"),
        chip("backups", 2, 0, "Other libraries'", "own key file + {A}", reach=L_),
        chip("ikc", 0, 0, "{A} · this Mac's own", "locks its key file", "A", reach=LA),
        chip("ikc", 0, 2 if synced else 1, "{A} · other libraries'", "this Mac's own, each", "A", reach=LA),
        chip("idrive", 0, 0, "Since Standard", "backups, if picked", reach=LA),
        chip("idrive", 0, 1, "Before a leave", "backups · that day's {P}, {W}"),
        chip("idrive", 0, 2, "Markdown exports", "plain text, if on", "plain", reach=LA),
    ]
    if not synced:
        c.append(chip("folder", 2, 2, "Plans for long acts", "sealed, named by the act", "memory"))
    if synced:
        c += [chip("keychain", 1, 0, "{M}+{C} · silent item", "the sync keys", "M", reach=L_),
              chip("folder", 2, 1, "{L} · locked with {M}", "the one key file", "L", lockby="M", reach=LA),
              chip("folder", 1, 2, "{M} · locked with {W}", "copied from the vault", "M", lockby="W"),
              chip("folder", 2, 2, "Plans for long acts", "sealed, named by the act", "memory"),
              chip("ikc", 0, 1, "{A} · the account's", "the vault's master only", "A", reach=LA),
              chip("vault", 0, 0, "{M} · locked with {P}", "", "M", lockby="P"),
              chip("vault", 0, 1, "{M} · locked with {W}", "", "M", lockby="W"),
              chip("vault", 0, 2, "{M} · locked with {A}", "the account's key", "M", lockby="A", reach=LA),
              chip("vault", 0, 3, "{C} · locked with {M}", "", "C", lockby="M", reach=LA),
              chip("rows", 0, 0, "Your writing", "encrypted with {C}", reach=LA),
              chip("rows", 0, 1, "Some plain facts", "dates, tag shape, sizes", "plain", reach=S_)]
    return c


OLDER_CASTLE = ("A library already in Castle before this change",
                "until it retires the old shared Apple key, its copies made under that key before Castle still open "
                "through the Apple account — asked once on each device, with a door in Settings ▸ Protection that goes "
                "once pressed. A library entering Castle after this change retires it as Use Castle's last step.")
SENT = ("Sent to another Mac",
        "it lands there under a fresh key with an empty history — nothing is shared. Your passphrase alone, or your "
        "words alone, unlocks the pair, and the landing asks for the other one, typed or made new. Either Mac "
        "entering or leaving Castle later changes nothing on the other.")
SENT_SYNCED = (SENT[0], SENT[1] + " A synced pair lands held, as today: a secret made new at its landing becomes the "
               "account's at Resume Sync, through the account's own forgot road with the secret just typed, and the "
               "landing says so.")
LOST_APPLE = ("If this Mac's own Apple key is lost",
              "an iCloud Keychain reset, or a change of Apple ID: no repair mints a new one. The assessment says the "
              "Apple road is lost and offers Re-link's library arm, which mints a fresh own key for this Mac and "
              "re-locks the key file under it — and every other Standard key file here that needs one, other "
              "libraries' included — re-keying nothing. Local-only libraries get it too. After a change of Apple ID, "
              "copies under the old key keep opening through the former account, for as long as its iCloud Keychain "
              "keeps the key — this Mac can't delete it there; a stated exception, said on their Opens with line.")


def _target_maps():
    return {
        "t-castle-local": dict(
            title="Castle — this Mac only", inactive=("server",), layout=True, chips=castle_target(False),
            notes=[note("vault", 0, "not used — no sync")],
            roads=[("On this Mac", "Touch ID — or your passphrase every time, with Always ask (then no Touch ID item exists)."),
                   ("Older copies", "today's key opens the history, which took everything when the library entered Castle — a Castle anchor from an earlier leave folded back in — so every older backup opens with nothing more typed. An anchor the typed secrets couldn't open (they had changed since that leave) was kept beside the history, unchanged: its copies open with the secrets of its day, and Use Castle's door said which secrets, of which day."),
                   ("On a new Mac", "your passphrase or words; the newest backup's history opens every older one."),
                   SENT,
                   ("Lose the passphrase, the words and every Touch ID item", "the library and every copy are gone — said at the door, with Export a plain copy offered first."),
                   OLDER_CASTLE]),
        "t-castle-sync": dict(
            title="Castle — synced", layout=True, chips=castle_target(True),
            roads=[("On this Mac", "Touch ID, or the passphrase."),
                   ("A new device", "sign in, then your passphrase or words once."),
                   ("Another device follows", "it types your passphrase or your words once, for the new master, and re-keys its own library into a new Castle key whose history takes every older key — and its anchor, when the secret it typed opens it; if not, the anchor is kept beside the history, unchanged. Its new key file is locked with the secret it typed and the new master, with the master's words copy beside it — so the words open it either way, and the passphrase directly when it was the one typed. It deletes every Apple key of its own for the library, records them and the account's as retired, and turns its scheduled Markdown export off."),
                   ("The server", "locked keys and encrypted writing only; no Apple copy anywhere."),
                   ("A device that joined without typing anything", "its key file also holds the master locked with your twelve words, so the words open it even after the master changes."),
                   SENT_SYNCED,
                   ("Leaving the account", "the library re-keys, both secrets typed — the passphrase typed, the words typed or made new. The new key's history takes the old one, so your copies keep opening for you, and any anchor rides along unchanged. The account you left opens only the copies from while it synced in Standard — until it replaces its keys or enters Castle — never what you write after."),
                   OLDER_CASTLE]),
        "t-std-local": dict(
            title="Standard — this Mac only", inactive=("server",), layout=True, chips=std_target(False),
            notes=[note("vault", 0, "not used — no sync")],
            roads=[("On this Mac", "the silent item — nothing asked."),
                   ("On a new Mac", "this Mac's own Apple key for the library arrives through iCloud Keychain (when it's on — Variorum can't see it) and opens the newest backup's key file — or your passphrase or words."),
                   ("What it means", "your Apple account, and anyone who can sign in to this Mac, open the library and every copy Variorum made of it since it came into Standard."),
                   ("After leaving Castle", "that means the library itself — with everything written in it, in Castle too — and every copy made after the leave. No copy made before the leave opens through them: those open with the passphrase or the twelve words you had on the day you left, through the Castle anchor. Leaving never makes new words, so that day's paper keeps working. Your other devices each follow with one secret typed, so their own copies from before open with the words, and with the passphrase when it was the one you typed there to follow; each copy's Opens with line says which, and from which day. A Castle-era copy you open into the library is known by its family tree, takes Standard, and the confirm says its writing will then open through the Apple account."),
                   ("Your passphrase and words", "changing the passphrase, or making new words, re-locks the current key and nothing else. The Castle anchor keeps the secrets of the day you left: it was locked once, when it was written, is never re-locked, and every later re-key carries it unchanged. While there's an anchor, every door that replaces a secret says what still opens the copies from before the leave: new words, Replace All Keys, a leave from an account and sync setup's new words say “Copies from before 12 October still open with the words you're replacing — keep that paper.”; change passphrase says “Copies from before 12 October still open with the passphrase you're replacing, or that day's words.”; and the reset road for a forgotten passphrase says “Copies from before 12 October now open with that day's twelve words — keep that paper.”"),
                   ("Other libraries' copies here", "an older library, or backups, of a library whose newest copy is in Standard: this Mac's own key file for it, beside its copies, under an Apple key of its own — it opens through the Apple account as before. Deleting a library's last copy deletes its key file and its Apple key."),
                   ("Sent to another Mac", "it lands there under a fresh key with an empty history — nothing is shared. If that Mac can read the Apple key that opens the pair, it lands with nothing typed, under an Apple key of that Mac's own, and the passphrase and words are offered as Standard offers them — declined, the confirm says the landed library opens through that Mac and its Apple account only. Otherwise one secret unlocks it and the other is typed or made new."),
                   LOST_APPLE]),
        "t-std-sync": dict(
            title="Standard — synced", layout=True, chips=std_target(True),
            roads=[("On this Mac", "the silent item — nothing asked."),
                   ("A new device", "sign in to iCloud and Variorum: the account's Apple key opens the vault's master, nothing typed (when iCloud Keychain carried it). The device then locks its own key file under an Apple key of its own."),
                   ("What it means", "the same as this-Mac-only, for every device of the account. The account's Apple key locks only the master in the vault; each device's key file is under that device's own."),
                   ("Leaving the account", "the library re-keys: a new key with its silent item, locked under this Mac's existing own Apple key — nothing is minted, as for Replace All Keys, since the account's key never locks the library; the passphrase typed or set new, the words typed or made new. The new key's history takes the old one, and any anchor rides along unchanged. The account you left opens only the copies from while it synced in Standard — until it replaces its keys or enters Castle — never what you write after. The account's Apple key is left to its other devices."),
                   ("Sent to another Mac", "as this-Mac-only — and a synced pair lands held, as today: a secret made new at its landing becomes the account's at Resume Sync, through the account's own forgot road with the secret just typed, and the landing says so."),
                   (LOST_APPLE[0], LOST_APPLE[1] + " The account's own Apple key, when no device can read it, is Re-link's: a fresh account key, landed under the vault's compare-and-set."),
                   ("Accounts from before this change", "their vault stays on the old shared Apple key until they enter Castle or are re-linked; nothing is written under it, and each device locks its own key file under a key of its own.")]),
    }


TARGET = under(TBOXES, TH, _target_maps)


def _new_full_maps():
    return {
        "castle-new": dict(
            title="Castle — the new design (synced parts marked)", layout=True, chips=castle_target(True),
            roads=[("On this Mac", "Touch ID (or the passphrase) opens the library — and, through the history, every older copy, nothing typed. Entering Castle took everything: the old key, its history, and a Castle anchor from an earlier leave, folded back in (or kept beside the history, unchanged, when the typed secrets couldn't open it)."),
                   ("On a new Mac", "your passphrase or words; the newest backup's history opens every older one."),
                   ("Sent to another Mac", "it lands there under a fresh key of its own; nothing is shared."),
                   ("Lose the passphrase, the words and every Touch ID item", "the library and its older copies are gone — said at the door; export a plain copy first if you want one.")]),
        "std-new": dict(
            title="Standard — the new design (synced parts marked)", layout=True, chips=std_target(True),
            roads=[("On this Mac", "the silent item — nothing asked."),
                   ("On a new Mac", "your Apple account brings it back, nothing typed: this Mac's own Apple key opens its key file, and, synced, the account's opens the vault's master — when iCloud Keychain carried them."),
                   ("What it means", "your Apple account — and anyone with this Mac's login password — can open the library and every copy Variorum made of it since it came into Standard. Out of Castle means not safe, said plainly."),
                   ("After leaving Castle", "the library itself opens to them, with everything written in it, in Castle too, and every copy made after the leave. No copy made before the leave does: those open with the passphrase or the twelve words you had on the day you left, through the Castle anchor — leaving never makes new words, so that day's paper keeps working. Your other devices each follow with one secret typed, so their own copies from before open with the words, and with the passphrase when it was the one you typed there to follow; each copy's Opens with line says which, and from which day."),
                   LOST_APPLE]),
    }


NEW_FULL = under(TBOXES, TH, _new_full_maps)


# ---- the history chain ------------------------------------------------------------------
def _hchip(x, y, cw, k, sub, kind, reach="you"):
    return (f'<g class="chip k-{kind}" data-reach="{reach}"><rect class="bg" x="{x}" y="{y}" width="{cw}" height="44" rx="8"/>'
            f'<rect class="bar" x="{x}" y="{y}" width="5" height="44" rx="2"/>'
            f'<foreignObject x="{x + 12}" y="{y}" width="{cw - 16}" height="44"><div xmlns="http://www.w3.org/1999/xhtml" class="cc big">'
            f'<div class="t">{rich(k)}</div><div class="s">{E(sub)}</div></div></foreignObject></g>')


def _harrow(ax, bx, y):
    return (f'<path class="arrow" d="M{ax} {y} H{bx - 8}"/>'
            f'<path class="arrowhead" d="M{bx - 8} {y - 5} L{bx} {y} L{bx - 8} {y + 5} Z"/>'
            f'<text class="nt" x="{ax}" y="{y - 9}">opens</text>')


def history_svg():
    """The history and the Castle anchor: a library that was Standard, entered Castle, replaced its keys there, and left."""
    w, h = 1000, 318
    out = [f'<svg class="map" viewBox="0 0 {w} {h}" role="img" aria-label="the key history and the Castle anchor">',
           '<text class="rowt" x="40" y="24">In Castle — and within any one mode — each newer key holds every older one, '
           'locked.</text>',
           '<text class="nt" x="960" y="24" text-anchor="end">blue bar: born Castle · teal bar: born Standard · a key '
           'keeps its kind for life</text>']
    row_a = [("{L3}", "today's key · Castle", "touch"), ("{L2}", "made entering Castle", "touch"),
             ("{L1}", "Replace All Keys · Standard", "L"), ("{L0}", "the first key · Standard", "L")]
    x0, gap, cw = 40, 50, 180
    for i, (k, sub, kind) in enumerate(row_a):
        x = x0 + i * (cw + gap)
        out.append(_hchip(x, 36, cw, k, sub, kind))
        if i < len(row_a) - 1:
            out.append(_harrow(x + cw + 6, x + cw + gap - 4, 58))
    out.append('<text class="rowt" x="40" y="122">Leaving Castle: the new key starts with an empty history. Everything from '
               'before the leave is sealed in the Castle anchor.</text>')
    out.append(_hchip(40, 154, 160, "{L4}", "Standard · empty history", "L", reach="login apple you"))
    out.append('<rect class="anchorbox" x="226" y="134" width="744" height="84" rx="10"/>'
               '<text class="anchort" x="240" y="150">The Castle anchor — locked once, with the leave day’s passphrase '
               'and words, never anything Apple-reachable</text>')
    ix, igap, icw = 240, 50, 138
    for i, (k, kind) in enumerate([("{L3}", "touch"), ("{L2}", "touch"), ("{L1}", "L"), ("{L0}", "L")]):
        x = ix + i * (icw + igap)
        out.append(_hchip(x, 160, icw, k, "born Castle" if kind == "touch" else "born Standard", kind))
        if i < 3:
            out.append(_harrow(x + icw + 6, x + icw + igap - 4, 182))
    for n, line in enumerate([
            "A key opens older keys, never newer ones: an old key opens nothing written after it. Entering Castle, the new key’s history takes everything —",
            "the old key, its history and the anchor, opened with the secrets typed at the door (or the one typed at a follow); an anchor they can’t open is",
            "kept beside it, unchanged. Within a mode, the history grows and the anchor rides along unchanged. Leaving Castle, or a different library landing,",
            "takes nothing: what came before keeps its own locks. The anchor is locked once, at the leave, and never re-locked — it keeps the secrets of its day.",
            "The family tree — no secrets, two homes — still names every key the library has had, so your own older copies are always known as yours."]):
        out.append(f'<text class="nt" x="40" y="{244 + 16 * n}">{E(line)}</text>')
    out.append("</svg>")
    return "".join(out)


# ---- the switch, animated: a synced library going from Standard to Castle ---------------------
ANIM_H = 450
ANIM_BOXES = {
    "you":      ("you", 40, 398, "Your head, paper, finger"),
    "keychain": ("mac", 40, 114, "This Mac's Keychain"),
    "folder":   ("mac", 164, 192, "Library folder"),
    "backups":  ("mac", 366, 72, "Backups folder"),
    "ikc":      ("apple", 40, 152, "iCloud Keychain"),
    "idrive":   ("apple", 202, 236, "iCloud Drive"),
    "vault":    ("server", 40, 192, "The vault (keys, locked)"),
    "rows":     ("server", 242, 196, "Synced writing"),
}
# The steps of Use Castle (design §3.9), by name, so the chips and the captions agree.
PRESS, ROTATE, NEWKEY, KEYFILE, SWAP, OLDGO, EXPORT, BACKUP, OWNA, SHARED_A, FOLLOWS, FIN = range(1, 13)


def switch_chips(s):
    """The chips at step s (0–12) of a synced library entering Castle. A just-changed chip pulses; a dead one is struck."""
    fin = s == FIN

    def j(*ks):
        return " just" if s in ks else ""
    swapped = s >= SWAP
    c = [chip("you", 0, 0, "{P} · passphrase", "in your head", kind="P", state=j(PRESS).strip()),
         chip("you", 0, 1, "{W} · twelve words", "on paper", kind="W", state=j(PRESS).strip()),
         chip("you", 0, 2, "{touch} · your finger", "on this Mac", kind="touch")]
    # This Mac's Keychain: the old silent items on top, the new Touch ID items below
    if s < OLDGO:
        c += [chip("keychain", 0, 0, "{L} · silent item", "opens without asking", "L", reach=L_),
              chip("keychain", 1, 0, "{M}+{C} · silent item", "the sync keys", "M", reach=L_)]
    elif not fin:
        c += [chip("keychain", 0, 0, "{L} · silent item", "deleted", "L", state="dead" + j(OLDGO)),
              chip("keychain", 1, 0, "{M}+{C} · silent item", "deleted", "M", state="dead" + j(OLDGO))]
    c.append(chip("keychain", 2, 0, "This Mac's memory", "second home: facts, tree", "memory",
                  state=j(OLDGO, EXPORT, OWNA).strip()))
    row = 0 if fin else 1
    if s >= ROTATE:
        c.append(chip("keychain", 1, row, "{M′}+{C′} · Touch ID item", "the new sync keys", "touch",
                      state="new" + j(ROTATE)))
    if s >= NEWKEY:
        c.append(chip("keychain", 0, row, "{L′} · Touch ID item", "made at your press", "touch",
                      state="new" + j(NEWKEY)))
    # The library folder: the library file, the one key file's locked copies, the anchor, the record, the plan
    c.append(chip("folder", 0, 0, "Library file", "encrypted with {L′}" if swapped else "encrypted with {L}",
                  reach="" if swapped else LA, state=j(SWAP).strip()))
    if s < KEYFILE:
        c += [chip("folder", 1, 0, "{L} · locked with {A}", "this Mac's own {A}", "L", lockby="A", reach=LA),
              chip("folder", 2, 0, "{L} · locked with {P}", "the key file", "L", lockby="P"),
              chip("folder", 0, 1, "{L} · locked with {W}", "the key file", "L", lockby="W"),
              chip("folder", 1, 1, "{L} · locked with {M}", "the key file", "L", lockby="M",
                   reach=LA if s < ROTATE else L_),
              chip("folder", 2, 1, "{M} · locked with {W}", "copied from the vault", "M", lockby="W"),
              chip("folder", 0, 2, "History: older keys", "each locked with {L}", "L", lockby="L", reach=LA),
              chip("folder", 1, 2, "Castle anchor", "that leave's {P}, {W}", "P", lockby="P")]
    else:
        if not fin:
            c += [chip("folder", 1, 0, "{L} · locked with {A}", "left the key file", "L", lockby="A",
                       state="dead" + j(KEYFILE)),
                  chip("folder", 1, 2, "Castle anchor", "folded into the history", "P", lockby="P",
                       state="dead" + j(KEYFILE))]
        c += [chip("folder", 2, 0, "{L′} · locked with {P}", "the new key file", "L", lockby="P", state="new" + j(KEYFILE)),
              chip("folder", 0, 1, "{L′} · locked with {W}", "the new key file", "L", lockby="W", state="new" + j(KEYFILE)),
              chip("folder", 1, 1, "{L′} · locked with {M′}", "the new key file", "L", lockby="M", state="new" + j(KEYFILE)),
              chip("folder", 2, 1, "{M′} · locked with {W}", "copied from the vault", "M", lockby="W",
                   state="new" + j(KEYFILE)),
              chip("folder", 0, 2, "History: everything", "each locked with {L′}", "L", lockby="L",
                   state="new" + j(KEYFILE))]
    c.append(chip("folder", 0, 3, "Record: Castle" if swapped else "Record: Standard",
                  "tree gains {L′} · Castle" if swapped else "mode · family tree", "memory", state=j(SWAP).strip()))
    c.append(chip("folder", 1, 3, "This Mac's section", "its facts' first home", "memory",
                  state=j(PRESS, EXPORT, OWNA).strip()))
    planned = PRESS <= s <= SHARED_A
    c.append(chip("folder", 2, 3, "Plan: Use Castle" if planned else "No plan in flight",
                  "named by the act in flight" if planned else "", "memory", state=j(PRESS).strip()))
    # The backups folder: the frozen key files' locked copies
    c.append(chip("backups", 0, 0, "This Mac's backups",
                  "plus a fresh one under {L′}" if s >= BACKUP else "each with a frozen key file",
                  reach=LA if s < OWNA else "", state=("new" + j(BACKUP)) if s >= BACKUP else ""))
    if fin:
        c.append(chip("backups", 1, 0, "Older backups", "via the history", "L", lockby="L"))
    elif s < OWNA:
        c.append(chip("backups", 1, 0, "{L} · locked with {A}", "in each backup", "L", lockby="A", reach=LA))
    else:
        c.append(chip("backups", 1, 0, "{L} · locked with {A}", "its Apple key is gone", "L", lockby="A",
                      state="dead" + j(OWNA)))
    if s < FOLLOWS:
        c.append(chip("backups", 2, 0, "{L} · locked with {M}",
                      "in each backup" if s < OLDGO else "until devices follow",
                      "L", lockby="M", reach=LA if s < ROTATE else (L_ if s < OLDGO else "")))
    elif not fin:
        c.append(chip("backups", 2, 0, "{L} · locked with {M}", "old master gone", "L", lockby="M",
                      state="dead" + j(FOLLOWS)))
    # iCloud Keychain: this Mac's own Apple key for the library, the account's, and (older stores) the old shared one
    if s < OWNA:
        c.append(chip("ikc", 0, 0, "{A} · this Mac's own", "locks its key file", "A", reach=LA))
    else:
        c.append(chip("ikc", 0, 0, "No Apple key" if fin else "{A} · this Mac's own",
                      "of this library" if fin else "all retired · no recovery", "A", state="dead" + j(OWNA)))
    if s < ROTATE:
        c.append(chip("ikc", 0, 1, "{A} · the account's", "the vault's master only", "A", reach=LA))
    elif not fin:
        c.append(chip("ikc", 0, 1, "{A} · the account's", "gone with the rotation", "A", state="dead" + j(ROTATE)))
    if s < SHARED_A:
        c.append(chip("ikc", 0, 2, "{A} · old shared key", "older stores only", "A", reach=LA,
                      state="warn" if s == OWNA else ""))
    elif not fin:
        c.append(chip("ikc", 0, 2, "{A} · old shared key", "retired after the checks", "A",
                      state="dead" + j(SHARED_A)))
    # iCloud Drive: the far folder's backups, and the scheduled Markdown export
    c.append(chip("idrive", 0, 0, "Backups", "if you picked iCloud" if s < OWNA else "open only with you now",
                  reach=LA if s < OWNA else ""))
    if s < EXPORT:
        c.append(chip("idrive", 0, 1, "Scheduled export", "on · plain-text copies", "plain", reach=LA))
    else:
        c.append(chip("idrive", 0, 1, "Scheduled export", "off · one notice", "plain", state="dead" + j(EXPORT)))
    # The server: the vault and the synced writing
    if s < ROTATE:
        c += [chip("vault", 0, 0, "{M} · locked with {P}", "", "M", lockby="P"),
              chip("vault", 0, 1, "{M} · locked with {W}", "", "M", lockby="W"),
              chip("vault", 0, 2, "{M} · locked with {A}", "the account's key", "M", lockby="A", reach=LA),
              chip("vault", 0, 3, "{C} · locked with {M}", "", "C", lockby="M", reach=LA)]
    else:
        c += [chip("vault", 0, 0, "{M′} · locked with {P}", "the new master", "M", lockby="P", state="new" + j(ROTATE)),
              chip("vault", 0, 1, "{M′} · locked with {W}", "", "M", lockby="W", state="new" + j(ROTATE)),
              chip("vault", 0, 2, "No Apple copy", "removed by the rotation", "A", state="dead" + j(ROTATE)),
              chip("vault", 0, 3, "{C′} · locked with {M′}", "the new sync key", "C", lockby="M",
                   state="new" + j(ROTATE))]
    c += [chip("rows", 0, 0, "Your writing", "re-encrypted with {C′}" if s >= ROTATE else "encrypted with {C}",
               reach=LA if s < ROTATE else "", state=j(ROTATE).strip()),
          chip("rows", 0, 1, "Some plain facts", "dates, tag shape, sizes", "plain", reach=S_)]
    return c


Y, N = "y", "n"
SWITCH_CAPS = [
    dict(t="Before: Standard, synced",
         d="Everything since the library came into Standard opens without asking — for you, for anyone who can sign in "
           "to this Mac, and for your Apple account. Each padlock wears the colour of the key that opens it. This "
           "Mac's own Apple key locks this Mac's key file; the account's locks only the master in the vault. This "
           "library left Castle once before, so its key file also holds a Castle anchor (that leave's re-key dropped "
           "any lock under the old shared key from the live key file); and its scheduled Markdown export is on. The "
           "old shared key at the right exists only on stores from before this change, where older copies still carry "
           "a lock under it.",
         who=("everything",
              (Y, "the library and every copy since it came into Standard — through the silent items and the Apple "
                  "keys Keychain Access reveals"),
              (Y, "the same — this Mac's own Apple key opens the key file; the account's opens the vault's master")),
         locks=["{L} locked with this Mac's {A}, {P}, {W} and {M} — in the key file, and in every backup's since "
                "Standard",
                "{M} locked with {P}, {W} and the account's {A} in the vault; {C} locked with {M}",
                "the Castle anchor: everything from before the earlier leave, under the {P} and {W} of that leave's day "
                "only — locked once, never re-locked"]),
    dict(t="You press Use Castle",
         d="You type your passphrase and your twelve words: they'll lock the new keys, and they open the anchor (one "
           "they can't open — they changed since that leave — is kept beside the history, unchanged, and the door "
           "says which secrets, of which day, still open the copies it holds). The "
           "screen says plainly: lose them and every Touch ID item, and this library and its older copies are gone — "
           "Export a plain copy first is offered. It names any copies here locked under an Apple key this Mac can't "
           "delete — one left in an Apple account it no longer uses. On a store from before this change, the old shared key's checks run "
           "here, at the door: a vault still on that key stops Use Castle before anything starts, and the sheet lists "
           "what its retirement would stop opening.",
         who=("everything", (Y, "the same — nothing has changed yet"), (Y, "the same — nothing has changed yet")),
         locks=["nothing yet — a plan is written beside the library, sealed and named by the act in flight in this "
                "Mac's section"]),
    dict(t="New sync keys, and a vault with no Apple copy",
         d="A new master {M′} and sync key {C′} are made and kept in a Touch ID item made at your press. Your writing "
           "on the server is re-encrypted with {C′}, and the vault is rewritten: {M′} locked with your passphrase and "
           "with your words — and no Apple copy. This rotation names no Apple key in the vault, so any device of the "
           "account may complete it, and none ever with an Apple copy. Once it completes, the account's Apple key is "
           "deleted and its id recorded as retired.",
         who=("everything", (Y, "the library and its copies since Standard — the silent items and this Mac's own Apple "
                                "key are still here"),
              (Y, "the library and its copies since Standard, through this Mac's own Apple key — no longer "
                  "the server's copy")),
         locks=["new: {M′} locked with {P} · {M′} locked with {W} · {C′} locked with {M′}",
                "gone: {M} locked with the account's {A} — the vault's Apple copy — and the account's {A} itself"]),
    dict(t="A new library key, born Castle",
         d="A new library key {L′} goes into its own Touch ID item (or nowhere, with Always ask). It is a Castle key "
           "for life: it will never have a silent item or an Apple lock. From now until the swap, backups and other "
           "copies pause, so none can carry a half-made change.",
         who=("everything", (Y, "the library and its copies since Standard — the silent items and this Mac's own Apple "
                                "key are still here"),
              (Y, "the library and its copies since Standard, through this Mac's own Apple key")),
         locks=["new: {L′} in a Touch ID item — only your finger opens it"]),
    dict(t="The new key file — everything comes along",
         d="The one key file is rewritten: {L′} locked with your passphrase, your words and the new master; its "
           "history takes everything — the old key {L}, its history, and the Castle anchor, opened with the passphrase "
           "and words you typed and folded back in; the master's words copy refreshed for {M′}. No Apple lock. From "
           "here, a crash at any point still leaves a road in.",
         who=("everything", (Y, "the library and its copies since Standard — the library file is still under {L}"),
              (Y, "the library and its copies since Standard, through each one's Apple lock on {L}")),
         locks=["new: {L′} locked with {P} · with {W} · with {M′}",
                "new: {L}, its history and the anchor's keys, each locked with {L′} — the history",
                "new: {M′} locked with {W} — the master's words copy",
                "dropped from the live key file: {L} locked with {A} — every backup's key file still has it"]),
    dict(t="The swap — the commit point",
         d="The record, now saying Castle, its family tree naming {L′} as a Castle key, is written into the staged "
           "copy; then the library file is swapped to {L′}. From this moment the library is in Castle. Copies resume, "
           "each carrying a key and a record that match; any copy's act in flight is cleared whenever it's opened.",
         who=("everything", (Y, "copies since Standard only — the silent item's {L} opens them, but not the library"),
              (Y, "copies since Standard only, through their Apple locks")),
         locks=["the library file: now encrypted with {L′}", "the record: Castle; the family tree names {L′}"]),
    dict(t="The old key's copies go",
         d="This Mac's memory follows. The silent items for {L} and the old sync keys are deleted — with any older "
           "per-library items, escrow items and old key files, each only once the history holds its key.",
         who=("everything", (Y, "copies since Standard only — through the Apple keys Keychain Access reveals"),
              (Y, "copies since Standard only, through their Apple locks")),
         locks=["gone: {L} in a silent item · {M}+{C} in a silent item"]),
    dict(t="The scheduled export turns off",
         d="This Mac's scheduled Markdown export turns off, with one notice, so Variorum writes no new plain-text "
           "copy. Turning it back on in Castle is your choice, said at that door; exports already made stay plain "
           "text.",
         who=("everything", (Y, "copies since Standard only — through the Apple keys Keychain Access reveals"),
              (Y, "copies since Standard only, through their Apple locks")),
         locks=["off: the scheduled Markdown export, in this Mac's facts"]),
    dict(t="A fresh backup",
         d="A new backup under {L′}. Its frozen key file carries the history, so every older backup opens through "
           "it, with nothing more typed.",
         who=("everything", (Y, "copies since Standard only — through the Apple keys Keychain Access reveals"),
              (Y, "copies since Standard only, through their Apple locks")),
         locks=["new: a backup whose key file locks {L′} with {P}, {W} and {M′}, with the history"]),
    dict(t="Every Apple key of this Mac's own goes",
         d="Every Apple key of this Mac's own for the library — every id its facts list as its own and not yet "
           "retired, not only the one the key file named: a Mac can hold more than one, since Re-link's library arm "
           "mints one beside a key it couldn't read, and a replacement Mac adopts its predecessor's — is deleted from "
           "iCloud Keychain on every device, with no sheet and no recovery, and each id recorded as retired in this "
           "Mac's facts, so a copy that comes back is deleted on sight. Every backup's Apple lock under them is now "
           "dead: the keys that opened them no longer exist. One left in an Apple account this Mac no longer uses "
           "can't be deleted from here; its copies are the stated exception the door named.",
         who=("everything",
              (N, "nothing — no silent item, no Apple key of this library, and a Touch ID item can't be read (a store "
                  "from before this change: not until step 10)"),
              (N, "nothing — no Apple key and no Apple copy (a store from before this change: not until step 10)")),
         locks=["gone: {A}, every Apple key of this Mac's own for the library",
                "dead: {L} locked with {A}, in every backup's key file"]),
    dict(t="Stores from before this change: the old shared key goes too",
         d="Last, after its checks at the door and the sheet you saw at step 1, the old shared Apple key is retired — "
           "deleted only by the id this device recorded — and every older copy's lock under it is dead too. Its vault "
           "check is read once more here: if an older build's Re-link put a vault back on it in between, the key "
           "stays, and the library lands with the door and the stated exception showing. A store made after this "
           "change never had this key.",
         who=("everything", (N, "nothing"), (N, "nothing")),
         locks=["gone: the old shared Apple key", "dead: every older copy's lock under it"]),
    dict(t="Your other devices follow",
         d="Each of your other devices types your passphrase or your words once, gets {M′} and {C′}, and re-keys its "
           "own library into a new Castle key whose history takes every older key. It deletes every Apple key of its "
           "own for the library, records them and the account's as retired, turns its scheduled export off, and its "
           "silent items go. The old master now opens nothing anywhere.",
         who=("everything, on every device", (N, "nothing, on any device that has followed"), (N, "nothing")),
         locks=["gone: the silent items and own Apple keys on your other devices",
                "dead: {L} locked with {M} in older backups — the old master is gone everywhere"]),
    dict(t="After: Castle",
         d="Only you. Touch ID, your passphrase or your words open {L′}, and through its history every older backup. "
           "Lose all three and it's gone — said at the door, with a plain copy offered first. Leaving Castle later is "
           "another key change: the new key starts with an empty history, everything from before the leave goes into "
           "a Castle anchor that only the passphrase and words of that day open, and your Apple account opens the "
           "library itself — with everything in it — and the copies made after the leave, never a copy from before it.",
         who=("everything — Touch ID, your passphrase or your words", (N, "nothing"), (N, "nothing")),
         locks=["{L′} locked with {P}, {W} and {M′}; the history locked with {L′}",
                "{M′} locked with {P} and {W}; {C′} locked with {M′}",
                "Touch ID items that only your finger opens"]),
]
assert len(SWITCH_CAPS) == FIN + 1


def anim_section():
    svgs = under(ANIM_BOXES, ANIM_H, lambda: [svg_map(f"Entering Castle, step {i}: {cap['t']}", switch_chips(i))
                                              for i, cap in enumerate(SWITCH_CAPS)])
    frames = []
    for i, (svg, cap) in enumerate(zip(svgs, SWITCH_CAPS)):
        you, login, apple = cap["who"]
        who = (f'<b>You</b><span>{rich(you)}</span>'
               f'<b>This Mac’s login password</b><span class="{login[0]}">{rich(login[1])}</span>'
               f'<b>Your Apple account</b><span class="{apple[0]}">{rich(apple[1])}</span>')
        locks = "".join(f"<li>{rich(x)}</li>" for x in cap["locks"])
        frames.append(f'<div class="frame" data-step="{i}"><figure>{svg}</figure>'
                      f'<div class="cap"><h4>{i}. {E(cap["t"])}</h4><p>{rich(cap["d"])}</p>'
                      f'<div class="who">{who}</div><div class="lockh">Locked copies in this step</div>'
                      f'<ul class="locks">{locks}</ul></div></div>')
    dots = "".join(f'<button type="button" data-go="{i}" aria-label="Step {i}">{i}</button>' for i in range(len(SWITCH_CAPS)))
    return ('<p class="lede">A synced library going from Standard to Castle, one step at a time — one that left Castle '
            'once before (so it has a Castle anchor) and has its scheduled Markdown export on. Each padlock wears the '
            'colour of the key that opens it; a struck chip opens nothing any more; a pulsing one just changed. The '
            'buttons at the top still light up what each person can open, at whichever step is showing.</p>'
            '<div class="anim" id="switch-anim" tabindex="0" aria-label="Entering Castle, step by step">'
            '<div class="anim-controls"><button type="button" data-anim="prev">Back</button>'
            '<button type="button" data-anim="play">Play</button><button type="button" data-anim="next">Next</button>'
            f'<span class="dots">{dots}</span></div>{"".join(frames)}</div>')


ANIM_CSS = r"""
.anim{margin:12px 0 6px;border:1px solid var(--rule);border-radius:12px;padding:12px 12px 4px}
.anim:focus{outline:2px solid var(--accent);outline-offset:2px}
.anim-controls{display:flex;flex-wrap:wrap;gap:6px 10px;align-items:center;margin:0 0 6px}
.anim-controls button{font:inherit;font-size:13.5px;border:1px solid var(--rule);background:var(--box);color:var(--fg);
border-radius:999px;padding:5px 12px;cursor:pointer}
.anim-controls .dots{display:flex;flex-wrap:wrap;gap:4px}
.anim-controls .dots button{padding:2px 9px;font-size:12.5px}
.anim-controls .dots button[aria-current="step"]{background:var(--hlbg);border-color:var(--hl);font-weight:650}
.anim .frame{display:none}
.anim .frame.on{display:block;animation:fadein .45s ease-out}
@keyframes fadein{from{opacity:.2}to{opacity:1}}
.map .chip.new .bg{stroke:var(--accent);stroke-width:2.4}
.map .chip.just .bg{stroke-width:3.2}
.map .chip.dead.just .bg{stroke:var(--warn)}
.anim .frame.on .chip.just{animation:pulse 1.6s ease-out 1}
@keyframes pulse{0%{opacity:.15}55%{opacity:1}100%{opacity:1}}
.cap h4{margin:8px 0 4px;font-size:16px}
.cap p{margin:4px 0 8px}
.cap .who{display:grid;grid-template-columns:max-content 1fr;gap:3px 12px;font-size:14px;margin:6px 0 8px}
.cap .who span.y:before{content:"can open: "}
.cap .who span.n:before{content:"can't open: "}
.cap .who span.y{color:var(--warn);font-weight:600}.cap .who span.n{color:var(--accent);font-weight:600}
.cap .lockh{font-size:13px;color:var(--muted);margin-top:6px}
.cap ul.locks{margin:4px 0 6px;padding-left:20px;font-size:14px}
@media (max-width:600px){.cap .who{grid-template-columns:1fr}}
@media (prefers-reduced-motion: reduce){.anim .frame.on,.anim .frame.on .chip.just{animation:none}}
"""

ANIM_JS = r"""
(function(){
  var root=document.getElementById('switch-anim'); if(!root) return;
  var frames=root.querySelectorAll('.frame'), dots=root.querySelectorAll('[data-go]');
  var play=root.querySelector('[data-anim="play"]'), i=0, timer=null;
  function show(n){ i=(n+frames.length)%frames.length;
    frames.forEach(function(f,k){ f.classList.toggle('on',k===i); });
    dots.forEach(function(d,k){ d.setAttribute('aria-current',k===i?'step':'false'); }); }
  function stop(){ if(timer){ clearInterval(timer); timer=null; } play.textContent='Play'; }
  function start(){ stop(); timer=setInterval(function(){ if(i===frames.length-1){ stop(); return; } show(i+1); },5200);
    play.textContent='Pause'; }
  root.querySelector('[data-anim="prev"]').addEventListener('click',function(){ stop(); show(i-1); });
  root.querySelector('[data-anim="next"]').addEventListener('click',function(){ stop(); show(i+1); });
  play.addEventListener('click',function(){ if(timer){ stop(); } else { if(i===frames.length-1){ show(0); } start(); } });
  dots.forEach(function(d){ d.addEventListener('click',function(){ stop(); show(+d.getAttribute('data-go')); }); });
  root.addEventListener('keydown',function(e){
    if(e.key==='ArrowRight'){ stop(); show(i+1); e.preventDefault(); }
    if(e.key==='ArrowLeft'){ stop(); show(i-1); e.preventDefault(); } });
  var m=/step=(\d+)/.exec(location.hash||''); show(m?+m[1]:0);
})();
"""


# ---- the cycle as a flow chart: what you have, the step, what's new, what goes away -------------
def _kind(text):
    m = TOKEN_RE.search(text)
    return m.group(1) if m else "file"


def _pills(items, dead=False):
    """Each item is its text, or (text, kind) where the first key in the text isn't the right colour."""
    out = []
    for x in items:
        text, kind = x if isinstance(x, tuple) else (x, _kind(x))
        out.append(pill(text, kind, dead) + " ")
    return "".join(out)


ANCHOR = ("the Castle anchor · the leave day's {P} or {W}", "P")
OLDER_LEAVE = ("An older build's leave (promise 13's one exception) puts the Castle-era master under the old shared Apple "
               "key with no change of keys; this build never adds to it.")

CYCLE_IN = dict(
    head="Into Castle — a synced library, from Standard",
    start=[("On this Mac", ["{L} · silent item", "{M}+{C} · silent item"]),
           ("The key file", ["{L} · locked with this Mac's {A}", "{L} · locked with {P}", "{L} · locked with {W}",
                             "{L} · locked with {M}", "older keys · locked with {L}", "{M} · locked with {W}",
                             ("the Castle anchor · if you left Castle before", "P")]),
           ("Each backup since Standard", ["{L} · locked with this Mac's {A}", "{L} · locked with {P}", "{L} · locked with {W}",
                             "{L} · locked with {M}"]),
           ("iCloud Keychain", ["{A} · this Mac's own, for this library", "{A} · the account's, for the vault only",
                                "{A} · the old shared key (older stores)"]),
           ("The vault", ["{M} · locked with {P}", "{M} · locked with {W}", "{M} · locked with the account's {A}",
                          "{C} · locked with {M}"]),
           ("This Mac's facts", [("the scheduled Markdown export · on", "plain")]),
           ("Your writing", ["the library file · under {L}", "the synced copy · under {C}"])],
    start_who=((Y, "the library and every copy since it came into Standard"),
               (Y, "the library and every copy since it came into Standard")),
    steps=[
        dict(t="You press Use Castle",
             d="You type your passphrase and your twelve words, and you're told plainly what losing them would cost, "
               "with a plain copy offered first. The door names any copies here locked under an Apple key this Mac "
               "can't delete — one left in an Apple account it no longer uses — with what that means. On a store from "
               "before this change, the old shared key's checks run "
               "here, at the door: a vault still on it stops Use Castle before anything starts.",
             who=((Y, "the same — nothing has changed yet"), (Y, "the same — nothing has changed yet"))),
        dict(t="New sync keys",
             d="A new master and sync key, in a Touch ID item made at your press. Your writing on the server is "
               "re-encrypted, and the vault is rewritten with no Apple copy. The rotation names no Apple key in the "
               "vault, so any device of the account may complete it, and none ever with an Apple copy. Once it "
               "completes, the account's Apple key is deleted and its id recorded as retired.",
             new=["{M′} · locked with {P}", "{M′} · locked with {W}", "{C′} · locked with {M′}",
                  "{M′}+{C′} · Touch ID item", "the synced copy · under {C′}"],
             gone=["{M} · locked with {A} — the vault's Apple copy", "{A} · the account's Apple key",
                   "{M} · locked with {P}", "{M} · locked with {W}", "{C} · locked with {M}"],
             who=((Y, "the library and its copies since Standard"),
                  (Y, "the library and its copies since Standard, through this Mac's own Apple key — not the server's "
                      "copy"))),
        dict(t="A new library key, born Castle",
             d="It goes into a Touch ID item made at your press (or nowhere, with Always ask), and it stays a Castle "
               "key for life. Copies pause until the swap.",
             new=["{L′} · Touch ID item"],
             who=((Y, "the library and its copies since Standard"), (Y, "the library and its copies since Standard"))),
        dict(t="The new key file — everything comes along",
             d="One key file, rewritten around the new key. Its history takes everything: the old key, its history, and "
               "the Castle anchor if there is one, opened with the passphrase and words you typed and folded back in. "
               "So every old backup keeps opening for you. No Apple lock. (An anchor they can't open — they changed "
               "since the leave — is kept beside the history, unchanged, and keeps opening with the secrets of its day; "
               "the door said which secrets, of which day.)",
             new=["{L′} · locked with {P}", "{L′} · locked with {W}", "{L′} · locked with {M′}",
                  "{L}, its history and the anchor's keys · locked with {L′}", "{M′} · locked with {W}"],
             gone=["{L} · locked with this Mac's {A}, {P}, {W}, {M} — from the key file (every backup still has them)",
                   ("the Castle anchor — folded into the history", "P"), "{M} · locked with {W}"],
             who=((Y, "the library and its copies since Standard"), (Y, "the library and its copies since Standard"))),
        dict(t="The swap",
             d="The record, now saying Castle — its family tree naming the new key as a Castle key — goes into the "
               "staged copy; then the library file is swapped to the new key. From here the library is in Castle.",
             new=["the library file · under {L′}", ("the family tree · {L′}, born Castle", "memory")],
             gone=["the library file · under {L}"],
             who=((Y, "copies since Standard only"), (Y, "copies since Standard only"))),
        dict(t="The old key's copies go",
             d="This Mac's memory follows; the old key's silent items go — with any older per-library items, escrow "
               "items and old key files, each once the history holds its key.",
             gone=["{L} · silent item", "{M}+{C} · silent item"],
             who=((Y, "copies since Standard only — through the Apple keys Keychain Access reveals"),
                  (Y, "copies since Standard only"))),
        dict(t="The scheduled export turns off",
             d="This Mac's scheduled Markdown export turns off, with one notice. Turning it back on in Castle is your "
               "choice, said at that door; exports already made stay plain text.",
             gone=[("the scheduled Markdown export", "plain")],
             who=((Y, "copies since Standard only — through the Apple keys Keychain Access reveals"),
                  (Y, "copies since Standard only"))),
        dict(t="A fresh backup",
             d="A new backup under the new key; its key file carries the history.",
             new=["a backup · {L′} locked with {P}, {W}, {M′}, with the history"],
             who=((Y, "copies since Standard only"), (Y, "copies since Standard only"))),
        dict(t="Every Apple key of this Mac's own goes",
             d="Every id this Mac's facts list as its own for the library, not only the one the key file named — a Mac "
               "can hold more than one, after Re-link's library arm or as a replacement Mac — is deleted from iCloud "
               "Keychain on every device, with no sheet and no recovery, and recorded as retired in this Mac's facts, "
               "so a copy that comes back is deleted on sight. One left in an Apple account this Mac no longer uses "
               "can't be deleted from here: its copies are the stated exception the door named.",
             gone=["{A} · every one of this Mac's own, for this library"],
             dead=["{L} · locked with this Mac's {A} — in every backup"],
             who=((N, "nothing (older stores: after the next step)"), (N, "nothing (older stores: after the next step)"))),
        dict(t="Older stores only: the old shared key goes",
             d="Last, after its checks at the door and the sheet you saw there — deleted only by the id this device "
               "recorded. Its vault check is read once more here; an older build's Re-link in between keeps the key, "
               "and the library lands with the door and the stated exception showing.",
             gone=["{A} · the old shared key"], dead=["older copies' locks under it"],
             who=((N, "nothing"), (N, "nothing"))),
        dict(t="Your other devices follow",
             d="Each types your passphrase or your words once, gets the new master, and re-keys its own library into a "
               "new Castle key whose history takes every older key. It deletes every Apple key of its own for the "
               "library, records them and the account's as retired, and turns its scheduled export off, with one notice.",
             gone=["their silent items", "{A} · every key of each device's own, for this library",
                   ("their scheduled Markdown exports", "plain")],
             dead=["{L} · locked with {M} — the old master is gone everywhere"],
             who=((N, "nothing, on any device that has followed"), (N, "nothing"))),
    ],
    end=[("On this Mac", ["{L′} · Touch ID item", "{M′}+{C′} · Touch ID item"]),
         ("The key file", ["{L′} · locked with {P}", "{L′} · locked with {W}", "{L′} · locked with {M′}",
                           "{L}, older keys and the anchor's · locked with {L′}", "{M′} · locked with {W}"]),
         ("The record", [("Castle · the family tree names every key", "memory")]),
         ("Backups", ["new ones · like the key file", "older ones · their own {P} and {W} locks, and the history"]),
         ("iCloud Keychain", ["nothing of this library"]),
         ("The vault", ["{M′} · locked with {P}", "{M′} · locked with {W}", "{C′} · locked with {M′}"]),
         ("Your writing", ["the library file · under {L′}", "the synced copy · under {C′}"])],
    end_who=((N, "nothing"), (N, "nothing")),
)

CYCLE_OUT = dict(
    head="Back to Standard — the same library, leaving Castle",
    start=None,
    steps=[
        dict(t="You press Use Standard",
             d="You type your passphrase and your twelve words — never new words here, so the paper you have keeps "
               "opening what stays behind. You're told plainly: the library itself, with everything you wrote in it "
               "in Castle, opens through your Apple account from now on, and so does every copy made after you leave. "
               "No copy made before you left opens through it — those open with the passphrase or the twelve words you "
               "had on the day you left. Leaving never makes new words, so that day's paper keeps working. Your other "
               "devices each follow with one secret typed, so their own copies from before open with the words, and "
               "with the passphrase when it was the one you typed there to follow; each copy's Opens with line says which, and from "
               "which day.",
             who=((N, "nothing"), (N, "nothing"))),
        dict(t="The Castle anchor, first",
             d="Before anything else is written, the outgoing Castle key and its whole history — and any earlier anchor "
               "kept beside it — are sealed under one fresh anchor key, locked with the passphrase and the words you just "
               "typed — never with anything Apple-reachable. It lives in the key file. It's locked once, here, and never "
               "re-locked: it keeps the secrets of this day, and every later re-key carries it unchanged.",
             new=[("the Castle anchor · {L′} and its whole history", "P"), ("the anchor key · locked with {P}", "P"),
                  ("the anchor key · locked with {W}", "W")],
             who=((N, "nothing"), (N, "nothing"))),
        dict(t="New sync keys — and the vault marked as leaving",
             d="The rotation, as Use Castle's: a new master and sync key; your writing on the server re-encrypted; the "
               "vault rewritten with the new master under your passphrase and your words. Its first write also names "
               "the account's fresh Apple key — minted at your press, in iCloud Keychain before the write — in the "
               "vault's Apple key id, with no wrap: the mark that this rotation is a leave. That write is the commit "
               "point: past it a crash resumes, never rolls back. Every device reads the vault's mode in three states — "
               "a wrap means Standard; an id with no wrap, leaving Castle, in progress; neither, Castle. Sync keys are "
               "held by what they can reach: until the previous corpus key leaves the vault, the new keys and the "
               "previous one are held the Castle way — the account's Touch ID sync item, made at your press and "
               "holding all three, or session memory under Always ask — so no Castle-era key is ever within the login "
               "password's reach.",
             new=["{M″} · locked with {P}", "{M″} · locked with {W}", "{C″} · locked with {M″}",
                  "{A} · the account's, fresh — its id in the vault, no wrap",
                  ("the account's Touch ID sync item, made at your press · {M″}+{C″} and the previous {C′}", "touch"),
                  "the synced copy · under {C″}"],
             gone=["{M′} · locked with {P}", "{M′} · locked with {W}", "{C′} · locked with {M′}",
                   ("{M′}+{C′} · Touch ID item — the account's one item, remade for the new keys", "touch")],
             who=((N, "nothing new — the new sync keys and the previous corpus key are held the Castle way"),
                  (N, "nothing new — the vault names the account's fresh Apple key, with no wrap yet"))),
        dict(t="One write completes the leave — the account's Apple wrap",
             d="One write adds the account's Apple wrap of the new master, under the key the vault names, with the "
               "previous-corpus-key window closed — so no Castle-era corpus key ever sits under anything "
               "Apple-reachable. Only a device that can read that named key makes it: this one, or another device of "
               "the account once iCloud Keychain carries the key there. Other devices walk and re-encrypt, but never "
               "clear the previous key while an id stands with no wrap; if an older build clears it first, the leave "
               "still reads as in progress, and the completing write is then just the wrap. Once the window is closed, "
               "the new sync keys reach nothing Castle-era, so they move to a silent item and the Touch ID item goes. "
               "If this device never finishes, another device of the account finishes it at a press that names it — "
               "“Finish leaving Castle, started on [device] on [day]” — waiting for the named key, and minting a fresh "
               "account key only if it never arrives (the vault's compare-and-set keeps one). A rotation with no id — "
               "Use Castle's, or a Castle Replace All Keys — is completed by any device, and never with an Apple copy.",
             new=["{M″} · locked with the account's {A} — the wrap", "{M″}+{C″} · silent item"],
             gone=[("the account's Touch ID sync item · {M″}+{C″} and {C′}", "touch"),
                   ("the previous {C′} · its window closed", "C")],
             who=((Y, "the server's copy, through the new sync keys' silent item"),
                  (Y, "the server's copy, through the account's Apple wrap"))),
        dict(t="A new library key, born Standard — with an empty history",
             d="It goes into a silent item, with a fresh Apple key of this Mac's own. The rewritten key file locks it "
               "with that Apple key, your passphrase, your words and the new master — and takes nothing back: its "
               "history is empty, and the anchor rides beside it.",
             new=["{L″} · silent item", "{A} · this Mac's own, fresh", "{L″} · locked with this Mac's {A}",
                  "{L″} · locked with {P}", "{L″} · locked with {W}", "{L″} · locked with {M″}",
                  "{M″} · locked with {W}", ("an empty history", "L")],
             gone=["{L′} · locked with {P}, {W}, {M′} — from the key file", "{M′} · locked with {W}"],
             stays=[("{L′} and every key from before the leave — in the anchor, which only the leave day's {P} and {W} "
                     "open", "P")],
             who=((Y, "the server's copy"), (Y, "the server's copy"))),
        dict(t="The swap",
             d="The record, now saying Standard — its family tree naming the new key as a Standard key — goes into the "
               "staged copy; then the library file is swapped to the new key.",
             new=["the library file · under {L″}", ("the family tree · {L″}, born Standard", "memory")],
             gone=["the library file · under {L′}"],
             who=((Y, "the library itself — everything in it, Castle-era writing included — and the server's copy; "
                      "no copy from before the leave"),
                  (Y, "the library itself — everything in it, Castle-era writing included — and the server's copy; "
                      "no copy from before the leave"))),
        dict(t="Castle's Touch ID item goes; a fresh backup",
             d="This Mac's memory follows; the Castle key's Touch ID item goes with its key; a new backup is made under "
               "the new key, its frozen key file carrying the anchor.",
             new=["a backup · {L″} locked with this Mac's {A}, {P}, {W}, {M″}, with the anchor"],
             gone=["{L′} · Touch ID item"],
             who=((Y, "the library and every copy from now on — none from before the leave"),
                  (Y, "the library and every copy from now on — none from before the leave"))),
        dict(t="Your other devices follow",
             d="Each types your passphrase or your words once, through the vault, for the new master — no follow waits "
               "on an Apple key. While the vault reads a rotation in progress — a previous corpus key standing, or an "
               "id with no wrap — a device follows the keys but holds its own library's re-key until the vault reads "
               "Standard or Castle, the keys it takes held the Castle way while the previous corpus key stands, as the acting "
               "device's are. Then it "
               "writes its own anchor first, under two birth-time locks: the secret it just typed — it opened the vault, "
               "so it is current — and its outgoing Castle key itself, in hand since the library is open, with that "
               "key's own locks from its key file copied beside it (the passphrase or words it held the key under, and "
               "the Castle-era master with its words copy). The one secret typed does both jobs, and nothing re-locks "
               "the anchor after it's written. So it opens with the secret typed at the follow and with whatever opened "
               "that device that day; only a device that never had the passphrase typed has an anchor that opens with "
               "the words alone, and its copies' Opens with line says the twelve words. If the vault's master is still "
               "the Castle-era one — an older build left without changing it, and put it under the old shared Apple "
               "key — the master's road is left out. Then a new Standard key with an empty history, its silent item and "
               "a fresh Apple key of its own. Its Castle key's Touch ID item goes. Until then it opens on its Castle key "
               "and you can write; sync waits, with the banner.",
             new=[("each device's anchor · under the secret typed at its follow, and its outgoing Castle key with that "
                   "key's own locks", "P"),
                  "{A} · each device's own, fresh"],
             gone=["their Castle keys' Touch ID items"],
             who=((Y, "the same, on every device that has followed"), (Y, "the same, on every device that has followed"))),
    ],
    end=[("On this Mac", ["{L″} · silent item", "{M″}+{C″} · silent item"]),
         ("The key file", ["{L″} · locked with this Mac's {A}", "{L″} · locked with {P}", "{L″} · locked with {W}",
                           "{L″} · locked with {M″}", "{M″} · locked with {W}", ("no history yet", "L"), ANCHOR]),
         ("The record", [("Standard · the family tree names every key, Castle's too", "memory")]),
         ("iCloud Keychain", ["{A} · this Mac's own, fresh", "{A} · the account's, fresh"]),
         ("The vault", ["{M″} · locked with {P}", "{M″} · locked with {W}", "{M″} · locked with the account's {A}",
                        "{C″} · locked with {M″}"]),
         ("Stays behind", [("every key from before the leave — in the anchor, and in each older backup's own {P} and "
                            "{W} locks", "P")])],
    end_who=((Y, "the library itself, with everything in it, and every copy from the leave on — no copy from before it"),
             (Y, "the library itself, with everything in it, and every copy from the leave on — no copy from before it")),
)


def _who(pair):
    (lc, lt), (ac, at) = pair
    return (f'<div class="fwho"><span>This Mac’s login password: <b class="{lc}">{rich(lt)}</b></span>'
            f'<span>Your Apple account: <b class="{ac}">{rich(at)}</b></span></div>')


def _inv(groups):
    return '<div class="inv">' + "".join(f'<div class="g">{E(g)}</div><div>{_pills(items)}</div>' for g, items in groups) + "</div>"


def _flow(c, start_title):
    out = ['<div class="flow">']
    if c["start"]:
        out.append(f'<div class="fcard edge"><div class="fh">{E(start_title)}</div>{_inv(c["start"])}{_who(c["start_who"])}</div>')
        out.append('<div class="farrow" aria-hidden="true">↓</div>')
    for n, st in enumerate(c["steps"], 1):
        rows = ""
        if st.get("new"):
            rows += f'<div class="frow"><span class="flab plus">＋ new</span>{_pills(st["new"])}</div>'
        if st.get("gone"):
            rows += f'<div class="frow"><span class="flab minus">− goes away</span>{_pills(st["gone"], True)}</div>'
        if st.get("dead"):
            rows += f'<div class="frow"><span class="flab minus">⊘ stops opening</span>{_pills(st["dead"], True)}</div>'
        if st.get("stays"):
            rows += f'<div class="frow"><span class="flab stay">◆ stays behind</span>{_pills(st["stays"])}</div>'
        out.append(f'<div class="fcard"><div class="fnum">{n}</div><div class="fbody"><div class="ft">{E(st["t"])}</div>'
                   f'<p>{rich(st["d"])}</p>{rows}{_who(st["who"])}</div></div>')
        out.append('<div class="farrow" aria-hidden="true">↓</div>')
    out.append(f'<div class="fcard edge"><div class="fh">You end with</div>{_inv(c["end"])}{_who(c["end_who"])}</div>')
    out.append("</div>")
    return "".join(out)


def cycle_section(older_line=False):
    return ('<p class="lede">The whole cycle as a flow: what you have, what each step does, what’s new, what goes away, '
            'and who else can open your library after it. Both crossings make a fresh key, born Castle or Standard for '
            'life. Into Castle, everything older comes along; out of Castle, nothing does — what came before goes into '
            'the Castle anchor, which only the passphrase and words you had that day open (on a device that followed, '
            'the secret typed at its follow and whatever opened that device that day): it keeps the secrets of its '
            'day, and every later re-key carries it unchanged. Each pill wears the colour of its key; a struck pill is '
            'gone or opens nothing any more.</p>'
            f'<h4 class="cyh">{E(CYCLE_IN["head"])}</h4>{_flow(CYCLE_IN, "You start with")}'
            f'<h4 class="cyh">{E(CYCLE_OUT["head"])}</h4><p class="lede">You start where the flow above ended.</p>'
            f'{_flow(CYCLE_OUT, "")}'
            + (f'<p class="lede">{E(OLDER_LEAVE)}</p>' if older_line else ''))


CYCLE_CSS = r"""
.flow{max-width:880px;margin:8px 0 18px}
.fcard{display:grid;grid-template-columns:34px 1fr;gap:6px 12px;border:1px solid var(--rule);border-radius:12px;
padding:10px 14px;background:var(--box)}
.fcard.edge{display:block;background:var(--chip);border-color:var(--accent)}
.fcard .fh{font-weight:650;font-size:15.5px;margin-bottom:6px}
.fnum{width:28px;height:28px;border-radius:50%;background:var(--accent);color:var(--bg);font-weight:700;font-size:14px;
display:flex;align-items:center;justify-content:center;margin-top:1px}
.fbody .ft{font-weight:650;font-size:15.5px}
.fbody p{margin:2px 0 6px;font-size:14.5px}
.frow{display:flex;flex-wrap:wrap;gap:5px 6px;align-items:center;margin:4px 0}
.flab{font-size:12.5px;font-weight:650;min-width:104px;color:var(--muted)}
.flab.plus{color:var(--accent)}.flab.minus{color:var(--warn)}.flab.stay{color:var(--k-M)}
.fwho{font-size:13.5px;margin-top:6px;display:flex;flex-wrap:wrap;gap:3px 22px;color:var(--muted)}
.fwho b.y{color:var(--warn)}.fwho b.n{color:var(--accent)}
.farrow{text-align:center;color:var(--muted);font-size:18px;line-height:1;margin:5px 0}
.inv{display:grid;grid-template-columns:max-content 1fr;gap:5px 14px;align-items:start}
.inv .g{font-size:13px;color:var(--muted);padding-top:3px}
.cyh{font-size:16px;margin:16px 0 4px}
@media (max-width:600px){.inv{grid-template-columns:1fr}.flab{min-width:0}}
"""


def cycle_page():
    body = f"""<main>
<h1>Castle key cycle</h1>
<p class="lede">What happens to every key when a synced library goes into Castle, and back out to Standard — step by
step. The binding text is <code>notes/plans/vx-266-castle-backups-prelaunch.md</code>; the full map is
<code>castle-target-key-map.html</code>.</p>
<div class="okbox"><b>A fresh key at every crossing.</b> Into or out of Castle, out of an account, onto another Mac —
plus Replace All Keys and the follow. A key is born Castle or Standard and keeps that kind for life: a Castle key only
ever has a Touch ID item (or none, under Always ask); a Standard key only a silent item and an Apple lock. Into Castle,
every older copy comes along. Out of an account, your copies come along too, and the account you left keeps only what
came before. Out of Castle and onto another Mac, the new key starts clean: what came before keeps its own locks.</div>
<h2 id="cast">The cast</h2>
{legend()}
<h2 id="cycle">The cycle, step by step</h2>
{cycle_section(older_line=True)}
<h2 id="watch">The same, on the map</h2>
{controls()}
{anim_section()}
</main>"""
    return html_page("Castle key cycle", body)


# ---- shared page parts ---------------------------------------------------------------------
CSS = r"""
:root{--bg:#fbfaf7;--fg:#1d1c1a;--muted:#6b675f;--rule:#e3dfd6;--box:#f3f0ea;--chip:#ffffff;--accent:#2f6f62;
--k-L:#1f8a7a;--k-M:#7a52c4;--k-C:#4b5bd1;--k-A:#d17a1f;--k-P:#2f8f3a;--k-W:#24702d;--k-touch:#2f6fd1;--k-file:#8a857b;
--k-memory:#5f6b7a;--k-plain:#9a7b52;--warn:#c4362c;--warnbg:#fdeceb;--hl:#e0a400;--hlbg:#fff4c7;--you:#2f6f62;--youbg:#e7f3ef}
@media (prefers-color-scheme: dark){:root:not([data-theme="light"]){--bg:#111;--fg:#e9e6df;--muted:#a19c92;--rule:#2d2b27;
--box:#191816;--chip:#1f1e1b;--accent:#7fc4b4;--k-L:#4fc1ae;--k-M:#a98be6;--k-C:#8b97f0;--k-A:#f0a050;--k-P:#6cc477;--k-W:#58ad63;
--k-touch:#6fa3f0;--k-file:#a39e94;--k-memory:#97a3b3;--k-plain:#c7a77a;--warn:#ef6b5f;--warnbg:#2b1715;--hl:#f2c94c;--hlbg:#2c2614;
--you:#7fc4b4;--youbg:#16302a}}
:root[data-theme="dark"]{--bg:#111;--fg:#e9e6df;--muted:#a19c92;--rule:#2d2b27;--box:#191816;--chip:#1f1e1b;--accent:#7fc4b4;
--k-L:#4fc1ae;--k-M:#a98be6;--k-C:#8b97f0;--k-A:#f0a050;--k-P:#6cc477;--k-W:#58ad63;--k-touch:#6fa3f0;--k-file:#a39e94;
--k-memory:#97a3b3;--k-plain:#c7a77a;--warn:#ef6b5f;--warnbg:#2b1715;--hl:#f2c94c;--hlbg:#2c2614;--you:#7fc4b4;--youbg:#16302a}
*{box-sizing:border-box}
body{margin:0;background:var(--bg);color:var(--fg);font:16px/1.55 -apple-system,BlinkMacSystemFont,"Helvetica Neue",Helvetica,Arial,sans-serif}
main{max-width:1060px;margin:0 auto;padding:28px 16px 96px}
h1{font-size:30px;line-height:1.2;margin:0 0 6px;font-weight:650}
h2{font-size:22px;margin:46px 0 8px;padding-top:12px;border-top:1px solid var(--rule);font-weight:650}
h3{font-size:17.5px;margin:30px 0 6px;font-weight:650}
p,li{max-width:80ch}.lede{color:var(--muted);margin:0 0 14px}
code{font:13.5px/1.4 ui-monospace,SFMono-Regular,Menlo,monospace;background:var(--box);padding:1px 5px;border-radius:4px}
.legend{display:grid;grid-template-columns:repeat(auto-fill,minmax(230px,1fr));gap:10px;margin:14px 0}
.card{background:var(--box);border:1px solid var(--rule);border-radius:10px;padding:10px 12px 10px 14px;position:relative}
.card:before{content:"";position:absolute;left:0;top:10px;bottom:10px;width:5px;border-radius:3px;background:var(--c)}
.card b{display:block;font-size:15px}.card span.d{color:var(--muted);font-size:14px}
.bar-top{position:sticky;top:0;z-index:5;background:var(--bg);padding:10px 0 8px;border-bottom:1px solid var(--rule);
display:flex;flex-wrap:wrap;gap:8px 14px;align-items:center}
.grp{display:flex;flex-wrap:wrap;gap:6px;align-items:center}
.lab{font-size:13px;color:var(--muted);margin-right:2px}
.bar-top button{font:inherit;font-size:13.5px;border:1px solid var(--rule);background:var(--box);color:var(--fg);
border-radius:999px;padding:5px 12px;cursor:pointer}
.bar-top button[aria-pressed="true"]{background:var(--hlbg);border-color:var(--hl);font-weight:600}
.bar-top button[data-actor="you"][aria-pressed="true"]{background:var(--youbg);border-color:var(--you)}
figure{margin:12px 0 4px}svg.map{width:100%;height:auto;display:block}
.map .colt{font-size:13px;font-weight:700;fill:var(--fg)}
.map .box{fill:var(--box);stroke:var(--rule)}.map .boxt{font-size:11.5px;fill:var(--muted)}
.map .inactive{opacity:.45}
.map .chip .bg{fill:var(--chip);stroke:var(--c);stroke-width:1.2}
.map .chip .bar{fill:var(--c)}
.cc{height:100%;display:flex;flex-direction:column;justify-content:center;overflow:hidden;white-space:nowrap;
font-family:-apple-system,BlinkMacSystemFont,"Helvetica Neue",Helvetica,Arial,sans-serif}
.cc .t{font-size:12px;font-weight:650;line-height:14px;color:var(--fg)}
.cc .s{font-size:10.5px;line-height:13px;color:var(--muted)}
.cc.big .t{font-size:15px;line-height:18px}
.map .lock path{stroke:var(--lc)}.map .lock rect{fill:var(--lc)}
.map .chip.warn .bg{stroke:var(--warn);stroke-width:2;fill:var(--warnbg)}
.map .chip.dead{opacity:.55}.map .chip.dead .bg{stroke-dasharray:4 3}
.map .strike{stroke:var(--warn);stroke-width:1.6}
.map .nt{font-size:11px;fill:var(--muted)}
.map .arrow{stroke:var(--muted);stroke-width:1.6;fill:none}.map .arrowhead{fill:var(--muted)}
.map .rowt{font-size:12.5px;font-weight:650;fill:var(--fg)}
.map .anchorbox{fill:none;stroke:var(--k-P);stroke-width:1.6;stroke-dasharray:6 4}
.map .anchort{font-size:11.5px;font-weight:650;fill:var(--k-P)}
.k-L{--c:var(--k-L);--lc:var(--k-L)}.k-M{--c:var(--k-M);--lc:var(--k-M)}.k-C{--c:var(--k-C);--lc:var(--k-C)}
.k-A{--c:var(--k-A);--lc:var(--k-A)}.k-P{--c:var(--k-P);--lc:var(--k-P)}.k-W{--c:var(--k-W);--lc:var(--k-W)}
.k-touch{--c:var(--k-touch);--lc:var(--k-touch)}.k-file{--c:var(--k-file);--lc:var(--k-file)}
.k-memory{--c:var(--k-memory);--lc:var(--k-memory)}.k-plain{--c:var(--k-plain);--lc:var(--k-plain)}
.g{color:var(--c);font-weight:700;white-space:nowrap}
.g .ico svg{width:1.05em;height:1.05em;vertical-align:-.17em;fill:none;stroke:var(--c);stroke-width:1.6;
stroke-linecap:round;stroke-linejoin:round}
.g .ico svg .dot,.g .ico svg circle{fill:var(--c);stroke:none}
.g .ico small{font-size:.8em;font-weight:700;margin-left:1px}
body:not([data-glyphs="icons"]) .g:not(.always) .ico{display:none}
body[data-glyphs="icons"] .g .ltr{display:none}
.roads{margin:6px 0 0;padding-left:20px}.roads li{margin:3px 0}
.steps{counter-reset:s;list-style:none;padding:0;margin:10px 0}
.steps li{counter-increment:s;position:relative;padding:8px 12px 8px 44px;margin:6px 0;background:var(--box);
border:1px solid var(--rule);border-radius:10px}
.steps li:before{content:counter(s);position:absolute;left:12px;top:8px;width:22px;height:22px;border-radius:50%;
background:var(--accent);color:var(--bg);font-size:13px;font-weight:700;text-align:center;line-height:22px}
.pill{display:inline-block;border:1px solid var(--c);border-left-width:5px;border-radius:6px;padding:0 6px;font-size:13.5px;
background:var(--chip);max-width:100%}
.pill.dead{text-decoration:line-through;opacity:.7}
.warnbox{border:1px solid var(--warn);background:var(--warnbg);border-radius:10px;padding:10px 14px;margin:10px 0}
.okbox{border:1px solid var(--accent);border-radius:10px;padding:10px 14px;margin:10px 0}
table{border-collapse:collapse;width:100%;font-size:14px;margin:12px 0;display:block;overflow-x:auto}
th,td{border:1px solid var(--rule);padding:7px 9px;vertical-align:top;text-align:left}th{background:var(--box)}
td.id{font:12.5px ui-monospace,SFMono-Regular,Menlo,monospace;white-space:nowrap}
.y{color:var(--warn);font-weight:700}.n{color:var(--accent);font-weight:700}
.compare{display:grid;grid-template-columns:1fr 1fr;gap:12px}
@media (max-width:760px){.compare{grid-template-columns:1fr}}
body[data-actor] .map .chip{opacity:.28;transition:opacity .15s}
body[data-actor="you"] .map .chip.dead{opacity:.45}
"""

ACTORS = [("you", "You"),
          ("login", "Someone who knows this Mac's login password"),
          ("apple", "Someone in your Apple account"),
          ("server", "The Variorum server")]


def actor_css():
    rules = []
    for key, _ in ACTORS:
        rules.append(f'body[data-actor="{key}"] .map .chip[data-reach~="{key}"]{{opacity:1}}')
        if key != "you":
            rules.append(f'body[data-actor="{key}"] .map .chip[data-reach~="{key}"] .bg'
                         f'{{stroke:var(--hl);stroke-width:3;fill:var(--hlbg)}}')
    return "\n".join(rules)


JS = r"""
(function(){
  var b=document.body, actorButtons=document.querySelectorAll('[data-actor]'), glyphButtons=document.querySelectorAll('[data-glyphs]');
  function setActor(a){ b.setAttribute('data-actor',a);
    actorButtons.forEach(function(x){ if(x.tagName==='BUTTON') x.setAttribute('aria-pressed',String(x.dataset.actor===a)); }); }
  function setGlyphs(g){ b.setAttribute('data-glyphs',g);
    glyphButtons.forEach(function(x){ if(x.tagName==='BUTTON') x.setAttribute('aria-pressed',String(x.dataset.glyphs===g)); });
    try{ localStorage.setItem('castleKeyMapGlyphs',g); }catch(e){} }
  actorButtons.forEach(function(x){ if(x.tagName==='BUTTON') x.addEventListener('click',function(){ setActor(x.dataset.actor); }); });
  glyphButtons.forEach(function(x){ if(x.tagName==='BUTTON') x.addEventListener('click',function(){ setGlyphs(x.dataset.glyphs); }); });
  var saved=null; try{ saved=localStorage.getItem('castleKeyMapGlyphs'); }catch(e){}
  var h=location.hash||'', ma=/actor=(\w+)/.exec(h), mg=/glyphs=(\w+)/.exec(h);
  setActor(ma?ma[1]:'you'); setGlyphs(mg?mg[1]:(saved||'letters'));
})();
"""


def controls():
    actors = "".join(f'<button type="button" data-actor="{k}" aria-pressed="false">{E(t)}</button>' for k, t in ACTORS)
    return ('<div class="bar-top"><div class="grp"><span class="lab">Light up what this person can open:</span>'
            f'{actors}</div><div class="grp"><span class="lab">Show keys as:</span>'
            '<button type="button" data-glyphs="letters" aria-pressed="true">Letters</button>'
            '<button type="button" data-glyphs="icons" aria-pressed="false">Icons</button></div></div>')


def legend():
    items = [
        ("{L} — the library key", "Opens your library file. A fresh one whenever the library crosses a line — into or out of Castle, out of an account, onto another Mac — or you replace your keys. Born Castle or Standard, it keeps that kind for life.", "L"),
        ("{P} — your passphrase", "In your head. Opens a locked copy of the library key (and, synced, of the master) — and, as it was on the day you left Castle, the Castle anchor (on a device that followed, when it was the one you typed there to follow).", "P"),
        ("{W} — your twelve words", "On paper. The same power as the passphrase — your way back if you forget it. Leaving Castle never makes new words, so that day's paper keeps opening the anchor.", "W"),
        ("{A} — an Apple key", "Lives in iCloud Keychain, named by its own id; anyone in your Apple account holds it. One per library per Mac — this Mac's own, locking its Standard key file — and one per sync account, locking only the account's master in the vault. A Mac can hold more than one of its own for a library: Re-link's library arm mints one beside a key it couldn't read, and a replacement Mac adopts all of its predecessor's. Entering Castle retires every one; one left in an Apple account this Mac no longer uses can't be deleted from here, and its copies are a stated exception.", "A"),
        ("{M} — the master key", "One per sync account. Opens the sync key and proves to the server that it's you.", "M"),
        ("{C} — the sync key", "Encrypts everything sent to the server. The server never holds it unlocked. On a device, the sync keys are held by what they can reach: the Castle way — a Touch ID item, or session memory under Always ask — while they reach a Castle-era key (in Castle, and through a leave's rotation until the previous corpus key leaves the vault), and in a silent item otherwise.", "C"),
        ("{touch} — a Touch ID item", "This Mac's copy of a Castle key, released only to your finger — never to the login password. A Castle key only ever has this, or nothing under Always ask.", "touch"),
        ("Silent item", "This Mac's copy of a Standard key, opened without asking. Keychain Access reveals it with the login password. A Standard key only ever has this, and an Apple lock.", "L"),
        ("Locked copy (a padlock)", "A key locked with another key. Whoever holds the second key gets the first. A key file is a set of these.", "file"),
        ("The history", "In the key file: older keys, each locked with the current key. Into Castle it takes everything; within a mode it grows, the anchor riding along unchanged; out of Castle, and for a library landing from another Mac, it starts empty.", "L"),
        ("The Castle anchor", "Written first at every leave from Castle: the outgoing Castle key with its whole history (and any earlier anchor kept beside it), under one anchor key locked once with what opened that Mac's library the day it left — on a Mac that followed, with the secret typed at its follow as well — never anything Apple-reachable. It keeps the secrets of its day: never re-locked, carried unchanged by every later re-key and backup. It folds back in when you enter Castle again.", "P"),
        ("The protection record", "A table inside the library file. The library's own facts, which every copy carries: its mode (the current key's kind), its account, and the family tree. And one section per Mac with that Mac's own facts.", "memory"),
        ("The family tree", "With no secrets: every key the library has had — its kind, which Mac made it, when it was made and retired. Two homes, unioned at open: the record, and a sealed mirror in this Mac's memory. Seeded at the migration with every fingerprint the catalog's key files name. It decides whether a copy is this library's own, so a rolled-back library file can't make its own copies look foreign.", "memory"),
        ("This Mac's facts", "The device identity and its hardware marker — a hash of this Mac's hardware identity with a random salt the record carries, never the identifier itself — the gate style (Touch ID or Always ask; a new device identity starts on Always ask), the idle lock, the scheduled export, the Apple key ids this Mac minted or followed and which are retired, and the act in flight. Two sealed homes — this Mac's section of the record and this Mac's memory: the newer wins, and the retired ids are the union. A Mac whose memory item is gone finds its own section by its hardware. Copies never carry them.", "memory"),
        ("This Mac's memory", "A Keychain item per library, no secret, sealed: which key is current, the mode and account last confirmed, the device identity with its hardware marker, a salted hash (on other hardware a new identity is minted), a mirror of the key file and of the family tree, and the second home of this Mac's facts. Deleting it changes nothing on its own: the Mac finds its own section by its hardware. Before unlock it's only a hint and decides nothing.", "memory"),
    ]
    return '<div class="legend">' + "".join(
        f'<div class="card k-{k}" style="--c:var(--k-{k})"><b>{rich(t)}</b><span class="d">{E(d)}</span></div>'
        for t, d, k in items) + "</div>"


def map_section(key, m):
    roads = "".join(f"<li><b>{E(a)}:</b> {rich(b)}</li>" for a, b in m["roads"])
    draw = lambda: svg_map(m["title"], m["chips"], m.get("notes", ()), m.get("inactive", ()))
    svg = under(TBOXES, TH, draw) if m.get("layout") else draw()
    return (f'<h3 id="{key}">{E(m["title"])}</h3><figure>{svg}</figure>'
            f'<ul class="roads">{roads}</ul>')


def pill(text, kind, dead=False):
    return f'<span class="pill k-{kind}{" dead" if dead else ""}">{rich(text)}</span>'


def steps(items):
    return '<ol class="steps">' + "".join(f"<li>{i}</li>" for i in items) + "</ol>"


ENTER = [
    "You type your passphrase and twelve words (set now if you have none). The screen says plainly: lose them and every Touch ID item, and this library and its older copies are gone — <b>Export a plain copy first</b> is offered. Any copies here locked under an Apple key this Mac can't delete — one left in an Apple account it no longer uses — are named, with what that means: they keep opening through that former account for as long as its iCloud Keychain keeps the key, and they can be deleted. If the secrets typed here changed since an earlier leave, so its anchor can't fold in, the door says which secrets, of which day, still open the copies it holds. While the store still has the old shared Apple key, its checks run here, at the door: a vault that still names it — one this device can read, or, while signed out, the account the record still names — stops Use Castle before anything starts, unless it's the account this very act moves into Castle, and the door names the way through. The sheet shows what the rest found (below).",
    f"Synced only: a new master {pill('{M′}', 'M')} and sync key {pill('{C′}', 'C')} go into a {pill('{touch} item', 'touch')} made at this press (session memory, under Always ask); your writing on the server is re-encrypted with {pill('{C′}', 'C')}; the vault is rewritten with {pill('{M′}', 'M')} under your passphrase and your words, and no Apple copy. The rotation names no Apple key in the vault, so any device of the account may complete it, and none ever with an Apple copy. The account's {pill('{A} Apple key', 'A', True)} goes with this rotation, deleted and recorded as retired once it completes.",
    f"A new library key {pill('{L′}', 'L')} — born Castle, and a Castle key for life — goes into its own {pill('{touch} item', 'touch')}, made at this press (or nowhere, with Always ask). Copies pause from here to the swap.",
    f"The new key file is written: {pill('{L′} · locked with {P}', 'P')} {pill('{L′} · locked with {W}', 'W')} (and, synced, {pill('{L′} · locked with {M′}', 'M')} with the master's words copy). <b>Its history takes everything</b> — the old key, its history, and the Castle anchor if you left Castle before, opened with the passphrase and words you typed and folded back in. (An anchor those can't open — they changed since the leave — is kept beside the history, unchanged, listed in Diagnostics, and never fails the entry; it keeps opening with the secrets of its day, the door said which, and a later leave seals it inside the new anchor.) No Apple lock. Now any crash still leaves a road in.",
    f"The record — saying Castle, its family tree naming {pill('{L′}', 'L')} as a Castle key — is written into the staged copy; then the library file is swapped to {pill('{L′}', 'L')}: the commit point. Copies resume, each carrying a matching key and record; any copy's act in flight is cleared whenever it's opened. Then this Mac's memory follows.",
    f"The old key's item, every {pill('silent item', 'L', True)} the library has had, the per-library-ID items the migration kept, the escrow items and the old key files go — each only once the history holds its key.",
    f"This Mac's {pill('scheduled Markdown export', 'plain', True)} turns off, with one notice. Turning it back on in Castle is your choice at that door: it writes plain text.",
    f"A fresh backup is made under {pill('{L′}', 'L')}.",
    f"<b>Every {pill('{A} Apple key', 'A', True)} of this Mac's own for the library</b> — every id this Mac's facts list as its own and not yet retired, not only the one the live key file names (a Mac can hold more than one: Re-link's library arm mints one beside a key it couldn't read, and a replacement Mac adopts its predecessor's) — is deleted from iCloud Keychain, with no sheet — every device, no recovery — and its id recorded as retired in this Mac's facts; a key this Mac can't reach now is deleted on sight if it ever comes back (by that id only: another Mac's own key for its copy is never touched). One it can never reach — left in an Apple account this Mac no longer uses — can't be deleted from here: copies locked under it are the last stated exception, named at the door. Synced: each other device types your passphrase or your words once, re-keys its own library into a new Castle key — its history taking every older key, and the anchor when the typed secret opens it — deletes every Apple key of its own for the library, records them and the account's as retired, and turns its scheduled export off.",
    f"Last, while the store still has it, the old shared {pill('{A} Apple key', 'A', True)} is retired — deleted only by the id this device recorded — so every older copy's Apple lock under it is dead, wherever the copy is. Its vault check is read fresh again here: if an older build's Re-link put a vault back on it in between, the key stays, and the library lands with the door and the stated exception showing. There is no keep-for-now: to deal with something the sheet listed first, cancel and come back.",
]
LEAVE_WRAP = pill("{M″} · locked with the account's {A}", "M")
LEAVE = [
    "You type your passphrase and your twelve words — leaving Castle is a key change, like entering it, and the words are never made new here, so the paper you have keeps opening what stays behind. The leave screen says plainly: <b>from now on your Apple account, and anyone who can sign in to this Mac, opens the library itself — with everything you wrote in it, in Castle too — and every copy made after you leave. No copy made before you leave opens through them</b>; those open with the passphrase or the twelve words you had on the day you left — leaving never makes new words, so that day's paper keeps working. Your other devices each follow with one secret typed, so their own copies from before open with the words, and with the passphrase when it was the one you typed there to follow; each copy's <i>Opens with</i> line says which, and from which day.",
    f"<b>The Castle anchor, first.</b> Before anything else is written, the outgoing Castle key with its whole history — and any earlier anchor kept beside it — is sealed under one fresh anchor key, locked with {pill('{P}', 'P')} and {pill('{W}', 'W')} as you just typed them — never with anything the Apple account or the login password reaches. It lives in the key file and rides frozen into every later backup. <b>It keeps the secrets of its day:</b> locked once, here, and never re-locked; every later re-key carries it unchanged.",
    f"Synced only: the rotation, as Use Castle's — a new master {pill('{M″}', 'M')} and sync key {pill('{C″}', 'C')}; your writing on the server re-encrypted; the vault rewritten with the new master under your passphrase and your words. <b>Its first write also names the account's fresh {pill('{A} Apple key', 'A')}</b> — minted at this press, in iCloud Keychain before the write — in the vault's <code>apple_key_id</code>, <b>with no wrap: the mark that this rotation is a leave.</b> That write is the account's commit point: past it a crash resumes, never rolls back. Every device reads the vault's mode in three states — a wrap means Standard; an id with no wrap, leaving Castle, in progress; neither, Castle. <b>Sync keys are held by what they can reach:</b> until the previous corpus key leaves the vault, the new keys and the previous one are held the Castle way — the account's {pill('{touch} sync item', 'touch')}, made at this press and holding all three, or session memory under Always ask — so no Castle-era key is ever within the login password's reach.",
    f"Synced only: <b>one write completes the leave</b> — it adds the account's Apple wrap of the new master, {LEAVE_WRAP}, under the key the vault names, with the previous-corpus-key window closed, so no Castle-era corpus key ever sits under anything Apple-reachable. <b>Only a device that can read that named key makes it</b>: this one, or another device of the account once iCloud Keychain carries the key there. Other devices walk and re-encrypt, but never clear the previous key while an id stands with no wrap; if an older build clears it first, the leave still reads as in progress, and the completing write is then just the wrap. Once the window is closed, the new sync keys reach nothing Castle-era, so they move to a {pill('silent item', 'L')} and the {pill('{touch} sync item', 'touch', True)} goes. If this device never finishes, another device of the account finishes it at a press that names it — <i>“Finish leaving Castle, started on [device] on [day]”</i> — waiting for the named key, and minting a fresh account key only if it never arrives (the vault's compare-and-set keeps one). A rotation with no id — Use Castle's, or a Castle Replace All Keys — is completed by any device, and never with an Apple copy.",
    f"A new library key {pill('{L″}', 'L')} — born Standard — goes into a {pill('silent item', 'L')}, with a fresh {pill('{A} Apple key', 'A')} of this Mac's own, minted under a new id. The new key file: {pill('{L″} · locked with {A}', 'A')} {pill('{L″} · locked with {P}', 'P')} {pill('{L″} · locked with {W}', 'W')} (and the new master, synced); <b>an empty history</b>; the anchor.",
    f"The record, now saying Standard — its family tree naming {pill('{L″}', 'L')} as a Standard key — goes into the staged copy; the library file is swapped to {pill('{L″}', 'L')}. Copies pause from the new key to the swap.",
    f"Then this Mac's memory; the Castle key's {pill('{touch} item', 'touch', True)} goes with its key; a fresh backup is made under {pill('{L″}', 'L')}.",
    "Your other devices follow, each typing your passphrase or your words once, for the new master — no follow waits on an Apple key. One that sees the rotation still in progress — a previous corpus key standing, or an id with no wrap — holds its re-key until the vault reads Standard or Castle, the keys it takes held the Castle way while the previous corpus key stands. Each writes its own anchor first, under the secret it just typed and under its outgoing Castle key with that key's own locks beside it — the one secret typed does both jobs — so its copies from before open with the words, and with the passphrase when it was the one you typed there to follow; then a new Standard key with an empty history and an Apple key of its own (below).",
]
REPLACE = [
    "For a key someone may have used, or a device someone may have had: you type your passphrase and twelve words (or make new words — while an anchor exists, the door then says <i>“Copies from before 12 October still open with the words you're replacing — keep that paper.”</i>).",
    f"New {pill('{M}', 'M')} and {pill('{C}', 'C')}; the server's writing re-encrypted; the vault rewritten (in Standard the new master is locked with the account's Apple key — an account still on the old shared key is re-linked first, with a fresh key of its own — and Castle is the answer to an Apple-account intruder). In Castle the rotation names no Apple key in the vault: any device completes it — one whose acting device was lost too — and never with an Apple copy, so the account is never lowered.",
    "A new library key of the same kind, the old one added to its history, so your copies keep opening, and any Castle anchor carried over unchanged. In Castle each other device follows by typing a secret once; in Standard it reads the new master through the account's Apple key, or takes the passphrase or the words where that key can't be read.",
]
FOLLOW = [
    "Another of your devices entered Castle, left it, or replaced the keys; this device sees the vault changed. Every device reads the vault's mode in three states: a wrap means Standard; an Apple key id with no wrap means leaving Castle, in progress; neither means Castle.",
    "<b>Into or out of Castle, it asks for one secret, once</b> — your passphrase or your words, through the vault, for the new master. Until then the library opens on its current key and you can write; sync waits, with a banner saying why. No such follow waits on an Apple key. A device that sees the master replaced while the vault reads a rotation in progress — a previous corpus key standing, or an id with no wrap (a leave not yet complete) — follows the keys but holds its own library's re-key until the vault reads Standard or Castle. While it holds, the keys it takes are held by what they reach, as the acting device's are: in its Castle-kind custody while the previous corpus key stands. It walks and re-encrypts, but never clears the previous key while an id stands with no wrap. Its new key file is locked with the secret it typed and the new master, with that master's words copy beside it — so the words open it either way, and the passphrase directly when it was the one typed. Typing the old passphrase after a change elsewhere is refused with the change named: <i>“Your passphrase was changed on [device] on [day] — enter the new one.”</i>",
    f"<b>Into Castle:</b> the new master {pill('{M′}', 'M')} from the vault; a new library key of Castle's kind — a {pill('{touch} item', 'touch')} made at this press where this device's gate style says so, or none — its history taking every older key, and the anchor if there is one when the typed secret opens it (one it can't open is kept beside the history, unchanged); every {pill('{A} Apple key', 'A', True)} of this Mac's own for the library deleted and recorded as retired, with the account's; the scheduled Markdown export off, with one notice.",
    f"<b>Into Standard:</b> the anchor first — this device's outgoing Castle key and its whole history, sealed under one anchor key locked with <b>the secret just typed</b> — it opened the vault, so it is current — and with that outgoing Castle key itself, its own locks from this device's key file copied beside it: the passphrase or words this device held it under, and the Castle-era master {pill('{M′}', 'M')} with its words copy. Both are birth-time locks, made with what's in hand as the anchor is sealed — the secret just typed, and the open library's own key — so the one secret typed does both jobs: it opens the vault for the new master, and it locks the anchor. Nothing re-locks an anchor after it's written. So it opens with the secret typed at this follow and with whatever opened this device that day; only a device that never had the passphrase typed has an anchor that opens with the words alone, and its copies' <i>Opens with</i> line says the twelve words. If the vault's master is still the Castle-era one — an older build left without changing it, and put it under the old shared Apple key — the master's road is left out. Then a new library key of Standard's kind — its {pill('silent item', 'L')} and a fresh {pill('{A} Apple key', 'A')} of this Mac's own — with an empty history; the Castle key's {pill('{touch} item', 'touch', True)} goes with its key. The typed step says the leave screen's sentence: from now on the Apple account opens this library, with everything in it, and every copy made after — no copy made before, which opens with the passphrase or the words you had on the day you left; and your other devices each follow with one secret typed, so their own copies from before open with the words, and with the passphrase when it was the one you typed there to follow — each copy's <i>Opens with</i> line says which, and from which day.",
    "<b>Keys replaced, same mode:</b> a new key of the same kind; the history grows, and any anchor rides along unchanged. In Standard it reads the new master through the account's Apple key, as today, or takes the passphrase or the words when that key can't be read here.",
]
KEY_DOORS = [
    "<b>Change passphrase</b> (it verifies the current one) and <b>new words</b> (they ask the passphrase) re-lock the current key and nothing else: the history needs no secret, and the Castle anchor keeps the secrets of its day — locked once, when it was written (at the leave, or on a follower at its follow), and never re-locked.",
    "<b>So copies from before a leave open with the passphrase or the words you had that day.</b> Leaving never makes new words, so that day's paper keeps opening them. Change both your passphrase and your words later, and those copies need the old ones; the route finder names the day.",
    "<b>Every door that replaces a secret while an anchor exists says what still opens the copies from before the leave</b> — one sentence, from the route finder, for this device's anchor and its day:"
    "<ul><li>every door that replaces the words — new words, Replace All Keys, a leave from an account, sync setup's choice to make new words: <i>“Copies from before 12 October still open with the words you're replacing — keep that paper.”</i></li>"
    "<li>change passphrase: <i>“Copies from before 12 October still open with the passphrase you're replacing, or that day's words.”</i></li>"
    "<li>Standard's reset road for a forgotten passphrase: <i>“Copies from before 12 October now open with that day's twelve words — keep that paper.”</i> It never points you at a passphrase you've told it you forgot.</li>"
    "<li>a Use Castle that can't fold an anchor in, because the secrets typed at its door changed since that leave: the anchor stays beside the history, unchanged, and the door says which secrets, of which day, still open the copies it holds.</li></ul>"
    "Where this device's anchor doesn't open with what the sentence names — a device that only ever had the words typed — the route finder says what does instead.",
    "<b>Re-link your Apple account</b> (a Standard account whose Apple key no device can read — after an iCloud Keychain reset or a change of Apple ID): a fresh account Apple key, minted at the press and landed under the vault's compare-and-set — never under the old shared key — re-keying nothing. Its consent says the new key reaches other devices only through iCloud Keychain, which Variorum can't see.",
    "<b>Its library arm</b> — for a Standard library whose own Apple key this Mac can't read (an iCloud Keychain reset, a change of Apple ID), local-only libraries included: it mints a fresh own Apple key for this Mac and re-locks the key file under it, for every Standard key file this Mac holds that needs one, other libraries' included. The assessment offers it wherever a Standard library's Apple road is lost — no repair mints one by itself. It re-keys nothing.",
]
OPEN_OLD = [
    "Inside Variorum, you pick an older backup of this library (or one is found at its place, say after a Time Machine rollback). Whatever unlocks your library comes first either way: Touch ID or the passphrase in Castle, the silent item in Standard.",
    "The family tree — its two homes unioned — says it's this library's own, whatever its kind. Its key is found through the history — today's key opens the older ones — so nothing more is typed. After a leave from Castle, a copy from before the leave opens with the passphrase or the words you had on the day you left, through the Castle anchor.",
    "Its act in flight, if it carries one, is cleared. The copy is re-encrypted with today's key, straight into place, and takes the library's current facts — its mode, account and family tree from the record, and this Mac's facts from the newer of their two homes, so a restored copy can't weaken delete on sight. The library you had joins your older libraries.",
    "Your library is back as it was then, in the mode it's in now. A Castle library stays in Castle. A Castle-era copy opened into a Standard library takes Standard, and the confirm says its writing will then open through your Apple account.",
]
OPEN_OTHER = [
    "<b>A Castle copy not in this library's family tree, into a Standard library here:</b> opening it raises the library to Castle through Use Castle's own steps — your passphrase and words, a fresh key — or you cancel. A copy never lowers the mode.",
    "<b>A copy whose key isn't in the family tree:</b> the restore list and the confirm mark it <i>“made on another Mac, or not by you”</i> before anything happens.",
    "<b>A different library, landing from another Mac:</b> it keeps its own mode and lands under a <b>fresh key with an empty history</b> (her ruling). Its passphrase alone, or its words alone, unlocks the pair; the landing then asks for the other one — typed, or made new (a new passphrase if it's forgotten, since the words proved access; new words if they're lost, since the passphrase did) — so both open it from the start. A Standard pair that opens through an Apple key this Mac can read lands with nothing typed, under an Apple key of this Mac's own, and the passphrase and words are offered as Standard offers them; if they're declined, the confirm says the landed library opens through this Mac and its Apple account only. The sent pair is never written and keeps its own locks; the library you had joins your older libraries. No key is ever held by two Macs. <b>A synced pair</b> lands held, as today: a secret made new at its landing becomes the account's at Resume Sync, through the account's own forgot road with the secret just typed, and the landing says so.",
    "<b>Send Library</b> writes the pair and says nothing about sharing: nothing is shared, since the other Mac lands it under a key of its own. Like any backup, the pair opens with its own locks.",
    "<b>A plaintext export</b> carries its library ID. If it's this library's, it comes in under today's key and mode; otherwise it becomes a new library in Standard, and the confirm says so.",
    "<b>A copy with no record</b> — anything made before this change — has its mode worked out once with today's rules, as the migration does. An exposed-era Standard copy with no passphrase or words is never defaulted to Castle.",
]
MIGRATE = [
    "Anything in flight finishes first, with today's runner; a stuck switch marker is cleared on proof that the switch never happened.",
    "The mode is worked out once with today's rules: a synced library takes the vault's word, and without it the mode is recorded as not yet confirmed. Corner 45's ambiguous case records Castle, not yet confirmed, with a one-time notice — the floor sentence, <b>Export a plain copy first</b>, and Use Standard offered as the key change it now is. <b>Until the mode is confirmed, no custody repair runs in either direction</b>: the library keeps today's custody shape, and nothing Apple-reachable is written. Confirming a mode the current key wasn't born in is a key change, never a move.",
    "The record, this Mac's memory (sealed, with this Mac's section in both homes) and the device identity are written — the identity carried over from the sync-keys item, with a hardware marker, so no new device cursor is created. The family tree's first entries: the current key takes the mode step 2 records; every older key the fold reaches is attributed by its key file — an Apple lock marks a Standard key, none a Castle key, and an unknown one counts as Castle's, the safe side, which strands nothing since all stay openable through the history; and every fingerprint the catalog's key files name for this library is listed, reached or not, so its own copies read as its own.",
    "Per-key custody items are added, each of its key's kind; the old per-library items stay, unread, for one release (entering Castle removes them once the history holds their key).",
    "Existing copies are attributed to their library and Mac; new backups go to per-library, per-Mac folders.",
    "The one key file is written and every reachable older key folded into the history — through the old shared Apple key while it's still readable, the passphrase if needed (asked once), custody, and the escrow items (removed once folded). An old key file stays until the history holds its key; one the fold couldn't reach stays for good.",
    "<b>Everything this Mac holds in Standard gains an Apple key of its own, beside the old shared one</b> — other libraries' copies first (this Mac's own key file for each), then the live library, local or synced, once its mode is confirmed Standard — then <b>a fresh backup</b>, so the newest copy carries the history and every lock. Nothing is removed; a synced account's vault stays on the old key until it enters Castle or is re-linked.",
    "A library already in Castle gets one calm ask on each device: copies from before Castle still open through the Apple account until the old key is retired — with the checks, the sheet and a door in Settings ▸ Protection.",
    "The road back: until the first re-key under the new build, an older build still opens the library; after that, the road back is the A1 safety copy, with the passphrase or words.",
]
SHARED = [
    "<b>One key, every library.</b> Today's builds lock every Standard library on an Apple account with one shared Apple key, on every device. Deleting it deletes it everywhere, with no recovery — so nothing loses its road through it before it's retired, and this build never writes under it.",
    "<b>The move</b> (each device's migration) only adds: everything this Mac holds in Standard gains an Apple key of its own beside the old one — the live library, local or synced, and this Mac's copies of other libraries (its own key file for each) — then a fresh backup. A synced account's vault stays on the old key until it enters Castle or is re-linked: it has room for one Apple copy, and macOS can't say whether iCloud Keychain carried a new key. A device joining such an account locks its own key file under its own key; nothing is ever written under the old one.",
    "<b>The checks, at Use Castle's door</b> (or the door on a store already in Castle): the move runs again; then, with the old key taken away, every copy this Mac can see — other libraries' and other Macs' in a shared backup folder included — and every account vault it can read. They list what would stop opening, every Standard library or copy here with no passphrase or words, and any other Mac's key file holding this library's keys — a library sent there before this change. <b>A vault still on the old key stops Use Castle at its door</b> — one this device can read, or, while signed out, the account the record still names — unless it's the account this act moves into Castle; the door names the way through: that account's own Castle, or Re-link on one of its devices.",
    "<b>The sheet</b> lists those things by name, and says what the Mac can't see: give any library still in Standard on your other devices a passphrase or words first — one with neither, on a device that's lost or reset, opens elsewhere only if iCloud Keychain carried its key, or not at all if that device hadn't been updated. It also says that another Variorum account still in Standard on this Apple account sets up new devices with its passphrase until it's re-linked.",
    "<b>Retiring</b> — Use Castle's last step, or its own door on a library already in Castle — deletes the old-name item only when its id is the one this device's section lists, and records it as retired there, so a copy that comes back is deleted on sight. A device that follows records the account's key and its own as retired, never the old shared key. There is no keep-for-now. A library that was already in Castle before this change gets one calm ask on each device and a door in Settings ▸ Protection that goes once pressed; until then, its Castle surfaces there say copies from before Castle still open through the Apple account.",
]


def who_table(target):
    rows = [
        ("You, on your Mac", "Touch ID or passphrase", "opens, nothing asked"),
        ("You, on a new Mac, with your Apple account only", "no — needs your passphrase or words", "yes, when iCloud Keychain carried the key"),
        ("You, on a new Mac, with your passphrase or words", "yes — at least the secrets of that copy's day; whatever opens the library opens them too", "yes, if set — at least the secrets of that copy's day"),
        ("Someone who knows this Mac's login password", '<span class="n">nothing</span> (Markdown exports you made are plain text)',
         '<span class="y">the library and every copy since it came into Standard</span> — after a leave from Castle, the '
         'library with everything in it, but <span class="n">no copy from before the leave</span>'),
        ("Someone in your Apple account", '<span class="n">nothing</span>',
         '<span class="y">the library and every copy Variorum made since it came into Standard</span>, wherever iCloud '
         'Keychain carried the key — after a leave from Castle, <span class="n">no copy from before the leave</span>'),
        ("The Variorum server", 'your writing <span class="n">no</span> · dates, tag shape, sizes yes', 'the same'),
        ("Someone who steals one backup file", '<span class="n">no</span> (needs a key)', '<span class="n">no</span> (needs a key)'),
    ]
    return ("<table><thead><tr><th>who</th><th>Castle</th><th>Standard</th></tr></thead><tbody>"
            + "".join(f"<tr><td><b>{E(a)}</b></td><td>{b}</td><td>{c}</td></tr>" for a, b, c in rows)
            + "</tbody></table>")


ACCOUNT_MOVES = (
    "<p><b>Leaving an account</b> (This Mac Only, Stop syncing here, deleting the account from this Mac, Move) <b>re-keys "
    "the library, in either mode</b>. The new key's history takes the old one, so your copies keep opening for you, and any "
    "anchor rides along unchanged; the account you left opens only the copies from while it synced in Standard — until it "
    "replaces its keys or enters Castle — and never what you write after. <b>In Castle:</b> both secrets — the passphrase "
    "typed, the words typed or made new. <b>In Standard:</b> this Mac holds the key, so the new key's silent item and "
    "this Mac's existing own Apple key carry it with nothing remembered — nothing is minted, as for Replace All Keys, "
    "since the account's key never locks the library; the passphrase is typed or set new (Standard's forgot road), and "
    "the words typed or made new. The account's Apple key is left alone: the account's other devices still use it. "
    "While an anchor exists, a secret made new here says its door's sentence — new words: <i>“Copies from before 12 "
    "October still open with the words you're replacing — keep that paper.”</i>; a forgotten passphrase set new: "
    "<i>“Copies from before 12 October now open with that day's twelve words — keep that paper.”</i> "
    "<i>(Her rulings, 2026-10-13.)</i></p>"
    "<p><b>Joining or moving into an account</b> in Castle is entering Castle for this library: the re-key, every Apple "
    "key of this Mac's own for the library retired, and the old shared key's checks. Into an account in Standard from Castle is leaving Castle for "
    "it: its key change and anchor, with the leave screen's sentence at the consent. Joining an account in the library's "
    "own mode — Standard from Standard, or Castle from Castle — adds the master's lock and takes nothing away, so the key "
    "stays. When the library's passphrase differs from the account's, enrolling re-locks the library key under the "
    "account's; the anchor, if any, is untouched and keeps the secrets of its day. Signing back in to an account the library "
    "left is an ordinary turn-on-sync, with its consent.</p>")

ACCOUNTS = ("<table><thead><tr><th>the library belongs to</th><th>signed in as</th><th>what happens</th></tr></thead><tbody>"
            "<tr><td>no account</td><td>anyone</td><td>local only; the Encryption tab offers to turn sync on</td></tr>"
            "<tr><td>account X</td><td>X</td><td>in sync; it follows X's mode</td></tr>"
            "<tr><td>account X</td><td>nobody</td><td>not syncing; Use Castle / Use Standard each offer one plain road — the mode applies to this Mac only, and this Mac stops using the old account; <i>Stop syncing this library on this Mac</i> beside them</td></tr>"
            "<tr><td>account X</td><td>another account Y</td><td>not syncing; one screen: <i>Move it to y@…</i> or <i>Sign out</i> (the same email with a different account is named)</td></tr>"
            "</tbody></table><p>New writing always belongs to the library's account, never to whoever happens to be signed in. "
            "The account changes only through acts: set up sync, enroll or join, This Mac Only, Stop syncing here, deleting "
            "the account from this Mac, and Move.</p>" + ACCOUNT_MOVES)

LOBBY = ("<table><thead><tr><th>this Mac, right now</th><th>the lobby shows</th></tr></thead><tbody>"
         "<tr><td>this scope has a Touch ID item for the library's current key, and Touch ID is usable</td><td>the <b>Unlock with Touch ID</b> button — whenever the item exists, however many times the prompt was dismissed (it asks by itself once, at open)</td></tr>"
         "<tr><td>the same item, but the lid closed, the keyboard disconnected or unpaired, or a lockout</td><td>the button stays; pressing it says why (<i>“Open the lid…”</i>) and nothing changes; the passphrase road beside it</td></tr>"
         "<tr><td>the stored Touch ID state hash moved with nothing changed (a macOS update)</td><td>the button stays, and a press opens; nothing is asked — the stored hash is only a hint</td></tr>"
         "<tr><td>no Touch ID item for the current key, or no finger enrolled on this Mac</td><td>no button; one quiet line says why — Touch ID isn't set up here, or isn't set up for this library — and the passphrase road. When this device's choice is Touch ID but no item exists — it was deleted, the keychain was wiped, or both of this Mac's homes were rolled back past a switch to Always ask — <b>nothing is asked</b>: Always ask is recorded quietly, the quiet line says Touch ID isn't set up for this library, and Touch ID comes back only from Settings, with the passphrase. With no item there's no press, so no question</td></tr>"
         "<tr><td>a press that fails against an item that exists — a biometry change invalidated it</td><td><i>Touch ID changed since you set it up — unlock with the passphrase</i>; once the passphrase opens it, the question <i>“Touch ID can't open Variorum on this Mac any more. Set it up again? Every finger enrolled on this Mac will open it.”</i> — a new item only on yes; a no records Always ask, at that press. No repair ever makes one.</td></tr>"
         "</tbody></table><p class=\"lede\">Before unlock, the lobby reads what this Mac remembers as a display hint only; it decides "
         "nothing. Her pick, 2026-10-13: <i>the button whenever a Touch ID item exists</i>; the “changed” line waits for a "
         "press, because the stored hash can't tell a changed finger from a macOS update.</p>"
         "<p>The choice — Touch ID or Always ask — is stored per device, in this Mac's facts, and nothing acts on a "
         "momentary reading: a closed lid, a disconnected keyboard or a lockout takes the passphrase road for that one open "
         "and changes nothing. A device with no choice yet — a landed library, a first follow into Castle — starts on Touch "
         "ID where this Mac has an enrolled finger, the item made at that act's own press, and on Always ask otherwise; its "
         "idle lock at the default, and its scheduled export off. A new device identity (a replacement Mac) has no act and "
         "so no press: it starts on Always ask, and Touch ID comes on only when you turn it on in Settings, with the "
         "passphrase. A Mac without Touch ID hardware: the Castle switch says so, and Always ask is recorded only at your "
         "press.</p>")


CHECKLIST = [
    # (id, element, what proves it)
    ("C-1", "Castle: a Castle key's only device copy is its Touch ID item — none under Always ask; no silent item for any key the library has had, the migration's per-library items included", "scenario promise 2 · real-Keychain drill"),
    ("C-2", "Castle: the one key file locks the current key with the passphrase and the twelve words (and, synced, the master, beside the master's words copy) — on a follower, with the secret it typed, the master and the master's words copy — never an Apple lock; a planted Apple lock on a Castle key is answered with a re-key", "model test · the posture drill · adversary scenario (edit a key file)"),
    ("C-3", "Castle: the history holds every older key, each locked with today's key — entering Castle took everything, a Castle anchor folded back in (one the typed secrets can't open kept beside it, unchanged, listed in Diagnostics, never failing the entry); an old key opens nothing newer", "model test · fixed scenario (Castle → Standard → Castle) · scenario promise 8"),
    ("C-4", "Castle: every Apple key of this Mac's own for the library — every id this Mac's facts list as its own and not yet retired, not only the one the live key file names (Re-link's library arm can mint one beside a key it couldn't read, and a replacement Mac adopts its predecessor's) — was retired at entering Castle, each deleted with no sheet; the account's was deleted and recorded as retired once the account's rotation completed; no Apple key this Mac's facts list as retired exists, and one that reappears is deleted on sight — by its recorded id only, never by library ID, so another Mac's own key for its copy is never touched", "scenario promise 2 · iCloud Keychain drill · fixed scenarios (one library on two Macs; This-Mac-Only Castle; replays — a rollback across a retirement; a Standard library leaves its account, is backed up, then enters Castle; Re-link's library arm, then Use Castle) · mutation pin (every own Apple key retired at entering Castle)"),
    ("C-5", "Castle: every backup carries its day's key file; older backups open through the history with Touch ID, the passphrase or the words", "scenario promise 5 · the restore drill"),
    ("C-6", "Castle, synced: the sync keys live only in a Touch ID item (session memory under Always ask)", "scenario promise 2 · drill"),
    ("C-7", "Castle, synced: the vault holds the master locked with the passphrase and words, the sync key locked with the master — no Apple copy", "fake-server suite · live round"),
    ("C-8", "Key files with a master lock carry the master locked with the twelve words, copied from the vault and refreshed while that master is current", "model test · fixed scenario (a silently-joined device)"),
    ("C-9", "Entering Castle turns this device's scheduled Markdown export off, with one notice — on Use Castle and on every follow into Castle", "fixed scenario (entering Castle with the scheduled Markdown export on) · mutation pin (the export-off step)"),
    ("C-10", "After leaving Castle, nothing the Apple account or a login-password holder can reach opens any copy made before the leave, or any key made in Castle — through the leave's rotation too: sync keys are held by what they reach, so on every device the new keys and the previous corpus key are held the Castle way until the previous corpus key leaves the vault, and the account's Apple wrap joins the vault only in the one write that completes the leave, made only by a device that reads the key the vault's id names; the library itself, with everything written in it, opens to them from the leave on, and the leave screen says so. The one exception: a leave or follow made by an older build, which puts the Castle-era master under the old shared Apple key with no change of keys — this build never adds to it", "scenario promise 13 · fixed scenarios (leaving Castle — a follower reaching the head first, an older build completing the leave's rotation; a follow after an older build's leave; a follow into Standard with iCloud Keychain off) · mutation pins (Castle-kind custody through a leave's rotation on every device; the leave's id gating its completion) · drill"),
    ("C-11", "Castle: copies locked under an Apple key in an Apple account this Mac has left — made in Standard before the Mac switched Apple ID — are rule 2's last stated exception: they open through that former account for as long as its iCloud Keychain keeps the key, which this Mac can't delete there; Use Castle's door names them, with what that means; their Opens with line says so; and they can be deleted", "fixed scenario (a Mac that switched Apple ID, then enters Castle) · scenario promise 9 · walk"),
    ("H-1", "A fresh key at every crossing — entering and leaving Castle, leaving an account in either mode, a different library landing on a Mac — plus Replace All Keys and the follow; every key is born Castle or Standard and keeps that kind for life, and no repair changes it", "model test · fixed scenarios (leaving Castle; a library leaves its account; Send Library after this change) · mutation pin (the re-key at every crossing)"),
    ("H-2", "The history: entering Castle takes everything (an anchor folded back in, or kept beside it, unchanged, when the typed secrets can't open it); within a mode it grows, the anchor carried over unchanged; leaving Castle and a landing take nothing — the new key's history starts empty", "model test · fixed scenarios (Castle → Standard → Castle; Send Library after this change)"),
    ("H-3", "The Castle anchor: written first at every leave, by the act and by each follow — the outgoing Castle key with its whole history (and any earlier anchor kept beside it) under one anchor key locked only with what opened that device's library on the day it left, never anything Apple-reachable: on the acting device, the passphrase and words typed there; on a follower, the secret typed at its follow — it opened the vault, so it is current — and the outgoing Castle key itself, with that key's own locks from its key file copied beside it, both birth-time locks made as the anchor is sealed, so the one secret typed at the follow does both jobs; the master's road left out when the vault's master is still the Castle-era one (an older build's leave); a follower's anchor opening with the secret typed at its follow and with whatever opened that device that day, and only a device that never had the passphrase typed having one that opens with the words alone — its copies' Opens with line saying the twelve words; in the key file and every later pair", "fixed scenarios (leaving Castle — followers typing the passphrase, and the words, an Always-ask follower relocked after the rotation among them; a crash at every step, on Touch ID and on Always ask; a follow after an older build's leave; the passphrase changed during Castle on another device, which then left Castle — a follower that never had the new passphrase typed, and a follower that typed the words) · mutation pins (the anchor written first; a follower's anchor locked under the secret typed at its follow)"),
    ("H-4", "The anchor keeps the secrets of its day: locked once, when it's written — at the leave, or on a follower at its follow — and never re-locked; change passphrase and new words re-lock only the current key; every later re-key (Replace All Keys, a follow that keeps the mode, leaving an account) carries it unchanged, and enrolling under a differing account passphrase leaves it untouched; copies from before the leave open with the leave day's passphrase or words on every device, and the route finder names the day; while an anchor exists, every door that replaces a secret says one sentence for this device's anchor and its day — the words doors (new words, Replace All Keys, a leave from an account, sync setup's new words): “Copies from before 12 October still open with the words you're replacing — keep that paper.”; change passphrase: “Copies from before 12 October still open with the passphrase you're replacing, or that day's words.”; Standard's reset road for a forgotten passphrase: “Copies from before 12 October now open with that day's twelve words — keep that paper.”, never naming the forgotten passphrase; a Use Castle that can't fold an anchor in: which secrets, of which day, still open the copies it holds — and where this device's anchor doesn't open with what the sentence names, the route finder says what does instead", "fixed scenarios (after a leave, change the passphrase and make new words — on this device, and on another device of the account — and reset a forgotten passphrase; a library leaves its account, carrying any anchor; a Castle library joins a Standard account whose passphrase differs) · mutation pin (the anchor written first and carried by every re-key) · walk"),
    ("H-5", "The family tree lists every key the library has had — its kind, the Mac that made it, its dates — with no secret, in two homes unioned at open (the record, and a sealed mirror in what this Mac remembers), seeded at the migration with every fingerprint the catalog's key files name for this library, reached or not; it decides whether a copy is this library's own", "model test · fixed scenarios (this library's own Castle-era copy, restored after a leave; a Time Machine rollback past a re-key) · mutation pin (the family tree's own-line check and its two homes)"),
    ("S-1", "Standard: a Standard key's device copy is its silent item; never a Touch ID item", "scenario promise 3 · drill"),
    ("S-2", "Standard: each device's key file locks its current key with that device's own Apple key for the library (named by its id) and, synced, with the master, beside the master's words copy; with the passphrase and the words where that device has them — a follower's carries the secret it typed", "model test · fixed scenario (leaving Castle, synced, with followers) · drill"),
    ("S-3", "Apple keys: one per library per Mac, minted and named by that Mac for its key file, and one per account, locking only the account's master in the vault; minted only by a deliberate act or the migration, under fresh ids; if two devices mint for one account, the vault's compare-and-set keeps one and the other deletes its own; a device that can't read the account's key waits for silent setup only — its own key file never waits", "convergence suite (the mint, wait and delete rules) · fixed scenario (a new device joining an old-key account)"),
    ("S-4", "Standard, synced: the vault's Apple copy is under the account's Apple key, named by its id; an account from before this change stays on the old shared key until it enters Castle or is re-linked; nothing moves a vault automatically", "fake-server suite · fixed scenario (an older build's Re-link)"),
    ("S-5", "Re-link mints a fresh account key under the vault's compare-and-set, and Replace All Keys re-links an account still on the old shared key first; nothing this build writes is locked with the old shared key", "executor tests · drill · fixed scenario (Replace All Keys on an old-key account)"),
    ("S-6", "Standard: the history holds the older keys since the library came into Standard, each locked with today's key; older copies open through it, and copies from before a leave through the anchor, with the leave day's passphrase or words", "model test · the restore drill"),
    ("S-7", "Re-link's library arm: where a Standard library's own Apple key can't be read here (an iCloud Keychain reset, a change of Apple ID), no repair mints one — the assessment says the Apple road is lost and offers the arm, which mints a fresh own Apple key for this Mac and re-locks under it every Standard key file here that needs one, other libraries' and local-only libraries' included, re-keying nothing; then promise 3 settles", "fixed scenario (a Standard library's own Apple key lost — iCloud Keychain reset, or a switch of Apple ID — for a local-only library too) · executor tests · drill"),
    ("R-1", "The protection record inside the library file states the library's own facts — its mode (the current key's kind) and whether it's confirmed, its account, its family tree — and every copy carries them; what this Mac remembers agrees", "scenario promise 1"),
    ("R-2", "This Mac's facts — the device identity and its hardware marker (a salted hash, never the hardware identifier itself), the gate style, idle lock, scheduled export, the Apple key ids this Mac minted or followed and which are retired, the act in flight — live in two sealed homes, this Mac's section of the record and what this Mac remembers; the newer wins and the retired ids are the union; a Mac whose memory item is gone finds its own section by its hardware; in Castle, a file, memory item or plan planted, edited, replayed or deleted alone changes nothing (in Standard, where a login-password holder holds the library key, no repair deletes or re-keys on the record's word alone); copies never carry them", "scenario promise 10 · fixed scenarios (replays; the memory item deleted alone on an Always-ask Castle Mac with an enrolled finger) · mutation pins (the two homes; the device section's hardware marker)"),
    ("R-3", "Plans live beside the library, sealed and named by the act in flight in this Mac's section, never in a backup; any copy's act in flight is cleared whenever it's opened, lock-time copies included; a plan the section doesn't name is ignored and reported; a missing one never blocks", "scenario promises 6, 10 · mutation pins (planted, replayed) · fixed scenario (an act in flight when a backup is taken)"),
    ("R-4", "Before unlock nothing decides: the lobby offers only self-verifying roads — the enumerated custody items and the route finder's, the history and the anchor among them — and a missing key file or memory item isn't fatal", "assess tests · the file-swap scenario · fixed scenario (key file and memory deleted)"),
    ("R-5", "The device identity and its hardware marker live in what this Mac remembers and in this Mac's section of the record; the marker is a hash of this Mac's hardware identity with a random salt the record carries, never the identifier itself, recomputed on the same hardware after unlock, and no log line, Diagnostics entry or support bundle carries a marker or the salt; on other hardware a new identity is minted, so two Macs never share a device cursor or a backups folder; on the same hardware, a Mac whose memory item is gone keeps its identity, found by its marker", "fixed scenarios (a memory item that turns up on new hardware; the memory item deleted alone) · model test (the encodings scanned: no raw hardware identifier) · executor tests (the logs scanned: no marker or salt)"),
    ("R-6", "A replacement Mac — a new identity on new hardware — takes over its predecessor's Apple keys: for each library it holds, the Apple key ids its live key file's locks name as its own, every other id its predecessor's section lists as its own (the predecessor is the identity named by the memory item it came with), and every id any device section of the record lists as retired; so entering Castle there retires all of the predecessor's own keys too, and delete on sight keeps working", "fixed scenario (a memory item that turns up on new hardware — a replacement Mac entering Castle retires its predecessor's own key) · iCloud Keychain drill"),
    ("T-1", "Use Castle runs ‘Entering Castle’ in order: the door-time check, a vault still on the old shared key stopping the act before anything starts, and the door naming any copies under an Apple key this Mac can't delete; prepare-then-commit, the record in the staged copy before the swap, copies paused; the export-off step; every Apple key of this Mac's own for the library retired, each with no sheet; last, the old shared key retired by its recorded id — and survives a crash at every step", "executor tests · crash scenarios · the posture drill · mutation pins (the door-time vault check; the export-off step; every own Apple key retired at entering Castle)"),
    ("T-2", "Use Standard runs ‘Leaving Castle’ in order: both secrets typed, the words never made new; the anchor first; synced, the rotation — its first write naming the account's fresh Apple key's id in the vault with no wrap, the commit point past which a crash resumes and never rolls back; the new sync keys and the previous corpus key held the Castle way, in the account's Touch ID sync item made at the press or session memory under Always ask, until the previous corpus key leaves the vault; one write completing the leave by adding the account's Apple wrap, made only by a device that reads the named key; then the sync keys moving to a silent item and the Touch ID item going; a lost actor's leave finished at a press that names it — “Finish leaving Castle, started on [device] on [day]” — waiting for the named key and minting a fresh one only if it never arrives; a new Standard key with an empty history, its silent item and a fresh Apple key of this Mac's own; the leave screen's sentence said", "executor tests · fixed scenarios (leaving Castle, synced and local, a crash at every step; an acting device lost mid-rotation, finished at a press that names the leave; an older build completing the leave's rotation) · mutation pins (Castle-kind custody through a leave's rotation on every device; the leave's id gating its completion) · walk"),
    ("T-3", "Replace All Keys runs as drawn, the old key joining the history and any anchor carried over unchanged — in Castle its rotation names no Apple key, so any device completes it, never with an Apple copy; every follow into or out of Castle types one secret, once, for the new master, and never waits on an Apple key — on the way into Standard writing the follower's anchor first, under the secret typed at its follow and under its outgoing Castle key with that key's own locks beside it, the one secret doing both jobs; a follower reads the vault's mode in three states (a wrap — Standard; an id with no wrap — leaving, in progress; neither — Castle), and while it reads a rotation in progress — a previous corpus key standing, or an id with no wrap — holds its re-key until the vault reads Standard or Castle, the keys it takes held the Castle way while the previous corpus key stands, walking and re-encrypting but never clearing the previous key while an id stands with no wrap; the refusal names a change made elsewhere", "executor tests · fixed scenarios (a follow into Standard with iCloud Keychain off; a follow after an older build's leave; leaving Castle — a follower that sees the rotation still in progress, and a follower reaching the head first; an acting device lost mid-way through a Castle Replace All Keys) · mutation pin (Castle-kind custody through a leave's rotation on every device) · drills · walk"),
    ("T-4", "Opening an older backup of this library — the family tree says it's ours — brings it in under today's key and mode, never lowering it: through the history with nothing more typed, or, from before a leave, with the passphrase or the words of the leave day through the anchor, the confirm saying its writing will then open through the Apple account", "fixed scenarios (VX-209's way back; this library's own Castle-era copy, restored after a leave) · restore drill · walk"),
    ("T-5", "A Castle copy not in the family tree raises a Standard library to Castle through Use Castle's steps; an unknown-key copy is flagged; a different library keeps its mode and lands under a fresh key with an empty history — one secret unlocks the pair, the other typed or made new; a Standard pair through a readable Apple key lands with nothing typed, under this Mac's own Apple key — the passphrase and words offered, and if they're declined the confirm says it opens through this Mac and its Apple account only; a synced pair lands held, a secret made new there becoming the account's at Resume Sync through the account's forgot road, as the landing says; no key is held by two Macs, and Send Library says nothing about sharing", "fixed scenarios (Send Library after this change; one local-only library on two Macs; a synced pair landed with a passphrase made new) · walk"),
    ("T-6", "The migration runs as drawn: no custody repair in either direction until the mode is confirmed, corner 45's notice offering Use Standard as a key change; the family tree's first entries — the current key taking the mode recorded, every fingerprint the catalog's key files name listed; the fold; then this Mac's copies of other libraries and the live library, local or synced once its mode is confirmed Standard, gain an Apple key of their own beside the old shared one; then a fresh backup — removing no road", "migration drills per shape · her stores' byte-copies · scenario promise 12 · fixed scenarios (corner 45's ambiguous case; today's Standard-waiting and exposed libraries through the migration; the window after the move; iCloud Keychain off)"),
    ("T-7", "Retiring the old shared key runs as drawn: the move again and the checks at Use Castle's door, a vault still on it stopping the act there; the sheet listing exactly what would stop opening and every Standard thing with no passphrase or words; no keep-for-now; deleted only by its recorded id; the last-step race landing with the door and the exception; the door only on a library already in Castle before this change, gone once pressed", "fixed scenarios (two libraries on one Apple account; an older build's Re-link) · walk"),
    ("T-8", "A plaintext export lands under today's key and mode when it carries this library's ID, otherwise as a new library in Standard — said in the confirm", "fixed scenario · the restore drill"),
    ("A-1", "The four account situations behave as the table says; signing in or out changes nothing", "account-sequence walk · scenario promise 4"),
    ("A-2", "New writing belongs to the library's account", "state-transition suite"),
    ("A-3", "Leaving an account re-keys the library in either mode — Castle: both secrets; Standard: the passphrase typed or set new, the words typed or made new, the new key under this Mac's existing own Apple key, nothing minted — the new key's history taking the old one, any anchor riding along unchanged; the account left opens only the copies from while it synced in Standard — until it replaces its keys or enters Castle — never what's written after; the account's Apple key is left to the account", "fixed scenarios (a library leaves its account — each of the four acts, in Castle and in Standard; This-Mac-Only Castle from an account in Standard) · account-sequence walk"),
    ("A-4", "Joining or moving into an account takes its mode: in Castle as entering Castle; in Standard from Castle as leaving Castle, with its anchor and the leave screen's sentence; in the library's own mode (Standard from Standard, Castle from Castle) keeping the key; a library passphrase that differs from the account's re-locks the library key under the account's, the anchor untouched", "executor tests · fixed scenario (a Castle library joins a Standard account whose passphrase differs) · account-sequence walk"),
    ("L-1", "The lobby follows the table (VX-310): the Unlock with Touch ID button whenever this scope has a Touch ID item for the current key; no item or no finger enrolled — no button and one quiet line; a press that fails against an item that exists — “Touch ID changed since you set it up — unlock with the passphrase”, then the re-arm question, “Touch ID can't open Variorum on this Mac any more. Set it up again? Every finger enrolled on this Mac will open it.” — a new item only on yes; a choice of Touch ID with no item behind it (deleted, the keychain wiped, or both homes rolled back past a switch to Always ask) — nothing asked, Always ask recorded quietly, the quiet line shown, and Touch ID back only from Settings, with the passphrase; a new device identity starting on Always ask; the stored hash only a hint", "lobby tests · fixed scenarios (the stored Touch ID hash moves with nothing changed; both homes rolled back past a switch to Always ask; a replacement Mac's first open) · mutation pin (no re-arm question without an existing item) · walk on a Mac with and without an enrolled finger"),
    ("K-1", "Retention and the offer act only on this Mac's copies of this library", "scenario promise 11 · fixed scenario (the cross-Mac prune)"),
    ("K-2", "Every sentence about what opens a copy comes from the route finder and is true", "scenario promise 9"),
    ("K-3", "Other libraries' copies whose newest copy is in Standard keep opening through this Mac's own key file and Apple key for them; deleting a library's last copy deletes its key file and its Apple key", "fixed scenario (an older library of another library) · walk"),
    ("K-4", "A copy with no record has its mode worked out once with today's rules; an exposed-era Standard copy with no passphrase or words never lands in Castle", "fixed scenario (a copy made before this change, of another library)"),
    ("O-1", "Who can open what matches the table, for every row", "adversary scenarios · Keychain Access check on the dev store"),
]


def checklist_table():
    return ("<table><thead><tr><th>id</th><th>element (as drawn above)</th><th>proven by</th><th>result</th></tr></thead><tbody>"
            + "".join(f'<tr><td class="id">{E(i)}</td><td>{E(e)}</td><td>{E(p)}</td><td>—</td></tr>' for i, e, p in CHECKLIST)
            + "</tbody></table>")


EXCEPTIONS = [
    "<b>A library already in Castle before this change:</b> its copies from before Castle, made under the old shared Apple key, open through your Apple account — and on this Mac for anyone with its login password — until that key is retired: one press, asked once on each device and kept in Settings ▸ Protection. A library entering Castle after this change retires it as Use Castle's last step (if that step's last check stops it, the same door shows).",
    "<b>A library that synced with an account in Standard and later left it:</b> its copies from those Standard days open through that account until the account replaces its keys or enters Castle. Nothing written after it left does, and nothing made while the account was in Castle ever does.",
    "<b>A library sent to another Mac before this change:</b> the two copies share its key until either one crosses a line; the retirement sheet names the other Mac's key file when it can see one. A library sent after this change shares nothing: it lands under a key of its own.",
    "<b>A retirement made while this Mac's iCloud Keychain is off</b> holds on this Mac at once, and everywhere once iCloud Keychain carries the deletion.",
    "<b>A Markdown export you turn back on in Castle</b> is plain text, by your choice at that door.",
    "<b>Copies locked under an Apple key in an Apple account this Mac has left</b> — made in Standard before the Mac switched Apple ID — open through that former account for as long as its iCloud Keychain keeps the key; this Mac can't delete it there. Their <i>Opens with</i> line says so, and they can be deleted. Use Castle's door names them.",
]


def exceptions_list():
    return '<ul class="roads">' + "".join(f"<li>{x}</li>" for x in EXCEPTIONS) + "</ul>"


THE_RULES = (
    "In Castle, nothing reachable through your Apple account or this Mac's login password opens your library, or any "
    "copy Variorum made of it on this Mac — or, once it syncs, on any device of your account after that device follows. "
    "In Standard, your Apple account opens your library and every copy Variorum made of it since it came into Standard — "
    "through iCloud Keychain, when it's on — and so does anyone who can sign in to this Mac. <b>Leaving Castle</b> gives "
    "them the library itself, with everything you wrote in it, and every copy made after the leave; no copy made before "
    "the leave opens through them — those open with the passphrase or the twelve words you had on the day you left, and "
    "leaving never makes new words, so that day's paper keeps working. Your other devices each follow with one secret "
    "typed, so their own copies from before open with the words, and with the passphrase when it was the one typed "
    "there; each copy's <i>Opens with</i> line says which, and from which day. <b>The library's key changes whenever it crosses a "
    "line</b> — into or out of Castle, out of an account, onto another Mac: into Castle, every older copy comes along; "
    "out of an account, your copies come along too, and the account you left keeps only what came before; out of Castle "
    "and onto another Mac, the new key starts clean, and what came before keeps its own locks. <i>In Castle = safe. Out "
    "of Castle = not safe.</i>")


def html_page(title, body):
    return (f'<!doctype html><html lang="en"><head><meta charset="utf-8">'
            f'<meta name="viewport" content="width=device-width, initial-scale=1">'
            f'<title>{E(title)}</title><style>{CSS}\n{ANIM_CSS}\n{CYCLE_CSS}\n{actor_css()}</style></head>'
            f'<body data-actor="you" data-glyphs="letters">{icon_defs()}{body}<script>{JS}\n{ANIM_JS}</script></body></html>')


def full_page():
    body = f"""<main>
<h1>Castle key map</h1>
<p class="lede">What each key is, where it lives, what it's locked with, and what the server holds — today, and in the
new design (your rulings of 2026-10-13, and round 3's of 2026-10-14). A companion to <code>second-opinion.html</code>; the build target alone is
<code>castle-target-key-map.html</code>.</p>
<div class="okbox"><b>The whole idea.</b> {THE_RULES} The stated exceptions are listed at the end.</div>
<h2 id="cast">The cast</h2>
<p>Every key is a random 256-bit number except your passphrase and words, which you hold. A <b>locked copy</b> is one key
locked with another; the padlock's colour says which key opens it. Nothing on the server — and nothing in a key file —
opens anything by itself.</p>
{legend()}
<h2 id="how">How to read the maps</h2>
<p>Each map has the same four places: <b>you</b>, <b>this Mac</b> (its Keychain, the library's folder, the backups folder),
<b>Apple</b> (iCloud Keychain and iCloud Drive) and the <b>Variorum server</b>. Red outlines are today's gaps; struck-out,
dashed chips are keys that don't exist or no longer open anything. The buttons light up what each person can open —
<b>You</b> first — and the toggle shows keys as letters or icons.</p>
{controls()}
<h2 id="today">Today</h2>
{''.join(map_section(k, m) for k, m in TODAY.items())}
<h2 id="new">The new design</h2>
{''.join(map_section(k, m) for k, m in NEW_FULL.items())}
<h3 id="history">The key history</h3><figure>{history_svg()}</figure>
<h2 id="moves">Moving between them</h2>
<h3 id="cycle">The cycle, step by step</h3>{cycle_section()}
<h3>Entering Castle</h3>{steps(ENTER)}
<h3 id="watch">Watch it happen</h3>{anim_section()}
<h3>Leaving Castle</h3>{steps(LEAVE)}
<p class="lede">{E(OLDER_LEAVE)}</p>
<h3>Another device follows</h3>{steps(FOLLOW)}
<h3>Leaving or joining an account</h3>{ACCOUNT_MOVES}
<h3>Opening an older backup</h3>
<div class="compare"><div class="warnbox"><b>Today (VX-209).</b> The backup's own Apple lock opens it silently; this
Mac's one Keychain slot for the library is overwritten with the backup's key; the Touch ID copy is deleted; the
library is now Standard. Bringing your Castle library back finds the silent slot and stays Standard.</div>
<div class="okbox"><b>New design.</b> {steps(OPEN_OLD)}</div></div>
<h3>Other copies, and a library landing from another Mac</h3><ul class="roads">{''.join(f'<li>{x}</li>' for x in OPEN_OTHER)}</ul>
<h2 id="who">Who can open what (new design)</h2>
<p>Read across a row. "Copies" means backups, older libraries and Time Machine copies Variorum made. In the rows about
you, plain text: what you can do. In the rows about other people, <span class="y">red</span> means they can open it and
<span class="n">green</span> means they can't.</p>
{who_table(False)}
<p class="lede">Leaving Castle: from then on the Standard column applies to the library itself — with everything
written in it, in Castle too — and to every copy made after the leave. No copy made before the leave opens through the
Apple account or the login password: those open with the passphrase or the twelve words you had on the day you left,
through the Castle anchor. Your other devices each follow with one secret typed, so their own copies from before open
with the words, and with the passphrase when it was the one you typed there to follow; each copy's <i>Opens with</i> line says which,
and from which day. Said on the leave screen.</p>
<p>The stated exceptions, each said on the affected copy's <i>Opens with</i> line:</p>
{exceptions_list()}
</main>"""
    return html_page("Castle key map", body)


def target_page():
    body = f"""<main>
<h1>Castle target key map</h1>
<p class="lede">The system the VX-266 plan builds — and nothing else. This page is an acceptance artifact (her ruling,
2026-10-13): at the effort's close, every element below is checked against the code, and the checklist at the end
records the proof for each. If a phase changes the design, this page changes in the same commit, at her word. The binding
text is <code>notes/plans/vx-266-castle-backups-prelaunch.md</code>.</p>
<div class="okbox"><b>The rules.</b> {THE_RULES} The stated exceptions are said where they apply, and below the
who-can-open table.</div>
<h2 id="cast">The cast</h2>
{legend()}
{controls()}
<h2 id="castle">Castle</h2>
{map_section("t-castle-local", TARGET["t-castle-local"])}
{map_section("t-castle-sync", TARGET["t-castle-sync"])}
<h2 id="standard">Standard</h2>
{map_section("t-std-local", TARGET["t-std-local"])}
{map_section("t-std-sync", TARGET["t-std-sync"])}
<h3 id="history">The key history (both modes)</h3><figure>{history_svg()}</figure>
<h2 id="moves">Every move</h2>
<h3 id="cycle">The cycle, step by step</h3>{cycle_section()}
<h3>Entering Castle</h3>{steps(ENTER)}
<h3 id="watch">Watch it happen</h3>{anim_section()}
<h3>Leaving Castle</h3>{steps(LEAVE)}
<p class="lede">{E(OLDER_LEAVE)}</p>
<h3>Replace All Keys</h3>{steps(REPLACE)}
<h3>Another device follows</h3>{steps(FOLLOW)}
<h3>The key doors</h3><ul class="roads">{''.join(f'<li>{x}</li>' for x in KEY_DOORS)}</ul>
<h3>Opening an older backup</h3>{steps(OPEN_OLD)}
<h3>Other copies, and a library landing from another Mac</h3><ul class="roads">{''.join(f'<li>{x}</li>' for x in OPEN_OTHER)}</ul>
<h3>Existing stores, once (the migration)</h3>
<p class="lede">It runs once, at first unlock on the new build, as a plan. The whole new system stays off in Release builds
until her word at release — the release switch, VX-329, where today's code splits: its deciding and writing roles die
there, while its read-only legacy readers stay (today's mode rule, the old items' reads, and today's finish path for one
release), so this migration can still run after the switch. On a Release build it runs only once she has turned the new
system on.</p>
{steps(MIGRATE)}
<h3 id="shared">The old shared Apple key (stores from before this change)</h3>{steps(SHARED)}
<h2 id="accounts">Accounts</h2>{ACCOUNTS}
<h2 id="lobby">The lobby and Touch ID</h2>{LOBBY}
<h2 id="who">Who can open what</h2>
<p>In the rows about you, plain text. In the rows about other people, <span class="y">red</span> means they can open it
and <span class="n">green</span> means they can't. Synced and this-Mac-only libraries answer the same way; synced
libraries add the server column's facts.</p>
{who_table(True)}
<p>The stated exceptions, where the Castle column's rows can still open something — each said on the affected
copy's <i>Opens with</i> line:</p>
{exceptions_list()}
<h2 id="checklist">The acceptance checklist</h2>
<p>Filled at the effort's close (phase 5). Every row needs its proof and a result; a row without one, or a mismatch,
blocks the close.</p>
{checklist_table()}
</main>"""
    return html_page("Castle target key map", body)


if __name__ == "__main__":
    kind, out = sys.argv[1], sys.argv[2]
    with open(out, "w", encoding="utf-8") as f:
        f.write(full_page() if kind == "full" else cycle_page() if kind == "cycle" else target_page())
    print("wrote", out)
