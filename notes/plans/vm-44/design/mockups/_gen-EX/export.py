# VM-44 — export-and-share.html (throwaway generator; static HTML out; no scripts in the output).
# REVISED after sitting 1: Export asks which file; Copy is the on-screen words and says nothing after; a book exports as one Markdown
# file or a PDF in v1; the folder of notes moves to the after-v1 section (VX-1000, Mac and phone). The alternatives she ruled on are gone.
# Stands on the shell-and-finding designer's base (_gen-SH/base.py), which stands on the books designer's base
# and the round-1 sketch generator: one frame, one shell, one set of sheets. Adds only the system surfaces
# (share sheet, Files) and a file card. Draft working record, not canon.
import sys, os
HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.join(HERE, '..', '_gen-SH'))
import base as SHB
from base import *

SHB.CSS += r"""
/* ---- added for export and share (in the sizing sheet's spirit; listed in the build notes) ---- */
.cap .id.alt{background:#8A5A12}
.cap .id.later{background:#6A6359}
.pw{display:inline-block;font:600 11px var(--sans);letter-spacing:.03em;background:#F0E3BF;color:#6B4A0C;border-radius:4px;padding:1px 6px;margin-left:4px;vertical-align:1px}
.laterband{max-width:1500px;margin:60px 0 0;padding:14px 20px;border-radius:14px;background:#EDE7D6;box-shadow:0 0 0 1px #D8CFB4;font:600 17px/1.4 var(--sans);color:#5B4A1C}
.zone.up{z-index:9}
.zone.out span{right:auto;left:-11px;bottom:-11px}
.laterband small{display:block;font:400 15px/1.45 var(--sans);margin-top:2px}

/* the note page's two marks this surface has to show */
.tkm{display:flex;justify-content:flex-end;align-items:center;gap:2px;margin:-2px 0 -4px;font:600 13px/18px var(--sans);color:var(--accent);vertical-align:1px}
.tkm svg{width:15px;height:15px}
.callout{margin:0 -10px 14px;padding:10px 12px 10px 10px;border-radius:12px;background:#F7EFD9;font:400 17px/27px var(--serif);display:flex;gap:8px}
.phone.dk .callout{background:#2A2415}
.callout .gl{flex:none;font:400 17px/27px var(--sans)}
.nchip .stc{margin-left:0;margin-right:6px}
.stc.eye{background:rgba(255,255,255,.6);box-shadow:inset 0 0 0 1px var(--takeline);color:var(--meta)}

/* sheets: a paragraph block, a progress bar, a busy line */
.cf.tight{padding-top:0}
.cf .big{font:600 17px/22px var(--sans);font-variant-numeric:tabular-nums;margin:0 0 6px}
.prog{height:6px;border-radius:3px;background:var(--wash);overflow:hidden;margin:0 20px 10px}
.prog i{display:block;height:100%;background:var(--accent);border-radius:3px}
.busy{display:flex;align-items:center;gap:10px;padding:6px 20px 10px;font:400 17px/22px var(--sans);color:var(--ink)}
.busy:before{content:"";flex:none;width:18px;height:18px;border-radius:50%;border:2px solid var(--takeline);border-top-color:var(--accent)}
.choice b .opn{display:inline-block;margin-top:0}
.choice.busyrow .go{display:none}
.choice.busyrow:after{content:"";flex:none;width:18px;height:18px;border-radius:50%;border:2px solid var(--takeline);border-top-color:var(--accent)}
.shead .st.two{display:-webkit-box;-webkit-line-clamp:3;-webkit-box-orient:vertical;overflow:hidden;padding:10px 0 6px}
.field .pd{letter-spacing:3px;font:400 17px var(--sans)}

/* settings: the lock-and-protection mockup's rows (52 minimum, label 17, detail 13), on the paper under section names on the room */
.sech{padding:22px 20px 8px;font:600 13px/18px var(--sans);color:var(--meta)}
.sech.first{padding-top:6px}
.sgroup{background:var(--surface);border-top:1px solid var(--line);border-bottom:1px solid var(--line)}
.srow{display:flex;align-items:center;gap:12px;min-height:52px;padding:8px 8px 8px 20px;position:relative}
.srow+.srow:before{content:"";position:absolute;left:20px;right:0;top:0;height:1px;background:var(--line)}
.srow .mid{flex:1;min-width:0}
.srow .lab{font:400 17px/22px var(--sans);color:var(--ink)}
.srow .lab.voice{font:600 17px/22px var(--serif)}
.srow .sub{font:400 13px/18px var(--sans);color:var(--meta);margin-top:2px;padding:0}
.srow .val{font:400 15px/20px var(--sans);color:var(--meta);flex:none}
.srow .chv{width:28px;flex:none;text-align:center;color:var(--faint);font:400 22px/1 var(--sans)}
.srow .ck{width:36px;flex:none;color:var(--accent);font:600 17px var(--sans);text-align:center}
.srow.hl{background:var(--taketint)}

/* ---- the system's surfaces, simplified: the share sheet, Files, another app, the home screen ---- */
.share{position:absolute;left:8px;right:8px;bottom:8px;z-index:8;border-radius:34px;background:#F8F8F6;box-shadow:0 0 0 1px rgba(0,0,0,.08),0 -6px 30px rgba(0,0,0,.2);padding:16px 16px 10px;font-family:var(--sans);color:#1c1c1e}
.share .fh{display:flex;gap:12px;align-items:center}
.thumb{flex:none;width:48px;height:60px;border-radius:8px;background:#fff;box-shadow:inset 0 0 0 1px #cfcfcf;display:flex;align-items:center;justify-content:center;font:600 11px/1 ui-monospace,"SF Mono",Menlo,monospace;color:#6A6359}
.thumb.fold{height:44px;border-radius:6px;background:#CFE0F3;box-shadow:none;color:#3D6B8E}
.fnm{font:600 17px/22px var(--sans);display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
.fmt{font:400 13px/18px var(--sans);color:#6A6359}
.share .xb{flex:none;margin-left:auto;width:30px;height:30px;border-radius:15px;background:rgba(127,127,127,.18);display:flex;align-items:center;justify-content:center;color:#6A6359;font:600 13px var(--sans)}
.share .apps{display:flex;gap:16px;padding:16px 2px;border-top:1px solid rgba(127,127,127,.2);border-bottom:1px solid rgba(127,127,127,.2);margin:14px 0 6px}
.share .apps div{width:66px;text-align:center;font:400 12px/16px var(--sans)}
.share .apps i{display:block;width:60px;height:60px;border-radius:14px;background:rgba(127,127,127,.22);margin:0 auto 6px}
.share .apps i.ours{background:#C2DDD3;display:flex;align-items:center;justify-content:center}
.share .sr{height:48px;display:flex;align-items:center;justify-content:space-between;font:400 17px/22px var(--sans);padding:0 6px;border-bottom:1px solid rgba(127,127,127,.14)}
.share .sr:last-child{border:0}
.share .sr svg{color:#3c3c43}
.files{position:absolute;left:0;right:0;top:62px;bottom:0;z-index:8;border-radius:28px 28px 0 0;background:#F2F2F7;box-shadow:0 -6px 30px rgba(0,0,0,.2);display:flex;flex-direction:column;overflow:hidden;font-family:var(--sans);color:#1c1c1e}
.files .fnav{flex:none;height:56px;display:flex;align-items:center;justify-content:space-between;padding:0 8px;font:600 17px var(--sans)}
.files .fnav span{height:44px;min-width:64px;padding:0 12px;display:inline-flex;align-items:center;justify-content:center;font:400 17px var(--sans);color:var(--accent)}
.files .fnav span.s{font-weight:600}
.files .fitem{flex:none;display:flex;gap:12px;align-items:center;margin:4px 16px 14px;padding:12px 14px;border-radius:14px;background:#fff}
.files .fmsg{flex:none;margin:0 16px 12px;font:400 13px/18px var(--sans);color:#6A6359}
.files .flab{flex:none;padding:6px 20px 6px;font:600 13px/18px var(--sans);color:#6A6359}
.files .fgrp{flex:none;margin:0 16px 12px;border-radius:14px;background:#fff;overflow:hidden}
.files .fr{display:flex;align-items:center;gap:12px;min-height:48px;padding:0 14px;font:400 17px/22px var(--sans);border-bottom:1px solid #E5E5EA}
.files .fr:last-child{border:0}
.files .fr.in{padding-left:44px}
.files .fr.on{background:#E3EEE9;font-weight:600}
.files .fr i{flex:none;width:26px;height:20px;border-radius:4px;background:#CFE0F3}
.files .fr i.doc{width:18px;height:22px;border-radius:3px;background:#fff;box-shadow:inset 0 0 0 1px #c8c8c8;margin:0 4px}
.files .fr .v{margin-left:auto;color:#8e8e93;font:400 15px var(--sans)}
.files:after{content:"";position:absolute;left:50%;bottom:8px;width:134px;height:5px;margin-left:-67px;border-radius:3px;background:#1c1c1e}
.doc{width:402px;margin:10px;border-radius:18px;background:#fff;box-shadow:0 0 0 1px #D8D4CA,0 6px 20px rgba(41,36,28,.08);overflow:hidden}
.doc .dh{display:flex;gap:12px;align-items:center;padding:14px 16px;background:#F7F6F2;border-bottom:1px solid #E6E3DB}
.doc pre{margin:0;padding:14px 16px 18px;font:400 13px/20px ui-monospace,"SF Mono",Menlo,monospace;color:#29241C;white-space:pre-wrap;word-break:break-word}
.doc pre mark{border-radius:3px;padding:1px 2px;color:inherit}
.doc pre mark.mh{background:#DDEDE6}
.doc pre mark.ma{background:#EFE7D2}
.doc pre mark.mq{background:#E4EAF4}
.doc pre i{font-style:normal;color:#8B7F6A}
.key{display:inline-block;border-radius:3px;padding:0 5px;font:600 12px/18px var(--sans);color:#29241C}
.key.mh{background:#DDEDE6}.key.ma{background:#EFE7D2}.key.mq{background:#E4EAF4}
.phone.other{background:#fff}
.phone.other .web{flex:1;padding:8px 22px 0;font:400 17px/26px Georgia,serif;color:#222;overflow:hidden}
.phone.other .web h5{font:700 24px/29px Georgia,serif;margin:6px 0 10px}
.phone.other .web .selx{background:#CFE0F3}
.phone.other .url{flex:none;margin:0 16px 6px;height:44px;border-radius:14px;background:#EFEFF2;display:flex;align-items:center;justify-content:center;font:400 15px var(--sans);color:#555}
.xcard{position:absolute;left:16px;right:16px;top:150px;z-index:8;border-radius:22px;background:var(--room);box-shadow:0 18px 50px rgba(0,0,0,.35);overflow:hidden;color:var(--ink);font-family:var(--sans)}
.xcard .xh{display:flex;align-items:center;justify-content:space-between;height:52px;padding:0 6px 0 4px;font:600 17px var(--sans)}
.xcard .xh span{height:44px;min-width:60px;padding:0 12px;display:inline-flex;align-items:center;justify-content:center;font:400 17px var(--sans);color:var(--accent)}
.xcard .xh span.s{font-weight:600}
.xcard .xt{margin:0 14px;padding:12px 14px;min-height:150px;border-radius:12px;background:var(--surface);border:1.5px dashed #8B7F6A;font:400 17px/24px var(--serif)}
.xcard .xt i{font-style:normal;color:var(--meta);font-size:15px;display:block;margin-top:8px}
.xcard .xd{padding:10px 18px 14px;font:400 13px/18px var(--sans);color:var(--meta)}
.phone.sys{background:linear-gradient(160deg,#5b6e68,#2b3a35 55%,#161d1b)}
.phone.sys .sb{color:#fff}
.phone.sys .sb .sig,.phone.sys .sb .wifi{background:#fff}
.phone.sys .sb .bat{border-color:#fff}.phone.sys .sb .bat:after{background:#fff}
.hgrid{display:grid;grid-template-columns:repeat(4,1fr);gap:26px 22px;padding:30px 28px 0}
.hgrid i{display:block;height:64px;border-radius:15px;background:rgba(255,255,255,.3)}
.widget{grid-column:span 2;grid-row:span 2;height:154px;border-radius:24px;background:#E5F0EC;padding:14px;display:flex;flex-direction:column;gap:8px;color:#29241C;font-family:var(--sans)}
.widget .wt{display:flex;align-items:center;gap:8px;font:600 15px/20px var(--serif)}
.widget .wb{flex:1;border-radius:12px;display:flex;align-items:center;justify-content:center;font:600 15px var(--sans)}
.widget .wb.a{background:#3B6A59;color:#fff}
.widget .wb.b{background:#CBE2D9;color:#3B6A59}
.scut{margin:26px 22px 0;border-radius:18px;background:rgba(250,250,250,.94);padding:14px 16px;color:#111;font-family:var(--sans)}
.scut .sl{font:600 13px/18px var(--sans);color:#6A6359}
.scut .sa{display:flex;align-items:center;gap:10px;margin-top:8px;font:400 17px/22px var(--sans)}
.scut .sa b{color:#3B6A59;font-weight:600}
.scut .sa em{font-style:normal;padding:2px 8px;border-radius:7px;background:#E5F0EC;color:#3B6A59}
.appicon{width:34px;height:34px;border-radius:9px;background:#C2DDD3;display:flex;align-items:center;justify-content:center;flex:none}

/* ---- the largest standard text size: the sheet rows this surface adds ---- */
.phone.xl .choice b{font-size:23px;line-height:28px}
.phone.xl .choice span{font-size:20px;line-height:26px}
.phone.xl .shead .st{font-size:27px;line-height:33px}
.phone.xl .shead .hb{font-size:23px}
.phone.xl .ssub,.phone.xl .c13b{font-size:18px;line-height:24px}
.phone.xl .mrow{font-size:23px;line-height:28px;min-height:64px}
.phone.xl .mrow .c13{font-size:18px;line-height:24px}
.phone.xl .cf p{font-size:20px;line-height:27px}
.phone.xl .page p,.phone.xl .callout{font-size:23px;line-height:35px}
.phone.xl .ntitle{font-size:30px;line-height:36px}
.phone.xl .nchip{font-size:18px;line-height:24px}
.phone.dk .field{background:#15261F}
.phone.dk .sheet{box-shadow:0 0 0 1px var(--takeline)}
"""
CSS = SHB.CSS

# ---------- icons, helpers ----------
I_FORK = ic('M7 4v4c0 4 4 3 4 7v3|M15 4v4c0 4-4 3-4 7')
I_EYE = ic('M2 11s3.5-6 9-6 9 6 9 6-3.5 6-9 6-9-6-9-6z', extra='<circle cx="11" cy="11" r="2.6"/>')
I_FOLDER = ic('M3 7V5.5A1.5 1.5 0 014.5 4h4l2 2.5h7A1.5 1.5 0 0119 8v9a1.5 1.5 0 01-1.5 1.5h-13A1.5 1.5 0 013 17V7z')
I_DOC = ic('M6 3h7l4 4v12H6V3z|M13 3v4h4|M9 12h5|M9 15h5')
I_DUP = I_SHARED
PW = '<span class="pw">draft</span>'
OPN = '<span class="opn">open</span>'
def mark(size=34):
    return ('<svg width="%d" height="%d" viewBox="0 0 56 56" fill="#C2DDD3" stroke="#3B6A59" stroke-width="1.8" stroke-linejoin="round">'
            '<rect x="17" y="12" width="22" height="30" rx="4" transform="rotate(-18 28 46)"/>'
            '<rect x="17" y="12" width="22" height="30" rx="4" transform="rotate(18 28 46)"/>'
            '<rect x="17" y="10" width="22" height="30" rx="4"/></svg>') % (size, size)
def optx(frame, oid, title, text, kind='', small=False):
    """kind: '' a step · 'mine' drawn as she ruled it · 'later' after v1"""
    f = '<div class="small">%s</div>' % frame if small else frame
    return '<div class="opt%s">%s<div class="cap"><span class="id %s">%s</span><b>%s</b> %s</div></div>' % (' sm' if small else '', f, kind, oid, title, text)
def ssub(t): return '<div class="ssub">%s</div>' % t
def c13b(t, alarm=False): return '<div class="c13b" style="margin-top:0%s">%s</div>' % (';color:var(--alarm)' if alarm else '', t)
def cf(*ps, tight=True): return '<div class="cf%s">%s</div>' % (' tight' if tight else '', ''.join(ps))
def p(t, w=False): return '<p%s>%s</p>' % (' class="w"' if w else '', t)
def prog(pct): return '<div class="prog"><i style="width:%d%%"></i></div>' % pct
def busy(t): return '<div class="busy">%s</div>' % t
def gap(n=8): return '<div style="height:%dpx"></div>' % n
def sech(t, first=False): return '<div class="sech%s">%s</div>' % (' first' if first else '', t)
def sgroup(*rows): return '<div class="sgroup">%s</div>' % ''.join(rows)
def srow(lab, sub='', val='', chev=False, cls='', check=None, hl=False):
    s = '<div class="sub">%s</div>' % sub if sub else ''
    v = '<span class="val">%s</span>' % val if val else ''
    c = '<span class="chv">›</span>' if chev else ''
    k = '' if check is None else '<span class="ck">%s</span>' % ('✓' if check else '')
    pad = '' if (chev or k) else '<span style="width:12px"></span>'
    return '<div class="srow%s"><div class="mid"><div class="lab %s">%s</div>%s</div>%s%s%s%s</div>' % (' hl' if hl else '', cls, lab, s, v, c, k, pad)
def long_head(title, right='Cancel'):
    r = '<span class="hb">%s</span>' % right if right else ''
    return '<div class="shead" style="align-items:flex-start"><span class="st two">%s</span>%s</div>' % (title, r)

# ---------- the draft-words registry (wording-list-2.md): every designer's line on this surface, by frame ----------
DRAFTS = []
def dw(frame_id, line, what):
    DRAFTS.append((frame_id, line, what)); return line

# ---------- the note ----------
TITLE = "On keeping a commonplace book"
B1 = "I started copying sentences into a notebook the winter I stopped trusting my memory for them."
B1W = "That winter I began copying other people’s sentences into a little notebook, and it felt like keeping company."
B1S = "I copy sentences into a notebook because my memory stopped keeping them."
CALL = "It was not a diary. A diary asks what happened; a commonplace book asks what was worth keeping."
B3 = "Copying other people’s sentences is slower than underlining them, and the slowness is the use of it."
B4 = "Most of what I copied that first winter I no longer agree with. That is the second use of it."
TK = '<span class="tkm">%s3</span>' % I_FORK
def page(title=TITLE, chipline='<b>Essays</b> · in Home · #essay #goals', body=None):
    body = body if body is not None else ('<p>%s%s</p><div class="callout"><span class="gl">💡</span><span>%s</span></div><p>%s</p><p>%s</p>' % (B1, TK, CALL, B3, B4))
    return '<div class="page"><div class="ntitle">%s</div><div class="nchip">%s</div>%s</div>' % (title, chipline, body)
def note(*over, below='', cls='', **kw):
    return P(nav(cb(I_SEARCH) + MORE), page(**kw), below, hi(), *over, cls=cls)

COPYROW = mrow(dw("2", "Copy text", "Row in the note’s menu."), I_COPY, cap=dw("2", "The words on screen.", "One line under Copy text."))
EXPROW = mrow("Export note…", I_EXPORT, cap=dw("2", "A file, to save or send.", "One line under Export note…."))
G_PLACE = grp(mrow("Add to a book…", I_BOOK), mrow("Move to wing…", I_WING), mrow("Copy to wing…", I_WING))
G_DUP = grp(mrow("Duplicate with tags", I_DUP), mrow("Duplicate without tags", I_DUP), mrow("Archive", I_ARCH))
G_DATE = grp(mrow("Date", I_CAL, v="Jul 25 " + CHEV), mrow("Shift date a day earlier", I_UP)) + grp(mrow("Delete note…", I_TRASH, cls='danger'))
FACTS = "1,204 words · 4 blocks · edited today at 9:12 AM"
def notemenu(out, top=66, head=G_PLACE, tail=G_DATE):
    return sheet(top, shead("Note", "Done") + ssub(FACTS) + head + G_DUP + out + tail)

n_rest = note(zone2(54, 54, 334, 6, "1", 'out'))
n_menu = note(notemenu(grp(COPYROW, EXPROW)), zone2(488, 124, 8, 8, "2", 'up'))

X_TEXT = choice(dw("3", "Just the text", "Export choice: the plain file."), dw("3", "The note as it reads now.", "One line under “Just the text”."))
X_FULL = choice(dw("3", "With takes and tags", "Export choice: the full Variorum document."), dw("3", "Every take, the title and the tags.", "One line under “With takes and tags”."))
X_NOTE = c13b(dw("3", "Both are Markdown. Comments and commits stay in Variorum.", "The one line under the two export choices."))
def xsheet(*rows, top=None, of=TITLE):
    return sheet(top, shead(dw("3", "Export note", "Title of the which-file sheet."), right="Cancel", strong=False), ssub("“%s”" % of), *rows)
n_choose = note(xsheet(X_TEXT, X_FULL, X_NOTE))
n_busy = note(xsheet(X_TEXT, choice("With takes and tags", dw("6", "Getting the file ready…", "Shown on the tapped choice while a long note’s file is made.")).replace('class="choice"', 'class="choice busyrow"'), X_NOTE, of="Field notes, 2019–2025"),
              title="Field notes, 2019–2025", chipline='No book · in Research · #fieldwork',
              body='<p>March. The first season on the estuary, and the notebooks are already damp.</p><p>The plan was simple: walk the same four transects every week and write down what was there.</p>'
                   '<p>What was there, mostly, was mud, and a great many things that live in mud.</p>')

def share(name, meta, ext='.md'):
    return (SCRIM + '<div class="share"><div class="fh"><span class="thumb">%s</span><div style="min-width:0"><div class="fnm">%s</div><div class="fmt">%s</div></div><span class="xb">✕</span></div>'
            '<div class="apps"><div><i></i>AirDrop</div><div><i></i>Messages</div><div><i></i>Mail</div><div><i></i>Notes</div></div>'
            '<div class="sr">Copy%s</div><div class="sr">Save to Files%s</div></div>') % (ext, name, meta, sm(I_COPY, 22), sm(I_FOLDER, 22))
n_share = note(share(TITLE + ".md", "Markdown document · 2 KB"))

def files(title, right, item='', msg='', rows=(), label='On My iPhone'):
    it = item
    m = '<div class="fmsg">%s</div>' % msg if msg else ''
    rr = ''.join(rows)
    return (SCRIM + '<div class="files"><div class="fnav"><span>Cancel</span>%s<span class="s">%s</span></div>%s%s<div class="flab">%s</div><div class="fgrp">%s</div>'
            '<div class="flab">Other places</div><div class="fgrp"><div class="fr"><i></i>iCloud Drive<span class="v">›</span></div></div></div>') % (title, right, it, m, label, rr)
def fitem(name, meta, ext='.md', fold=False):
    return '<div class="fitem"><span class="thumb%s">%s</span><div style="min-width:0"><div class="fnm">%s</div><div class="fmt">%s</div></div></div>' % (' fold' if fold else '', ext, name, meta)
def fr(name, on=False, ind=False, doc=False, v=''):
    return '<div class="fr%s%s"><i%s></i>%s%s</div>' % (' on' if on else '', ' in' if ind else '', ' class="doc"' if doc else '', name, '<span class="v">%s</span>' % v if v else '')
FOLDERS = [fr("Downloads", v="›"), fr("Exports", on=True, v="✓"), fr("Scans", v="›")]
n_files = note(files("Save to Files", "Save", fitem(TITLE + ".md", "Markdown document · 2 KB"), rows=FOLDERS))

def doc(name, meta, body, ext='.md'):
    return '<div class="doc"><div class="dh"><span class="thumb' + ('' if ext else ' fold') + '">%s</span><div style="min-width:0"><div class="fnm">%s</div><div class="fmt">%s</div></div></div><pre>%s</pre></div>' % (ext, name, meta, body)
D_TEXT = doc(TITLE + ".md", "Just the text · 1 KB",
             "%s\n\n<mark class=\"mq\">&gt; 💡 %s</mark>\n\n%s\n\n%s" % (B1, CALL, B3, B4))
D_FULL = doc(TITLE + ".md", "With takes and tags · 2 KB",
             "<mark class=\"mh\">{t:\"%s\"} {#essay} {#goals}</mark>\n\n%s\n\n<mark class=\"ma\">--- Alternates for this block ---\n\ntake: \"warmer\"\n\n%s\n\ntake: 2\n\n%s\n\n--- end alternates ---</mark>\n\n"
             "<mark class=\"mq\">&gt; 💡 %s</mark>\n\n%s\n\n%s" % (TITLE, B1, B1W, B1S, CALL, B3, B4))

EMPTYBODY = '<p style="color:var(--meta)">No text yet</p>'
n_empty = note(title="Untitled", chipline='No book · in Home · today', body=EMPTYBODY,
               below=rcpt("Nothing to export — this note has no text yet.", refusal=True, x=True))
SEALCHIP = ('<span class="stc">%sSealed</span><span class="stc eye">%sPrivate</span><b>Letters</b> · in Home'
            % (sm(I_LOCK, 13), sm(I_EYE, 13)))
n_sealed = note(sheet(None, shead("Note", "Done") + ssub("312 words · 3 blocks · sealed Oct 2")
                      + grp(mrow("Unseal", I_LOCK, cap=dw("9", "Sealed notes can’t be edited.", "One line under Unseal (the same line as note-write E7).")),
                            mrow(dw("9", "Private", "Read-only row on a note marked Private on a Mac (the same as note-write E7)."), I_EYE, cap=dw("9", "Not shared with AI. Set on your Mac.", "One line under the Private row."), cls='off'))
                      + grp(COPYROW, EXPROW) + grp(mrow("Versions", I_LIST, v="1 " + CHEV))),
                title="To my sister, on the house", chipline=SEALCHIP,
                body='<p>I have been meaning to write this since March, and the house has been sold since April.</p><p>You will say it does not matter now. It matters to me that I said it.</p>')

s1 = [
    optx(n_rest, "1", "A note with a fan and a callout.",
         "“On keeping a commonplace book”, in Essays. The first block has three takes (the badge at its end); the second is a callout. "
         "These two are what a copy or a file has to decide about. <span class=\"n1\">1</span> She taps ⋯."),
    optx(n_menu, "2 · NT-3", "Copy and Export, one line each.",
         "<span class=\"n1\">2</span> Two rows, side by side in the note’s menu, each with one line saying what it is for. "
         "<b>Copy text</b> puts what she sees on the clipboard: the take on screen for each block, no title, no tags (her rule: “copy should follow what’s on the screen”). The menu closes and nothing is said: a copy is an ordinary act. "
         "<b>Export note…</b> makes a file. The same two rows sit in a note row’s menu in the Library and in a book. " + PW, 'mine'),
    optx(n_choose, "3 · NT-3", "She taps Export note….",
         "Her ruling: “Yes, ask which file.” A short sheet. <b>Just the text</b> is what she would hand to someone else. <b>With takes and tags</b> is the Variorum document, the one that goes back in whole. "
         "One line under them says both are Markdown and what stays behind. " + PW, 'mine'),
    optx(D_TEXT, "4a", "What “Just the text” holds.",
         "The note as it reads now. The fanned block gives the take on screen only. <span class=\"key mq\">The callout</span> becomes a Markdown quote, led by its emoji. "
         "No title line and no tags; the file’s name carries the title. This is the Mac’s plain export (<code>Queries.exportPost</code>), byte for byte."),
    optx(D_FULL, "4b", "What “With takes and tags” holds.",
         "<span class=\"key mh\">The first line</span> is the title and the tags. The fanned block keeps the take on screen in place, and <span class=\"key ma\">its other takes</span> follow it, each under its label "
         "(an unnamed take gets a number). <span class=\"key mq\">The callout</span> is a quote here too. Comments, commits and archived takes do not travel. "
         "This is exactly the Mac’s Export Note… and Copy full text (<code>Queries.variorumDocumentText</code>)."),
    optx(n_share, "5", "She picks one. The share sheet.",
         "The system’s own sheet with the file, named for the note. AirDrop, Messages, Mail, Copy, Save to Files: nothing here is drawn by the app. Closing the sheet says nothing more."),
    optx(n_files, "5a", "Save to Files.",
         "The system’s Files screen. She picks a folder and taps Save, and is back on her note. The app adds no line of its own; Files has already shown where it went."),
    optx(n_busy, "6", "A very long note.",
         "The longest seeded note is about 40,000 words. The row she tapped shows it is working; the share sheet follows when the file is ready. Cancel stops it. " + PW, small=True),
    optx(n_empty, "7", "An empty note.",
         "The Mac’s sentence, as a refusal that stays until dismissed. Copy text on an empty note says “This note has no text to copy.” (the phone’s line today).", small=True),
    optx(n_sealed, "8", "A sealed note, a Private note.",
         "Both rows work as usual. A seal stops edits, not reading (the Mac: “archived and sealed notes export like any other”). Private keeps a note from AI on the Mac; it does not stop her own copy or file. "
         "The Private chip and row show only because this note carries the mark and the library’s AI-marks switch is on (her ruling); they are read here, not changed. An exported file carries no seal and no Private mark. " + PW),
]

# ---------------------------------------------------------------- 2 · a book
BLOG = [sec("Published", "2"), nrow("Five apps I deleted this year", "Aug 9", "None of them were bad. All of them wanted me back."),
        nrow("A year of daily notes", "Aug 18", "Three hundred and forty entries, eleven of them worth rereading."),
        sec("In progress", "3"), nrow("Draft: on phones and attention", "Tue", "I want a phone that is boring in the best way.", pin=True),
        nrow("The tyranny of the blank page", "Oct 30", "The blank page is not empty. It is full of everything you have not decided yet."),
        nrow("Notes toward a post about ferries", "Oct 12", "The timetable is the only literature the harbour publishes."),
        sec("Someday", "2"), nrow("Why I stopped tracking my reading", "Sep 2", "The list had become the point."),
        nrow("A letter to the person who took my seat", "Aug 30", "You were right about the view.")]
def book(*over, cls='', name="Blog drafts", meta="8 notes · 3 chapters · #blog", rows=BLOG):
    return P(bookhead(name, meta, TRAY0 + READ + MORE), lst(*rows), foot("New note in this book…"), hi(), *over, cls=cls)
BOOKMENU = (shead("Blog drafts", "Done") + ssub("8 notes · on Writing, in Home")
            + grp(mrow("New chapter…", I_LIST), mrow("Duplicate book…", I_SHARED), mrow("Move to shelf", I_SHELF, v="Writing " + CHEV), mrow("Move to wing", I_WING, v="Home " + CHEV))
            + grp(mrow(dw("9", "Export book…", "Row in the book’s menu."), I_EXPORT, cap=dw("9", "A file, to save or send.", "One line under Export book….")))
            + grp(mrow("Finish", I_CHECK), mrow("Seal…", I_LOCK), mrow("Own its notes…", I_BOOK))
            + grp(mrow("Archive", I_ARCH), mrow("Delete book…", I_TRASH, cls='danger')))
b_menu = book(sheet(None, BOOKMENU), zone2(480, 70, 8, 8, "1", 'up'))
B_ONE = choice(dw("10", "One Markdown file", "Book export choice."), dw("10", "The book as it reads. Chapters become headings.", "One line under “One Markdown file”."))
B_PDF = choice("PDF", dw("10", "The same, as pages.", "One line under PDF."))
L_FOLD = "A folder of notes"
L_FOLDSUB = "Each note in its own file, with its takes and tags. Chapters become folders."
B_FOLD = choice(dw("after v1 · VX-1000", L_FOLD, "Book export choice, after v1 (Mac and phone)."), dw("after v1 · VX-1000", L_FOLDSUB, "One line under “A folder of notes”."))
def bsheet(*rows): return sheet(None, shead(dw("10", "Export book", "Title of the book’s which-file sheet."), right="Cancel", strong=False), ssub("“Blog drafts” · 8 notes in 3 chapters"), *rows)
b_two = book(bsheet(B_ONE, B_PDF))
b_three = book(bsheet(B_ONE, B_PDF, B_FOLD))
b_busy = book(sheet(None, shead("Export book", right="Cancel", strong=False), ssub("“The Prince” · 28 notes"), busy(dw("12", "Getting 28 notes ready…", "Shown while a big book’s file is made.")), cf(p('<span class="big">12 of 28</span>')), prog(43), gap(10)),
              name="The Prince", meta="28 notes · sample book",
              rows=[nrow("Dedication", "Oct 1", "To the Magnificent Lorenzo di Piero de’ Medici."), nrow("I — How many kinds of principalities there are", "Oct 1", "All states, all powers, that have held and hold rule over men have been and are either republics or principalities."),
                    nrow("II — Concerning hereditary principalities", "Oct 1", "I will leave out all discussion on republics, inasmuch as in another place I have written of them at length."),
                    nrow("III — Concerning mixed principalities", "Oct 1", "But the difficulties occur in a new principality.")])
b_files = book(files("Save to Files", "Save", fitem("Blog drafts", "Folder · 8 files in 3 folders", ext='', fold=True), rows=FOLDERS))
D_TREE = doc("Blog drafts", "Folder · 8 files in 3 folders",
             "Blog drafts/\n  <mark class=\"ma\">Published/</mark>\n    Five apps I deleted this year.md\n    A year of daily notes.md\n  <mark class=\"ma\">In progress/</mark>\n    Draft- on phones and attention.md\n"
             "    The tyranny of the blank page.md\n    Notes toward a post about ferries.md\n  <mark class=\"ma\">Someday/</mark>\n    Why I stopped tracking my reading.md\n    A letter to the person who took my seat.md\n"
             "  what if the essay is actually a letter.md\n\n<i>Each file is the “with takes and tags” document.\nA note in no chapter sits at the top level.</i>", ext='')
D_ONE = doc("Blog drafts.md", "One Markdown file · 14 KB",
            "<mark class=\"mh\"># Blog drafts</mark>\n\n<mark class=\"ma\">## Published</mark>\n\n### Five apps I deleted this year\n\nNone of them were bad. All of them wanted me back.\n\n<i>…</i>\n\n"
            "### A year of daily notes\n\nThree hundred and forty entries, eleven of them worth rereading.\n\n<i>…</i>\n\n<mark class=\"ma\">## In progress</mark>\n\n### Draft: on phones and attention\n\nI want a phone that is boring in the best way.\n\n<i>…</i>")
b_empty = P(bookhead("Receipts", "No notes yet", TRAY0 + READ + MORE), lst('<div class="empty">No notes in this book yet.</div>'),
            rcpt(dw("13", "Nothing to export — this book has no notes yet.", "Refusal when an empty book is exported (after the Mac’s line for a note)."), refusal=True, x=True), foot("New note in this book…"), hi())
s2 = [
    optx(b_menu, "9", "Where the door lives.",
         "The book’s menu: ⋯ on the book’s bar, or press and hold the book’s row anywhere. The menu is the books mockup’s one table, here scrolled past Unstar, Rename and Book settings. "
         "<span class=\"n1\">1</span> <b>Export book…</b> gets its own group, between where the book lives and its three state doors. A gathering has the same row. " + PW, 'mine'),
    optx(b_two, "10", "She taps Export book….",
         "Two files in v1, the Mac’s two (its menu says Export Markdown… and Export PDF…): the book as one document, one take per block, as Markdown or as pages. "
         "A folder of notes is after v1, on the Mac and the phone together (VX-1000; section 5). " + PW, 'mine'),
    optx(D_ONE, "11", "What “One Markdown file” holds.",
         "<span class=\"key mh\">The book’s name</span>, then <span class=\"key ma\">each chapter as a heading</span> with its notes under it, in the book’s order; notes in no chapter come last under “unfiled”. "
         "Bodies are the plain text (callouts as quotes). The PDF is this same text, set as pages. Core <code>Queries.exportReading</code>."),
    optx(b_busy, "12", "A big book.",
         "The sample book has 28 notes. The sheet stays and counts while the file is made; the share sheet follows (frame 5). Cancel stops it and nothing is left behind. " + PW),
    optx(b_empty, "13", "An empty book.",
         "Export book… on a book with no notes: one sentence, after the Mac’s for a note. " + PW, small=True),
]

# ---------------------------------------------------------------- 3 · the whole library
def shelfbehind(): return ''.join([wmast("Home"), dots(0), chips(HOME_CHIPS, 2, fade=True), lst(*WRITING, NEWBOOK), qe(), tabs_words(1), hi()])
def P2(*over, cls=''): return P(shelfbehind(), *over, cls=cls)
SETROWS = (sech("Writing", first=True) + sgroup(srow("Writing", sub="New blocks, commits, the formatting bar", chev=True))
           + sech("Tags") + sgroup(srow("Manage tags", chev=True))
           + sech(dw("14", "Export", "Settings group name.")) + sgroup(srow(dw("14", "Export every note…", "Settings row: the whole library as Markdown files."), sub=dw("14", "A folder of Markdown files.", "One line under Export every note…."), chev=True, hl=False),
                                     srow("Export an unencrypted copy…", sub=dw("14", "The whole library in one file.", "One line under Export an unencrypted copy…."), chev=True))
           + sech("Help") + sgroup(srow("Take the tour", chev=True), srow("Open the pocket guide", chev=True), srow("What’s new", chev=True)))
l_set = P2(sheet(62, shead("Settings", "Done"), SETROWS), zone2(338, 160, 4, 4, "1", 'up'))

MD_BODY = cf(p(dw("15", "All 149 notes, from all 9 wings, as Markdown files. Takes, tags and archived notes come too.", "What Export every note… will write.")),
             p(dw("15", "The files are not encrypted. Anyone who has them can read them.", "The one plain warning before the library exports.")),
             p(dw("15", "A big library takes a little while. Keep Variorum open.", "Before a long export starts.")))
T_EVERY = dw("15", "Export every note", "Title of the library export sheet.")
B_WHERE = "Choose where…"
l_md = P2(sheet(None, shead(T_EVERY, right="Cancel", strong=False), MD_BODY, btn(B_WHERE), gap(2)))
PICK = [fr("Downloads", v="›"), fr("Exports", on=True, v="✓"), fr("Scans", v="›")]
PICKMSG = dw("16", "Choose a folder. Variorum writes the copy into it.", "The line on the system’s folder picker.")
l_pick = P2(files("On My iPhone", "Open", msg=PICKMSG, rows=PICK))
l_mdgo = P2(sheet(None, shead(T_EVERY, right="", strong=False), busy(dw("17", "Writing your notes…", "Shown while the library’s files are written.")), cf(p('<span class="big">62 of 149</span>')), prog(42),
                  cf(p(dw("17", "Keep Variorum open until it’s done.", "Under the count while files are written."))), gap(6)))
l_mddone = P2(sheet(None, shead(T_EVERY, right="", strong=False), cf(p("Exported 149 files."), p('<span style="color:var(--meta)">%s</span>' % dw("18", "In On My iPhone ▸ Exports ▸ Variorum export.", "Where the exported folder is, said in the sheet when it is done."))), btn("Done"), gap(2)))
D_LIB = doc("Variorum export", "Folder · 149 files", "Variorum export/\n  2026-11-12 Walk note- the ferry timetable changes in December.md\n  2026-11-12 On keeping a commonplace book.md\n  2026-11-12.md\n  2026-11-11 The case for slow mornings.md\n  <i>… one file for every note, in every wing</i>\n"
            "  <mark class=\"ma\">Archived/</mark>\n    2026-10-18 Letters I never sent.md\n  <mark class=\"ma\">Pools/</mark>\n    Snippets.md\n  <mark class=\"ma\">Readings/</mark>\n    Essays.md\n    Journal.md\n    <i>… each book as one file</i>", ext='')

UN_TITLE = "Export an unencrypted copy of your library."
UN_BODY = ("This writes your whole library as a plain, unencrypted database file, readable by anyone who has it, anywhere you put it. "
           "Variorum never does this on its own. Choose where it goes and treat it like the writing itself.")
UN_FOR = dw("19", "It’s a copy you can open without Variorum.", "One added line of purpose under the Mac’s three sentences.")
def unsheet(*rows, right="Cancel", cls=''): return sheet(None, long_head(UN_TITLE, right), *rows, cls=cls)
l_un = P2(unsheet(cf(p(UN_BODY), p(UN_FOR)), '<div class="glab" style="padding-top:2px">Enter your passphrase.</div>',
                  field('<span class="pd">••••••••••••</span>', focus=True), btn(B_WHERE), kb('return'), cls='kbd'))
l_unbad = P2(unsheet(cf(p(UN_BODY)), '<div class="glab" style="padding-top:2px">Enter your passphrase.</div>',
                     field('<span class="pd">•••••••</span>', focus=True), c13b("That passphrase doesn’t unlock this library.", alarm=True), btn(B_WHERE), kb('return'), cls='kbd'))
l_unplain = P2(unsheet(cf(p(UN_BODY), p(UN_FOR)), btn("Export"), gap(2)))
l_ungo = P2(unsheet(busy("Writing the unencrypted copy…"), cf(p(dw("22", "A big library takes a little while. Keep Variorum open until it’s done.", "Under the busy line while the unencrypted copy is written."))), gap(6), right=""))
l_undone = P2(unsheet(cf(p("Written: On My iPhone ▸ Exports ▸ Variorum-unencrypted.sqlite")), btn("Done"), gap(2), right=""))
l_unfail = P2(unsheet(cf(p(dw("24", "The copy wasn’t finished. Nothing was saved.", "Failure line when the unencrypted copy could not be written."), w=True),
                         p(dw("24", "Keep Variorum open while it writes, and check your iPhone has room.", "What to do after a failed copy."))),
                      btn(dw("24", "Try again", "Button after a failed copy.")), btn("Close", 'quiet'), gap(2), right=""))
l_mdnone = P2(sheet(None, shead(T_EVERY, right="Cancel", strong=False), cf(p(dw("25", "Nothing to export — this library has no notes yet.", "Refusal when an empty library is exported."), w=True)), btn("Close", 'quiet'), gap(2)))
s3 = [
    optx(l_set, "14", "Settings, scrolled.",
         "⋯ ▸ Settings on any root screen (the lock-and-protection mockup’s list). <span class=\"n1\">1</span> A group, <b>Export</b>, with the two ways the whole library leaves: "
         "every note as a Markdown file, and the unencrypted copy (VM-30). One line under each says what you get. " + PW, 'mine'),
    optx(l_md, "15", "Export every note….",
         "The Mac’s Export Library…, which on the Mac goes straight to a folder panel. Here a short sheet first: how much, that archived notes come too, the one plain line that the files are not encrypted, and that it can take a while. "
         "The count names all nine wings because the export is the whole library, not the wing she is in. " + PW),
    optx(l_pick, "16", "Choose where.",
         "The system’s folder picker. She chooses the place first and the app writes straight into it, as the Mac does, so no plain copy is ever left sitting inside the app. " + PW, small=True),
    optx(l_mdgo, "17", "Writing, with a count.",
         "The sheet stays up and counts files. It cannot be swiped away while it writes. " + PW),
    optx(l_mddone, "18", "Done.",
         "The Mac’s sentence, then where the folder is. This is said in the sheet she is already looking at, not as a passing line. " + PW, small=True),
    optx(D_LIB, "18a", "What the folder holds.",
         "The Mac’s layout, unchanged: one file per note named by date and title, each the “with takes and tags” document; <span class=\"key ma\">Archived</span>, "
         "<span class=\"key ma\">Pools</span> (the snippets) and <span class=\"key ma\">Readings</span> (each book as one file). Nine wings land in one folder; the Mac has no wing folders either."),
    optx(l_un, "19 · VM-30", "Export an unencrypted copy…, in Castle.",
         "The Mac’s title and its three sentences, unchanged: they say once, plainly, that the file is unencrypted and readable by anyone who has it. One added line says what it is for. "
         "In Castle, and in Standard when a passphrase is set, she types the passphrase. Face ID alone never opens this door (the shared rule). Then “Choose where…”, the Mac’s button. " + PW, 'mine'),
    optx(l_unbad, "20", "A wrong passphrase.", "The Mac’s sentence, under the field. The sheet stays; nothing was written.", small=True),
    optx(l_unplain, "21", "In Standard, with no passphrase set.", "No field. The Mac’s plain button, “Export”, then the folder picker (frame 16).", small=True),
    optx(l_ungo, "22", "Writing.",
         "The Mac’s line. This one is a single file, so there is no honest count to show: a spinner, and the same line about keeping the app open. No Cancel and no swipe-away while it writes. " + PW),
    optx(l_undone, "23", "Done: where it landed.",
         "The Mac’s “Written:” and the place, with the Mac’s file name. The file opens in any SQLite reader, and on a Mac through File ▸ Open Library… as a new library."),
    optx(l_unfail, "24", "It could not finish.",
         "She left the app mid-way, or the phone ran out of room. The half-made file is removed and the sheet says so, with what to do. Never the system’s raw error. " + PW),
    optx(l_mdnone, "25", "Nothing to export.", "A library with no notes. The Mac says “Exported 0 files.” and treats it as a refusal; this says why instead. " + PW, small=True),
]

# ---------------------------------------------------------------- 4 · the largest text, dark
x_xl = note(xsheet(X_TEXT, X_FULL, X_NOTE), cls='xl')
x_dk = note(xsheet(X_TEXT, X_FULL, X_NOTE), cls='dk')
x_dkmenu = note(notemenu(grp(COPYROW, EXPROW)), cls='dk')
x_dkun = P2(unsheet(cf(p(UN_BODY), p(UN_FOR)), '<div class="glab" style="padding-top:2px">Enter your passphrase.</div>',
                    field('<span class="pd">••••••••••••</span>', focus=True), btn(B_WHERE), kb('return'), cls='kbd'), cls='dk')
x_dkbook = book(bsheet(B_ONE, B_PDF), cls='dk')
s4 = [
    optx(x_xl, "26", "The export choice at the largest text size.",
         "The densest sheet here. Titles are 23 pt, their lines 20 pt and wrap as they need; each choice is still one full-width target and the sheet grows upward."),
    optx(x_dk, "27", "The export choice, dark.", ""),
    optx(x_dkmenu, "28", "The note’s menu, dark.", "", small=True),
    optx(x_dkun, "29", "The unencrypted copy, dark.", ""),
    optx(x_dkbook, "30", "The book’s export choice, dark.", "", small=True),
]

# ---------------------------------------------------------------- 5 · after v1 (concepts)
IMPMSG = "Pick a document, or a folder — a folder becomes a book, its folders its chapters."
i_pick = P2(files("On My iPhone", "Open", msg=IMPMSG,
                  rows=[fr("Downloads", v="›"), fr("o ladrão de raios", on=True, v="✓"), fr("1 o semideus", ind=True), fr("2 a excursão", ind=True), fr("notes from the train.md", doc=True)]))
UNSH = [brow("o ladrão de raios", "4 notes · 2 chapters"), brow("Holidays", "2 notes"), brow("Kids’ sayings", "4 notes"), '<div class="addrow">+ New book</div>']
i_done = P(wmast("Home"), dots(0), chips(HOME_CHIPS, 1, fade=True), lst(*UNSH), qe(), tabs_words(1), hi())
c_share = ('<div class="phone other">' + B.SB + '<div class="url">theatlantic.example</div><div class="web"><h5>The harbour that keeps its own time</h5>'
           '<p>For forty years the ferry has left at seven forty, whatever the timetable says.</p>'
           '<p><span class="selx">“The sea doesn’t keep appointments,” the kiosk man told me, “so we keep them for it.”</span></p><p>He has sold tickets here since 1986 and has never once been late.</p></div>'
           + hi() + SCRIM +
           '<div class="xcard"><div class="xh"><span>Cancel</span>%s<span class="s">File</span></div>'
           '<div class="xt">“The sea doesn’t keep appointments,” the kiosk man told me, “so we keep them for it.”<i>theatlantic.example</i></div>'
           '<div class="xd">%s</div></div></div>') % (dw("after v1 · SC-2", "Add to Variorum", "Title of the share card from another app (concept)."), dw("after v1 · SC-2", "A new note in Home.", "Where a shared text will land (concept)."))
c_widget = ('<div class="phone sys">' + B.SB + '<div class="hgrid"><div class="widget"><div class="wt">%s Variorum</div><div class="wb a">%s</div><div class="wb b">✎ Today</div></div>'
            '<i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i></div>'
            '<div class="scut"><div class="sl">Shortcuts · an action</div><div class="sa">%s<span><b>Add</b> <em>Text</em> <b>to Variorum</b></span></div></div>'
            '</div>') % (mark(26), dw("after v1 · SC-2", "New note", "Widget button (concept)."), '<span class="appicon">%s</span>' % mark(26))
dw("after v1 · SC-5", "Import…", "The Bookcase menu row that opens the file picker (concept; named in the caption, not drawn).")
s5 = [
    optx(b_three, "after v1 · VX-1000", "A book as a folder of notes: the third choice.",
         "Her ruling: “this should be a thing after v1 … so that it’s not just a mobile ticket - this is a good improvement for mac.” The same sheet as frame 10 with one more row. "
         "It is the only way a book’s takes leave as files, and the shape the Mac’s Import reads back as a book. Built on the Mac and the phone together. " + PW, 'later'),
    optx(D_TREE, "after v1 · VX-1000", "What “A folder of notes” holds.",
         "<span class=\"key ma\">A folder for each chapter</span>, a file for each note, each the “with takes and tags” document. An empty chapter still gets its folder. Characters a file name cannot hold are swapped, as the Mac’s export does. "
         "<b>To settle in VX-1000:</b> Import orders by file name, so keeping the book’s order needs numbers in front of the names, and those numbers would then show in the names on the way back in.", 'later'),
    optx(b_files, "after v1 · VX-1000", "The folder goes to Files.",
         "A folder is saved through Files (or AirDrop); most other share targets cannot take one.", 'later', small=True),
    optx(i_pick, "after v1 · SC-5", "Import: pick a file or a folder.",
         "From ⋯ ▸ Import… on the Bookcase. The system’s picker with the Mac’s sentence. A file becomes a note in the Pool of the wing she is in; a folder becomes a book, its folders its chapters. "
         "<b>Open questions:</b> also offer “Open in Variorum” from the Files app and from a share sheet? Does a file land in the Pool or ask for a book? What does a refusal that names a file and a line look like on a phone?", 'later'),
    optx(i_done, "after v1 · SC-5", "It landed.",
         "The book is on the Bookcase, unshelved, as on the Mac. Nothing is said: the book appearing is the answer. The import is one undo entry, as on the Mac. "
         "<b>Open question:</b> how big a folder is allowed before the phone asks her to do it on the Mac? MobileSoul says no bulk import; a book is not bulk, a whole library is.", 'later'),
    optx(c_share, "after v1 · SC-2", "From another app: Add to Variorum.",
         "She selects a sentence in a browser and shares it. A small card: the words, where they came from, File. "
         "<b>Open questions:</b> the library is encrypted and may be locked, and a share card cannot unlock it. So does the text wait outside the library until Variorum is next opened, and is that wait acceptable in Castle? "
         "Which wing: always Home, or the last one used? Does a link come in as text, or as a reference on the note?", 'later'),
    optx(c_widget, "after v1 · SC-2", "A widget and a Shortcut.",
         "Two buttons on the home screen: New note opens the capture box with the keyboard up; Today opens today’s journal entry. Both only open the app, so the lock still stands in front. "
         "The Shortcuts action files text without opening the app, and so has the share card’s question. "
         "<b>Open questions:</b> is opening the app enough for v1.x, leaving the silent action for later? Does the widget show any of her words (it would, on a locked phone)?", 'later'),
]

INTRO = """
<p class="lede"><b>VM-44 mockups, revised after sitting 1 — export, share and copy.</b> Today the phone has one way out: Copy, which puts the note’s text on the clipboard. There is no share sheet anywhere in the app, no file export for a note,
a book or the library, and no way to make the plain copy the Mac offers. Nothing comes in but typing.</p>
<p class="q">“I think we need to word things more simply”</p>
<div class="pick" style="max-width:1100px"><p><b>What she chose.</b> Copy is the words on screen. Export asks which file: just the text, or with takes and tags (“Yes, ask which file”). A book exports as one Markdown file or a PDF in v1;
a book as a folder of notes comes after v1, on the Mac and the phone (VX-1000). No message after an ordinary act, so a copy says nothing. No longer drawn: a third “Copy with takes” row, a “Copied.” line, and the folder as a v1 choice.</p></div>
<p class="lede">On a phone the share sheet is the export grammar (MobileSoul §5.7), so every door here ends in the system’s own sheet or its Files screen; the app draws only the question before it.
No export writes anything to the library. Words are the Mac’s wherever the Mac has a face for the same thing (<code>NoteExport</code>, <code>ProtectionCopy.exportPlaintext…</code>, <code>ExportModel</code>, <code>DocumentImportCopy</code>);
every frame holding a designer’s line wears the <span class="pw">draft</span> tag in its caption, and the lines are listed at the end and in <code>design/wording-list-2.md</code>. A finished export says nothing unless it happened in a sheet she is still looking at.</p>
"""
LATER = ('<div class="laterband">After v1 — concepts, not flows.<small>A book as a folder of notes (VX-1000, the Mac and the phone together), import through Files (SC-5) and capture from outside the app (SC-2). '
         'These frames show the idea and the questions each raises; none is sized or scheduled here.</small></div>')
sections = [
    ("1 · A note: copy, and export", '<p class="lede">Copy follows the screen. Export makes a file and asks which one.</p>', s1),
    ("2 · A whole book", '<p class="lede">One row in the book’s menu, then the same road. Two files in v1.</p>', s2),
    ("3 · The whole library, from Settings", '<p class="lede">Every note as Markdown, and the unencrypted copy (VM-30).</p>', s3),
    ("4 · The largest text size, and dark", '', s4),
    ("5 · After v1: a book as a folder, import, and capture from outside", LATER, s5),
]
_rows = {}
for _f, _l, _w in DRAFTS:
    _rows.setdefault(_f, [])
    if _l not in _rows[_f]: _rows[_f].append(_l)
WORDS_TABLE = ''.join('<tr><td>%s</td><td>%s</td></tr>' % (f, ' · '.join('“%s”' % l for l in ls)) for f, ls in _rows.items())
NOTES = """
<div class="pick" style="max-width:1500px"><h2>The designer’s own calls, not ruled on</h2>
<p><b>A short sheet before the library exports (frame 15).</b> The Mac goes straight to the folder panel for Export Library…. On a phone the write is long, can be interrupted, and must say once that the files are not encrypted, so a sheet comes first.</p>
<p><b>Considered and not drawn.</b> A warning when a Private note is exported: Private is about AI, not about her own files, and the Mac says nothing, so neither does this. A scheduled export on the phone: the Mac’s is off by default and the phone has no folder it can keep writing to; it stays out.</p></div>

<h2>Build notes</h2>
<table class="bn">
<tr><th>Screen</th><th>Work-list rows it delivers</th><th>Shared brain it stands on</th><th>What is new</th><th>Must not get wrong</th><th>Size</th></tr>
<tr><td>Copy text (frames 2, 7)</td><td>W-232 (NT-3, ruled)</td>
<td>Phone <code>MobileNoteClipboard</code> over Core <code>Queries.exportPost</code> (the take on screen, callouts as quotes).</td>
<td>The row’s one line.</td>
<td>Ruled: Copy is the on-screen words. It copies what is on screen, a take being looked at through the pill included, after pending typing is saved. It says nothing afterwards (today’s “Copied this note to the clipboard.” goes). An empty note refuses in words. The existing callout caveat stays true and stays said.</td><td>S</td></tr>
<tr><td>Export note… (frames 3–6, 8)</td><td>W-233; the door in W-150 (the note’s menu) and W-048 (the row menu)</td>
<td>Core <code>Queries.variorumDocumentText</code> and <code>Queries.exportPost</code>; the Mac’s <code>NoteExport</code> (file name rule, <code>Queries.sanitizedFilename</code>, the refusal words) — hoist owed to Shared.</td>
<td>The which-file sheet; the system share sheet (the app’s first).</td>
<td>Ruled: Export asks which file (just the text / with takes and tags). Pending typing is saved before the read, so the file says what she sees. The export writes no row. The file is made in a temporary place and removed when the share sheet closes, saved or not, and at next launch if the app died.
Sealed, archived and Private notes export like any other. The share sheet and Files leave the app active, not in the background: they must not start the lock’s minutes. A long note shows the busy row, never a frozen sheet. No line after a finished share.</td><td>M</td></tr>
<tr><td>Export book… (frames 9–13)</td><td>W-234; the row in W-070’s book menu</td>
<td>Core <code>Queries.exportReading</code> (one Markdown file); the Mac’s <code>PDFExporter</code> — Mac-local, hoist owed.</td>
<td>The row; the two-choice sheet; the counted busy sheet.</td>
<td>Ruled: one Markdown file or a PDF in v1. A gathering exports its current notes. Cancel removes whatever was half made. A book with no notes refuses in words. Do not build the folder choice here: it is VX-1000, after v1.</td><td>M</td></tr>
<tr><td>Settings ▸ Export; Export every note… (frames 14–18a, 25)</td><td>W-235; a group in W-211’s Settings list</td>
<td>Core <code>Queries.bulkExportManifest</code>; Shared <code>ExportWriter</code>; the Mac’s <code>ExportModel</code> words (“Exported N files.”).</td>
<td>The Settings group; the sheet before; the counted progress.</td>
<td>She chooses the folder first and the files are written straight into it. The export is every wing, and says so. It reads off the main thread and writes off it; the sheet counts real files. If the app leaves the screen mid-way it stops cleanly, says so on return, and can be run again.
Zero notes is a refusal in words. The unencrypted line is said once, here.</td><td>M</td></tr>
<tr><td>Export an unencrypted copy… (frames 19–24)</td><td>W-236 (absorbs VM-30)</td>
<td>Shared <code>PlaintextExportModel</code> (authorize by posture, choosing, exporting, done, failed) and <code>ProtectionCopy.exportPlaintext…</code> (title, body, “Enter your passphrase.”, “Choose Where…”, “Export”); Core <code>StorePlaintextExport</code>; the Mac’s file name <code>Variorum-unencrypted.sqlite</code>.</td>
<td>The phone face only; one added line of purpose; the folder picker road.</td>
<td>In Castle the passphrase, never Face ID alone; in Standard the passphrase if one is set, else the plain button: the shared model already decides this. The copy is written straight into the folder she picked, never staged inside the app.
A half-written file is removed on failure or interruption. The sheet cannot be dismissed while writing. The failure line is words, never <code>String(describing: error)</code>. Never scheduled, never automatic. The words are the Mac’s; only the casing of “Choose where…” differs, which is her wording pass.</td><td>M</td></tr>
<tr><td>Largest text, dark (frames 26–30)</td><td>W-001, W-004</td><td>The phone type layer.</td><td>—</td><td>Each choice stays one full-width target at every size; lines wrap, never truncate.</td><td>—</td></tr>
<tr><td>After v1: a book as a folder of notes</td><td>VX-1000 (the Mac and the phone; W-234’s third choice)</td><td><code>Queries.variorumDocumentText</code> per note and the book’s chapters (<code>readingSections</code>, <code>assembleReading</code>).</td><td>The folder writer, new on both platforms.</td>
<td>Not sized here. A folder is handed to Files or AirDrop as a folder, not zipped behind her back. Chapter and file names go through the one sanitize rule; an empty chapter still makes its folder; notes in no chapter sit at the top level, which is how Import reads them back. The file-order point is VX-1000’s to settle.</td><td>—</td></tr>
<tr><td>After v1: import (SC-5)</td><td>W-237</td><td>Core <code>importDocument</code>, <code>importBook</code>; the Mac’s <code>DocumentImportCopy</code> (panel sentence, refusals) — hoist owed.</td><td>The picker road; document types.</td><td>Not sized. One import is one undo entry. Refusals name the folder, the file and the line. No message after a landed import.</td><td>—</td></tr>
<tr><td>After v1: capture from outside (SC-2)</td><td>W-029</td><td>Core <code>importPost(wingId:)</code>; the phone’s quick-note model.</td><td>A share extension, a widget, an App Intent.</td><td>Not sized. An extension cannot open a locked or Castle library; whatever waits outside it must be decided with CastleRules in hand, not designed around.</td><td>—</td></tr>
</table>

<h2>Lines that are drafts (everything else is the app’s)</h2>
<table class="bn">
<tr><th>Frame</th><th>The lines</th></tr>
""" + WORDS_TABLE + """
</table>
<p class="note-ann"><b>Added to the sizing sheet’s vocabulary</b> (in its spirit): the <b>choice row with a busy state</b> (the books designer’s choice card, its chevron swapped for the 18 pt spinner);
a <b>busy line</b> and a <b>6 pt progress bar</b> with a 17 pt count for long writes inside a sheet; a <b>three-line sheet title</b> for the Mac’s long sentence-titles;
the lock-and-protection mockup’s <b>settings row</b>, reused as is. The share sheet, the Files screens, the browser and the home screen are the system’s, drawn simplified and never themed;
the file cards (4a, 4b, 11, 18a and the folder card) are annotations showing what a file holds, not screens.</p>
"""
if os.environ.get('WORDING_DIR'):
    import json
    json.dump([list(x) for x in DRAFTS], open(os.path.join(os.environ['WORDING_DIR'], 'export-and-share.json'), 'w'), ensure_ascii=False, indent=1)
write('export-and-share.html', 'VM-44 mockups — export, share and copy', INTRO, sections, NOTES, check_dir=os.environ.get('SH_CHECK'))
print('drafts:', len(DRAFTS))
