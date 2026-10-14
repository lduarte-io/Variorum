#!/usr/bin/env python3
"""Castle key maps — two self-contained pages from one source.

  python3 keymap_gen2.py full   <out.html>   # today and the new design, for understanding
  python3 keymap_gen2.py target <out.html>   # ONLY the system the VX-266 plan builds — the acceptance artifact

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
CHIP_H = 34

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
    col, by, bh, _ = BOXES[box]
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
    full_reach = (reach + (" you" if state != "dead" else "")).strip()
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
    if state == "dead":
        parts.append(f'<line class="strike" x1="{x + 8:.1f}" y1="{y + CHIP_H / 2:.1f}" '
                     f'x2="{x + w - 8:.1f}" y2="{y + CHIP_H / 2:.1f}"/>')
    parts.append("</g>")
    return "".join(parts)


def note(box, ri, text):
    col, by, _, _ = BOXES[box]
    cx, _ = COLS[col]
    return f'<text class="nt" x="{cx + 14:.1f}" y="{by + 26 + ri * (CHIP_H + 6) + 20:.1f}">{E(text)}</text>'


def svg_map(title, chips, notes=(), inactive=()):
    out = [f'<svg class="map" viewBox="0 0 {W} {H}" role="img" aria-label="{E(title)}">']
    for col, (cx, _) in COLS.items():
        dim = " inactive" if col in inactive else ""
        out.append(f'<text class="colt{dim}" x="{cx + 4}" y="24">{E(COL_TITLES[col])}</text>')
    for bid, (col, by, bh, bt) in BOXES.items():
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
def castle_target(synced):
    c = you(finger=True) + [
        chip("keychain", 0, 0, "{L} · Touch ID item", "one per key", "touch"),
        chip("keychain", 2, 0, "This Mac's memory", "sealed · no secret", "memory"),
        chip("folder", 0, 0, "Library file", "encrypted with {L}"),
        chip("folder", 1, 0, "{L} · locked with {P}", "the one key file", "L", lockby="P"),
        chip("folder", 2, 0, "{L} · locked with {W}", "the one key file", "L", lockby="W"),
        chip("folder", 1, 1, "History: older keys", "each locked with {L}", "L", lockby="L", span=2),
        chip("folder", 0, 2, "Record: Castle", "inside the library file", "memory"),
        chip("folder", 1, 2, "Plans for long acts", "sealed with {L}", "memory"),
        chip("backups", 0, 0, "This Mac's backups", "key file + history"),
        chip("backups", 1, 0, "Old Apple locks", "dead — key deleted", "A", state="dead"),
        chip("ikc", 0, 0, "No Apple key", "deleted everywhere", "A", state="dead"),
        chip("idrive", 0, 0, "Backups", "{P}, {W}, or the history"),
    ]
    if synced:
        c += [chip("keychain", 1, 0, "{M}+{C} · Touch ID item", "the sync keys", "touch"),
              chip("folder", 0, 1, "{L} · locked with {M}", "the one key file", "L", lockby="M"),
              chip("folder", 2, 2, "{M} · locked with {W}", "copied from the vault", "M", lockby="W"),
              chip("vault", 0, 0, "{M} · locked with {P}", "", "M", lockby="P"),
              chip("vault", 0, 1, "{M} · locked with {W}", "", "M", lockby="W"),
              chip("vault", 0, 2, "No Apple copy", "account key deleted", "A", state="dead"),
              chip("vault", 0, 3, "{C} · locked with {M}", "", "C", lockby="M"),
              chip("rows", 0, 0, "Your writing", "encrypted with {C}"),
              chip("rows", 0, 1, "Some plain facts", "dates, tag shape, sizes", "plain", reach=S_)]
    return c


def std_target(synced):
    c = you() + [
        chip("keychain", 0, 0, "{L} · silent item", "one per key", "L", reach=L_),
        chip("keychain", 2, 0, "This Mac's memory", "sealed · no secret", "memory"),
        chip("folder", 0, 0, "Library file", "encrypted with {L}", reach=L_),
        chip("folder", 1, 0, "{L} · locked with {A}", "this library's key", "L", lockby="A", reach=LA),
        chip("folder", 2, 0, "{L} · locked with {P}", "", "L", lockby="P"),
        chip("folder", 0, 1, "{L} · locked with {W}", "", "L", lockby="W"),
        chip("folder", 1, 1, "History: older keys", "each locked with {L}", "L", lockby="L", reach=LA,
             span=1 if synced else 2),
        chip("folder", 0, 2, "Record: Standard", "inside the library file", "memory"),
        chip("folder", 1, 2, "Plans for long acts", "sealed with {L}", "memory"),
        chip("backups", 0, 0, "This Mac's backups", "key file + history", reach=L_),
        chip("ikc", 0, 0, "{A} · the account's" if synced else "{A} · this library's", "named by its own id",
             "A", reach=LA),
        chip("idrive", 0, 0, "Backups", "if you picked iCloud", reach=LA),
    ]
    if synced:
        c += [chip("keychain", 1, 0, "{M}+{C} · silent item", "the sync keys", "M", reach=L_),
              chip("folder", 2, 2, "{L} · locked with {M}", "", "L", lockby="M", reach=LA),
              chip("folder", 2, 1, "{M} · locked with {W}", "copied from the vault", "M", lockby="W"),
              chip("vault", 0, 0, "{M} · locked with {P}", "", "M", lockby="P"),
              chip("vault", 0, 1, "{M} · locked with {W}", "", "M", lockby="W"),
              chip("vault", 0, 2, "{M} · locked with {A}", "the account's key", "M", lockby="A", reach=LA),
              chip("vault", 0, 3, "{C} · locked with {M}", "", "C", lockby="M", reach=LA),
              chip("rows", 0, 0, "Your writing", "encrypted with {C}", reach=LA),
              chip("rows", 0, 1, "Some plain facts", "dates, tag shape, sizes", "plain", reach=S_)]
    return c


TARGET = {
    "t-castle-local": dict(title="Castle — this Mac only", inactive=("server",), chips=castle_target(False),
                           notes=[note("vault", 0, "not used — no sync")],
                           roads=[("On this Mac", "Touch ID — or your passphrase every time, with Always ask (then no Touch ID item exists)."),
                                  ("Older copies", "today's key opens the history, so every older backup opens with nothing more typed."),
                                  ("On a new Mac", "your passphrase or words; the newest backup's history opens every older one."),
                                  ("Lose the passphrase, the words and every Touch ID item", "the library and every copy are gone — said at the door, with Export a plain copy offered first."),
                                  ("Stores from before this change", "until the old shared Apple key is retired, copies made under it before Castle still open through the Apple account. Use Castle retires it unless you keep it for now; Settings ▸ Protection has the door.")]),
    "t-castle-sync": dict(title="Castle — synced", chips=castle_target(True),
                          roads=[("On this Mac", "Touch ID, or the passphrase."),
                                 ("A new device", "sign in, then your passphrase or words once."),
                                 ("The server", "locked keys and encrypted writing only; no Apple copy anywhere."),
                                 ("A device that joined without typing anything", "its key file also holds the master locked with your twelve words, so the words open it even after the master changes."),
                                 ("Stores from before this change", "until the old shared Apple key is retired, copies made under it before Castle still open through the Apple account. Use Castle retires it unless you keep it for now; Settings ▸ Protection has the door.")]),
    "t-std-local": dict(title="Standard — this Mac only", inactive=("server",), chips=std_target(False),
                        notes=[note("vault", 0, "not used — no sync")],
                        roads=[("On this Mac", "the silent item — nothing asked."),
                               ("On a new Mac", "this library's Apple key arrives through iCloud Keychain and opens it — or your passphrase or words."),
                               ("What it means", "your Apple account, and anyone who can sign in to this Mac, can open the library and every copy Variorum keeps."),
                               ("Other libraries' copies here", "an older library, or backups, of a library whose newest copy is in Standard: a key file of its own in its backup folder, under an Apple key of its own — it opens as before. Deleting a library's last copy deletes its key.")]),
    "t-std-sync": dict(title="Standard — synced", chips=std_target(True),
                       roads=[("On this Mac", "the silent item — nothing asked."),
                              ("A new device", "sign in to iCloud and Variorum: the account's Apple key opens the vault's master, nothing typed."),
                              ("What it means", "the same as this-Mac-only, for every device of the account.")]),
}

NEW_FULL = {
    "castle-new": dict(title="Castle — the new design (synced parts marked)", chips=castle_target(True),
                       roads=[("On this Mac", "Touch ID (or the passphrase) opens the library — and, through the history, every older copy, nothing typed."),
                              ("On a new Mac", "your passphrase or words; the newest backup's history opens every older one."),
                              ("Lose the passphrase, the words and every Touch ID item", "the library and its older copies are gone — said at the door; export a plain copy first if you want one.")]),
    "std-new": dict(title="Standard — the new design (synced parts marked)", chips=std_target(True),
                    roads=[("On this Mac", "the silent item — nothing asked."),
                           ("On a new Mac", "your Apple account brings everything back, nothing typed."),
                           ("What it means", "your Apple account — and anyone with this Mac's login password — can open the library and every copy Variorum keeps. Out of Castle means not safe, said plainly.")]),
}


# ---- the history chain ------------------------------------------------------------------
def history_svg():
    w, h = 1000, 150
    keys = [("{L3}", "today's key", "touch"), ("{L2}", "before Replace All Keys", "L"),
            ("{L1}", "entered Castle", "L"), ("{L0}", "the first key", "L")]
    out = [f'<svg class="map" viewBox="0 0 {w} {h}" role="img" aria-label="the key history chain">']
    x0, gap, cw = 40, 50, 180
    for i, (k, sub, kind) in enumerate(keys):
        x = x0 + i * (cw + gap)
        out.append(f'<g class="chip k-{kind}" data-reach="you"><rect class="bg" x="{x}" y="46" width="{cw}" height="44" rx="8"/>'
                   f'<rect class="bar" x="{x}" y="46" width="5" height="44" rx="2"/>'
                   f'<foreignObject x="{x + 12}" y="46" width="{cw - 16}" height="44"><div xmlns="http://www.w3.org/1999/xhtml" class="cc big">'
                   f'<div class="t">{rich(k)}</div><div class="s">{E(sub)}</div></div></foreignObject></g>')
        if i < len(keys) - 1:
            ax = x + cw + 6
            out.append(f'<path class="arrow" d="M{ax} 68 H{ax + gap - 12}"/>'
                       f'<path class="arrowhead" d="M{ax + gap - 12} 63 L{ax + gap - 4} 68 L{ax + gap - 12} 73 Z"/>'
                       f'<text class="nt" x="{ax}" y="58">opens</text>')
    out.append('<text class="nt" x="40" y="118">Each newer key holds every older one, locked. Whatever opens today’s key opens the past —</text>')
    out.append('<text class="nt" x="40" y="134">never the other way round: an old key opens nothing written after it.</text>')
    out.append("</svg>")
    return "".join(out)


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
background:var(--chip);white-space:nowrap}
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
        ("{L} — the library key", "Opens your library file. One per library file; replaced when you enter Castle or replace your keys.", "L"),
        ("{P} — your passphrase", "In your head. Opens a locked copy of the library key (and, synced, of the master).", "P"),
        ("{W} — your twelve words", "On paper. The same power as the passphrase — your way back if you forget it.", "W"),
        ("{A} — an Apple key", "Lives in iCloud Keychain. Standard's silent road: anyone in your Apple account holds it.", "A"),
        ("{M} — the master key", "One per sync account. Opens the sync key and proves to the server that it's you.", "M"),
        ("{C} — the sync key", "Encrypts everything sent to the server. The server never holds it unlocked.", "C"),
        ("{touch} — a Touch ID item", "This Mac's copy of a key, released only to your finger (Castle). Keychain Access can't read it.", "touch"),
        ("Silent item", "This Mac's copy that opens without asking (Standard). Keychain Access reveals it with the login password.", "L"),
        ("Locked copy (a padlock)", "A key locked with another key. Whoever holds the second key gets the first. A key file is a set of these.", "file"),
        ("This Mac's memory", "Which key is current, the mode, the account, your settings — no secret, and sealed so edits are caught.", "memory"),
    ]
    return '<div class="legend">' + "".join(
        f'<div class="card k-{k}" style="--c:var(--k-{k})"><b>{rich(t)}</b><span class="d">{E(d)}</span></div>'
        for t, d, k in items) + "</div>"


def map_section(key, m):
    roads = "".join(f"<li><b>{E(a)}:</b> {rich(b)}</li>" for a, b in m["roads"])
    return (f'<h3 id="{key}">{E(m["title"])}</h3><figure>'
            f'{svg_map(m["title"], m["chips"], m.get("notes", ()), m.get("inactive", ()))}</figure>'
            f'<ul class="roads">{roads}</ul>')


def pill(text, kind, dead=False):
    return f'<span class="pill k-{kind}{" dead" if dead else ""}">{rich(text)}</span>'


def steps(items):
    return '<ol class="steps">' + "".join(f"<li>{i}</li>" for i in items) + "</ol>"


ENTER = [
    "You type your passphrase and twelve words (set now if you have none). The screen says plainly: lose them and every Touch ID item, and this library and its older copies are gone — <b>Export a plain copy first</b> is offered. While the store still has the old shared Apple key, its checks run first and the sheet shows what they found (below).",
    f"Synced only: a new master {pill('{M}', 'M')} and sync key {pill('{C}', 'C')} are made; your writing on the server is re-encrypted with the new {pill('{C}', 'C')}; the vault is rewritten with no Apple copy.",
    f"A new library key {pill('{L′}', 'L')} is made and goes into its own {pill('{touch} item', 'touch')} (or nowhere, with Always ask).",
    f"The new key file is written: {pill('{L′} · locked with {P}', 'P')} {pill('{L′} · locked with {W}', 'W')} (and {pill('{L′} · locked with {M}', 'M')} if synced), the old key added to the history — no Apple lock. Now any crash still leaves a road in.",
    f"The library file is re-encrypted with {pill('{L′}', 'L')} — the commit point. The record inside it says Castle; this Mac's memory follows, sealed.",
    f"The old key's item, every {pill('silent item', 'L', True)} of the library, the per-library-ID items and the old key files go — each only once the history holds its key.",
    f"A fresh backup is made under {pill('{L′}', 'L')}.",
    f"This library's (or the account's) {pill('{A} Apple key', 'A', True)} is deleted from iCloud Keychain — every device, no recovery — and its id recorded as retired, so a copy of it that comes back is deleted on sight. Synced: each other device asks for your passphrase once, re-encrypts its own library, and deletes and records its own Apple keys too.",
    f"Last, the old shared {pill('{A} Apple key', 'A', True)} is retired — unless you chose <i>Use Castle, keep the old Apple key for now</i>. Then every older copy's Apple lock is dead, wherever the copy is.",
]
LEAVE = [
    "You confirm with Touch ID or the passphrase, after the plain warning: your Apple account — and anyone who can sign in to this Mac — will be able to open this library and every copy Variorum kept, including copies made while you were in Castle.",
    f"A fresh {pill('{A} Apple key', 'A')} is made, with a new id. Only this device makes it; your other devices wait for it.",
    f"The key file gains {pill('{L} · locked with {A}', 'A')}; synced, the vault gains {pill('{M} · locked with {A}', 'A')}.",
    f"{pill('{L}', 'L')} moves from its {pill('{touch} item', 'touch')} to a {pill('silent item', 'L')}; the record and this Mac's memory say Standard.",
    "Your other devices follow without asking anything; each adds its own Apple lock when the new key arrives.",
]
REPLACE = [
    "For a key someone may have used, or a device someone may have had: you type your passphrase and twelve words (or make new words).",
    f"New {pill('{M}', 'M')} and {pill('{C}', 'C')}; the server's writing re-encrypted; the vault rewritten (in Standard the new master is locked with the same account Apple key — Castle is the answer to an Apple-account intruder).",
    f"A new library key, with the old one added to the history; every other device follows by typing a secret once.",
]
FOLLOW = [
    "Another of your devices entered Castle or replaced the keys; this device sees the vault changed.",
    "It asks for your passphrase or words — once. Typing the old passphrase after a change elsewhere is refused with the change named: <i>“Your passphrase was changed on [device] on [day] — enter the new one.”</i>",
    f"It gets the new {pill('{M}', 'M')} and {pill('{C}', 'C')}, re-encrypts its own library with a new key (the old key joins its history), and — into Castle — deletes its own Apple keys and records them as retired.",
    "Until then it still opens and you can write; it just doesn't sync, and a banner says why. A follow into Standard asks nothing.",
]
OPEN_OLD = [
    "Inside Variorum, you pick an older backup of this library (or one is found at its place, say after a Time Machine rollback — Touch ID or the passphrase comes first either way).",
    "Its key is found through the history — today's key opens the older ones — so nothing more is typed.",
    "The copy is re-encrypted with today's key, straight into place; the library you had joins your older libraries.",
    "Your library is back as it was then, in the mode it's in now. A Castle library stays in Castle.",
]
OPEN_OTHER = [
    "<b>A Castle copy of this library from another Mac, into a Standard library here:</b> opening it runs Use Castle's own steps — your passphrase and words, a fresh key — or you cancel. Castle comes with a Castle library; a copy never lowers.",
    "<b>A copy whose key isn't in this library's history:</b> the restore list and the confirm mark it <i>“made on another Mac, or not by you”</i> before anything happens.",
    "<b>A different library:</b> it keeps its own key and mode, and the confirm says so concretely; the library you had joins your older libraries.",
    "<b>A plaintext export:</b> if it carries this library's ID it comes in under today's key and mode; otherwise it becomes a new library in Standard, and the confirm says so.",
]
MIGRATE = [
    "Anything in flight finishes first, with today's runner.",
    "The mode is worked out once with today's rules; a synced library takes the vault's word; anything ambiguous records Castle (with a one-time notice and Use Standard one press away); nothing Apple-reachable is written meanwhile.",
    "The record, this Mac's memory (sealed) and the device identity are written; per-key items added; old items left untouched for one release (entering Castle removes them once the history holds their key).",
    "Existing copies are attributed to their library and Mac; new backups go to per-library, per-Mac folders.",
    "The one key file is written and every reachable older key folded into the history — through the old shared Apple key while it's still readable, and the passphrase if needed (asked once). An old key file stays until the history holds its key; one the fold couldn't reach stays for good.",
    "Everything this Mac holds in Standard moves off the old shared Apple key: other libraries' copies first (a key file and Apple key of their own), then the live library (a synced account only with a fresh vault read), then <b>a fresh backup</b>, so the newest copy carries the history and the new locks.",
    "A store already in Castle gets one notice: copies from before Castle still open through the Apple account until the old key is retired — with the door to retire it.",
]
SHARED = [
    "<b>One key, every library.</b> Today's builds lock every Standard library on an Apple account with one shared Apple key, on every device. Deleting it deletes it everywhere, with no recovery — so it goes only after everything that needs it has moved off.",
    "<b>The moves</b> (each device's migration): every library this Mac holds in Standard gets an Apple key of its own — the live library, and other libraries' older copies; a synced account's key goes to the vault under its CAS; then a fresh backup. An older build can put an account back on the old key (its Re-link); the next device on this build moves it off again.",
    "<b>The checks</b> (Use Castle, or the door on a store already in Castle): the moves run again; then every copy this Mac can see — other libraries' and other Macs' in a shared backup folder included — and every account vault it can read are checked for anything that would stop opening. A vault still on the old key stops the retirement.",
    "<b>The sheet</b> lists those things by name, and says what the Mac can't see: a device not yet updated keeps its library working there, but if it's lost or reset before it updates, its library and backups open only with a passphrase or the words — and without either, not at all.",
    "<b>Retiring</b> deletes the old key and records its id, so a copy that comes back is deleted on sight. <i>Keep it for now</i> is offered only when something listed would stop opening; until it's retired, every Castle surface says copies from before Castle still open through the Apple account.",
]


def who_table(target):
    rows = [
        ("You, on your Mac", "Touch ID or passphrase", "opens, nothing asked"),
        ("You, on a new Mac, with your Apple account only", "no — needs your passphrase or words", "yes"),
        ("You, on a new Mac, with your passphrase or words", "yes", "yes"),
        ("Someone who knows this Mac's login password", '<span class="n">nothing</span> (Markdown exports you made are plain text)', '<span class="y">everything</span>'),
        ("Someone in your Apple account", '<span class="n">nothing</span>', '<span class="y">everything Variorum keeps</span>'),
        ("The Variorum server", 'your writing <span class="n">no</span> · dates, tag shape, sizes yes', 'the same'),
        ("Someone who steals one backup file", '<span class="n">no</span> (needs a key)', '<span class="n">no</span> (needs a key)'),
    ]
    return ("<table><thead><tr><th>who</th><th>Castle</th><th>Standard</th></tr></thead><tbody>"
            + "".join(f"<tr><td><b>{E(a)}</b></td><td>{b}</td><td>{c}</td></tr>" for a, b, c in rows)
            + "</tbody></table>")


ACCOUNTS = ("<table><thead><tr><th>the library belongs to</th><th>signed in as</th><th>what happens</th></tr></thead><tbody>"
            "<tr><td>no account</td><td>anyone</td><td>local only; the Encryption tab offers to turn sync on</td></tr>"
            "<tr><td>account X</td><td>X</td><td>in sync; it follows X's mode</td></tr>"
            "<tr><td>account X</td><td>nobody</td><td>not syncing; Use Castle / Use Standard each offer one plain road — this Mac only, and this Mac stops using the old account; <i>Stop syncing this library on this Mac</i> beside them</td></tr>"
            "<tr><td>account X</td><td>another account Y</td><td>not syncing; one screen: <i>Move it to y@…</i> or <i>Sign out</i> (the same email with a different account is named)</td></tr>"
            "</tbody></table><p>New writing always belongs to the library's account, never to whoever happens to be signed in.</p>")

LOBBY = ("<table><thead><tr><th>this Mac, right now</th><th>the lobby shows</th></tr></thead><tbody>"
         "<tr><td>a Touch ID item for this library's key, and Touch ID usable</td><td>the <b>Unlock with Touch ID</b> button — always, however many times the prompt was dismissed (it asks by itself once, at open)</td></tr>"
         "<tr><td>the same item, but the lid closed, the keyboard unplugged, or a lockout</td><td>the button stays; pressing it says why (<i>“Open the lid…”</i>) — nothing is changed or removed; the passphrase road beside it</td></tr>"
         "<tr><td>Touch ID hardware, but no finger enrolled</td><td>no button; one quiet line — Touch ID isn't set up on this Mac — and the passphrase road</td></tr>"
         "<tr><td>after a finger was added or removed (or macOS updated)</td><td>no button; one quiet line — Touch ID changed since you set it up — and the passphrase road; once open, the question <i>“Touch ID changed on this Mac … Use Touch ID for Variorum again? Every finger enrolled on this Mac will open it.”</i> — re-armed only on yes</td></tr>"
         "</tbody></table><p class=\"lede\">PROVISIONAL, hers to confirm: this reads her <i>“there should always be a button”</i> as always, wherever Touch ID can work.</p>")


CHECKLIST = [
    # (id, element, what proves it)
    ("C-1", "Castle: the library key's only device copy is one Touch ID item per key — none under Always ask; no silent item for any key the library has had", "scenario promise 2 · real-Keychain drill"),
    ("C-2", "Castle: the one key file locks the current key with the passphrase and the twelve words (and the master, synced) — no Apple lock", "model test · the posture drill"),
    ("C-3", "Castle: the history holds every older key, each locked with today's key; an old key opens nothing newer", "model test · scenario promise 8"),
    ("C-4", "Castle: no Apple key this library has retired exists; one that reappears is deleted on sight — by its recorded id only, never another Mac's key for its own copy", "scenario promise 2 · iCloud Keychain drill · fixed scenario (one library on two Macs)"),
    ("C-5", "Castle: every backup carries its day's key file; older backups open through the history with Touch ID, the passphrase or the words", "scenario promise 5 · the restore drill"),
    ("C-6", "Castle, synced: the sync keys live only in a Touch ID item (session memory under Always ask)", "scenario promise 2 · drill"),
    ("C-7", "Castle, synced: the vault holds the master locked with the passphrase and words, the sync key locked with the master — no Apple copy", "fake-server suite · live round"),
    ("C-8", "Synced key files carry the master locked with the twelve words, copied from the vault and refreshed while that master is current", "model test · fixed scenario (a silently-joined device)"),
    ("S-1", "Standard: the library key's device copy is a silent item per key; no Touch ID item", "scenario promise 3 · drill"),
    ("S-2", "Standard: the key file locks the current key with this library's Apple key (named by its id), the passphrase and the words", "model test · drill"),
    ("S-3", "Standard: Apple keys are minted only by a deliberate act or the migration, under fresh ids; an account keeps the one its vault names; other devices wait for it", "convergence suite (the follow race)"),
    ("S-4", "Standard, synced: the vault's Apple copy is under the account's own Apple key, named by its id; a vault on the old shared key is moved off it", "fake-server suite · fixed scenario (an older build's Re-link)"),
    ("S-5", "Re-link mints a fresh account key under the vault's CAS; nothing this build writes is locked with the old shared key", "executor tests · drill"),
    ("R-1", "The protection record inside the library file states the mode and account; this Mac's memory agrees", "scenario promise 1"),
    ("R-2", "This Mac's memory holds no secret; its protection-weakening fields are sealed; an edited one reads as the stricter value", "scenario promise 10 · adversary scenarios"),
    ("R-3", "Plans live beside the library, sealed, never inside it and never in a backup; a planted plan is ignored and reported", "scenario promises 6, 10 · mutation pin"),
    ("R-4", "Before unlock nothing decides: the lobby offers only self-verifying roads", "assess tests · the file-swap scenario"),
    ("T-1", "Use Castle runs §‘Entering Castle’ in order, prepare-then-commit, and survives a crash at every step", "executor tests · crash scenarios · the posture drill"),
    ("T-2", "Use Standard runs §‘Leaving Castle’ in order; its warning is said; other devices follow without asking", "executor tests · walk"),
    ("T-3", "Replace All Keys and the follow run as drawn; the old key joins the history; the refusal names a change made elsewhere", "executor tests · drills · walk"),
    ("T-4", "Opening an older backup brings it in under today's key and mode, never lowering it, nothing more typed", "fixed scenario VX-209 · restore drill · walk"),
    ("T-5", "A Castle copy from another Mac raises a Standard library to Castle; an unknown-key copy is flagged; a different library keeps its own mode, said concretely", "fixed scenarios · walk"),
    ("T-6", "The migration runs as drawn: the fold, then every Standard library moved to a key of its own, then a fresh backup", "migration drills per shape · her stores' byte-copies · fixed scenario (the window after the move)"),
    ("T-7", "Retiring the old shared key runs as drawn: the moves again, the checks, the sheet's list exactly what would stop opening, a vault still on it stopping the retirement, keep-for-now only with a list", "fixed scenarios (two libraries on one Apple account; an older build's Re-link) · walk"),
    ("A-1", "The four account situations behave as the table says; signing in or out changes nothing", "account-sequence walk · scenario promise 4"),
    ("A-2", "New writing belongs to the library's account", "state-transition suite"),
    ("L-1", "The lobby's Touch ID line and button follow the table (VX-310)", "lobby tests · walk on a Mac with and without an enrolled finger"),
    ("K-1", "Retention and the offer act only on this Mac's copies of this library", "scenario promise 11 · fixed scenario VX-302"),
    ("K-2", "Every sentence about what opens a copy comes from the route finder and is true", "scenario promise 9"),
    ("K-3", "Other libraries' copies whose newest copy is in Standard keep opening through their own Apple key; deleting a library's last copy deletes its key", "fixed scenario (an older library of another library) · walk"),
    ("O-1", "Who can open what matches the table, for every row", "adversary scenarios · Keychain Access check on the dev store"),
]


def checklist_table():
    return ("<table><thead><tr><th>id</th><th>element (as drawn above)</th><th>proven by</th><th>result</th></tr></thead><tbody>"
            + "".join(f'<tr><td class="id">{E(i)}</td><td>{E(e)}</td><td>{E(p)}</td><td>—</td></tr>' for i, e, p in CHECKLIST)
            + "</tbody></table>")


def html_page(title, body):
    return (f'<!doctype html><html lang="en"><head><meta charset="utf-8">'
            f'<meta name="viewport" content="width=device-width, initial-scale=1">'
            f'<title>{E(title)}</title><style>{CSS}\n{actor_css()}</style></head>'
            f'<body data-actor="you" data-glyphs="letters">{icon_defs()}{body}<script>{JS}</script></body></html>')


def full_page():
    body = f"""<main>
<h1>Castle key map</h1>
<p class="lede">What each key is, where it lives, what it's locked with, and what the server holds — today, and in the
new design (your rulings of 2026-10-13). A companion to <code>second-opinion.html</code>; the build target alone is
<code>castle-target-key-map.html</code>.</p>
<div class="okbox"><b>The whole idea in two lines.</b> In Castle, your Apple account opens nothing of this library —
not the library, not any copy Variorum made of it on this Mac or a device of your account (stores from before this
change: once the old shared Apple key is retired). In Standard, it opens your library and every copy Variorum made of
it. <i>In Castle = safe. Out of Castle = not safe.</i></div>
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
<h3>Entering Castle</h3>{steps(ENTER)}
<h3>Leaving Castle</h3>{steps(LEAVE)}
<h3>Another device follows</h3>{steps(FOLLOW)}
<h3>Opening an older backup</h3>
<div class="compare"><div class="warnbox"><b>Today (VX-209).</b> The backup's own Apple lock opens it silently; this
Mac's one Keychain slot for the library is overwritten with the backup's key; the Touch ID copy is deleted; the
library is now Standard. Bringing your Castle library back finds the silent slot and stays Standard.</div>
<div class="okbox"><b>New design.</b> {steps(OPEN_OLD)}</div></div>
<h2 id="who">Who can open what (new design)</h2>
<p>Read across a row. "Copies" means backups, older libraries and Time Machine copies Variorum made. In the rows about
you, plain text: what you can do. In the rows about other people, <span class="y">red</span> means they can open it and
<span class="n">green</span> means they can't.</p>
{who_table(False)}
<p class="lede">Leaving Castle: the Standard column applies from then on — including to copies made while you were in
Castle. Said plainly on the leave screen.</p>
</main>"""
    return html_page("Castle key map", body)


def target_page():
    body = f"""<main>
<h1>Castle target key map</h1>
<p class="lede">The system the VX-266 plan builds — and nothing else. This page is an acceptance artifact (her ruling,
2026-10-13): at the effort's close, every element below is checked against the code, and the checklist at the end
records the proof for each. If a phase changes the design, this page changes in the same commit, at her word. The binding
text is <code>notes/plans/vx-266-castle-backups-prelaunch.md</code>.</p>
<div class="okbox"><b>The two rules.</b> In Castle, nothing reachable through your Apple account or this Mac's login
password opens your library, or any copy Variorum made of it on this Mac or on a device of your account once it has
followed. In Standard, your Apple account — and anyone who can sign in to this Mac — opens your library and every copy
Variorum made of it. <i>In Castle = safe. Out of Castle = not safe.</i> The one stated exception, for stores from before
this change, is the old shared Apple key's, until it's retired (below).</div>
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
<h3>Entering Castle</h3>{steps(ENTER)}
<h3>Leaving Castle</h3>{steps(LEAVE)}
<h3>Replace All Keys</h3>{steps(REPLACE)}
<h3>Another device follows</h3>{steps(FOLLOW)}
<h3>Opening an older backup</h3>{steps(OPEN_OLD)}
<h3>Other copies</h3><ul class="roads">{''.join(f'<li>{x}</li>' for x in OPEN_OTHER)}</ul>
<h3>Existing stores, once (the migration)</h3>{steps(MIGRATE)}
<h3 id="shared">The old shared Apple key (stores from before this change)</h3>{steps(SHARED)}
<h2 id="accounts">Accounts</h2>{ACCOUNTS}
<h2 id="lobby">The lobby and Touch ID</h2>{LOBBY}
<h2 id="who">Who can open what</h2>
<p>In the rows about you, plain text. In the rows about other people, <span class="y">red</span> means they can open it
and <span class="n">green</span> means they can't. Synced and this-Mac-only libraries answer the same way; synced
libraries add the server column's facts.</p>
{who_table(True)}
<p class="lede">Stores from before this change: until the old shared Apple key is retired, copies made under it before
Castle still open for the two red rows' people in the Castle column too. Every Castle surface says so until it's
retired.</p>
<h2 id="checklist">The acceptance checklist</h2>
<p>Filled at the effort's close (phase 5). Every row needs its proof and a result; a row without one, or a mismatch,
blocks the close.</p>
{checklist_table()}
</main>"""
    return html_page("Castle target key map", body)


if __name__ == "__main__":
    kind, out = sys.argv[1], sys.argv[2]
    with open(out, "w", encoding="utf-8") as f:
        f.write(full_page() if kind == "full" else target_page())
    print("wrote", out)
