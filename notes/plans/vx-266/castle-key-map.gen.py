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
LAYOUT = {"boxes": BOXES, "h": H}   # swapped while the animation's frames are drawn
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
def castle_target(synced):
    c = you(finger=True) + [
        chip("keychain", 0, 0, "{L} · Touch ID item", "one per key", "touch"),
        chip("keychain", 2, 0, "This Mac's memory", "sealed · decides nothing", "memory"),
        chip("folder", 0, 0, "Library file", "encrypted with {L}"),
        chip("folder", 1, 0, "{L} · locked with {P}", "the one key file", "L", lockby="P"),
        chip("folder", 2, 0, "{L} · locked with {W}", "the one key file", "L", lockby="W"),
        chip("folder", 1, 1, "History: older keys", "each locked with {L}", "L", lockby="L", span=2),
        chip("folder", 0, 2, "Record: Castle", "in the library file · settings too", "memory"),
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
    c = you(p="in your head, if set", w="on paper, if made") + [
        chip("keychain", 0, 0, "{L} · silent item", "one per key", "L", reach=L_),
        chip("keychain", 2, 0, "This Mac's memory", "sealed · decides nothing", "memory"),
        chip("folder", 0, 0, "Library file", "encrypted with {L}", reach=L_),
        chip("folder", 1, 0, "{L} · locked with {A}", "this library's key", "L", lockby="A", reach=LA),
        chip("folder", 2, 0, "{L} · locked with {P}", "if set", "L", lockby="P"),
        chip("folder", 0, 1, "{L} · locked with {W}", "if made", "L", lockby="W"),
        chip("folder", 1, 1, "History: older keys", "each locked with {L}", "L", lockby="L", reach=LA,
             span=1 if synced else 2),
        chip("folder", 0, 2, "Record: Standard", "in the library file · settings too", "memory"),
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
                                  ("A library already in Castle before this change", "until it retires the old shared Apple key, its copies made under that key before Castle still open through the Apple account — one press in Settings ▸ Protection. Use Castle always retires it.")]),
    "t-castle-sync": dict(title="Castle — synced", chips=castle_target(True),
                          roads=[("On this Mac", "Touch ID, or the passphrase."),
                                 ("A new device", "sign in, then your passphrase or words once."),
                                 ("The server", "locked keys and encrypted writing only; no Apple copy anywhere."),
                                 ("A device that joined without typing anything", "its key file also holds the master locked with your twelve words, so the words open it even after the master changes."),
                                 ("A library already in Castle before this change", "until it retires the old shared Apple key, its copies made under that key before Castle still open through the Apple account — one press in Settings ▸ Protection. Use Castle always retires it.")]),
    "t-std-local": dict(title="Standard — this Mac only", inactive=("server",), chips=std_target(False),
                        notes=[note("vault", 0, "not used — no sync")],
                        roads=[("On this Mac", "the silent item — nothing asked."),
                               ("On a new Mac", "this library's Apple key arrives through iCloud Keychain (when it's on — Variorum can't see it) and opens it — or your passphrase or words."),
                               ("What it means", "your Apple account, and anyone who can sign in to this Mac, can open the library and every copy Variorum keeps."),
                               ("Other libraries' copies here", "an older library, or backups, of a library whose newest copy is in Standard: this Mac's own key file for it, beside its copies, under an Apple key of its own — it opens through the Apple account as before. Deleting a library's last copy deletes its key.")]),
    "t-std-sync": dict(title="Standard — synced", chips=std_target(True),
                       roads=[("On this Mac", "the silent item — nothing asked."),
                              ("A new device", "sign in to iCloud and Variorum: the account's Apple key opens the vault's master, nothing typed (when iCloud Keychain carried it)."),
                              ("What it means", "the same as this-Mac-only, for every device of the account."),
                              ("Accounts from before this change", "stay on the old shared Apple key until they enter Castle or are re-linked.")]),
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


# ---- the switch, animated: a synced library going from Standard to Castle ---------------------
ANIM_H = 410
ANIM_BOXES = {
    "you":      ("you", 40, 358, "Your head, paper, finger"),
    "keychain": ("mac", 40, 114, "This Mac's Keychain"),
    "folder":   ("mac", 164, 152, "Library folder"),
    "backups":  ("mac", 326, 72, "Backups folder"),
    "ikc":      ("apple", 40, 112, "iCloud Keychain"),
    "idrive":   ("apple", 162, 236, "iCloud Drive"),
    "vault":    ("server", 40, 192, "The vault (keys, locked)"),
    "rows":     ("server", 242, 156, "Synced writing"),
}


def switch_chips(s):
    """The chips at step s (0–11) of a synced library entering Castle. A just-changed chip pulses; a dead one is struck."""
    fin = s == 11
    def j(k):
        return " just" if s == k else ""
    swapped = s >= 5
    c = [chip("you", 0, 0, "{P} · passphrase", "in your head", kind="P", state=j(1).strip()),
         chip("you", 0, 1, "{W} · twelve words", "on paper", kind="W", state=j(1).strip()),
         chip("you", 0, 2, "{touch} · your finger", "on this Mac", kind="touch")]
    # This Mac's Keychain: the old silent items on top, the new Touch ID items below
    if s < 6:
        c += [chip("keychain", 0, 0, "{L} · silent item", "opens without asking", "L", reach=L_),
              chip("keychain", 1, 0, "{M}+{C} · silent item", "the sync keys", "M", reach=L_)]
    elif not fin:
        c += [chip("keychain", 0, 0, "{L} · silent item", "deleted", "L", state="dead" + j(6)),
              chip("keychain", 1, 0, "{M}+{C} · silent item", "deleted", "M", state="dead" + j(6))]
    c.append(chip("keychain", 2, 0, "This Mac's memory", "sealed · decides nothing", "memory"))
    row = 0 if fin else 1
    if s >= 2:
        c.append(chip("keychain", 1, row, "{M′}+{C′} · Touch ID item", "the new sync keys", "touch", state="new" + j(2)))
    if s >= 3:
        c.append(chip("keychain", 0, row, "{L′} · Touch ID item", "made at your press", "touch", state="new" + j(3)))
    # The library folder: the library file, the one key file's locked copies, the record, the plan
    c.append(chip("folder", 0, 0, "Library file", "encrypted with {L′}" if swapped else "encrypted with {L}",
                  reach="" if swapped else LA, state=j(5).strip()))
    if s < 4:
        c += [chip("folder", 1, 0, "{L} · locked with {A}", "the account's key", "L", lockby="A", reach=LA),
              chip("folder", 2, 0, "{L} · locked with {P}", "the key file", "L", lockby="P"),
              chip("folder", 0, 1, "{L} · locked with {W}", "the key file", "L", lockby="W"),
              chip("folder", 1, 1, "History: older keys", "each locked with {L}", "L", lockby="L", reach=LA),
              chip("folder", 2, 1, "{M} · locked with {W}", "copied from the vault", "M", lockby="W"),
              chip("folder", 2, 2, "{L} · locked with {M}", "the key file", "L", lockby="M", reach=LA if s < 2 else L_)]
    else:
        if not fin:
            c.append(chip("folder", 1, 0, "{L} · locked with {A}", "left the key file", "L", lockby="A",
                          state="dead" + j(4)))
        c += [chip("folder", 2, 0, "{L′} · locked with {P}", "the new key file", "L", lockby="P", state="new" + j(4)),
              chip("folder", 0, 1, "{L′} · locked with {W}", "the new key file", "L", lockby="W", state="new" + j(4)),
              chip("folder", 1, 1, "History: older keys", "each locked with {L′}", "L", lockby="L", state="new" + j(4)),
              chip("folder", 2, 1, "{M′} · locked with {W}", "copied from the vault", "M", lockby="W", state="new" + j(4)),
              chip("folder", 2, 2, "{L′} · locked with {M′}", "the new key file", "L", lockby="M", state="new" + j(4))]
    c.append(chip("folder", 0, 2, "Record: Castle" if swapped else "Record: Standard", "settings live here too",
                  "memory", state=j(5).strip()))
    planned = 1 <= s <= 9
    c.append(chip("folder", 1, 2, "Plan: Use Castle" if planned else "No plan in flight",
                  "named by the record" if planned else "", "memory", state=j(1).strip()))
    # The backups folder: the frozen key files' locked copies
    c.append(chip("backups", 0, 0, "This Mac's backups",
                  "plus a fresh one under {L′}" if s >= 7 else "each with a frozen key file",
                  reach=LA if s < 8 else "", state=("new" + j(7)) if s >= 7 else ""))
    if fin:
        c.append(chip("backups", 1, 0, "Older backups", "via the history", "L", lockby="L"))
    elif s < 8:
        c.append(chip("backups", 1, 0, "{L} · locked with {A}", "in each backup", "L", lockby="A", reach=LA))
    else:
        c.append(chip("backups", 1, 0, "{L} · locked with {A}", "its lock key is gone", "L", lockby="A", state="dead" + j(8)))
    if s < 10:
        c.append(chip("backups", 2, 0, "{L} · locked with {M}",
                      "in each backup" if s < 6 else "until devices follow",
                      "L", lockby="M", reach=LA if s < 2 else (L_ if s < 6 else "")))
    elif not fin:
        c.append(chip("backups", 2, 0, "{L} · locked with {M}", "old master gone", "L", lockby="M",
                      state="dead" + j(10)))
    # iCloud Keychain and iCloud Drive
    if s < 8:
        c.append(chip("ikc", 0, 0, "{A} · the account's", "named by its own id", "A", reach=LA))
    else:
        c.append(chip("ikc", 0, 0, "{A} · the account's" if not fin else "No Apple key",
                      "deleted · no recovery", "A", state="dead" + j(8)))
    if s < 9:
        c.append(chip("ikc", 0, 1, "{A} · the old shared key", "older stores only", "A", reach=LA,
                      state="warn" if s == 8 else ""))
    elif not fin:
        c.append(chip("ikc", 0, 1, "{A} · the old shared key", "retired after the checks", "A", state="dead" + j(9)))
    c.append(chip("idrive", 0, 0, "Backups", "if you picked iCloud" if s < 8 else "open only with you now",
                  reach=LA if s < 8 else ""))
    # The server: the vault and the synced writing
    if s < 2:
        c += [chip("vault", 0, 0, "{M} · locked with {P}", "", "M", lockby="P"),
              chip("vault", 0, 1, "{M} · locked with {W}", "", "M", lockby="W"),
              chip("vault", 0, 2, "{M} · locked with {A}", "the Apple copy", "M", lockby="A", reach=LA),
              chip("vault", 0, 3, "{C} · locked with {M}", "", "C", lockby="M", reach=LA)]
    else:
        c += [chip("vault", 0, 0, "{M′} · locked with {P}", "the new master", "M", lockby="P", state="new" + j(2)),
              chip("vault", 0, 1, "{M′} · locked with {W}", "", "M", lockby="W", state="new" + j(2)),
              chip("vault", 0, 2, "No Apple copy", "removed by the rotation", "A", state="dead" + j(2)),
              chip("vault", 0, 3, "{C′} · locked with {M′}", "the new sync key", "C", lockby="M", state="new" + j(2))]
    c += [chip("rows", 0, 0, "Your writing", "re-encrypted with {C′}" if s >= 2 else "encrypted with {C}",
               reach=LA if s < 2 else "", state=j(2).strip()),
          chip("rows", 0, 1, "Some plain facts", "dates, tag shape, sizes", "plain", reach=S_)]
    return c


Y, N = "y", "n"
SWITCH_CAPS = [
    dict(t="Before: Standard, synced",
         d="Everything opens without asking — for you, for anyone who can sign in to this Mac, and for your Apple "
           "account. Each padlock wears the colour of the key that opens it. The old shared key at the right exists "
           "only on stores from before this change.",
         who=("everything", (Y, "everything — through the silent items, and the Apple key Keychain Access reveals"),
              (Y, "everything — the Apple key opens the vault's master and every key file")),
         locks=["{L} locked with {A}, {P}, {W} and {M} — in the key file, and in every backup's",
                "{M} locked with {P}, {W} and {A} in the vault; {C} locked with {M}"]),
    dict(t="You press Use Castle",
         d="You type your passphrase and your twelve words: they'll lock the new keys. The screen says plainly: lose "
           "them and every Touch ID item, and this library and its older copies are gone — Export a plain copy first "
           "is offered. On a store from before this change, the old shared key's checks run here, and the sheet "
           "lists anything they'd stop opening.",
         who=("everything", (Y, "everything — nothing has changed yet"), (Y, "everything — nothing has changed yet")),
         locks=["nothing yet — a plan is written beside the library, sealed and named by the record"]),
    dict(t="New sync keys, and a vault with no Apple copy",
         d="A new master {M′} and sync key {C′} are made and kept in a Touch ID item made at your press. Your writing "
           "on the server is re-encrypted with {C′}, and the vault is rewritten: {M′} locked with your passphrase and "
           "with your words — and no Apple copy.",
         who=("everything", (Y, "the library and every backup — the silent items and the Apple key are still here"),
              (Y, "the library and every backup, through the key files' Apple locks — but no longer the server's copy")),
         locks=["new: {M′} locked with {P} · {M′} locked with {W} · {C′} locked with {M′}",
                "gone: {M} locked with {A} — the vault's Apple copy"]),
    dict(t="A new library key",
         d="A new library key {L′} goes into its own Touch ID item (or nowhere, with Always ask). From now until the "
           "swap, backups and other copies pause, so none can carry a half-made change.",
         who=("everything", (Y, "the library and every backup — the silent items and the Apple key are still here"),
              (Y, "the library and every backup, through the key files' Apple locks")),
         locks=["new: {L′} in a Touch ID item — only your finger opens it"]),
    dict(t="The new key file",
         d="The one key file is rewritten: {L′} locked with your passphrase, your words and the new master; the old "
           "key {L} — and every older one — locked with {L′} in the history; the master's words copy refreshed for "
           "{M′}. No Apple lock. From here, a crash at any point still leaves a road in.",
         who=("everything", (Y, "the library and every backup — the library file is still under {L}"),
              (Y, "the library and every backup, through every backup's Apple lock on {L}")),
         locks=["new: {L′} locked with {P} · with {W} · with {M′}",
                "new: {L} and every older key, locked with {L′} — the history",
                "new: {M′} locked with {W} — the master's words copy",
                "dropped from the live key file: {L} locked with {A} — every backup's key file still has it"]),
    dict(t="The swap — the commit point",
         d="The record, now saying Castle, is written into the staged copy; then the library file is swapped to "
           "{L′}. From this moment the library is in Castle. Copies resume, each carrying a key and a record that "
           "match.",
         who=("everything", (Y, "older backups only — the silent item's {L} opens them, but not the library"),
              (Y, "older backups only, through their Apple locks")),
         locks=["the library file: now encrypted with {L′}", "the record: Castle"]),
    dict(t="The old key's copies go",
         d="The silent items for {L} and the old sync keys are deleted — with any older per-library items, escrow "
           "items and old key files, each only once the history holds its key.",
         who=("everything", (Y, "older backups only — through the Apple key Keychain Access reveals"),
              (Y, "older backups only, through their Apple locks")),
         locks=["gone: {L} in a silent item · {M}+{C} in a silent item"]),
    dict(t="A fresh backup",
         d="A new backup under {L′}. Its frozen key file carries the history, so every older backup opens through "
           "it, with nothing more typed.",
         who=("everything", (Y, "older backups only — through the Apple key Keychain Access reveals"),
              (Y, "older backups only, through their Apple locks")),
         locks=["new: a backup whose key file locks {L′} with {P}, {W} and {M′}, with the history"]),
    dict(t="The Apple keys go",
         d="The account's Apple key — and any other Apple key this library alone used — is deleted from iCloud "
           "Keychain on every device, with no recovery, and its id recorded, so a copy that comes back is deleted on "
           "sight. Every backup's Apple lock is now dead: the key that opened it no longer exists.",
         who=("everything", (N, "nothing — no silent item, no Apple key, and a Touch ID item can't be read"),
              (N, "nothing — no Apple key and no Apple copy (a store from before this change: not until step 9)")),
         locks=["gone: {A}, the account's Apple key", "dead: {L} locked with {A}, in every backup's key file"]),
    dict(t="Stores from before this change: the old shared key goes too",
         d="Last, after its checks and the sheet you saw at step 1, the old shared Apple key is retired, and every "
           "older copy's lock under it is dead too. A store made after this change never had this key.",
         who=("everything", (N, "nothing"), (N, "nothing")),
         locks=["gone: the old shared Apple key", "dead: every older copy's lock under it"]),
    dict(t="Your other devices follow",
         d="Each of your other devices asks for your passphrase or words once, gets {M′} and {C′}, re-keys its own "
           "library — its old key joins its history — and deletes its Apple keys and silent items. The old master "
           "now opens nothing anywhere.",
         who=("everything, on every device", (N, "nothing, on any device that has followed"), (N, "nothing")),
         locks=["gone: the silent items on your other devices",
                "dead: {L} locked with {M} in older backups — the old master is gone everywhere"]),
    dict(t="After: Castle",
         d="Only you. Touch ID, your passphrase or your words open {L′}, and through its history every older backup. "
           "Lose all three and it's gone — said at the door, with a plain copy offered first. Leaving Castle later "
           "would give your Apple account a key to all of it again, and the leave screen says so.",
         who=("everything — Touch ID, your passphrase or your words", (N, "nothing"), (N, "nothing")),
         locks=["{L′} locked with {P}, {W} and {M′}; the history locked with {L′}",
                "{M′} locked with {P} and {W}; {C′} locked with {M′}",
                "Touch ID items that only your finger opens"]),
]


def anim_section():
    LAYOUT["boxes"], LAYOUT["h"] = ANIM_BOXES, ANIM_H
    try:
        svgs = [svg_map(f"Entering Castle, step {i}: {cap['t']}", switch_chips(i)) for i, cap in enumerate(SWITCH_CAPS)]
    finally:
        LAYOUT["boxes"], LAYOUT["h"] = BOXES, H
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
    return ('<p class="lede">A synced library going from Standard to Castle, one step at a time. Each padlock wears the '
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
    f"A new library key {pill('{L′}', 'L')} is made and goes into its own {pill('{touch} item', 'touch')}, made at this press (or nowhere, with Always ask).",
    f"The new key file is written: {pill('{L′} · locked with {P}', 'P')} {pill('{L′} · locked with {W}', 'W')} (and {pill('{L′} · locked with {M}', 'M')} if synced), the old key added to the history — no Apple lock. Now any crash still leaves a road in.",
    f"The record is written into the staged copy, saying Castle; then the library file is swapped to {pill('{L′}', 'L')} — the commit point. Copies pause from the new key's making to the swap, so every copy carries a matching key and record. This Mac's memory follows.",
    f"The old key's item, every {pill('silent item', 'L', True)} of the library, the per-library-ID items, the escrow items and the old key files go — each only once the history holds its key.",
    f"A fresh backup is made under {pill('{L′}', 'L')}.",
    f"The {pill('{A} Apple keys', 'A', True)} this library alone uses — its own and every device-own key — are deleted from iCloud Keychain, every device, no recovery, and their ids recorded as retired, so a copy that comes back is deleted on sight. The account's goes when the account itself enters Castle: its rotation removes the vault's Apple copy. Synced: each other device asks for your passphrase once, re-encrypts its own library, and records and deletes its own Apple keys too.",
    f"Last, the old shared {pill('{A} Apple key', 'A', True)} is retired, so every older copy's Apple lock is dead, wherever the copy is. (There is no keep-for-now: to deal with something the sheet listed first, cancel and come back.)",
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
    f"New {pill('{M}', 'M')} and {pill('{C}', 'C')}; the server's writing re-encrypted; the vault rewritten (in Standard the new master is locked with the account's Apple key — an account still on the old shared key is re-linked first, with a fresh key of its own — and Castle is the answer to an Apple-account intruder).",
    f"A new library key, with the old one added to the history; every other device follows by typing a secret once.",
]
FOLLOW = [
    "Another of your devices entered Castle or replaced the keys; this device sees the vault changed.",
    "It asks for your passphrase or words — once. Typing the old passphrase after a change elsewhere is refused with the change named: <i>“Your passphrase was changed on [device] on [day] — enter the new one.”</i>",
    f"It gets the new {pill('{M}', 'M')} and {pill('{C}', 'C')}, re-encrypts its own library with a new key (the old key joins its history), and — into Castle — records every Apple key its key file names as retired (the account's, its own, the old shared one) and deletes its own.",
    "Until then it still opens and you can write; it just doesn't sync, and a banner says why. A follow into Standard asks nothing, and ends with a notice: your Apple account can now open this library and every copy Variorum kept of it, including copies made while you were in Castle.",
]
OPEN_OLD = [
    "Inside Variorum, you pick an older backup of this library (or one is found at its place, say after a Time Machine rollback). Whatever unlocks your library comes first either way: Touch ID or the passphrase in Castle, the silent item in Standard.",
    "Its key is found through the history — today's key opens the older ones — so nothing more is typed.",
    "The copy is re-encrypted with today's key, straight into place; the library you had joins your older libraries.",
    "Your library is back as it was then, in the mode it's in now. A Castle library stays in Castle.",
]
OPEN_OTHER = [
    "<b>A Castle copy of this library from another Mac, into a Standard library here:</b> opening it runs Use Castle's own steps — your passphrase and words, a fresh key — or you cancel. Castle comes with a Castle library; a copy never lowers.",
    "<b>A copy whose key isn't in this library's history:</b> the restore list and the confirm mark it <i>“made on another Mac, or not by you”</i> before anything happens.",
    "<b>A different library:</b> it keeps its own mode and the key it came with, so its passphrase alone or its words alone open it (her ruling); in Standard it also gets an Apple key of this Mac's own. The two copies share that key — said at Send Library and on Use Castle's sheet. The confirm says so concretely; the library you had joins your older libraries.",
    "<b>A plaintext export:</b> if it carries this library's ID it comes in under today's key and mode; otherwise it becomes a new library in Standard, and the confirm says so.",
]
MIGRATE = [
    "Anything in flight finishes first, with today's runner.",
    "The mode is worked out once with today's rules; a synced library takes the vault's word; anything ambiguous records Castle (with a one-time notice and Use Standard one press away); nothing Apple-reachable is written meanwhile.",
    "The record, this Mac's memory (sealed) and the device identity are written; per-key items added; old items left untouched for one release (entering Castle removes them once the history holds their key).",
    "Existing copies are attributed to their library and Mac; new backups go to per-library, per-Mac folders.",
    "The one key file is written and every reachable older key folded into the history — through the old shared Apple key while it's still readable, and the passphrase if needed (asked once). An old key file stays until the history holds its key; one the fold couldn't reach stays for good.",
    "Everything this Mac holds in Standard gains an Apple key of its own beside the old shared one — other libraries' copies first (this Mac's own key file for each), then a local-only live library — then <b>a fresh backup</b>, so the newest copy carries the history and every lock. Nothing is removed; a synced account stays on the old key until it enters Castle or is re-linked.",
    "A library already in Castle gets one calm ask: copies from before Castle still open through the Apple account until the old key is retired — with the checks, the sheet and a door in Settings ▸ Protection.",
]
SHARED = [
    "<b>One key, every library.</b> Today's builds lock every Standard library on an Apple account with one shared Apple key, on every device. Deleting it deletes it everywhere, with no recovery — so nothing loses its road through it before you choose to retire it.",
    "<b>The move</b> (each device's migration) only adds: everything this Mac holds in Standard gains an Apple key of its own beside the old one — a local-only live library, and this Mac's copies of other libraries (its own key file for each) — then a fresh backup. A synced account stays on the old key until it enters Castle or is re-linked: its vault has room for one Apple copy, and macOS can't say whether iCloud Keychain carried a new key. A device joining such an account wraps its own key file under a key of its own; nothing is ever written under the old key.",
    "<b>The checks</b> (Use Castle, or the door on a store already in Castle): the move runs again; then, with the old key taken away, every copy this Mac can see — other libraries' and other Macs' in a shared backup folder included — and every account vault it can read. They list what would stop opening, every Standard library or copy here with no passphrase or words, and any other Mac's key file holding this library's keys. A vault still on the old key — other than the account this act moves into Castle, and read fresh again at the last step — stops the retirement.",
    "<b>The sheet</b> lists those things by name, and says what the Mac can't see: give any library still in Standard on your other devices a passphrase or words first — one with neither, on a device that's lost or reset, opens elsewhere only if iCloud Keychain carried its key, or not at all if that device hadn't been updated.",
    "<b>Retiring</b> deletes the old key and records its id, so a copy that comes back is deleted on sight. Use Castle always retires it — there is no keep-for-now. A library that was already in Castle before this change gets one calm ask and a door in Settings ▸ Protection; until it's pressed, every Castle surface there says copies from before Castle still open through the Apple account.",
]


def who_table(target):
    rows = [
        ("You, on your Mac", "Touch ID or passphrase", "opens, nothing asked"),
        ("You, on a new Mac, with your Apple account only", "no — needs your passphrase or words", "yes, when iCloud Keychain carried the key"),
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
            "</tbody></table><p>New writing always belongs to the library's account, never to whoever happens to be signed in.</p>"
            "<p><b>Leaving an account</b> (This Mac Only, Stop syncing here, deleting it here, Move): a Castle library re-keys, both secrets typed, so its key is never left under a master it no longer holds. Its copies from while it synced open through that account while it stays in Standard — said at the act. The account's Apple key is left to the account. <b>Joining or moving into an account</b> in Castle is entering Castle; into one in Standard is leaving Castle, with the leave screen's sentence. <i>(Her ruling, 2026-10-13.)</i></p>")

LOBBY = ("<table><thead><tr><th>this Mac, right now</th><th>the lobby shows</th></tr></thead><tbody>"
         "<tr><td>a working Touch ID item for this library's key (its stored state hash matches), and Touch ID usable</td><td>the <b>Unlock with Touch ID</b> button — always, however many times the prompt was dismissed (it asks by itself once, at open)</td></tr>"
         "<tr><td>the same item, but the lid closed, the keyboard unplugged, or a lockout</td><td>the button stays; pressing it says why (<i>“Open the lid…”</i>) — nothing is changed or removed; the passphrase road beside it</td></tr>"
         "<tr><td>Touch ID hardware, but no finger enrolled</td><td>no button; one quiet line — Touch ID isn't set up on this Mac — and the passphrase road</td></tr>"
         "<tr><td>after a finger was added or removed (or macOS updated) — or the item was deleted, or the keychain wiped, while the record says Touch ID</td><td>no button; one quiet line — Touch ID changed since you set it up — and the passphrase road; once open, the question <i>“Touch ID changed on this Mac … Use Touch ID for Variorum again? Every finger enrolled on this Mac will open it.”</i> — a new item only on yes; a no records Always ask. No repair ever makes one.</td></tr>"
         "</tbody></table><p class=\"lede\">Her pick, 2026-10-13: <i>“there should always be a button”</i> reads as always, wherever Touch ID can work.</p>")


CHECKLIST = [
    # (id, element, what proves it)
    ("C-1", "Castle: the library key's only device copy is one Touch ID item per key — none under Always ask; no silent item for any key the library has had", "scenario promise 2 · real-Keychain drill"),
    ("C-2", "Castle: the one key file locks the current key with the passphrase and the twelve words (and the master, synced) — no Apple lock", "model test · the posture drill"),
    ("C-3", "Castle: the history holds every older key, each locked with today's key; an old key opens nothing newer", "model test · scenario promise 8"),
    ("C-4", "Castle: none of the Apple keys this library alone used exists, and none it has retired; one that reappears is deleted on sight — by its recorded id only, never another Mac's key for its own copy, never the account's while the account is in Standard", "scenario promise 2 · iCloud Keychain drill · fixed scenarios (one library on two Macs; This-Mac-Only Castle)"),
    ("C-5", "Castle: every backup carries its day's key file; older backups open through the history with Touch ID, the passphrase or the words", "scenario promise 5 · the restore drill"),
    ("C-6", "Castle, synced: the sync keys live only in a Touch ID item (session memory under Always ask)", "scenario promise 2 · drill"),
    ("C-7", "Castle, synced: the vault holds the master locked with the passphrase and words, the sync key locked with the master — no Apple copy", "fake-server suite · live round"),
    ("C-8", "Synced key files carry the master locked with the twelve words, copied from the vault and refreshed while that master is current", "model test · fixed scenario (a silently-joined device)"),
    ("S-1", "Standard: the library key's device copy is a silent item per key; no Touch ID item", "scenario promise 3 · drill"),
    ("S-2", "Standard: the key file locks the current key with this library's Apple key (named by its id), the passphrase and the words", "model test · drill"),
    ("S-3", "Standard: Apple keys are minted only by a deliberate act or the migration, under fresh ids; an account keeps the one its vault names; other devices wait for it; a device joining an account still on the old shared key uses a key of its own", "convergence suite (the follow race) · fixed scenario (a device joining an old-key account)"),
    ("S-4", "Standard, synced: the vault's Apple copy is under the account's Apple key, named by its id — its own key once made or re-linked by this build; an account from before stays on the old shared key until it enters Castle or is re-linked; nothing moves a vault automatically", "fake-server suite · fixed scenario (an older build's Re-link)"),
    ("S-5", "Re-link mints a fresh account key under the vault's CAS, and Replace All Keys re-links an account still on the old shared key first; nothing this build writes is locked with the old shared key", "executor tests · drill · fixed scenario (Replace All Keys on an old-key account)"),
    ("S-6", "Standard: the history holds every older key, each locked with today's key, as in Castle; older copies open through it", "model test · the restore drill"),
    ("R-1", "The protection record inside the library file states the mode and account; this Mac's memory agrees", "scenario promise 1"),
    ("R-2", "This Mac's memory holds no secret and decides nothing (sealed); the settings that could weaken protection live in the protection record, per device; an edited or replayed memory item changes nothing", "scenario promise 10 · adversary scenarios (edit, replay)"),
    ("R-3", "Plans live beside the library, sealed and named by the record's act in flight, never in a backup; a plan the record doesn't name is ignored and reported; a missing one never blocks", "scenario promises 6, 10 · mutation pins (planted, replayed)"),
    ("R-4", "Before unlock nothing decides: the lobby offers only self-verifying roads — the enumerated custody items and the route finder's — and a missing key file or memory item isn't fatal", "assess tests · the file-swap scenario · fixed scenario (key file and memory deleted)"),
    ("T-1", "Use Castle runs §‘Entering Castle’ in order, prepare-then-commit — the record in the staged copy before the swap, copies paused — and survives a crash at every step", "executor tests · crash scenarios · the posture drill"),
    ("T-2", "Use Standard runs §‘Leaving Castle’ in order; its warning is said; other devices follow without asking", "executor tests · walk"),
    ("T-3", "Replace All Keys and the follow run as drawn; the old key joins the history; the refusal names a change made elsewhere", "executor tests · drills · walk"),
    ("T-4", "Opening an older backup brings it in under today's key and mode, never lowering it, nothing more typed", "fixed scenario VX-209 · restore drill · walk"),
    ("T-5", "A Castle copy from another Mac raises a Standard library to Castle; an unknown-key copy is flagged; a different library keeps its mode and its key (passphrase or words alone open it), gains this Mac's own Apple key in Standard, and the shared key is said at Send Library", "fixed scenarios (Send Library after this change) · walk"),
    ("T-6", "The migration runs as drawn: the fold, then keys of their own beside the old one for everything in Standard, then a fresh backup — removing no road", "migration drills per shape · her stores' byte-copies · scenario promise 12 · fixed scenarios (the window after the move; iCloud Keychain off)"),
    ("T-7", "Retiring the old shared key runs as drawn: the move again, the checks, the sheet listing exactly what would stop opening and every Standard thing with no passphrase or words, a vault still on it stopping the retirement; no keep-for-now; the door only on a library already in Castle before this change, gone once pressed", "fixed scenarios (two libraries on one Apple account; an older build's Re-link) · walk"),
    ("T-8", "A plaintext export lands under today's key and mode when it carries this library's ID, otherwise as a new library in Standard — said in the confirm", "fixed scenario · the restore drill"),
    ("A-1", "The four account situations behave as the table says; signing in or out changes nothing", "account-sequence walk · scenario promise 4"),
    ("A-2", "New writing belongs to the library's account", "state-transition suite"),
    ("A-3", "Leaving an account re-keys a Castle library; joining or moving into an account takes its mode, with the right sentence; the account's Apple key is left to the account", "fixed scenarios (the four leaving acts; This-Mac-Only Castle) · account-sequence walk"),
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
            f'<title>{E(title)}</title><style>{CSS}\n{ANIM_CSS}\n{actor_css()}</style></head>'
            f'<body data-actor="you" data-glyphs="letters">{icon_defs()}{body}<script>{JS}\n{ANIM_JS}</script></body></html>')


def full_page():
    body = f"""<main>
<h1>Castle key map</h1>
<p class="lede">What each key is, where it lives, what it's locked with, and what the server holds — today, and in the
new design (your rulings of 2026-10-13). A companion to <code>second-opinion.html</code>; the build target alone is
<code>castle-target-key-map.html</code>.</p>
<div class="okbox"><b>The whole idea in two lines.</b> In Castle, your Apple account opens nothing of this library —
not the library, not any copy Variorum made of it on this Mac or a device of your account (the stated exceptions
aside: a library already in Castle before this change, until it retires the old shared Apple key; copies from while a
library synced with an account still in Standard; copies under a key shared with another Mac by Send Library). In Standard, it opens your library and every copy Variorum made of
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
<h3 id="watch">Watch it happen</h3>{anim_section()}
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
Variorum made of it. <i>In Castle = safe. Out of Castle = not safe.</i> The stated exceptions — a library already in
Castle before this change, until it retires the old shared Apple key; copies from while a library synced with an
account still in Standard; and copies under a key shared with another Mac by Send Library — are said where they
apply, and below.</div>
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
<h3 id="watch">Watch it happen</h3>{anim_section()}
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
<p class="lede">The stated exceptions, where the Castle column's red rows can still open something: a library already in
Castle before this change, until it retires the old shared Apple key (its copies from before Castle; every Castle
surface says so); copies made while a library synced with an account still in Standard (through that account); and
copies under a key shared with another Mac by Send Library (wherever that Mac's copy opens).</p>
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
