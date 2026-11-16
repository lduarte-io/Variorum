# VM-44 shell-and-finding designer — throwaway generator base (static HTML out; no scripts in the output).
# Stands on the books designer's base (which stands on the round-1 sketch generator), so the three
# designers' frames are one system: same phone frame, same shell helpers, same sheets and confirms.
import sys, os, html
HERE = os.path.dirname(os.path.abspath(__file__))
MOCK = os.path.abspath(os.path.join(HERE, '..'))
sys.path.insert(0, MOCK)
from _bk_base import *          # P, mast, dots, chips, brow, lst, sec, kb, tabs_words, hi, sheet, grp, mrow, confirm, …
import _bk_base as B

CSS = B.CSS + r"""
/* ---- the sizing sheet's capture box (48 at rest, radius 12, the Mac's dashed edge in the corrected faint) ---- */
.qe{margin:8px 20px 8px;gap:8px}
.qebox{min-height:48px;border-radius:12px;border:1.5px dashed #8B7F6A;color:#8B7F6A;padding:0 14px;font:400 17px/24px var(--serif)}
.phone.dk .qebox{border-color:#736C5D;color:#948C7C}
.qebox.typed{padding:11px 14px;color:var(--ink);display:block}
.phone.dk .qebox.typed{color:var(--ink)}
.qebox.typed p{margin:0 0 10px}
.qebox.typed p:last-child{margin:0}
.qebox.cap{max-height:214px;overflow:hidden;position:relative}
.qebox.cap:before{content:"";position:absolute;right:4px;top:60px;width:3px;height:70px;border-radius:2px;background:rgba(41,36,28,.28)}
.qebox.cap:after{content:"";position:absolute;left:0;right:0;bottom:0;height:20px;background:linear-gradient(rgba(255,255,255,0),var(--surface));border-radius:0 0 11px 11px}
.caret{height:20px}
.list:after{content:"";position:absolute;left:0;right:0;bottom:0;height:26px;background:linear-gradient(rgba(255,255,255,0),var(--surface));pointer-events:none}
.phone.dk .list:after,.phone.dk .qebox.cap:after{background:linear-gradient(rgba(15,26,22,0),var(--surface))}
.sbody .ssub{margin-top:0}
.today{height:48px;border-radius:12px;padding:0 14px}
.qact{margin:0 20px 8px;gap:8px}
.qact .dest{font:400 13px/18px var(--sans);color:var(--meta)}
.qact .pill.off{opacity:.4}
.mkey{flex:none;height:32px;padding:0 11px;border-radius:16px;background:var(--surface);box-shadow:inset 0 0 0 1px var(--takeline);display:inline-flex;align-items:center;font:500 15px/20px var(--sans);color:var(--accent)}
.tok{color:var(--accent)}

/* ---- the one message line (sizing sheet: 44 tall, words 15, the act 15 semibold in a 60 x 44 hit area) ---- */
.rcpt{flex:none;display:flex;align-items:center;gap:8px;min-height:44px;padding:0 8px 0 20px;font:400 15px/20px var(--sans);color:var(--meta)}
.rcpt span{flex:1;padding:6px 0}
.rcpt b{flex:none;height:44px;min-width:60px;padding:0 12px;display:inline-flex;align-items:center;justify-content:center;font:600 15px/20px var(--sans);color:var(--accent);white-space:nowrap}
.rcpt.refusal span{color:var(--alarm)}
.rcpt .x{flex:none;width:44px;height:44px;display:inline-flex;align-items:center;justify-content:center;color:var(--meta)}
.rcpt .x svg{width:16px;height:16px}
.list .rcpt{background:var(--room);border-top:1px solid var(--line);position:absolute;left:0;right:0;bottom:0}

/* ---- the wing band mid-swipe ---- */
.mast.drag{position:relative;overflow:hidden}
.mast.drag .wname{position:absolute;top:13px;white-space:nowrap}
.dots i.half{background:var(--accent);opacity:.55}
.list.dimmed>*{opacity:.38}
.hand{position:absolute;z-index:7;width:44px;height:44px;border-radius:22px;background:rgba(180,71,47,.16);box-shadow:0 0 0 2px #B4472F;pointer-events:none}
.hand:after{content:"";position:absolute;top:21px;height:2px;background:#B4472F;border-radius:1px}
.hand.l:after{right:46px;width:54px}
.hand.r:after{left:46px;width:54px}

/* ---- menus ---- */
.menu{width:346px;top:108px}
.menu .mi{height:auto;min-height:52px;border-bottom:1px solid var(--line)}
.menu .mi .ct{font-size:13px;white-space:nowrap}
.menu .mh{padding:12px 16px 8px}
.phone.dk .dim{background:rgba(0,0,0,.5)}
.opn{display:inline-block;margin-left:8px;padding:1px 6px;border:1px dashed #B4472F;border-radius:5px;font:600 11px/15px var(--sans);color:#B4472F;letter-spacing:.02em;vertical-align:1px}
.phone.dk .opn{color:#E59A84;border-color:#E59A84}
.ctx{position:absolute;z-index:6;width:274px;border-radius:14px;background:var(--surface);box-shadow:0 12px 40px rgba(41,36,28,.3);overflow:hidden}
.ctx .ch{padding:10px 16px;font:400 13px/18px var(--sans);color:var(--meta);border-bottom:1px solid var(--line);background:var(--taketint)}
.ctx .ci{min-height:46px;display:flex;align-items:center;justify-content:space-between;gap:10px;padding:0 16px;font:400 17px/22px var(--sans);border-bottom:1px solid var(--line)}
.ctx .ci:last-child{border-bottom:0}
.ctx .ci svg{width:19px;height:19px;color:var(--meta);flex:none}
.ctx .ci.gap{border-top:7px solid var(--taketint)}
.ctx .ci.danger,.ctx .ci.danger svg{color:var(--alarm)}
.ctx .ci.ck:before{content:"✓";color:var(--accent);font-weight:600;margin-right:-2px}
.ctx .ci.ck{justify-content:flex-start}
.ctx .ci.nock{padding-left:39px}
.ctx .cs{padding:8px 16px 4px;font:600 13px/18px var(--sans);color:var(--meta)}
.lift{position:absolute;z-index:6;left:12px;right:12px;border-radius:14px;background:var(--surface);box-shadow:0 8px 30px rgba(41,36,28,.25);overflow:hidden}
.lift .nrow,.lift .brow{border-bottom:0}
.pop{position:absolute;z-index:6;padding:10px 14px;border-radius:12px;background:var(--surface);box-shadow:0 8px 28px rgba(41,36,28,.28),0 0 0 1px var(--line);font:400 15px/20px var(--sans);color:var(--ink)}
.pop i{font-style:normal;color:var(--meta);display:block;font-size:13px;line-height:18px}
.pop:before{content:"";position:absolute;left:26px;top:-6px;width:12px;height:12px;background:var(--surface);transform:rotate(45deg);box-shadow:-1px -1px 0 var(--line)}

/* ---- pushed rooms: a 20 pt title (the sheet's screen-title role) ---- */
.stitle{flex:none;padding:2px 20px 0;font:600 20px/25px var(--serif)}
.sub{padding:3px 20px 10px}
.sec{background:var(--surface)}
.list .sec{border-bottom:0}
.endline{padding:18px 20px 22px;text-align:center;font:400 13px/18px var(--sans);color:var(--meta)}
.loadline{padding:14px 20px;text-align:center;font:400 13px/18px var(--sans);color:var(--meta)}
.loadline:before{content:"";display:inline-block;width:12px;height:12px;border-radius:50%;border:2px solid var(--takeline);border-top-color:var(--accent);margin-right:8px;vertical-align:-2px}
.morerow{display:flex;align-items:center;min-height:44px;padding:0 20px;font:500 15px/20px var(--sans);color:var(--accent);border-bottom:1px solid var(--line)}
.empty{padding:48px 36px 0}
.empty small{display:block;margin-top:10px;font:400 15px/21px var(--sans);color:var(--meta)}
.nt .st{flex:none;font:400 13px/18px var(--sans);color:var(--meta)}
.np2l{font:400 15px/20px var(--serif);color:var(--meta);margin-top:2px;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
.np .stz{outline:1.5px dashed #2F6B4F;outline-offset:8px;border-radius:2px}
.kindw{font:400 13px/18px var(--sans);color:var(--meta);flex:none}

/* ---- search ---- */
.search{height:44px}
.cbtn.onb{background:var(--wash);box-shadow:inset 0 0 0 1.5px var(--accent)}
.phone.dk .cbtn.onb{background:var(--wash)}
.search.focus{box-shadow:0 0 0 2px var(--accent);color:var(--ink)}
.search .sq{flex:1;color:var(--ink);white-space:nowrap;overflow:hidden}
.search .clr{flex:none;width:20px;height:20px;border-radius:10px;background:var(--faint);color:#fff;display:inline-flex;align-items:center;justify-content:center;font:700 12px/1 var(--sans)}
.searchrow{margin:2px 16px 4px}
.searchrow .cancel{flex:none;height:44px;padding:0 4px 0 6px;display:inline-flex;align-items:center;font:400 17px var(--sans);color:var(--accent)}
.swrow{flex:none;display:flex;align-items:center;gap:8px;height:48px;padding:0 20px;font:400 15px/20px var(--sans);color:var(--ink)}
.swrow .sw1{flex:1;display:flex;align-items:center;gap:10px}
.swrow .toggle{margin-left:0}
.scope{flex:none;padding:0 20px 8px;font:400 13px/18px var(--sans);color:var(--meta)}
.scope b{color:var(--ink);font-weight:600}
.cnt{padding:10px 20px 8px;font:400 13px/18px var(--sans);color:var(--meta);border-bottom:1px solid var(--line)}
.hh{padding:11px 20px 2px}
.hh .nt{align-items:baseline}
.hh .nw{margin-top:1px}
.psg{display:block;min-height:44px;padding:8px 20px 8px 32px;font:400 15px/20px var(--serif);color:var(--meta);position:relative}
.psg:before{content:"";position:absolute;left:20px;top:10px;bottom:10px;width:2px;border-radius:1px;background:var(--takeline)}
.psg mark{background:var(--wash);color:var(--ink);font-weight:600;border-radius:3px;padding:0 2px}
.psg i{font:400 13px/18px var(--sans);font-style:normal;color:var(--meta);display:block}
.grpend{border-bottom:1px solid var(--line)}
.alln{display:flex;align-items:center;height:44px;padding:0 20px 0 32px;font:500 15px/20px var(--sans);color:var(--accent)}
.fchip{display:inline-flex;align-items:center;gap:8px;height:32px;padding:0 12px;border-radius:16px;background:var(--surface);box-shadow:inset 0 0 0 1px var(--takeline);font:500 15px/20px var(--sans);color:var(--ink)}
.fchip svg{width:12px;height:12px;color:var(--meta)}
.fchip.offer{color:var(--accent)}
.fbarrow{flex:none;display:flex;gap:8px;align-items:center;height:44px;padding:0 20px}
.page mark.sel{background:rgba(59,106,89,.28);color:var(--ink);border-radius:2px;padding:1px 0}
.phone.dk .page mark.sel{background:rgba(144,193,175,.32)}
.findbar{flex:none;height:48px;display:flex;align-items:center;gap:4px;padding:0 8px 0 16px;background:var(--room);border-top:1px solid var(--line);font:400 15px var(--sans);color:var(--meta)}
.findbar .fq{flex:1;height:36px;border-radius:10px;background:var(--surface);box-shadow:0 0 0 1px var(--line);display:flex;align-items:center;padding:0 12px;font:400 17px var(--sans);color:var(--ink);gap:8px}
.findbar .fq i{font-style:normal;margin-left:auto;font-size:13px;color:var(--meta)}
.findbar .fb{width:44px;height:44px;display:flex;align-items:center;justify-content:center;color:var(--accent)}

/* ---- select mode ---- */
.nrow.selm,.brow.selm,.trw.selm,.tg.selm{padding-left:60px;position:relative}
.nrow.selon,.trw.selon,.tg.selon{background:var(--taketint)}
.selbar{flex:none;display:flex;align-items:center;justify-content:space-between;height:56px;padding:0 8px 0 20px}
.selbar .n{font:600 20px/25px var(--serif)}
.selbar .hb{height:44px;min-width:60px;padding:0 12px;display:inline-flex;align-items:center;justify-content:center;font:600 17px var(--sans);color:var(--accent)}
.actbar{flex:none;display:flex;justify-content:space-between;align-items:center;height:60px;padding:0 12px;border-top:1px solid var(--line)}
.actbar .ab{min-width:64px;height:48px;padding:0 10px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;font:500 13px/16px var(--sans);color:var(--accent)}
.actbar .ab svg{width:22px;height:22px}
.actbar .ab.danger{color:var(--alarm)}
.actbar .ab.off{opacity:.35}
.actbar.two .ab{flex-direction:row;gap:8px;font:600 17px/22px var(--sans);padding:0 16px;border-radius:12px;background:var(--surface);box-shadow:0 0 0 1px var(--line)}

/* ---- swipe panels (the books designer's 104 pt panels, two more colours) ---- */
.swipe .act.star{background:var(--star)}
.swipe .act.alarm{background:var(--alarm);right:0}
.swipe .act.arch{background:#6A6359;right:104px}
.swipe .act svg{width:22px;height:22px}
.swipe .nrow,.swipe .trw{background:var(--surface);position:relative}
.phone.dk .swipe .act{color:#0F1A16}

/* ---- Trash and Archived rows ---- */
.trw{display:flex;align-items:center;gap:8px;min-height:72px;padding:10px 8px 10px 20px;border-bottom:1px solid var(--line);background:var(--surface)}
.trw .mid{flex:1;min-width:0}
.trw .t{font:600 17px/22px var(--serif);display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;overflow:hidden}
.trw .p{font:400 15px/20px var(--serif);color:var(--meta);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;margin-top:2px}
.trw .m{font:400 13px/18px var(--sans);color:var(--meta);margin-top:3px}
.trw .m b{font-weight:600;color:var(--ink)}
.trw .m .soon{color:var(--alarm);font-weight:600}
.pb{flex:none;height:44px;display:inline-flex;align-items:center;padding:0 4px}
.pb span{height:32px;padding:0 13px;border-radius:16px;background:var(--wash);color:var(--accent);font:600 15px/32px var(--sans);white-space:nowrap}
.footdoors{padding:20px 20px 28px}
.footdoors .fd{display:flex;align-items:center;min-height:48px;font:400 17px/22px var(--sans);color:var(--accent);border-bottom:1px solid var(--line)}
.footdoors .fd:last-child{border-bottom:0}
.footdoors .fd.danger{color:var(--alarm)}
.footdoors .fl{font:600 13px/18px var(--sans);color:var(--meta);padding:0 0 4px}
.footdoors .fgap{height:20px}

/* ---- tags ---- */
.tg{display:flex;align-items:center;min-height:52px;padding:6px 4px 6px 20px;border-bottom:1px solid var(--line);background:var(--surface);gap:8px}
.tg .tn{flex:1;min-width:0;font:600 17px/22px var(--serif);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.tg .tn i{font-style:normal;color:var(--meta);font-weight:400}
.tg .tc{flex:none;font:400 13px/18px var(--sans);color:var(--meta)}
.tg .tm{flex:none;width:44px;height:44px;display:flex;align-items:center;justify-content:center;color:var(--accent)}
.tg.d1{padding-left:44px}
.tg.unused .tc{color:var(--alarm)}

/* ---- the day filter's month ---- */
.cal{padding:0 16px 8px}
.calh{display:flex;align-items:center;justify-content:space-between;height:48px;font:600 17px/22px var(--sans);padding:0 4px}
.calh span.ar{width:44px;height:44px;display:inline-flex;align-items:center;justify-content:center;color:var(--accent)}
.calw,.calr{display:grid;grid-template-columns:repeat(7,1fr);text-align:center}
.calw{font:600 13px/24px var(--sans);color:var(--meta)}
.calr span{height:46px;display:flex;align-items:center;justify-content:center;font:400 17px var(--sans)}
.calr span.o{color:var(--faint)}
.calr span.on b{width:40px;height:40px;border-radius:20px;background:var(--accent);color:#fff;display:flex;align-items:center;justify-content:center;font-weight:600}
.phone.dk .calr span.on b{color:#0F1A16}
.calr span.now b{width:40px;height:40px;border-radius:20px;box-shadow:inset 0 0 0 1.5px var(--accent);display:flex;align-items:center;justify-content:center;font-weight:400}
.calr span b{font-weight:400}
.armed{padding:6px 20px 14px;font:400 15px/20px var(--sans);color:var(--meta)}
.armed b{color:var(--ink);font-weight:600}

/* ---- keyboard, dark ---- */
.phone.dk .kb{background:#2A2B2E}
.phone.dk .k{background:#6B6C70;color:#fff;box-shadow:none}
.phone.dk .k.d,.phone.dk .k.w{background:#47484B}
.phone.dk .kbs,.phone.dk .kbf{color:#D8D8D8}
.phone.dk .sb .sig,.phone.dk .sb .wifi{background:var(--ink)}
.phone.dk .hi:after,.phone.dk .sheet:after{background:var(--ink)}
.phone.dk .cbtn,.phone.dk .pill{background:#15261F}
.phone.dk .search,.phone.dk .ctx,.phone.dk .menu,.phone.dk .pop,.phone.dk .lift{background:#15261F}
.phone.dk .pill.fill{background:var(--accent)}
.phone.dk .menu .mi{border-color:var(--line)}

/* ---- the largest standard text size (xxxLarge, about 1.35x): her words scale on, chrome scales to here and holds ---- */
.phone.xl .wname{font-size:32px;line-height:38px}
.phone.xl .mast{height:64px}
.phone.xl .chips{height:68px}
.phone.xl .chip{font-size:20px;height:50px;padding:0 16px}
.phone.xl .brow{min-height:86px}
.phone.xl .brow .t,.phone.xl .trw .t{font-size:23px;line-height:29px}
.phone.xl .brow .m,.phone.xl .trw .m{font-size:18px;line-height:24px}
.phone.xl .tabs{height:64px}
.phone.xl .tab{font-size:22px}
.phone.xl .tab.on span{padding:8px 9px}
.phone.xl .today{font-size:20px;height:60px}
.phone.xl .qebox{font-size:23px;line-height:30px;min-height:60px}
.phone.xl .addrow{font-size:23px;height:68px}
.phone.xl .search{font-size:23px;height:56px}
.phone.xl .cbtn{width:52px;height:52px;border-radius:26px}
.phone.xl .nt .st,.phone.xl .kindw{font-size:18px;line-height:24px}
.phone.xl .pb span{font-size:20px;height:42px;line-height:42px;border-radius:21px;padding:0 16px}
.phone.xl .pb{height:52px}
.phone.xl .stitle{font-size:27px;line-height:33px}
.phone.xl .trw .p{font-size:20px;line-height:26px}
"""

# ---------- icons this surface adds ----------
I_CAL = ic('M4 9h14|M7 3v3|M15 3v3', extra='<rect x="3" y="5" width="16" height="14" rx="2.5"/>')
I_SHARE = ic('M11 14V3|M7 7l4-4 4 4|M5 11v7h12v-7')
I_COPY = ic('M8 8V5a2 2 0 012-2h7a2 2 0 012 2v7a2 2 0 01-2 2h-3', extra='<rect x="3" y="8" width="11" height="11" rx="2"/>')
I_SELECT = ic('M7 11l3 3 5-6', extra='<circle cx="11" cy="11" r="8"/>')
I_UNDO = ic('M7 5L3 9l4 4|M3 9h9a6 6 0 010 12h-2')
I_PUTBACK = ic('M7 4L3 8l4 4|M3 8h10a5 5 0 010 10H8')
I_STARF = '<svg width="22" height="22" viewBox="0 0 22 22" fill="currentColor"><path d="M11 3l2.4 5 5.4.7-3.9 3.8.9 5.3L11 15.3 6.2 17.8l.9-5.3L3.2 8.7 8.6 8 11 3z"/></svg>'
def sm(icon, n=18): return icon.replace('width="22" height="22"', 'width="%d" height="%d"' % (n, n))

# ---------- the shell, thin and swappable ----------
WINGS = [("Home", 10, 64), ("Work", 3, 31), ("Fiction", 3, 22), ("Research", 2, 12), ("Family", 2, 10),
         ("Health", 1, 4), ("Side project", 1, 5), ("Poetry", 0, 1), ("Taxes 2025", 1, 0)]
WNAMES = [w[0] for w in WINGS]
def wcount(b, n):
    bb = "%d book%s" % (b, '' if b == 1 else 's') if b else ''
    nn = "%d note%s" % (n, '' if n == 1 else 's') if n else ''
    return ' · '.join(x for x in (bb, nn) if x) or 'nothing yet'
def wi(name): return WNAMES.index(name)

TODAY = '<div class="today">✎ Today</div>'
def qe(text='New note', today=True, cls=''):
    return '<div class="qe %s"><div class="qebox">%s</div>%s</div>' % (cls, text, TODAY if today else '')
def qe_typed(paras, cap=False, caret=True, today=False):
    ps = ''.join('<p>%s</p>' % p for p in paras[:-1]) + '<p>%s%s</p>' % (paras[-1], '<span class="caret"></span>' if caret else '')
    return '<div class="qe"><div class="qebox typed%s">%s</div>%s</div>' % (' cap' if cap else '', ps, TODAY if today else '')
def qact(wing, on=True, keys=False):
    off = '' if on else ' off'
    k = '<span class="mkey">#tag</span><span class="mkey">title</span>' if keys else ''
    return ('<div class="qact"><span class="dest" style="margin-right:auto">in %s</span>%s<span class="pill%s">Open</span><span class="pill fill%s">File</span></div>'
            % (wing, k, off, off))
def rcpt(text, act='', refusal=False, x=False):
    a = '<b>%s</b>' % act if act else ''
    xx = '<span class="x">%s</span>' % I_X if x else ''
    return '<div class="rcpt%s"><span>%s</span>%s%s</div>' % (' refusal' if refusal else '', text, a, xx)

HOME_CHIPS = ["★ Starred", "Unshelved", "✎ Writing", "Reading &amp; reference", "☼ Life", "Welcome", "All"]
WRITING = [brow("Essays", "8 notes · #essay #goals", STAR), brow("Blog drafts", "7 notes · #blog #draft"),
           brow("Letters", "3 notes · finished", FIN), brow("Ideas inbox", "3 notes · 3 waiting", badge(3))]
READING = [brow("Reading notes", "6 notes · #reading"), brow("Quotes", "gathering · #quote · 6 notes")]
LIFE = [brow("Journal", "13 entries · daily journal", STAR), brow("Recipes", "5 notes · #recipe"), brow("Lisbon trip", "4 entries · #travel")]
WELCOME = [brow("The Prince", "28 notes · sample book")]
NEWBOOK = '<div class="addrow">+ New book on Writing</div>'
WORK_CHIPS = ["★ Starred", "Unshelved", "Projects", "All"]
WORK_ALL = [sec("Unshelved", "1"), brow("Ideas inbox", "2 notes · #idea"),
            sec("Projects", "2"), brow("Product specs", "4 notes · #spec", STAR), brow("Meeting notes", "8 notes · #meeting #q4")]
def home_all(): return [sec("✎ Writing", "4"), *WRITING, sec("Reading &amp; reference", "2"), *READING, sec("☼ Life", "3"), *LIFE, sec("Welcome", "1"), *WELCOME]

def wmast(name, buttons=('search', 'more'), extra=''):
    return mast(name, buttons=buttons).replace('<div class="mbtns">', '<div class="mbtns">' + extra)
def home(*over, wing="Home", chipset=None, on=2, rows=None, foot=None, bar=True, cls='', tab=1):
    chipset = HOME_CHIPS if chipset is None else chipset
    rows = WRITING + [NEWBOOK] if rows is None else rows
    return P(wmast(wing), dots(wi(wing)), chips(chipset, on, fade=len(chipset) > 4), lst(*rows),
             foot if foot is not None else qe(), tabs_words(tab) if bar else '', hi() if bar else '', *over, cls=cls)

def wing_menu(on, manage=True):
    rows = ''.join('<div class="mi%s"><span class="ck">%s</span>%s<span class="ct">%s</span></div>' %
                   (' on' if i == on else '', '✓' if i == on else '', html.escape(w), wcount(b, n)) for i, (w, b, n) in enumerate(WINGS))
    m = ('<div class="mi act">New wing…<span class="opn">open</span></div>'
         '<div class="mi act" style="border:0">Manage wings…<span class="opn">open</span></div>') if manage else ''
    return '<div class="dim"></div><div class="menu"><div class="mh">Wings — each a separate library</div>%s%s</div>' % (rows, m)

def ctx(top, items, head='', left=None, right=16, width=274):
    pos = ('left:%dpx' % left) if left is not None else ('right:%dpx' % right)
    h = '<div class="ch">%s</div>' % head if head else ''
    out = ''
    for it in items:
        if isinstance(it, str) and it.startswith('§'):
            out += '<div class="cs">%s</div>' % it[1:]; continue
        label, icon, cls = (it + ('', ''))[:3] if isinstance(it, tuple) else (it, '', '')
        out += '<div class="ci %s"><span>%s</span>%s</div>' % (cls, label, icon)
    return '<div class="ctx" style="top:%dpx;%s;width:%dpx">%s%s</div>' % (top, pos, width, h, out)
SCRIM = '<div class="scrim"></div>'
def zone2(top, height, left, right, num, cls=''):
    return '<div class="zone %s" style="top:%dpx;height:%dpx;left:%dpx;right:%dpx"><span>%s</span></div>' % (cls, top, height, left, right, num)
def lift(top, inner): return '<div class="lift" style="top:%dpx">%s</div>' % (top, inner)

# ---------- note rows: LS-1 (b), the grader's pick, with the Mac's stamp words ----------
def nr(title, stamp, preview, where=None, star=False, cls='', sel=None, stz=False):
    s = STAR if star else ''
    w = '<div class="nw">%s</div>' % where if where else ''
    tick = ''
    if sel is not None:
        tick = '<span class="selc%s">%s</span>' % (' on' if sel else '', I_CHECK if sel else '')
        cls += ' selm' + (' selon' if sel else '')
    st = '<b%s>%s</b>' % (' class="stz"' if stz else '', stamp)
    return ('<div class="nrow %s">%s<div class="nt"><span class="x">%s</span>%s</div><div class="np">%s%s</div>%s</div>'
            % (cls, tick, title, s, st, preview, w))
LIB = [
    ("Walk note: the ferry timetable changes in December", "today 2:14 PM", "and the morning boat now leaves at seven forty. Tell M. before Friday.", "No book", {}),
    ("On keeping a commonplace book", "today 1:02 PM", "I started copying sentences into a notebook the winter I stopped trusting my memory for them.", "Essays", dict(star=True)),
    ("Thursday 12 November", "today 8:40 AM", "Slept badly. The heron was back on the jetty before seven, standing like a question mark.", "Journal", {}),
    ("The case for slow mornings", "yesterday", "Nothing good was ever decided before the second coffee, and I have the minutes to prove it.", "Essays", {}),
    ("Grocery list", "Nov 10", "Oat milk, lemons, the good butter, stamps, something for the neighbour with the piano.", "No book", dict(star=True)),
    ("Tuesday 10 November", "Nov 10", "10 km along the river path. Left knee fine until the bridge, then not.", "Journal", {}),
    ("Untitled", "Nov 9", "No text yet", "No book", {}),
    ("Write the bread recipe as a poem", "Nov 7", "Flour, water, salt, patience. The last one is the only ingredient that is not sold.", "No book", {}),
    ("Day 3 — Cacilhas", "Nov 5", "We took the ferry across for grilled fish and nearly missed the last one back.", "Lisbon trip", {}),
]
def lib_rows(n=None, sel=None, **kw):
    rows = LIB if n is None else LIB[:n]
    return [nr(t, s, p, w, sel=(None if sel is None else (i in sel)), **k) for i, (t, s, p, w, k) in enumerate(rows)]
LIBF = ["All", "Notes", "Books", "Pool", "Snippets", "Archived"]
def searchrow(place, when=True, focus=False, q='', cancel=False):
    inner = ('%s <span class="sq">%s<span class="caret"></span></span><span class="clr">×</span>' % (I_SEARCH, q)) if q else \
            ('%s %s%s' % (I_SEARCH, '<span class="caret" style="margin:0 -5px 0 0"></span>' if focus else '', place))
    w = '<span class="cbtn%s">%s</span>' % (' onb' if when == 'on' else '', I_CAL) if when else ''
    tail = '<span class="cancel">Cancel</span>' if cancel else (w + '<span class="cbtn">%s</span>' % sm(I_SORT.replace('width="14" height="14"', 'width="22" height="22"'), 20))
    return '<div class="searchrow"><div class="search%s">%s</div>%s</div>' % (' focus' if focus or q else '', inner, tail)
TRASHB = '<span class="cbtn">%s</span>' % I_TRASH
def library(*over, wing="Home", on=1, rows=None, foot=None, bar=True, cls='', head=None, filt=LIBF, mid='', when=True):
    rows = lib_rows() if rows is None else rows
    return P(wmast(wing, buttons=('more',), extra=TRASHB), dots(wi(wing)),
             head if head is not None else searchrow("Search " + wing, when=when),
             chips(filt, on, fade=True) if filt else '', mid, lst(*rows),
             foot if foot is not None else qe(today=False), tabs_words(2) if bar else '', hi() if bar else '', *over, cls=cls)

def room(title, sub, right='', *parts, cls='', bar=True, tab=2, over=()):
    return P(nav(right), '<div class="stitle">%s</div><div class="sub">%s</div>' % (title, sub), *parts,
             tabs_words(tab) if bar else '', hi() if bar else '', *over, cls=cls)

# ---------- page writer ----------
VALUES = """
<h2>The values these frames are drawn with</h2>
<p class="lede">Everything inherits <code>sketches/sizing-sheet.html</code>: Study voice under the sea-glass palette; type at 13 · 15 · 17 · 20 · 24
(Iowan Old Style for her words and for names, SF for chrome); a 44 pt touch minimum; lists and her words on the paper, bars, sheets and section bands on the
sea-glass room; the corrected meta ink <code>#6A6359</code> and faint <code>#8B7F6A</code>; the dark values are the sheet's <code>.dk</code> set. The shell is her rulings
(SW-1 the wing band, SW-3 the Bookcase with the one-line box, SW-4 File and Open, LK-5 words on a chip, the Today button) drawn with the round-1 sketch generator's
frame and the books designer's sheets, so a different pick on an open question is a re-skin. Frames are 402 × 874 pt, one CSS pixel to the point.
Fonts fall back to Palatino or Georgia where Iowan is not installed. Dashed red and green outlines, the red finger mark and the red “open” tag are annotations, not design.</p>
"""
def write(fname, title, intro, sections, notes, check_dir=None):
    body = ''.join('<h2>%s</h2>%s%s' % (h, lede, row(*opts)) for h, lede, opts in sections)
    doc = ('<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">'
           '<title>%s</title><style>%s</style></head><body><h1>%s</h1>%s%s%s%s</body></html>') % (html.escape(title), CSS, html.escape(title), intro, body, notes, VALUES)
    path = os.path.join(MOCK, fname)
    open(path, 'w').write(doc)
    print(path, len(doc), sum(len(o) for _, _, o in sections), 'frames')
    if check_dir:
        os.makedirs(check_dir, exist_ok=True)
        n = 0
        for si, (h, lede, opts) in enumerate(sections):
            for k in range(0, len(opts), 4):
                n += 1
                d = ('<!doctype html><html><head><meta charset="utf-8"><style>%s body{padding:6px 16px 16px} .row{flex-wrap:nowrap;overflow:visible}</style></head><body><p style="margin:2px 0"><b>%s</b></p>%s</body></html>'
                     % (CSS, h, row(*opts[k:k + 4])))
                open(os.path.join(check_dir, '%s-%02d.html' % (fname.replace('.html', ''), n)), 'w').write(d)
        print(n, 'check pages')
