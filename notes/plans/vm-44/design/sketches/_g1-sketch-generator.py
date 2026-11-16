# VM-44 grader 1 — throwaway generator for the sitting sketches (static HTML out; no scripts in the output).
import os, html
OUT = 'notes/plans/vm-44/design/sketches'
DESIGN = 'notes/plans/vm-44/design'
os.makedirs(OUT, exist_ok=True)

CSS = r"""
:root{--room:#E5F0EC;--surface:#FFFFFF;--ink:#29241C;--muted:#8D8578;--meta:#6A6359;--faint:#B5AD9E;
--accent:#3B6A59;--line:#CBE2D9;--wash:#CBE2D9;--taketint:#E8F2EE;--takeline:#B7D7CB;--alarm:#9B3B2F;
--star:#3D6B8E;--positive:#5A7D46;
--serif:"Iowan Old Style","Iowan Old Style BT",Palatino,"Palatino Linotype","Book Antiqua",Georgia,serif;
--sans:-apple-system,BlinkMacSystemFont,"SF Pro Text","Helvetica Neue",Helvetica,Arial,sans-serif;}
*{box-sizing:border-box}
body{margin:0;padding:36px 40px 80px;background:#F1EFEA;color:#29241C;font-family:var(--sans);font-size:16px;line-height:1.5}
h1{font:600 30px/1.2 var(--serif);margin:0 0 6px}
h2{font:600 22px/1.25 var(--serif);margin:52px 0 6px}
p{margin:8px 0}
.lede{max-width:900px}
.q{max-width:900px;border-left:3px solid var(--accent);padding:2px 0 2px 14px;font:italic 17px/1.5 var(--serif);margin:12px 0}
.row{display:flex;gap:30px;align-items:flex-start;overflow-x:auto;padding:14px 12px 26px}
.opt{flex:0 0 422px;width:422px}
.cap{margin:16px 10px 0;font-size:15px;line-height:1.45}
.cap .id{display:inline-block;font:600 13px var(--sans);letter-spacing:.03em;background:#29241C;color:#fff;border-radius:6px;padding:3px 8px;margin-right:6px}
.cap .id.mine{background:var(--accent)}
.cap b{font-weight:600}
.pick{max-width:900px;background:#fff;border-radius:14px;padding:18px 22px;margin-top:28px;box-shadow:0 0 0 1px #DAD6CC}
.pick h2{margin-top:0}
table.legend{border-collapse:collapse;font-size:14px;margin-top:10px}
table.legend td,table.legend th{border:1px solid #D8D4CA;padding:5px 10px;text-align:left;vertical-align:top}
table.legend th{background:#E9E6DF;font-weight:600}
.sw{display:inline-block;width:14px;height:14px;border-radius:3px;vertical-align:-2px;margin-right:6px;box-shadow:0 0 0 1px rgba(0,0,0,.15)}

/* ---- the phone, 402 x 874 pt, 1 CSS px = 1 pt ---- */
.phone{position:relative;width:402px;height:874px;margin:10px;border-radius:56px;background:var(--room);overflow:hidden;
 box-shadow:0 0 0 1px #8b8f92,0 0 0 9px #1c1c1e,0 0 0 10px #55585b;display:flex;flex-direction:column;color:var(--ink);font-family:var(--sans)}
.sb{flex:none;height:54px;position:relative}
.sb .time{position:absolute;left:50px;top:18px;font:600 17px var(--sans)}
.sb .island{position:absolute;left:50%;top:12px;width:124px;height:36px;margin-left:-62px;border-radius:20px;background:#000}
.sb .sbr{position:absolute;right:36px;top:23px;display:flex;gap:6px;align-items:center}
.sb .sig{width:17px;height:11px;background:var(--ink);clip-path:polygon(0 100%,100% 0,100% 100%)}
.sb .wifi{width:15px;height:11px;background:var(--ink);border-radius:50% 50% 0 0/100% 100% 0 0}
.sb .bat{width:25px;height:12px;border:1.5px solid var(--ink);border-radius:4px;position:relative}
.sb .bat:after{content:"";position:absolute;left:1.5px;top:1.5px;bottom:1.5px;right:6px;background:var(--ink);border-radius:1.5px}
.hi{flex:none;height:34px;position:relative}
.hi:after{content:"";position:absolute;left:50%;bottom:8px;width:134px;height:5px;margin-left:-67px;border-radius:3px;background:var(--ink)}

.mast{flex:none;display:flex;align-items:center;justify-content:space-between;height:56px;padding:0 16px 0 20px}
.wingbtn{display:flex;align-items:center;gap:8px;height:48px}
.wname{font:600 24px/30px var(--serif)}
.chev{display:inline-block;width:0;height:0;border-left:6px solid transparent;border-right:6px solid transparent;border-top:8px solid var(--accent);margin-top:4px}
.mbtns{display:flex;gap:8px}
.cbtn{width:44px;height:44px;border-radius:22px;background:var(--surface);display:inline-flex;align-items:center;justify-content:center;color:var(--accent);box-shadow:0 0 0 1px var(--line)}
.pill{height:44px;padding:0 16px;border-radius:22px;background:var(--surface);display:inline-flex;align-items:center;gap:6px;color:var(--accent);box-shadow:0 0 0 1px var(--line);font:400 17px var(--sans)}
.pill.fill{background:var(--accent);color:#fff;box-shadow:none;font-weight:600}
.dots{flex:none;display:flex;gap:7px;padding:0 22px;height:22px;align-items:flex-start}
.dots.c{justify-content:center}
.dots i{width:7px;height:7px;border-radius:50%;background:var(--takeline)}
.dots i.on{background:var(--accent)}
.sub{flex:none;padding:2px 20px 10px;font:400 13px/18px var(--sans);color:var(--meta)}

.chips{flex:none;display:flex;gap:6px;align-items:center;height:56px;padding:0 16px;overflow:hidden;white-space:nowrap;position:relative}
.chips.fade:after{content:"";position:absolute;right:0;top:0;bottom:0;width:40px;background:linear-gradient(90deg,rgba(229,240,236,0),var(--room))}
.chip{flex:none;height:40px;padding:0 14px;border-radius:9px;display:inline-flex;align-items:center;gap:5px;font:400 15px var(--sans);color:var(--meta);background:rgba(255,255,255,.55)}
.chip.on{background:var(--wash);color:var(--ink);font-weight:600;box-shadow:inset 0 0 0 1px var(--takeline)}
.sortbtn{margin-left:auto;flex:none;height:44px;padding:0 6px;font:500 15px var(--sans);color:var(--accent);display:flex;align-items:center;gap:6px}
.seg{margin-left:auto;flex:none;height:40px;border-radius:10px;background:rgba(255,255,255,.55);display:flex;padding:3px;font:500 15px var(--sans);color:var(--meta)}
.seg span{padding:0 14px;display:flex;align-items:center;border-radius:8px}
.seg span.on{background:var(--wash);color:var(--ink);font-weight:600}

.list{flex:1;overflow:hidden;position:relative;min-height:0;background:var(--surface);border-top:1px solid var(--line)}
.brow{display:flex;align-items:center;min-height:64px;padding:8px 20px;gap:12px;border-bottom:1px solid var(--line)}
.brow .t{font:600 17px/22px var(--serif)}
.brow .m{font:400 13px/18px var(--sans);color:var(--meta);margin-top:3px}
.brow .tr{margin-left:auto;display:flex;gap:10px;align-items:center;flex:none}
.brow.dim{opacity:.45}
.star{color:var(--star);font-size:15px}
.fin{color:var(--positive);font:600 16px var(--sans)}
.badge{height:26px;min-width:26px;padding:0 9px;border-radius:13px;background:var(--accent);color:#fff;font:600 13px/26px var(--sans);text-align:center}
.gly{display:inline-block;width:22px;text-align:center;color:var(--accent)}
.sec{display:flex;align-items:flex-end;justify-content:space-between;height:44px;padding:0 20px 8px;font:600 13px var(--sans);letter-spacing:.03em;color:var(--meta)}
.sec.tap{height:48px;align-items:center;padding:0 20px;font:600 15px var(--sans);letter-spacing:0;color:var(--ink);background:var(--taketint);border-bottom:1px solid var(--line)}
.sec .n{font-weight:400;color:var(--meta)}
.shelfrow{display:flex;align-items:center;gap:14px;min-height:76px;padding:10px 20px;border-bottom:1px solid var(--line)}
.shelfrow .tile{flex:none;width:48px;height:48px;border-radius:11px;background:var(--wash);display:flex;align-items:center;justify-content:center;font:400 22px var(--serif);color:var(--accent)}
.shelfrow .t{font:600 17px/22px var(--serif)}
.shelfrow .m{font:400 13px/18px var(--sans);color:var(--meta);margin-top:2px;white-space:nowrap;overflow:hidden;text-overflow:ellipsis;max-width:250px}
.go{margin-left:auto;color:var(--faint);font:400 22px var(--sans)}
.addrow{display:flex;align-items:center;height:52px;padding:0 20px;font:400 17px var(--sans);color:var(--accent)}

.search{flex:none;margin:2px 16px 4px;height:44px;border-radius:12px;background:var(--surface);box-shadow:0 0 0 1px var(--line);display:flex;align-items:center;gap:8px;padding:0 14px;font:400 17px var(--sans);color:var(--meta)}
.nrow{padding:11px 20px;border-bottom:1px solid var(--line)}
.nt{font:600 17px/22px var(--serif);display:flex;gap:8px;align-items:baseline}
.nt span.x{white-space:nowrap;overflow:hidden;text-overflow:ellipsis;flex:1;min-width:0}
.np{font:400 15px/20px var(--serif);color:var(--meta);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;margin-top:2px}
.np b{font:500 14px/20px var(--sans);color:var(--ink);margin-right:8px}
.nw{font:400 13px/18px var(--sans);color:var(--meta);margin-top:3px}
.ncard{margin:0 16px 10px;background:var(--surface);padding:13px 16px 12px;border-radius:14px;background:var(--surface);box-shadow:0 0 0 1px var(--line)}
.ncard .np2{font:400 15px/20px var(--serif);color:var(--meta);margin-top:4px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden;max-height:40px}
.ncard .nf{display:flex;justify-content:space-between;font:400 13px/18px var(--sans);color:var(--meta);margin-top:8px}
.pin{color:var(--meta);flex:none}

.nav{flex:none;height:52px;display:flex;align-items:center;justify-content:space-between;padding:0 16px}
.nav .r{display:flex;gap:8px}
.btitle{flex:none;padding:4px 20px 0;font:600 24px/30px var(--serif)}

.qe{flex:none;margin:8px 16px;display:flex;gap:10px;align-items:flex-end}
.qebox{flex:1;min-height:52px;border-radius:14px;background:var(--surface);border:1.5px dashed var(--takeline);display:flex;align-items:center;padding:0 16px;font:400 17px/27px var(--serif);color:var(--meta)}
.qebox.typed{align-items:flex-start;padding:13px 16px;color:var(--ink);display:block}
.qebox.typed p{margin:0 0 10px}
.qebox.typed p:last-child{margin:0}
.caret{display:inline-block;width:2px;height:21px;background:var(--accent);vertical-align:-4px;margin-left:1px}
.today{flex:none;height:52px;padding:0 14px;border-radius:14px;background:var(--wash);color:var(--accent);font:600 15px var(--sans);display:flex;align-items:center;gap:6px}
.qact{flex:none;display:flex;align-items:center;gap:8px;margin:0 16px 8px;height:44px}
.qact .dest{font:400 13px var(--sans);color:var(--meta);margin-right:auto}
.qact .saved{font:500 13px var(--sans);color:var(--positive);margin-right:auto}
.receipt{flex:none;margin:0 16px;height:44px;display:flex;align-items:center;justify-content:space-between;font:400 13px var(--sans);color:var(--meta)}
.receipt b{color:var(--accent);font-weight:600;font-size:15px;padding:12px 0 12px 12px}

.tabs{flex:none;height:56px;display:flex;border-top:1px solid var(--line)}
.tab{flex:1;display:flex;align-items:center;justify-content:center;font:400 17px var(--sans);color:var(--meta)}
.tab.on span{background:var(--wash);color:var(--ink);font-weight:600;padding:8px 16px;border-radius:9px}
.tabs.iw{height:64px}
.tabs.iw .tab{flex-direction:column;gap:3px;font-size:13px}
.tabs.iw .tab.on{color:var(--accent);font-weight:600}
.tabs.iw .tab.on span{background:none;padding:0;color:var(--accent)}
.systabs{flex:none;height:62px;margin:2px 20px 0;display:flex;gap:10px}
.syscap{flex:1;border-radius:31px;background:rgba(255,255,255,.78);box-shadow:0 3px 16px rgba(41,36,28,.16),inset 0 0 0 1px rgba(255,255,255,.95);display:flex;padding:4px}
.sysitem{flex:1;border-radius:27px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;font:500 10px var(--sans);color:#3c3c43}
.sysitem.on{background:rgba(120,120,128,.16);color:var(--accent)}
.syssearch{flex:none;width:62px;border-radius:31px;background:rgba(255,255,255,.78);box-shadow:0 3px 16px rgba(41,36,28,.16),inset 0 0 0 1px rgba(255,255,255,.95);display:flex;align-items:center;justify-content:center;color:#3c3c43}
.wingline{flex:none;height:44px;display:flex;align-items:center;justify-content:center;gap:18px;font:400 15px var(--sans);color:var(--meta);border-top:1px solid var(--line)}
.wingline b{font:600 17px var(--serif);color:var(--ink);display:flex;align-items:center;gap:6px}

.kb{flex:none;height:330px;background:#D9DCE2;border-radius:26px 26px 0 0;padding:6px 3px 0}
.kbs{height:40px;display:flex;align-items:center;font:400 17px var(--sans);color:#3c3c43}
.kbs span{flex:1;text-align:center}
.kr{display:flex;justify-content:center;gap:6px;margin-top:11px}
.k{width:33.5px;height:43px;border-radius:6px;background:#fff;font:400 22px var(--sans);display:flex;align-items:center;justify-content:center;box-shadow:0 1px 0 #9a9ca1;color:#000}
.k.d{background:#B6BAC3;width:44px;font-size:17px}
.k.s{width:186px}
.k.w{width:92px;font-size:16px;background:#B6BAC3}
.k.ret{background:var(--accent);color:#fff;font-weight:600}

.dim{position:absolute;inset:0;background:rgba(41,36,28,.22);z-index:5}
.menu{position:absolute;z-index:6;left:16px;top:112px;width:300px;border-radius:16px;background:var(--surface);box-shadow:0 12px 40px rgba(41,36,28,.28);overflow:hidden}
.menu .mi{height:48px;display:flex;align-items:center;gap:10px;padding:0 16px;font:400 17px var(--serif);border-bottom:1px solid #EEF3F0}
.menu .mi .ck{width:18px;color:var(--accent);font:600 16px var(--sans)}
.menu .mi .ct{margin-left:auto;font:400 14px var(--sans);color:var(--meta)}
.menu .mi.on{font-weight:600;background:var(--taketint)}
.menu .mi.act{font:500 16px var(--sans);color:var(--accent)}
.menu .mh{padding:10px 16px 6px;font:600 13px var(--sans);color:var(--meta);letter-spacing:.03em}

.zone{position:absolute;left:6px;right:6px;border:2px dashed #B4472F;border-radius:14px;z-index:4;pointer-events:none}
.zone span{position:absolute;right:6px;bottom:6px;width:24px;height:24px;border-radius:12px;background:#B4472F;color:#fff;font:700 14px/24px var(--sans);text-align:center;box-shadow:0 1px 4px rgba(0,0,0,.25)}
.zone.t span{bottom:auto;top:6px}
.zone.b{border-color:#2F5FA8}.zone.b span{background:#2F5FA8}
.n1,.n2{display:inline-block;width:20px;height:20px;border-radius:10px;color:#fff;font:700 13px/20px var(--sans);text-align:center;vertical-align:1px}
.n1{background:#B4472F}.n2{background:#2F5FA8}
.searchrow{flex:none;display:flex;gap:8px;align-items:center;margin:2px 16px 4px}
.searchrow .search{flex:1;margin:0}
.kbf{display:flex;justify-content:space-between;padding:14px 28px 0;font:400 26px var(--sans);color:#3c3c43}
.scrollbar{position:absolute;right:3px;top:30px;width:3px;height:120px;border-radius:2px;background:rgba(41,36,28,.28)}
"""

# ---------- icons (inline SVG, currentColor) ----------
I_SEARCH = '<svg width="20" height="20" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round"><circle cx="8.5" cy="8.5" r="5.5"/><path d="M13 13l4.5 4.5"/></svg>'
I_MORE = '<svg width="22" height="22" viewBox="0 0 22 22" fill="currentColor"><circle cx="5" cy="11" r="1.7"/><circle cx="11" cy="11" r="1.7"/><circle cx="17" cy="11" r="1.7"/></svg>'
I_BACK = '<svg width="20" height="20" viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12.5 4l-6 6 6 6"/></svg>'
I_PIN = '<svg class="pin" width="13" height="15" viewBox="0 0 13 15" fill="currentColor"><path d="M3.5 0h6l-.8 4.6 2.8 2.9H1.5l2.8-2.9L3.5 0z"/><rect x="6" y="7.5" width="1.1" height="7"/></svg>'
I_SORT = '<svg width="14" height="14" viewBox="0 0 14 14" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M4 2v10M4 12l-2.5-2.5M4 12l2.5-2.5M10 12V2M10 2L7.5 4.5M10 2l2.5 2.5"/></svg>'
I_TSTAR = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"><path d="M12 3.5l2.6 5.4 5.9.8-4.3 4.1 1 5.8L12 16.9l-5.2 2.7 1-5.8-4.3-4.1 5.9-.8L12 3.5z"/></svg>'
I_TBOOKS = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linejoin="round"><rect x="4" y="4" width="4.2" height="16" rx="1"/><rect x="9.9" y="4" width="4.2" height="16" rx="1"/><path d="M16 6.2l3.6-1 3 13.8-3.6 1z" transform="translate(-2 0)"/></svg>'
I_TLIST = '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round"><path d="M5 7h14M5 12h14M5 17h9"/></svg>'

WINGS = ["Home", "Work", "Fiction", "Research", "Family", "Health", "Side project", "Poetry", "Taxes 2025"]
WCOUNT = {"Home": "11 books", "Work": "5 books", "Fiction": "4 books", "Research": "3 books", "Family": "2 books",
          "Health": "1 book", "Side project": "2 books", "Poetry": "2 books", "Taxes 2025": "1 book"}

def esc(s): return html.escape(s, quote=False)

def sb():
    return '<div class="sb"><span class="time">9:41</span><span class="island"></span><span class="sbr"><i class="sig"></i><i class="wifi"></i><i class="bat"></i></span></div>'
def hi(): return '<div class="hi"></div>'
def phone(*parts): return '<div class="phone">' + sb() + ''.join(parts) + '</div>'

def mast(name, chev=True, buttons=('search', 'more')):
    b = ''.join('<span class="cbtn">%s</span>' % (I_SEARCH if x == 'search' else I_MORE) for x in buttons)
    c = '<span class="chev"></span>' if chev else ''
    return '<div class="mast"><div class="wingbtn"><span class="wname">%s</span>%s</div><div class="mbtns">%s</div></div>' % (esc(name), c, b)
def dots(on, centered=False):
    return '<div class="dots%s">%s</div>' % (' c' if centered else '', ''.join('<i%s></i>' % (' class="on"' if i == on else '') for i in range(9)))
def chips(items, on, fade=True, tail=''):
    out = ''.join('<span class="chip%s">%s</span>' % (' on' if i == on else '', x) for i, x in enumerate(items))
    return '<div class="chips%s">%s%s</div>' % (' fade' if fade and not tail else '', out, tail)
def brow(t, m, trail='', dim=False):
    tr = '<div class="tr">%s</div>' % trail if trail else ''
    return '<div class="brow%s"><div><div class="t">%s</div><div class="m">%s</div></div>%s</div>' % (' dim' if dim else '', esc(t), m, tr)
STAR = '<span class="star">★</span>'
FIN = '<span class="fin">✓</span>'
def badge(n): return '<span class="badge">%s</span>' % n
def lst(*rows): return '<div class="list">' + ''.join(rows) + '</div>'
def sec(label, n='', tap=False, state=''):
    return '<div class="sec%s"><span>%s%s</span><span class="n">%s</span></div>' % (' tap' if tap else '', label, (' <span class="n">· %s</span>' % n) if n and not tap else '', (n + ' ' + state) if tap else '')
def qe_rest(today=True, text='New note…'):
    t = '<div class="today">✎ Today</div>' if today else ''
    return '<div class="qe"><div class="qebox">%s</div>%s</div>' % (text, t)
def qe_typed(paras, minh=0):
    ps = ''.join('<p>%s</p>' % esc(p) for p in paras[:-1]) + '<p>%s<span class="caret"></span></p>' % esc(paras[-1])
    st = ' style="min-height:%dpx"' % minh if minh else ''
    return '<div class="qe"><div class="qebox typed"%s>%s</div></div>' % (st, ps)
def tabs_words(on, names=("Starred", "Bookcase", "Library")):
    return '<div class="tabs">%s</div>' % ''.join('<div class="tab%s"><span>%s</span></div>' % (' on' if i == on else '', n) for i, n in enumerate(names))
def tabs_iw(on):
    it = [(I_TSTAR, "Starred"), (I_TBOOKS, "Bookcase"), (I_TLIST, "Library")]
    return '<div class="tabs iw">%s</div>' % ''.join('<div class="tab%s">%s<span>%s</span></div>' % (' on' if i == on else '', ic, n) for i, (ic, n) in enumerate(it))
def tabs_sys(on):
    it = [(I_TSTAR, "Starred"), (I_TBOOKS, "Bookcase"), (I_TLIST, "Library")]
    cap = ''.join('<div class="sysitem%s">%s<span>%s</span></div>' % (' on' if i == on else '', ic, n) for i, (ic, n) in enumerate(it))
    return '<div class="systabs"><div class="syscap">%s</div><div class="syssearch">%s</div></div>' % (cap, I_SEARCH.replace('width="20" height="20"', 'width="24" height="24"'))
def kb(ret='return', accent=False):
    def row(keys, pre='', post=''):
        return '<div class="kr">%s%s%s</div>' % (pre, ''.join('<span class="k">%s</span>' % k for k in keys), post)
    r = ' ret' if accent else ''
    return ('<div class="kb"><div class="kbs"><span>I</span><span>The</span><span>I’m</span></div>'
            + row("qwertyuiop") + row("asdfghjkl")
            + row("zxcvbnm", '<span class="k d">⇧</span>', '<span class="k d">⌫</span>')
            + '<div class="kr"><span class="k w">123</span><span class="k s"></span><span class="k w%s">%s</span></div><div class="kbf"><span>☺</span><span style="font-size:20px">◉</span></div></div>' % (r, ret))
def zone(top, height, num, cls=''):
    return '<div class="zone %s" style="top:%dpx;height:%dpx"><span>%s</span></div>' % (cls, top, height, num)
N1 = '<span class="n1">1</span>'
N2 = '<span class="n2">2</span>'
def searchrow(place):
    return '<div class="searchrow"><div class="search">%s %s</div><span class="cbtn">%s</span></div>' % (I_SEARCH, place, I_SORT.replace('width="14" height="14"', 'width="18" height="18"'))
def opt(frame, oid, title, text, mine=False):
    return '<div class="opt">%s<div class="cap"><span class="id%s">%s</span><b>%s</b> %s</div></div>' % (frame, ' mine' if mine else '', oid, title, text)
def row(*opts): return '<div class="row">' + ''.join(opts) + '</div>'

LEGEND = """
<h2>Legend — the values these frames are drawn with</h2>
<p class="lede">Study voice under the sea-glass palette, light. Colours are the code's own: the voice's inks from
<code>App/Variorum/Shared/Theme/VoiceTokens.swift</code> (<code>studyLight</code>), the palette family computed by
<code>PaletteDerivation.derive</code> from the sea-glass seed <code>#C2DDD3</code> at the bold depth. Sizes are a
proposed phone layer over those tokens (work-list W-001); they are the proposal these sketches exist to test, not
values in the build.</p>
<table class="legend">
<tr><th>Token</th><th>Value</th><th>Where it comes from</th></tr>
<tr><td><span class="sw" style="background:#E5F0EC"></span>room</td><td>#E5F0EC</td><td>sea-glass, derived (bold: L .920, S ≤ .75) — the bars: masthead, chips, capture box, tabs</td></tr>
<tr><td><span class="sw" style="background:#FFFFFF"></span>surface · card</td><td>#FFFFFF</td><td>Study light keeps its own paper under a palette — the lists sit on it, as the Mac's Bookcase column does</td></tr>
<tr><td><span class="sw" style="background:#CBE2D9"></span>wash · line</td><td>#CBE2D9</td><td>sea-glass, derived (selected chip, hairlines)</td></tr>
<tr><td><span class="sw" style="background:#B7D7CB"></span>takeLine</td><td>#B7D7CB</td><td>sea-glass, derived (the capture box's dashed edge, chip outline)</td></tr>
<tr><td><span class="sw" style="background:#3B6A59"></span>accent</td><td>#3B6A59</td><td>sea-glass deepened until it clears 4.5:1 on room and wash (5.3 / 4.6)</td></tr>
<tr><td><span class="sw" style="background:#29241C"></span>ink</td><td>#29241C</td><td>Study light (13.2:1 on the room)</td></tr>
<tr><td><span class="sw" style="background:#8D8578"></span>muted</td><td>#8D8578</td><td>Study light — 3.1:1 on this room, so not used for text here</td></tr>
<tr><td><span class="sw" style="background:#6A6359"></span>meta ink (proposed)</td><td>#6A6359</td><td>not a token today: the corrected muted from <code>sizing-sheet.html</code> (about 5:1 on the room, 5.9:1 on paper), for previews, stamps and meta (W-004)</td></tr>
<tr><td><span class="sw" style="background:#3D6B8E"></span>star</td><td>#3D6B8E</td><td>Study light (the star stays the voice's blue)</td></tr>
<tr><td><span class="sw" style="background:#5A7D46"></span>positive</td><td>#5A7D46</td><td>Study light (finished ✓, saved)</td></tr>
</table>
<table class="legend">
<tr><th>Text</th><th>Face and size</th><th>Today (Study)</th></tr>
<tr><td>Wing / screen title</td><td>Iowan Old Style 24 semibold</td><td>11.5 pt sans "path line"</td></tr>
<tr><td>Row title (book, note)</td><td>Iowan Old Style 17 semibold, line 22</td><td>Iowan 16</td></tr>
<tr><td>Preview line · capture text</td><td>Iowan 15 (her words stay in her face) · the capture box types in Iowan 17</td><td>no preview · capture text 11.5</td></tr>
<tr><td>Meta, stamps, section labels</td><td>SF 13 (the stamp inside a preview line, SF 14 medium)</td><td>11.5</td></tr>
<tr><td>Chips · tabs and buttons</td><td>SF 15 · SF 17</td><td>11.5</td></tr>
</table>
<table class="legend">
<tr><th>Touch</th><th>Drawn</th><th>Today</th></tr>
<tr><td>List rows</td><td>62–80 pt tall, the whole row one target</td><td>37–39 pt</td></tr>
<tr><td>Round and capsule buttons</td><td>44 pt</td><td>14 pt-tall words</td></tr>
<tr><td>Chips</td><td>40 pt tall in a 56 pt row; the hit area is the row's height</td><td>21–56 × 14 pt</td></tr>
<tr><td>Tab bar</td><td>56 pt, three 134 pt-wide targets</td><td>35–50 × 14 pt</td></tr>
<tr><td>Capture box at rest</td><td>52 pt</td><td>about 34 pt</td></tr>
</table>
<p class="lede">The type sizes are the five in <code>sketches/sizing-sheet.html</code> (13 · 15 · 17 · 20 · 24) so every sketch for the sitting is one system. The shelf and filter chips keep the Mac strip's near-square shape at 40 pt; the sizing sheet's 32 pt capsule is for a note's facts. The fonts fall back to Palatino or Georgia where Iowan Old Style is not installed. Frames are 402 × 874 pt
(iPhone 17 Pro), one CSS pixel to the point. Dashed red and blue outlines are annotations, not part of the design.</p>
"""

def page(fname, title, intro, body, where=OUT):
    doc = ('<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">'
           '<title>%s</title><style>%s</style></head><body><h1>%s</h1>%s%s%s</body></html>') % (esc(title), CSS, esc(title), intro, body, LEGEND)
    with open(os.path.join(where, fname), 'w') as f: f.write(doc)
    print(os.path.join(where, fname), len(doc))

# ---------- shared content ----------
T_TODAY = '<span class="pill" style="height:36px;padding:0 12px;font-size:14px">✎ Today</span>'
HOME_WRITING = [brow("Essays", "8 notes · #essay #goals", STAR), brow("Blog drafts", "7 notes · #blog #draft"),
                brow("Letters", "3 notes · finished", FIN), brow("Ideas inbox", "3 notes · 3 waiting", badge(3))]
HOME_READING = [brow("Reading notes", "6 notes · #reading"), brow("Quotes", "gathers #quote · 6 notes"), brow("Sources", "5 notes · #source")]
HOME_LIFE = [brow("Journal", "13 entries · daily", STAR), brow("Recipes", "5 notes · #recipe"), brow("Lisbon trip", "4 entries · #travel"), brow("Running log", "4 entries · #run")]
HOME_UNSH = [brow("Holidays", "2 notes"), brow("Kids’ sayings", "4 notes")]
HOME_CHIPS = ["★ Starred", "Unshelved", "✎ Writing", "Reading &amp; reference", "☼ Life", "Welcome", "All"]
WORK_ROWS = [brow("Product specs", "4 notes · #spec", STAR), brow("Meeting notes", "8 notes · #meeting #q4"),
             brow("Interview transcripts", "3 notes · #interview"), brow("App ideas", "2 notes"), brow("Ideas inbox", "2 notes · #idea")]
WORK_CHIPS = ["★ Starred", "Unshelved", "Projects", "All"]

def wing_menu(on):
    rows = ''.join('<div class="mi%s"><span class="ck">%s</span>%s<span class="ct">%s</span></div>' %
                   (' on' if i == on else '', '✓' if i == on else '', esc(w), WCOUNT[w]) for i, w in enumerate(WINGS))
    return ('<div class="dim"></div><div class="menu"><div class="mh">Wings — each a separate library</div>%s'
            '<div class="mi act">New wing…</div><div class="mi act" style="border:0">Manage wings…</div></div>') % rows

# =====================================================================
# SW-1
# =====================================================================
def sw1():
    a = phone(mast("Work"), dots(1), chips(WORK_CHIPS, 2), lst(*WORK_ROWS), qe_rest(), tabs_words(1), hi(),
              zone(56, 78, "1"),
              zone(192, 518, "2", 'b'))
    b = phone(mast("Bookcase", chev=False), chips(WORK_CHIPS, 2), lst(*WORK_ROWS), qe_rest(),
              '<div class="wingline"><span>‹ Home</span><b>Work <span class="chev"></span></b><span>Fiction ›</span></div>',
              tabs_words(1), hi(),
              zone(738, 104, "1", 't'),
              zone(114, 550, "2", 'b'))
    c = phone(mast("Work"), dots(1), chips(WORK_CHIPS, 2), lst(*WORK_ROWS), qe_rest(), tabs_words(1), hi(),
              zone(56, 660, "1"),
              zone(782, 60, "2", 'b'))
    d = phone(mast("Work"), dots(1), chips(WORK_CHIPS, 2), lst(*WORK_ROWS), qe_rest(), tabs_words(1), hi(), wing_menu(1))
    lib_rows = [nrow("Spec — export subset", "1:02 pm", "Export only what the reader can see, and say what was left out.", "Product specs", star=True),
                nrow("Weekly sync", "Mon", "Agenda: the release pass, who owns the importer, the Q4 list.", "Meeting notes"),
                nrow("Faster cold start", "Mon", "Measure first. The store opens off the main thread already, so…", "Ideas inbox"),
                nrow("Expense report reminder", "Sun", "Hotel, two dinners, the train back. Receipts are in the blue folder.", "No book"),
                nrow("1:1 with D.", "Oct 15", "Wants a smaller team and a longer runway; asked about the phone app.", "Meeting notes")]
    e = phone(mast("Work", buttons=('more',)), dots(1), searchrow("Search Work"),
              chips(["All", "Notes", "Books", "Bookless", "Scraps"], 1),
              lst(*lib_rows), qe_rest(today=False), tabs_words(2), hi(),
              zone(56, 78, "1"))
    intro = """
<p class="lede"><b>SW-1 — how a quick wing swipe and a dropdown for nine wings live beside the Starred · Shelf · Library swipe.</b>
Today the phone has no wings at all; every wing's books and notes show in one bunch. The three frames below are the three
options in the questions file, each drawn on the Work wing's Bookcase (wing 2 of 9). The dropdown is the same in all three and is drawn once, underneath.</p>
<p class="q">“I have 9, so UI options should work well with many. a quick swipe between them and also a dropdown option would be nice.”</p>
"""
    body = row(
        opt(a, "SW-1 (a)", "The wing is the masthead.", N1 + " The wing's name is the screen's title: swipe that band to step Home ‹ Work › Fiction, tap the name for all nine; the dots show where you are. " + N2 + " The page below keeps today's swipe between Starred, Bookcase and Library. Costs: the wing swipe is at the top of a tall phone, a stretch for one hand, and two horizontal swipes on one screen have to be learned by where the finger starts.", mine=True),
        opt(b, "SW-1 (b)", "The wing rides the bottom bar.", N1 + " A wing line sits on top of the tab bar, in the thumb's reach: swipe the bottom bar to step wings, tap the name for all nine. " + N2 + " The page keeps the root swipe. Costs: three bars stack at the foot once the capture box is there (158 pt becomes 202 pt of chrome), a swipe that starts on a tab is easy to fumble into a tap, and nothing at the top says which wing you are in."),
        opt(c, "SW-1 (c)", "The whole screen swipes wings.", N1 + " Swipe anywhere to step Home ‹ Work › Fiction; tap the name for all nine. " + N2 + " The three roots become taps. The biggest and most findable gesture, the one every paged phone app teaches. Cost: the root swipe she asked for earlier goes away; Starred, Bookcase and Library become taps on the bar (now 56 pt tall, so the taps are easy)."),
    ) + '<h2>The dropdown, and the band on another root</h2>' + row(
        opt(d, "all options", "The dropdown for nine.", "Tapping the wing's name opens one menu: nine 48 pt rows with each wing's size, the current one marked, and the two management doors at the foot. It fits the screen without scrolling up to about thirteen wings; past that it scrolls. This is the jump; the swipe is for neighbours."),
        opt(e, "SW-1 (a)", "The same band on the Library.", N1 + " Under (a) the wing band is the masthead of all three roots, so the Library and its search are visibly scoped (“Search Work”); the sort door sits beside the field. The capture box rides here too, as on the Mac."),
    ) + """
<div class="pick"><h2>My pick: (a), the wing as the masthead</h2>
<p>It is the only option that keeps both things she has asked for: the root swipe she already has and uses, and a quick wing swipe.
It also fixes a second problem for free — today no root has a real title — by making the wing's name the title of every root,
which is what tells her at a glance why a list is short. The dots make nine wings legible without a second strip of chrome above the shelf chips.</p>
<p>What would change my mind: if she says at the sitting that she rarely swipes between Starred, Bookcase and Library now that the bar is tappable,
(c) is the better gesture — larger, in reach, and the one a new user finds without being told. (b) I would not build: it spends the most chrome where the capture box needs the room.</p></div>
"""
    page('SW-1-wing-swipe.html', 'SW-1 — the wing swipe and the dropdown', intro, body)

# ---------- note rows ----------
def nrow(title, stamp, preview, where=None, star=False, pin=False):
    p = I_PIN if pin else ''
    s = STAR if star else ''
    w = '<div class="nw">%s</div>' % esc(where) if where else ''
    return '<div class="nrow"><div class="nt">%s<span class="x">%s</span>%s</div><div class="np"><b>%s</b>%s</div>%s</div>' % (p, esc(title), s, esc(stamp), esc(preview), w)
def ncard(title, stamp, preview, where, star=False):
    s = STAR if star else ''
    return '<div class="ncard"><div class="nt"><span class="x">%s</span>%s</div><div class="np2">%s</div><div class="nf"><span>%s</span><span>%s</span></div></div>' % (esc(title), s, esc(preview), esc(where), esc(stamp))

LIB = [
    ("Walk note: the ferry timetable changes in December", "2:14 pm", "and the morning boat now leaves at seven forty. Tell M. before Friday.", "No book", False),
    ("On keeping a commonplace book", "1:02 pm", "I started copying sentences into a notebook the winter I stopped trusting my memory for them.", "Essays", True),
    ("Thursday 12 November", "8:40 am", "Slept badly. The heron was back on the jetty before seven, standing like a question mark.", "Journal", False),
    ("The case for slow mornings", "Yesterday", "Nothing good was ever decided before the second coffee, and I have the minutes to prove it.", "Essays", False),
    ("Grocery list", "Tue", "Oat milk, lemons, the good butter, stamps, something for the neighbour with the piano.", "No book", True),
    ("Tuesday 10 November", "Tue", "10 km along the river path. Left knee fine until the bridge, then not.", "Journal", False),
    ("Untitled", "Mon", "No text yet", "No book", False),
    ("Write the bread recipe as a poem", "Nov 7", "Flour, water, salt, patience. The last one is the only ingredient that is not sold.", "No book", False),
]
LIB_CHIPS = ["All", "Notes", "Books", "Bookless", "Scraps"]

def ls1():
    head = lambda tail: (mast("Home", buttons=('more',)) + searchrow("Search Home") + chips(LIB_CHIPS, 1))
    sort = '<span class="sortbtn">%s Edited</span>' % I_SORT
    a = phone(head(sort), lst('<div style="height:6px"></div>', *[ncard(t, s, p, w, st) for t, s, p, w, st in LIB]), qe_rest(today=False), tabs_words(2), hi())
    b = phone(head(sort), lst(*[nrow(t, s, p, w, st) for t, s, p, w, st in LIB]), qe_rest(today=False), tabs_words(2), hi())
    c = phone(mast("Home", buttons=('more',)) + searchrow("Search Home") + chips(LIB_CHIPS, 1)
              + '<div class="chips" style="height:48px"><span style="font:400 14px var(--sans);color:var(--meta);padding-left:4px">64 notes · edited</span><span class="seg"><span class="on">List</span><span>Cards</span></span></div>',
              lst(*[nrow(t, s, p, w, st) for t, s, p, w, st in LIB]), qe_rest(today=False), tabs_words(2), hi())
    # book contents
    def bookhead(name, meta, right):
        return ('<div class="nav"><span class="cbtn">%s</span><div class="r">%s</div></div><div class="btitle">%s</div><div class="sub">%s</div>'
                % (I_BACK, right, esc(name), meta))
    R = '<span class="pill">Read</span><span class="cbtn">%s</span>' % I_MORE
    foot = '<div class="qe"><div class="qebox">New note in this book…</div></div>'
    lk = phone(bookhead("The Lighthouse Keeper", "9 notes · 3 chapters · #draft #setting", R),
               lst(sec("Part one — the island", "3"),
                   nrow("The keeper wakes", "Nov 9", "Elias wakes before the lamp does, as he has every morning for thirty years.", pin=True),
                   nrow("The logbook", "Nov 8", "Wind NNW, force 6. Lamp trimmed at dusk. Nothing to report, which he reports."),
                   nrow("Supply day", "Nov 3", "The boat comes on the second Tuesday, weather allowing, and weather rarely allows."),
                   sec("Part two — the storm", "3"),
                   nrow("The night of the storm", "Nov 11", "Ryder passed his tongue over his parched lips. “I will tell you it just as it happened, sir.”", star=True),
                   nrow("The letter", "Oct 28", "It had been folded and unfolded so many times the creases had gone soft as cloth."),
                   nrow("Barometer", "Oct 22", "Falling since noon."),
                   sec("Part three — the relief boat", "3"),
                   nrow("Morning after", "Oct 21", "The sea had the nerve to be calm.")),
               foot, hi())
    JR = '<span class="pill fill">✎ Today</span><span class="cbtn">%s</span>' % I_MORE
    jfoot = '<div class="qe"><div class="qebox">New entry…</div></div>'
    J = [("Thursday 12 November", "9:15 pm", "Second entry. The ferry timetable changes in December; wrote it down twice."),
         ("Thursday 12 November", "8:40 am", "Slept badly. The heron was back on the jetty before seven, standing like a question mark."),
         ("Wednesday 11 November", "7:55 am", "Rain on the skylight. Finished the Montaigne chapter and understood half."),
         ("Tuesday 10 November", "6:30 pm", "10 km along the river path. Left knee fine until the bridge, then not."),
         ("Sunday 8 November", "10:02 am", "M. called about the move. Said yes before I had thought about it."),
         ("Friday 6 November", "8:11 am", "No coffee in the house. A short entry, and a resentful one."),
         ("Wednesday 4 November", "9:47 pm", "Physio says rest. I say eight easy kilometres is rest."),
         ("Monday 2 November", "7:20 am", "First frost. The jetty boards rang like a xylophone.")]
    jd = phone(bookhead("Journal", "14 entries · daily · #health", JR),
               lst(sec("November 2026"), *[nrow(d, t, p) for d, t, p in J]), jfoot, hi())
    JW = [(p, d.split(' ', 1)[1].replace('November', 'Nov') + ', ' + t) for d, t, p in J]
    def wrow(words, stamp):
        return '<div class="nrow"><div class="nt"><span class="x">%s</span></div><div class="np">%s</div></div>' % (esc(words), esc(d_short(stamp)))
    def d_short(s): return s
    DAYS = ["Thu", "Thu", "Wed", "Tue", "Sun", "Fri", "Wed", "Mon"]
    jw = phone(bookhead("Journal", "14 entries · daily · #health", JR),
               lst(sec("November 2026"), *[wrow(w, DAYS[i] + ' ' + s) for i, (w, s) in enumerate(JW)]), jfoot, hi())
    intro = """
<p class="lede"><b>LS-1 — the note row, with a preview.</b> Today a Library row is one line: the stored title or, for every quick note and journal entry,
a raw date like “2026-11-12”, sometimes printed twice. Five of the first eight rows in the seeded Library read only that date. The three frames show the
same eight notes from the Home wing under each option — a named note, an untitled quick note, two journal entries and an empty note among them.</p>
<p class="q">“showing preview more lot apple notes so i know what each note is.”</p>
"""
    body = row(
        opt(a, "LS-1 (a)", "Cards.", "Title, two preview lines, then where it lives and when. The most words per note and the closest to the Mac's Cards. Cost: about four notes on a screen where the list shows five or six, and a boxed look that is busier than the Library has ever been."),
        opt(b, "LS-1 (b)", "A list, Apple Notes' own row.", "Title; then the stamp and one line of the note's words; then where it lives. Five or six notes per screen, no boxes, the same hairline list as the Bookcase. Cost: one line of preview is roughly forty characters, which may be thin for telling two journal entries apart.", mine=True),
        opt(c, "LS-1 (c)", "A List / Cards toggle.", "Both faces, as on the Mac (the Cards face is frame (a)). Cost: a second control row under the filters (48 pt gone before the first note), two faces to build and keep in step, and a choice she has to make before she can read."),
    ) + """
<h2>How untitled notes and journal entries read</h2>
<p class="lede">The rule is the one the Mac already has in core (<code>NoteCardFace</code>), so the phone forks nothing:
a note she named leads with its name; an unnamed note leads with its own first words and previews what follows (row 1 above);
a journal entry leads with its day and previews its first words (rows 3 and 6); a note with no words says “Untitled · No text yet” (row 7).
Stamps use the Mac's time words — a clock time today, then “Yesterday”, a weekday, a date — never the raw day key.</p>
<h2>The same row in a book's contents</h2>
""" + row(
        opt(lk, "LS-1 (b) in a book", "A chaptered book.", "The same row without its third line — inside a book, the book's name is the screen's title. Chapters are section labels with their counts; a pinned note wears the muted pin (BK-4 (a)); the foot carries the book's own capture box, so “new note” is never the last row of a long list."),
        opt(jd, "book list (ii)", "The Journal — the day leads.", "Core's rule today: the entry's day is its name, and the second line carries the time and the first words. Reads as a calendar; two entries on one day are told apart by time and preview. Cost: the bold column is all dates, so the eye has to drop to the second line for meaning.", mine=True),
        opt(jw, "book list (i)", "The Journal — the first words lead.", "The Library's unnamed-note rule applied to entries: the words are the name and the day drops to the meta line (the orchestrator's lean). Cost: the bold column no longer scans as dates, a long first sentence truncates, and it departs from the rule the Mac's core already applies to journal entries."),
    ) + """
<div class="pick"><h2>My pick: (b), one list face, with the day leading journal entries</h2>
<p>She named Apple Notes, and this is its row: a bold name, then a stamp and a line of the note's own words. It answers “so i know what each note is”
for every case in the seeded Library, keeps five or six notes on screen, and uses the same row anatomy as the Bookcase and a book's contents, so the
four different note rows the phone has today collapse into one. No toggle: one face is calmer and is half the work.</p>
<p>The one dial I would leave open for her phone: if a single preview line proves thin, the same row takes a second line (four or five notes per screen)
without any other change. For journal entries I would keep the day as the lead, in the Library and in the Journal alike — it is what the shared rule
already does on the Mac, and a journal reads as a calendar; the preview line is what tells the days apart.</p></div>
"""
    page('LS-1-note-rows.html', 'LS-1 — note rows with a preview', intro, body)

# =====================================================================
# BK-1
# =====================================================================
def bk1():
    newbook = '<div class="addrow">+ New book on Writing</div>'
    a = phone(mast("Home"), dots(0), chips(HOME_CHIPS, 2), lst(*HOME_WRITING, newbook), qe_rest(), tabs_words(1), hi())
    a_all = phone(mast("Home"), dots(0), chips(["Reading &amp; reference", "☼ Life", "Welcome", "All"], 3, fade=False).replace('class="chips"', 'class="chips" style="justify-content:flex-end"'),
                  lst(sec("Unshelved", "2"), *HOME_UNSH, sec("✎ Writing", "4"), *HOME_WRITING, sec("Reading &amp; reference", "3"), *HOME_READING[:1]),
                  qe_rest(), tabs_words(1), hi())
    b = phone(mast("Home"), dots(0),
              lst(sec("Unshelved", "2", tap=True, state="⌄"), *HOME_UNSH,
                  sec("✎ Writing", "4", tap=True, state="⌄"), *HOME_WRITING,
                  sec("Reading &amp; reference", "3", tap=True, state="›"),
                  sec("☼ Life", "4", tap=True, state="⌄"), *HOME_LIFE[:2]),
              qe_rest(), tabs_words(1), hi())
    def shelf(tile, name, n, names):
        return '<div class="shelfrow"><div class="tile">%s</div><div><div class="t">%s</div><div class="m">%s · %s</div></div><span class="go">›</span></div>' % (tile, name, n, names)
    c = phone(mast("Home"), dots(0),
              lst(shelf("★", "Starred", "2 books", "Journal, Essays"),
                  shelf("✎", "Writing", "4 books", "Essays, Blog drafts, Letters, Ideas inbox"),
                  shelf("R", "Reading &amp; reference", "3 books", "Reading notes, Quotes, Sources"),
                  shelf("☼", "Life", "4 books", "Journal, Recipes, Lisbon trip, Running log"),
                  shelf("W", "Welcome", "1 book", "The Prince"),
                  shelf("–", "Unshelved", "2 books", "Holidays, Kids’ sayings"),
                  shelf("≡", "All books", "11 books", "every shelf, stacked"),
                  '<div class="addrow">+ New shelf</div>'),
              qe_rest(), tabs_words(1), hi())
    c2 = phone('<div class="nav"><span class="cbtn">%s</span><div class="r"><span class="cbtn">%s</span></div></div><div class="btitle">✎ Writing</div><div class="sub">Home · 4 books</div>' % (I_BACK, I_MORE),
               lst(*HOME_WRITING, newbook), qe_rest(), tabs_words(1), hi())
    intro = """
<p class="lede"><b>BK-1 — the Bookcase's phone shape, inside one wing.</b> Today the phone has no shelves: 23 books from nine wings sit in one flat list,
“Ideas inbox” twice, and “+ New Book” is the last row, hidden under the capture box. These frames show the Home wing's eleven books on its
shelves (Writing, Reading &amp; reference, Life, Welcome) plus the starred shelf, Unshelved and All. The 13i sitting ruled “the Bookcase/shelf strip as a list” but not the form.</p>
<p class="lede">Book rows are the same in every option: a 64 pt row, the name in Iowan 17, one meta line, and at most one mark at the trailing edge
(the star, the finished ✓, or the count of arrivals waiting).</p>
"""
    body = row(
        opt(a, "BK-1 (a)", "A chip row of shelves, one shelf at a time.", "The Mac's strip at phone size: quiet chips, the solo'd one filled, scrolling sideways with a fade. The screen shows one shelf's books and nothing else — the calmest home. Cost: the strip grows with shelves and the later chips are off-screen; a book on another shelf is two taps away (chip, then book).", mine=True),
        opt(b, "BK-1 (b)", "One list, shelves as headers.", "Everything in the wing in one scroll, each shelf a 48 pt header that folds; tap a header to fold or solo. Nothing is hidden behind a chip. Cost: with eleven books it is already two screens long, the header rows add up, and there is no starred shelf unless it becomes a section too."),
        opt(c, "BK-1 (c)", "Two levels: shelves, then books.", "The Bookcase is a short list of shelves, each naming its first books; tapping one pushes that shelf. The tidiest first screen and the most room per shelf. Cost: every book is one more tap and one more back away, every time."),
    ) + '<h2>What the other state of each looks like</h2>' + row(
        opt(a_all, "BK-1 (a) · All", "The chip row with “All” chosen.", "All stacks the shelves in strip order with Unshelved first, as the Mac rules it — which is option (b)'s list, minus the folding. So (a) contains (b): she picks solo or All per wing, and the phone remembers."),
        opt(c2, "BK-1 (c) · pushed", "A shelf, pushed.", "The second level of (c). It is the same list as (a)'s solo, reached by a push instead of a chip; the shelf's own menu (rename, glyph, delete) lives in the round button."),
    ) + """
<div class="pick"><h2>My pick: (a), the chip row, solo by default with All as the last chip</h2>
<p>It is the Mac's Bookcase read aloud on a phone — the same strip, the same solo-and-All rule, the same starred shelf leading — so the two devices teach each other.
It is also the calmest answer to “everything just shows up in one bunch”: one wing, one shelf, four or five books, room to breathe.
And because All is just the last chip, nobody who wants (b)'s one long list loses it.</p>
<p>Two things the strip needs to be honest on a phone: the row is 56 pt tall so a chip is a real target, and the strip scrolls back to show the solo'd chip
whenever the screen appears. “New book” is a row at the end of the shelf it will land on and an entry in the round menu, never a row hidden under the capture box.</p></div>
"""
    page('BK-1-bookcase.html', 'BK-1 — the Bookcase on the phone', intro, body)

# =====================================================================
# SW-3 (+ SW-4, LK-5)
# =====================================================================
def sw3():
    ALL_LIST = [sec("Unshelved", "2"), *HOME_UNSH, sec("✎ Writing", "4"), *HOME_WRITING, sec("Reading &amp; reference", "3"), *HOME_READING]
    # (a) R27 kept
    a_rest = phone(mast("Home"), dots(0), chips(HOME_CHIPS, 2), lst(*HOME_WRITING, '<div class="addrow">+ New book on Writing</div>'),
                   qe_rest(today=False, text='New note — tap to write'), tabs_words(1), hi())
    a_focus = phone(mast("Home"), chips(HOME_CHIPS, 2),
                    '<div class="list" style="flex:none;height:193px">%s<div class="scrollbar"></div></div>' % ''.join(HOME_WRITING),
                    qe_typed(["Walk note: the ferry timetable changes in December"], minh=113),
                    '<div class="qact"><span class="saved">✓ Saved</span><span class="pill fill">Open ↵</span></div>',
                    kb('go'),
                    zone(362, 124, "1", 't'))
    b_rest = phone(mast("Home"), dots(0), chips(HOME_CHIPS, 2), lst(*HOME_WRITING, '<div class="addrow">+ New book on Writing</div>'),
                   qe_rest(), tabs_words(1), hi())
    b_focus = phone(mast("Home"), chips(HOME_CHIPS, 2), lst(*HOME_WRITING[:3]),
                    qe_typed(["Walk note: the ferry timetable changes in December"]),
                    '<div class="qact"><span class="dest">to Home · no book</span><span class="pill">File</span><span class="pill fill">Open</span></div>',
                    kb('return'))
    c_few = phone(mast("Poetry"), dots(7), chips(["★ Starred", "Unshelved", "All"], 2, fade=False),
                  lst(brow("Drafts", "6 notes · #draft"), brow("Finished poems", "3 notes · finished", FIN)),
                  '<div class="qe"><div class="qebox" style="min-height:300px;align-items:flex-start;padding-top:14px">New note — tap to write</div></div>',
                  tabs_words(1), hi())
    # SW-4
    two = ["Walk note: the ferry timetable changes in December.", "Morning boat now leaves at seven forty — tell M. before Friday."]
    s4a = phone(mast("Home"), chips(HOME_CHIPS, 2), lst(*HOME_WRITING[:2]),
                qe_typed(two),
                '<div class="qact"><span class="dest">to Home · no book</span><span class="pill">File</span><span class="pill fill">Open</span></div>',
                kb('return'))
    s4b = phone(mast("Home"), chips(HOME_CHIPS, 2), lst(*HOME_WRITING[:3]),
                qe_typed(["Walk note: the ferry timetable changes in December. Morning boat now leaves at seven forty — tell M. before Friday."]),
                '<div class="qact"><span class="saved">✓ Saved</span><span class="pill fill">Open ↵</span></div>',
                kb('go', accent=True))
    s4c = phone(mast("Home"), chips(HOME_CHIPS, 2), lst(*HOME_WRITING[:3]),
                '<div class="receipt"><span>Filed to Home — “Walk note: the ferry…”</span><b>Open ›</b></div>',
                '<div class="qe"><div class="qebox">New note…<span class="caret"></span></div></div>',
                '<div class="qact"><span class="dest">to Home · no book</span><span class="pill" style="opacity:.45">Open</span></div>',
                kb('done', accent=True))
    # LK-5
    def home_with(bar): return phone(mast("Home"), dots(0), chips(HOME_CHIPS, 2), lst(*HOME_WRITING, '<div class="addrow">+ New book on Writing</div>'), qe_rest(), bar, hi())
    l5a = home_with(tabs_words(1))
    l5b = home_with(tabs_iw(1))
    l5c = home_with(tabs_sys(1))
    intro = """
<p class="lede"><b>SW-3 — the home screen once wings and shelves arrive</b>, with <b>SW-4</b> (how the capture box files and makes paragraphs) and
<b>LK-5</b> (the tab bar's form) folded in, because the three share the bottom third of the screen. Today the capture box is a 34 pt dashed outline
with 11.5 pt text; the book list runs underneath it with a row sliced through; focused, it becomes a half-screen dashed rectangle with the tab bar
wedged between it and the keyboard; and Return opens the note, losing any words typed during the hand-off.</p>
<p class="q">“the box looks awkward” · “There's significant lag when going to the quick entry box, when going from the quick entry box into a note”</p>
<p class="lede">Every frame uses the wing masthead from SW-1 (a) and the shelf chips from BK-1 (a) so the home screen is judged whole. In every option
the tab bar leaves while the keyboard is up, the text she types is 17 pt, and the buttons stand by themselves with no band behind them
(“rather than just hte buttons themsleves”).</p>
<h2>SW-3 — at rest and focused</h2>
"""
    body = row(
        opt(a_rest, "SW-3 (a) · rest", "R27 kept: the bounded Bookcase.", "The books scroll inside their own region between the fixed masthead and a one-line box, as ruled. At rest it differs little from (b): about eight rows show at phone-right sizes where fourteen show today, which is plenty with one shelf solo'd and a small window when All is chosen."),
        opt(a_focus, "SW-3 (a) · focused", "R27 kept: the half-screen writing area.", N1 + " Tapping the box hands it half of what the keyboard leaves, however little is typed: a roomy page straight away. Cost: for a one-line note it is a large empty dashed rectangle, and the Bookcase shrinks to three rows behind its own scroll bar. This is today's shape, drawn at its best."),
        opt(b_rest, "SW-3 (b) · rest", "The Bookcase gets the screen.", "One scroll for the whole Bookcase; the capture box is a 52 pt field at the foot, the Mac's own posture. The journal's Today door sits beside it so it is in reach on any shelf (my addition — not ruled).", mine=True),
        opt(b_focus, "SW-3 (b) · focused", "The box grows with the words.", "Focused, the box is as tall as what is typed — one line here, up to about six before it scrolls — so the Bookcase stays in view above it. Cost: a long first thought starts in a small field, and R27 is a ruling this reverses.", mine=True),
        opt(c_few, "SW-3 (c)", "Split by how full the wing is.", "A wing with few books (Poetry has two) gives the spare room to the writing area; a full shelf falls back to (b). Cost: two layouts to build and keep, and the home screen looks different from wing to wing as she swipes."),
    ) + """
<h2>SW-4 — what Return does in the box, and its buttons</h2>
<p class="lede">Drawn on (b). Her lost-prose words: “we need full multi line editing clearly or some other solution because this was not it.”
The keyboard's own key is labelled as iOS would label it in each case.</p>
""" + row(
        opt(s4a, "SW-4 (a)", "Return makes a paragraph; two buttons file.", "Return is only ever a new line, so nothing she types can be swallowed by a hand-off. “File” saves the note and clears the box for the next one; “Open” saves and opens it in Write. The line at the left says where it will land. Cost: filing is a reach to a button rather than the Return key.", mine=True),
        opt(s4b, "SW-4 (b)", "Return files and opens (today).", "One key does everything, and the Return key says “go”. Cost: the box can only ever hold one paragraph, and this is the shape whose hand-off dropped her words and froze for about 0.7 s in the recording."),
        opt(s4c, "SW-4 (c)", "Return files and stays.", "Return files the note, clears the box and leaves a receipt with an Open door; good for a burst of separate thoughts. Cost: still one paragraph per note, and a slip of the thumb files a half sentence."),
    ) + """
<h2>LK-5 — the tab bar's form</h2>
<p class="lede">Today: three 11.5 pt words whose tap areas are about 14 pt tall, hidden on every pushed screen. All three options below are 56 pt or taller with full-width targets.</p>
""" + row(
        opt(l5a, "LK-5 (a)", "Words only, at a real size.", "The Mac's mode row on a phone: 17 pt words, the current one on a wash chip, three 134 × 56 pt targets. Reads as Variorum and nothing else. Cost: no icons to catch a glancing eye, and its behaviours (hiding, large-text, VoiceOver) are ours to build.", mine=True),
        opt(l5b, "LK-5 (b)", "Icons and words.", "The usual phone bar, drawn in the Study voice: three glyphs with 13 pt labels, 64 pt tall. Easier to hit without reading. Cost: three icons to design that mean Starred, Bookcase and Library, and a busier foot beside the capture box."),
        opt(l5c, "LK-5 (c)", "The system's tab bar.", "iOS 26's floating glass capsule, with its separate search button. Free: large-text support, accessibility, hiding on scroll, a system-standard search door. Cost: glass and SF icons are not the Mac's Study look, the labels are the system's 10 pt, and it floats over the capture box rather than sitting under it."),
    ) + """
<div class="pick"><h2>My picks: SW-3 (b), SW-4 (a), LK-5 (a)</h2>
<p><b>SW-3 (b).</b> The box is awkward today because it is two things at once — a thin outline that the list runs under, then a half-screen void. As a 52 pt field at the
foot that grows with the words it is one thing, it is the Mac's own posture, and the Bookcase (now with shelves to show) keeps the screen.
I would keep one piece of R27's intent: when she is clearly writing something long — past about six lines — offer “Open” more loudly rather than making the box taller.</p>
<p><b>SW-4 (a).</b> It is the only option in which Return can never cost her words, and it gives the phone the multi-paragraph box she asked for. “File” and “Open”
are the Mac's ⌘⏎ and ⏎ as two plain buttons. It also removes the worst moment of the lag from the common case: filing without opening never mounts the editor.</p>
<p><b>LK-5 (a).</b> Her direction is the Mac's look; the Mac's navigation is words on a quiet chip. At 17 pt in a 56 pt bar the words stop being tiny without becoming a different app.
If she wants the system's search button from (c), it fits in the masthead's round buttons instead.</p></div>
"""
    page('SW-3-home-screen.html', 'SW-3 — the home screen, with SW-4 (the capture box) and LK-5 (the tab bar)', intro, body)

# =====================================================================
# shell directions (the brief's item for grader 1)
# =====================================================================
def shell():
    d1 = phone(mast("Home"), dots(0), chips(HOME_CHIPS, 2), lst(*HOME_WRITING, '<div class="addrow">+ New book on Writing</div>'), qe_rest(), tabs_words(1), hi(),
               zone(56, 78, "1"), zone(192, 518, "2", 'b'))
    d2 = phone(mast("Home", buttons=('more',)), dots(0, centered=False), chips(HOME_CHIPS, 2), lst(*HOME_WRITING, '<div class="addrow">+ New book on Writing</div>'), qe_rest(), tabs_sys(1), hi(),
               zone(56, 654, "1"), zone(776, 68, "2", 'b'))
    starred = '<div class="chips" style="height:60px"><span class="chip on" style="height:44px">★ Journal</span><span class="chip" style="height:44px">★ Essays</span><span class="chip" style="height:44px">★ On keeping a common…</span></div>'
    d3 = phone(mast("Home", buttons=('more',)), dots(0), '<div class="search">%s Search Home</div>' % I_SEARCH, starred,
               lst(sec("✎ Writing", "4", tap=True, state="⌄"), *HOME_WRITING[:3],
                   sec("☼ Life", "4", tap=True, state="›"), sec("Reading &amp; reference", "3", tap=True, state="›"), sec("Unshelved", "2", tap=True, state="›"),
                   '<div class="brow"><div><div class="t">All notes</div><div class="m">64 notes in Home · newest first</div></div><div class="tr"><span class="go">›</span></div></div>'),
               qe_rest(), hi(),
               zone(56, 700, "1"))
    intro = """
<p class="lede"><b>Three directions for the phone's navigation</b> — how wings, the Bookcase, the Library, quick entry and search fit together. Each is one
home screen with its gestures outlined; they are assembled from the options in the four question sketches in <code>sketches/</code>, so choosing a
direction here is the same as answering SW-1, SW-3, BK-1 and LK-5 together.</p>
<p class="q">“there are no different wings (!!) so everything just shows up in one bunch but it's hard to find items in the library.”</p>
"""
    body = row(
        opt(d1, "Direction 1", "The Mac, folded.", N1 + " The wing is the masthead: swipe the band, tap for the dropdown. " + N2 + " Starred · Bookcase · Library on a words-only bar and on today's page swipe; the capture box at the foot of the Bookcase and the Library; search is the Library's own field, scoped to the wing. Keeps everything she has and has asked for. Cost: the most chrome (a masthead, a chip row, a box and a bar) and two swipes to tell apart.", mine=True),
        opt(d2, "Direction 2", "Wings are the pages.", N1 + " The whole screen swipes wings. " + N2 + " The roots are taps on the system's tab bar, whose search button is the one door into search. The simplest gesture model and the most native. Cost: retires the root swipe, and the glass bar is the one piece that does not look like the Mac's Study voice."),
        opt(d3, "Direction 3", "One home per wing.", N1 + " No tab bar: each wing is one scroll — search, a starred strip, the shelves as folding sections, and “All notes” as the door to the Library. Wings swipe full-screen. The least chrome and the most room for words. Cost: the Library is a push away rather than a root, the starred page becomes a strip, and it is the furthest from what she uses today."),
    ) + """
<div class="pick"><h2>My pick: direction 1</h2>
<p>It changes nothing she has ruled or asked for and adds the two things that are missing — a wing that is always named at the top, and shelves.
Its cost is chrome, and the sketches answer that with size discipline rather than removal: every bar is a real target, and the chip row and the
dots are the only additions above the list. Direction 2 is the one to take if she would rather swipe wings than roots; direction 3 is worth a look
only if she finds three roots one too many once wings exist.</p></div>
"""
    page('shell-directions.html', 'The shell — three directions for navigation', intro, body, where=DESIGN)

sw1(); ls1(); bk1(); sw3(); shell()
