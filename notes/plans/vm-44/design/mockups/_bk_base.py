# VM-44 books designer — throwaway generator base (static HTML out; no scripts in the output).
# Reuses the round-1 sketch generator's frame CSS, icons and shell helpers WITHOUT running its page writers.
import os, re, html
HERE = os.path.dirname(os.path.abspath(__file__))
SK = os.path.join(HERE, '..', 'sketches', '_g1-sketch-generator.py')
_src = open(SK).read()
_prefix = _src.split('# =====================================================================')[0]
G = {}
exec(_prefix, G)            # CSS, icons, sb/hi/mast/dots/chips/brow/lst/sec/qe_rest/kb/tabs_words…
CSS0 = G['CSS']
I_SEARCH, I_MORE, I_BACK, I_PIN, I_SORT = G['I_SEARCH'], G['I_MORE'], G['I_BACK'], G['I_PIN'], G['I_SORT']
mast, dots, chips, brow, lst, sec, qe_rest, kb, tabs_words, hi, badge, zone = (G[k] for k in
    ('mast', 'dots', 'chips', 'brow', 'lst', 'sec', 'qe_rest', 'kb', 'tabs_words', 'hi', 'badge', 'zone'))
STAR, FIN = G['STAR'], G['FIN']
SB = G['sb']()

def ic(d, w=22, extra=''):
    return ('<svg width="%d" height="%d" viewBox="0 0 22 22" fill="none" stroke="currentColor" stroke-width="1.7" '
            'stroke-linecap="round" stroke-linejoin="round">%s%s</svg>') % (w, w, ''.join('<path d="%s"/>' % p for p in d.split('|')), extra)
I_TRAY = ic('M3 13l2.5-8h11L19 13v5H3v-5z|M3 13h5l1 2.5h4l1-2.5h5')
I_GEAR = ic('M4 7h8|M17 7h1|M4 15h1|M10 15h8', extra='<circle cx="14.5" cy="7" r="2.2"/><circle cx="7.5" cy="15" r="2.2"/>')
I_SHARED = ic('M9 7V5a2 2 0 012-2h6a2 2 0 012 2v6a2 2 0 01-2 2h-2', extra='<rect x="3" y="8" width="11" height="11" rx="2"/>')
I_LOCK = ic('M8 10V7a3 3 0 016 0v3', extra='<rect x="5" y="10" width="12" height="9" rx="2"/>')
I_ARCH = ic('M5 8v10h12V8|M9 12h4', extra='<rect x="3" y="4" width="16" height="4" rx="1"/>')
I_TRASH = ic('M4 6h14|M9 6V4h4v2|M6 6l1 13h8l1-13')
I_WING = ic('M4 18V8l7-4 7 4v10|M4 18h14|M9 18v-5h4v5')
I_LIST = ic('M5 6h12|M5 11h12|M5 16h8')
I_EXPORT = ic('M11 14V4|M7 8l4-4 4 4|M4 13v5h14v-5')
I_PENCIL = ic('M4 18l1-4L15 4l3 3L8 17l-4 1z')
I_CHECK = ic('M4 11l5 5 9-10')
I_PLUS = ic('M11 4v14|M4 11h14')
I_UP = ic('M11 18V4|M5 10l6-6 6 6')
I_DOWN = ic('M11 4v14|M5 12l6 6 6-6')
I_TAG = ic('M3 11V4h7l9 9-7 7-9-9z', extra='<circle cx="7.5" cy="8.5" r="1.2"/>')
I_BOOK = ic('M4 4h10a3 3 0 013 3v12H7a3 3 0 01-3-3V4z|M4 16a3 3 0 013-3h10')
I_STARO = ic('M11 3l2.4 5 5.4.7-3.9 3.8.9 5.3L11 15.3 6.2 17.8l.9-5.3L3.2 8.7 8.6 8 11 3z')
I_OPEN = ic('M9 5h8v8|M17 5L6 16')
I_X = ic('M6 6l10 10|M16 6L6 16')
I_SHELF = ic('M3 18h16|M5 18V6h3v12|M10 18V4h3v14|M15 18V8h3v10')
I_SUN = ic('M11 3v2|M11 17v2|M3 11h2|M17 11h2', extra='<circle cx="11" cy="11" r="4"/>')
I_FWD = ic('M8 4l6 7-6 7')
I_BACK2 = ic('M14 4l-6 7 6 7')
PINM = I_PIN

CSS = CSS0 + r"""
.row{flex-wrap:wrap;overflow:visible;row-gap:18px}
h3{font:600 17px/1.3 var(--sans);margin:26px 0 2px;max-width:900px}
.small{zoom:.62}
.opt.sm{flex:0 0 280px;width:280px}
.opt.sm .cap{margin-left:4px}
.note-ann{max-width:900px;font-size:14px;color:#5b574f}
table.bn{border-collapse:collapse;font-size:14px;margin-top:10px;max-width:1500px}
table.bn td,table.bn th{border:1px solid #D8D4CA;padding:7px 10px;text-align:left;vertical-align:top}
table.bn th{background:#E9E6DF;font-weight:600}
table.bn td:first-child{font-weight:600;white-space:nowrap}
code{font:13px/1.4 "SF Mono",ui-monospace,Menlo,monospace;background:#E9E7E0;padding:1px 4px;border-radius:4px}

/* ---- dark: the sizing sheet's .dk values ---- */
.phone.dk{--room:#000000;--surface:#0F1A16;--ink:#E8E3D8;--muted:#948C7C;--meta:#948C7C;--faint:#6B6456;--accent:#90C1AF;
 --line:#1C332A;--wash:#1F382F;--taketint:#0D1713;--takeline:#254137;--alarm:#D98A78;--star:#82ABCC;--positive:#93B57E}
.phone.dk .pill.fill,.phone.dk .btn.fill,.phone.dk .badge{color:#0F1A16}
.phone.dk .qebox{background:var(--surface)}
.phone.dk .chip{background:rgba(255,255,255,.06)}

/* ---- book screen ---- */
.pill.arr{gap:7px;font-weight:600;background:var(--accent);color:#fff;box-shadow:none;padding:0 14px 0 12px}
.cbtn.calm{color:var(--meta)}
.sub .stc,.stc{display:inline-flex;align-items:center;gap:4px;height:24px;padding:0 9px;border-radius:12px;background:var(--wash);color:var(--accent);font:600 13px/24px var(--sans);margin:0 4px 0 2px;vertical-align:middle}
.stc svg{width:13px;height:13px}
.sub{padding-bottom:12px}
.nrow.cur{background:var(--taketint);box-shadow:inset 3px 0 0 var(--accent)}
.nw svg{width:13px;height:13px;vertical-align:-2px;margin-right:3px}
.band{flex:none;display:flex;align-items:center;gap:10px;min-height:56px;padding:8px 8px 8px 20px;font:400 15px/20px var(--sans);color:var(--ink);background:var(--taketint);border-top:1px solid var(--line)}
.band span.t{flex:1}
.band .act{height:44px;padding:0 14px;display:inline-flex;align-items:center;font:600 15px var(--sans);color:var(--accent);flex:none}
.empty{padding:56px 36px 0;text-align:center;font:400 17px/25px var(--serif);color:var(--meta)}
.winline{padding:14px 20px;font:400 15px/20px var(--sans);color:var(--meta)}
.winline b{color:var(--accent);font-weight:600;margin-left:4px}
.msg{flex:none;margin:0 20px;padding:9px 0;font:400 15px/20px var(--sans);color:var(--meta);display:flex;gap:10px;align-items:flex-start}
.msg span{flex:1}
.msg b{color:var(--accent);font-weight:600;white-space:nowrap}
.msg.refusal{color:var(--alarm)}

/* ---- the note, opened from a book ---- */
.page{flex:1;min-height:0;overflow:hidden;background:var(--surface);border-top:1px solid var(--line);padding:18px 20px 0}
.ntitle{font:600 24px/30px var(--serif)}
.nchip{font:400 13px/18px var(--sans);color:var(--meta);margin:6px 0 14px}
.nchip b{color:var(--accent);font-weight:500}
.page p{font:400 17px/27px var(--serif);margin:0 0 14px}
.strip{flex:none;height:48px;display:flex;align-items:center;background:var(--room);border-top:1px solid var(--line)}
.strip.top{border-top:0}
.strip .sbtn{width:60px;height:48px;display:flex;align-items:center;justify-content:center;color:var(--accent);flex:none}
.strip .sbtn.off{color:var(--faint)}
.strip .smid{flex:1;min-width:0;display:flex;align-items:center;justify-content:center;gap:7px;font:500 15px/20px var(--sans);color:var(--ink);white-space:nowrap;overflow:hidden}
.strip .smid span{color:var(--meta);font-weight:400}
.strip .smid svg{width:16px;height:16px;color:var(--accent);flex:none}

/* ---- sheets, grouped rows, confirms ---- */
.scrim{position:absolute;inset:0;background:rgba(41,36,28,.28);z-index:5}
.phone.dk .scrim{background:rgba(0,0,0,.55)}
.sheet{position:absolute;left:0;right:0;bottom:0;z-index:6;background:var(--room);border-radius:28px 28px 0 0;box-shadow:0 -8px 40px rgba(41,36,28,.22);display:flex;flex-direction:column;overflow:hidden;padding-bottom:34px}
.sheet>*{flex-shrink:0}
.sheet.kbd{padding-bottom:0}
.sheet:after{content:"";position:absolute;left:50%;bottom:8px;width:134px;height:5px;margin-left:-67px;border-radius:3px;background:var(--ink)}
.sheet.kbd:after{display:none}
.grab{width:36px;height:5px;border-radius:3px;background:var(--faint);margin:8px auto 0;flex:none}
.shead{flex:none;display:flex;align-items:center;justify-content:space-between;min-height:56px;padding:0 8px 0 20px;gap:8px}
.shead .st{font:600 20px/25px var(--serif);flex:1;min-width:0}
.shead .hb{height:44px;min-width:60px;padding:0 12px;display:inline-flex;align-items:center;justify-content:center;font:400 17px var(--sans);color:var(--accent);flex:none}
.shead .hb.s{font-weight:600}
.shead .hb.off{opacity:.4}
.shead.c3 .hb:first-child{padding-left:0;justify-content:flex-start}
.ssub{flex:none;padding:0 20px 10px;font:400 13px/18px var(--sans);color:var(--meta);margin-top:-6px}
.sbody{flex:1;min-height:0;overflow:hidden}
.glab{padding:10px 20px 6px;font:600 13px/18px var(--sans);color:var(--meta);letter-spacing:.02em}
.grp{margin:0 16px 12px;background:var(--surface);border-radius:14px;box-shadow:0 0 0 1px var(--line);overflow:hidden}
.mrow{display:flex;align-items:center;gap:12px;min-height:52px;padding:7px 16px;border-bottom:1px solid var(--line);font:400 17px/22px var(--sans);color:var(--ink)}
.mrow:last-child{border-bottom:0}
.mrow .ic{width:24px;flex:none;color:var(--accent);display:flex;justify-content:center}
.mrow .mid{flex:1;min-width:0}
.mrow .c13{font:400 13px/18px var(--sans);color:var(--meta);margin-top:2px}
.mrow .v{margin-left:auto;color:var(--meta);font:400 15px/20px var(--sans);flex:none;display:flex;align-items:center;gap:6px}
.mrow .v svg{width:14px;height:14px}
.mrow.acc{color:var(--accent)}
.mrow.danger,.mrow.danger .ic{color:var(--alarm)}
.mrow.off{opacity:.4}
.mrow.on{background:var(--taketint)}
.mrow .ck{color:var(--accent);margin-left:auto;flex:none}
.mrow.serif{font-family:var(--serif)}
.sent{padding:11px 16px;border-bottom:1px solid var(--line);font:400 17px/24px var(--sans)}
.sent i{font-style:normal;color:var(--meta);font-size:15px;display:block;line-height:20px}
.sent b{font-weight:500}
.c13b{padding:0 20px 12px;font:400 13px/18px var(--sans);color:var(--meta);margin-top:-4px}
.field{margin:0 16px 12px;min-height:52px;border-radius:12px;background:var(--surface);box-shadow:0 0 0 1px var(--line);display:flex;align-items:center;padding:0 14px;font:400 17px var(--serif);gap:8px}
.field.focus{box-shadow:0 0 0 2px var(--accent)}
.field i{font-style:normal;color:var(--meta);font:400 15px var(--sans);flex:none}
.field .ph{color:var(--meta)}
.toggle{width:51px;height:31px;border-radius:16px;background:var(--faint);position:relative;flex:none;margin-left:auto}
.toggle:after{content:"";position:absolute;left:2px;top:2px;width:27px;height:27px;border-radius:14px;background:#fff;box-shadow:0 1px 3px rgba(0,0,0,.25)}
.toggle.on{background:var(--accent)}.toggle.on:after{left:22px}
.segc{margin:0 16px 12px;height:44px;border-radius:11px;background:rgba(255,255,255,.6);box-shadow:inset 0 0 0 1px var(--line);display:flex;padding:3px;font:500 15px var(--sans);color:var(--meta)}
.phone.dk .segc{background:rgba(255,255,255,.06)}
.segc span{flex:1;display:flex;align-items:center;justify-content:center;border-radius:8px;white-space:nowrap}
.segc span.on{background:var(--wash);color:var(--ink);font-weight:600;box-shadow:inset 0 0 0 1px var(--takeline)}
.btn{height:50px;border-radius:14px;display:flex;align-items:center;justify-content:center;font:600 17px var(--sans);margin:0 16px 10px;gap:8px}
.btn.fill{background:var(--accent);color:#fff}
.btn.plain{background:var(--surface);color:var(--accent);box-shadow:0 0 0 1px var(--line)}
.btn.alarm{background:var(--surface);color:var(--alarm);box-shadow:0 0 0 1px var(--line)}
.btn.quiet{color:var(--accent);font-weight:400;margin-bottom:0}
.btn.off{opacity:.45}
.cf{padding:6px 20px 8px}
.cf .ct{font:600 20px/26px var(--serif);margin:6px 0 10px}
.cf p{font:400 15px/21px var(--sans);margin:0 0 9px;color:var(--ink)}
.cf p.w{color:var(--alarm);font-weight:500}
.cf ul{margin:0 0 10px;padding:0;list-style:none;background:var(--surface);border-radius:12px;box-shadow:0 0 0 1px var(--line)}
.cf li{padding:10px 14px;font:400 15px/20px var(--serif);border-bottom:1px solid var(--line)}
.cf li:last-child{border:0}
.cf li span{font:400 13px/18px var(--sans);color:var(--meta);display:block}
.choice{margin:0 16px 10px;padding:13px 16px;border-radius:14px;background:var(--surface);box-shadow:0 0 0 1px var(--line);display:flex;gap:12px;align-items:center}
.choice .mid{flex:1}
.choice b{display:block;font:600 17px/22px var(--sans);color:var(--accent)}
.choice span{display:block;font:400 15px/20px var(--sans);color:var(--ink);margin-top:2px}
.choice.off{opacity:.45}
.choice .go{margin:0;color:var(--faint)}
.tchips{display:flex;flex-wrap:wrap;gap:8px;padding:0 16px 12px}
.tchip{display:inline-flex;align-items:center;gap:8px;height:36px;padding:0 12px;border-radius:18px;background:var(--surface);box-shadow:inset 0 0 0 1px var(--takeline);font:500 15px var(--sans);color:var(--ink)}
.tchip svg{width:13px;height:13px;color:var(--meta)}
.tchip.add{background:transparent;color:var(--accent);box-shadow:inset 0 0 0 1px var(--takeline)}
.tchip.not{background:var(--taketint)}
.term{display:flex;align-items:center;gap:10px;min-height:52px;padding:4px 6px 4px 16px;border-bottom:1px solid var(--line);font:500 17px var(--sans)}
.term:last-child{border:0}
.term .nt2{height:32px;padding:0 10px;border-radius:8px;font:500 13px/32px var(--sans);color:var(--meta);box-shadow:inset 0 0 0 1px var(--line);margin-left:auto}
.term .nt2.on{background:var(--wash);color:var(--ink);font-weight:600}
.term .x{width:44px;height:44px;display:flex;align-items:center;justify-content:center;color:var(--meta);flex:none}
.term .x svg{width:16px;height:16px}
.term.locked{color:var(--meta);font-weight:400}
.term.locked .x{margin-left:auto}

/* ---- arrivals ---- */
.arow{padding:10px 20px 4px;border-bottom:1px solid var(--line);background:var(--surface);position:relative}
.arow .at{font:600 17px/22px var(--serif);display:flex;gap:8px;align-items:baseline}
.arow .at .x{flex:1;min-width:0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.arow .why{font:400 13px/18px var(--sans);color:var(--meta);margin-top:3px}
.arow .why b{font-weight:600;color:var(--ink)}
.arow .rsn{font:italic 400 15px/20px var(--serif);color:var(--ink);margin-top:3px}
.arow .own{font:400 13px/18px var(--sans);color:var(--meta);margin-top:2px}
.arow .own svg{width:13px;height:13px;vertical-align:-2px;margin-right:3px}
.arms{display:flex;gap:8px;align-items:center;height:44px}
.arm{height:32px;padding:0 16px;border-radius:16px;font:600 15px/32px var(--sans);display:inline-flex;align-items:center}
.arm.add{background:var(--wash);color:var(--accent)}
.arm.dis{color:var(--meta);box-shadow:inset 0 0 0 1px var(--line);font-weight:500}
.amark{display:inline-block;height:20px;padding:0 7px;border-radius:5px;font:600 12px/20px var(--sans);color:var(--meta);box-shadow:inset 0 0 0 1px var(--line);flex:none}
.arow.selm{padding-left:60px;padding-bottom:10px}
.selc{position:absolute;left:20px;top:50%;margin-top:-13px;width:26px;height:26px;border-radius:13px;box-shadow:inset 0 0 0 1.5px var(--faint);display:flex;align-items:center;justify-content:center;color:#fff}
.selc.on{background:var(--accent);box-shadow:none}
.selc svg{width:15px;height:15px;stroke-width:2.4}
.arow.selon{background:var(--taketint)}
.swipe{position:relative;overflow:hidden;border-bottom:1px solid var(--line)}
.swipe .act{position:absolute;top:0;bottom:0;width:104px;display:flex;flex-direction:column;gap:4px;align-items:center;justify-content:center;font:600 15px var(--sans);color:#fff}
.swipe .act.l{left:0;background:var(--accent)}
.swipe .act.r{right:0;background:#6A6359}
.swipe .act.r2{right:104px;background:var(--accent)}
.swipe .arow,.swipe .nrow{border-bottom:0}
.swipe .sl{transform:translateX(104px)}
.swipe .sr{transform:translateX(-104px)}
.swipe .sr2{transform:translateX(-208px)}
.fbar{flex:none;display:flex;gap:10px;padding:10px 16px 2px}
.fbar .btn{flex:1;margin:0;height:48px}

/* ---- the largest standard text size (xxxLarge, about 1.35x) ---- */
.phone.xl .nt,.phone.xl .arow .at{font-size:23px;line-height:29px}
.phone.xl .nt span.x,.phone.xl .arow .at .x{white-space:normal;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical}
.phone.xl .np{font-size:20px;line-height:26px;white-space:normal;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical}
.phone.xl .np b{font-size:18px}
.phone.xl .nw,.phone.xl .sub,.phone.xl .arow .why,.phone.xl .arow .own{font-size:18px;line-height:24px}
.phone.xl .sec{font-size:18px;height:auto;padding:22px 20px 8px}
.phone.xl .btitle{font-size:32px;line-height:38px}
.phone.xl .pill,.phone.xl .arm{font-size:20px}
.phone.xl .arm{height:40px;border-radius:20px}.phone.xl .arms{height:52px}
.phone.xl .arow .rsn{font-size:20px;line-height:26px}
.phone.xl .qebox{font-size:23px;min-height:60px}
.phone.xl .stc{font-size:17px;height:30px;border-radius:15px}
.phone.xl .btn{font-size:22px;height:58px}
"""

def P(*parts, cls=''):
    return '<div class="phone %s">%s%s</div>' % (cls, SB, ''.join(parts))

def cb(icon, cls=''): return '<span class="cbtn %s">%s</span>' % (cls, icon)
BACK = cb(I_BACK); MORE = cb(I_MORE); TRAY0 = cb(I_TRAY, 'calm'); READ = '<span class="pill">Read</span>'
def arr(n): return '<span class="pill arr">%s %d</span>' % (I_TRAY.replace('width="22" height="22"', 'width="18" height="18"'), n)
def nav(right='', left=BACK): return '<div class="nav">%s<div class="r">%s</div></div>' % (left, right)
def stc(word, icon=''): return '<span class="stc">%s%s</span>' % (icon, word)
def bookhead(name, meta, right, star=False):
    s = ' <span class="star" style="font-size:18px;vertical-align:2px">★</span>' if star else ''
    return nav(right) + '<div class="btitle">%s%s</div><div class="sub">%s</div>' % (name, s, meta)

def nrow(title, stamp, preview, where=None, star=False, pin=False, shared=False, cur=False):
    p = PINM if pin else ''
    s = STAR if star else ''
    sh = '<span style="color:var(--meta);flex:none">%s</span>' % I_SHARED.replace('width="22" height="22"', 'width="15" height="15"') if shared else ''
    w = '<div class="nw">%s</div>' % where if where else ''
    return ('<div class="nrow%s"><div class="nt">%s<span class="x">%s</span>%s%s</div><div class="np"><b>%s</b>%s</div>%s</div>'
            % (' cur' if cur else '', p, title, sh, s, stamp, preview, w))
def trow(title, pin=False, cur=False, meta=''):
    return ('<div class="mrow serif%s" style="font-weight:600">%s<span class="mid" style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis">%s</span>%s</div>'
            % (' on' if cur else '', PINM if pin else '', title, '<span class="v">%s</span>' % meta if meta else ''))
def foot(text): return '<div class="qe"><div class="qebox">%s</div></div>' % text
def band(text, act=''): return '<div class="band"><span class="t">%s</span>%s</div>' % (text, '<span class="act">%s</span>' % act if act else '')
def msg(text, door='', refusal=False):
    return '<div class="msg%s"><span>%s</span>%s</div>' % (' refusal' if refusal else '', text, '<b>%s</b>' % door if door else '')

def sheet(top, head, *body, cls=''):
    st = ' style="top:%dpx"' % top if top is not None else ''
    return '<div class="scrim"></div><div class="sheet %s"%s><div class="grab"></div>%s<div class="sbody">%s</div></div>' % (cls, st, head, ''.join(body))
def shead(title, right='Done', left=None, strong=True, roff=False):
    l = '<span class="hb">%s</span>' % left if left else ''
    r = '<span class="hb%s%s">%s</span>' % (' s' if strong else '', ' off' if roff else '', right) if right else ''
    return '<div class="shead%s">%s<span class="st"%s>%s</span>%s</div>' % (' c3' if left else '', l, ' style="text-align:center"' if left else '', title, r)
def grp(*rows): return '<div class="grp">%s</div>' % ''.join(rows)
def glab(t): return '<div class="glab">%s</div>' % t
def mrow(label, icon='', v='', cls='', cap='', trail=''):
    i = '<span class="ic">%s</span>' % icon if icon else ''
    c = '<div class="c13">%s</div>' % cap if cap else ''
    vv = '<span class="v">%s</span>' % v if v else ''
    return '<div class="mrow %s">%s<div class="mid">%s%s</div>%s%s</div>' % (cls, i, label, c, vv, trail)
CHEV = '<span style="color:var(--faint);font-size:20px">›</span>'
def toggle(on=False): return '<span class="toggle%s"></span>' % (' on' if on else '')
def seg(items, on): return '<div class="segc">%s</div>' % ''.join('<span%s>%s</span>' % (' class="on"' if i == on else '', x) for i, x in enumerate(items))
def btn(label, kind='fill', off=False): return '<div class="btn %s%s">%s</div>' % (kind, ' off' if off else '', label)
def confirm(top, title, lines, buttons, items=None, after=None):
    body = '<div class="cf"><div class="ct">%s</div>%s%s%s</div>' % (
        title, ''.join('<p>%s</p>' % l for l in lines),
        '<ul>%s</ul>' % ''.join('<li>%s</li>' % i for i in items) if items else '',
        ''.join('<p class="w">%s</p>' % l for l in (after or [])))
    st = ' style="top:%dpx"' % top if top is not None else ''
    return '<div class="scrim"></div><div class="sheet"%s><div class="grab"></div>%s%s</div>' % (st, body, ''.join(buttons))
def choice(title, text, off=False): return '<div class="choice%s"><div class="mid"><b>%s</b><span>%s</span></div><span class="go">›</span></div>' % (' off' if off else '', title, text)
def field(text, focus=False, label='', ph=False):
    l = '<i>%s</i>' % label if label else ''
    t = '<span class="ph">%s</span>' % text if ph else text
    return '<div class="field%s">%s%s%s</div>' % (' focus' if focus else '', l, t, '<span class="caret"></span>' if focus else '')
def tchip(t, x=True, cls=''): return '<span class="tchip %s">%s%s</span>' % (cls, t, I_X if x else '')
def term(label, neg=False, x=True, locked=False):
    if locked:
        return '<div class="term locked">%s<span style="flex:1">%s</span><span class="x">%s</span></div>' % (I_LOCK.replace('width="22" height="22"', 'width="16" height="16"'), label, I_X)
    return '<div class="term"><span>%s</span><span class="nt2%s">not</span><span class="x">%s</span></div>' % (label, ' on' if neg else '', I_X)

def opt(frame, oid, title, text, mine=False, small=False):
    f = '<div class="small">%s</div>' % frame if small else frame
    return '<div class="opt%s">%s<div class="cap"><span class="id%s">%s</span><b>%s</b> %s</div></div>' % (' sm' if small else '', f, ' mine' if mine else '', oid, title, text)
def row(*opts): return '<div class="row">' + ''.join(opts) + '</div>'

VALUES = """
<h2>The values these frames are drawn with</h2>
<p class="lede">Everything here inherits <code>sketches/sizing-sheet.html</code>: Study voice under the sea-glass palette; type at 13 · 15 · 17 · 20 · 24
(Iowan Old Style for her words and for names, SF for chrome); a 44 pt touch minimum; lists and prose on the paper, bars, sheets and section bands on the
sea-glass room; the corrected meta ink <code>#6A6359</code>; the dark values are the sheet's <code>.dk</code> set. The shell (the wing masthead, the
shelf chips, the tab bar, the capture box) is the graders' picks SW-1 (a), SW-3 (b), BK-1 (a), drawn with the round-1 sketch generator's own frame so a
different pick is a re-skin. Frames are 402 × 874 pt, one CSS pixel to the point. Fonts fall back to Palatino or Georgia where Iowan is not installed.</p>
"""

def write(fname, title, intro, sections, notes, check_dir=None):
    body = ''.join('<h2>%s</h2>%s%s' % (h, lede, row(*opts)) for h, lede, opts in sections)
    doc = ('<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">'
           '<title>%s</title><style>%s</style></head><body><h1>%s</h1>%s%s%s%s</body></html>') % (html.escape(title), CSS, html.escape(title), intro, body, notes, VALUES)
    path = os.path.join(HERE, fname)
    open(path, 'w').write(doc)
    print(path, len(doc), sum(len(o) for _, _, o in sections), 'frames')
    if check_dir:
        os.makedirs(check_dir, exist_ok=True)
        n = 0
        for si, (h, lede, opts) in enumerate(sections):
            for k in range(0, len(opts), 3):
                n += 1
                d = ('<!doctype html><html><head><meta charset="utf-8"><style>%s body{padding:10px 20px 20px}</style></head><body><p><b>%s</b></p>%s</body></html>'
                     % (CSS, h, row(*opts[k:k + 3])))
                open(os.path.join(check_dir, '%s-%02d.html' % (fname.replace('.html', ''), n)), 'w').write(d)
