# VM-44 designer D — throwaway generator base (static HTML out; no scripts in the output).
# Reuses the round-1 sketch generator's frame, CSS and shell helpers so the mockups read as one system.
import os, html

G1 = 'notes/plans/vm-44/design/sketches/_g1-sketch-generator.py'
OUT = 'notes/plans/vm-44/design/mockups'
os.makedirs(OUT, exist_ok=True)

_src = open(G1).read().split('# =====================================================================')[0]
_ns = {}
exec(compile(_src, G1, 'exec'), _ns)
G1CSS = _ns['CSS']
for _k in ('esc', 'sb', 'hi', 'mast', 'chips', 'brow', 'STAR', 'FIN', 'badge', 'lst', 'qe_rest', 'qe_typed',
           'tabs_words', 'kb', 'zone', 'wing_menu', 'I_SEARCH', 'I_MORE', 'I_BACK', 'HOME_WRITING', 'HOME_CHIPS',
           'WINGS', 'WCOUNT'):
    globals()[_k] = _ns[_k]

EXTRA = r"""
:root{--faint2:#8B7F6A;--sand:#F7EFD9}
.row{flex-wrap:wrap;overflow:visible;row-gap:34px}
h3{font:600 17px/1.3 var(--sans);margin:26px 0 4px}
.lede b{font-weight:600}
code{font:13px/1.4 "SF Mono",ui-monospace,Menlo,monospace;background:#E6E3DB;padding:1px 5px;border-radius:4px}
.cap .id.alt{background:#8A5A12}
.cap small{display:block;margin-top:6px;font-size:13px;color:#5b574f;line-height:1.45}
.new{display:inline-block;font:600 11px var(--sans);letter-spacing:.04em;background:#F0E3BF;color:#6B4A0C;border-radius:4px;padding:1px 6px;margin-left:4px;vertical-align:1px}
table.bn{border-collapse:collapse;font-size:14px;margin:12px 0 0;max-width:1500px}
table.bn td,table.bn th{border:1px solid #D8D4CA;padding:7px 10px;text-align:left;vertical-align:top;line-height:1.45}
table.bn th{background:#E9E6DF;font-weight:600}
table.bn td:first-child{white-space:nowrap;font-weight:600}

/* dark: the sizing sheet's .dk tokens */
.phone.dk,.scr.dk{--room:#000;--surface:#0F1A16;--ink:#E8E3D8;--meta:#948C7C;--accent:#90C1AF;--line:#1C332A;--wash:#1F382F;
 --taketint:#0D1713;--takeline:#254137;--alarm:#D98A78;--star:#82ABCC;--positive:#93B57E;--faint2:#736C5D;--faint:#6B6456;--sand:#2A2415}
.dk .chip{background:rgba(255,255,255,.07)}
.dk .chips.fade:after{background:linear-gradient(90deg,rgba(0,0,0,0),#000)}
.dk .kb{background:#2A2B2E}.dk .k{background:#6B6C70;color:#fff;box-shadow:none}.dk .k.d,.dk .k.w{background:#47484B}
.dk .kbs,.dk .kbf{color:#ddd}
.dk .btn.pri,.dk .badge,.dk .pill.fill{color:#0F1A16}
.dk .sb .island{background:#151515;box-shadow:0 0 0 1px #222}
.dk .dim{background:rgba(0,0,0,.55)}
.dk .sheet{box-shadow:0 0 0 1px #1C332A}

/* the masthead's second line: wing dots (the shell's) + the ambient sync line (this mockup's) */
.dotsrow{flex:none;display:flex;align-items:flex-start;justify-content:space-between;height:22px;padding:0 20px 0 22px}
.dotsrow .d{display:flex;gap:7px}
.dotsrow .d i{width:7px;height:7px;border-radius:50%;background:var(--takeline)}
.dotsrow .d i.on{background:var(--accent)}
.stat{display:flex;gap:6px;align-items:center;font:400 13px/14px var(--sans);color:var(--meta);margin-top:-4px;white-space:nowrap}
.stat.warn{color:var(--ink)}
.spin{width:11px;height:11px;border-radius:50%;border:1.6px solid var(--accent);border-top-color:transparent;flex:none}
.offg{width:13px;height:13px;flex:none;color:var(--meta)}

.empty{padding:56px 36px 0;text-align:center;font:400 17px/25px var(--serif);color:var(--meta)}
.empty .door{display:flex;align-items:center;justify-content:center;height:44px;margin-top:8px;font:400 17px var(--sans);color:var(--accent)}

/* the band above the quick entry: the app's asks, as cards (W-194) */
.band{flex:none;margin:8px 16px 0;display:flex;flex-direction:column;gap:8px}
.bcard{position:relative;background:var(--surface);border-radius:12px;box-shadow:0 0 0 1px var(--takeline);padding:12px 16px 0}
.bcard .hd{display:flex;gap:12px;align-items:flex-start}
.bcard .gl{flex:none;width:28px;display:flex;justify-content:center;padding-top:1px;color:var(--accent)}
.bcard .tt{font:600 17px/22px var(--serif);margin-bottom:2px}
.bcard .ln{font:400 15px/20px var(--sans);color:var(--ink)}
.bcard .ln.m{color:var(--meta);margin-top:4px}
.bcard.x .ln.first{padding-right:26px}
.bcard .doors{display:flex;align-items:center;gap:24px;min-height:44px;margin-top:2px;flex-wrap:wrap}
.bcard .door{font:600 15px/44px var(--sans);color:var(--accent)}
.bcard .door.qt{font-weight:400;color:var(--meta)}
.bcard .xx{position:absolute;right:0;top:0;width:44px;height:44px;display:flex;align-items:center;justify-content:center;color:var(--meta);font:400 17px var(--sans)}

/* sheets: the system's, on the room */
.sheet{position:absolute;left:0;right:0;bottom:0;z-index:7;background:var(--room);border-radius:38px 38px 0 0;display:flex;flex-direction:column;overflow:hidden;box-shadow:0 -4px 24px rgba(41,36,28,.18)}
.grab{flex:none;width:36px;height:5px;border-radius:3px;background:var(--faint2);opacity:.6;margin:8px auto 0}
.shead{flex:none;display:flex;align-items:center;justify-content:space-between;height:56px;padding:0 8px 0 20px}
.shead.bk{padding-left:6px}
.shead .l{display:flex;align-items:center;min-width:0}
.shead .bkb{width:44px;height:44px;display:inline-flex;align-items:center;justify-content:center;color:var(--accent);flex:none}
.shead .st{font:600 20px/25px var(--serif)}
.shead .done{height:44px;min-width:64px;padding:0 12px;display:inline-flex;align-items:center;justify-content:center;font:600 17px var(--sans);color:var(--accent);flex:none}
.shead .done.qt{font-weight:400}
.sbody{flex:1;min-height:0;overflow:hidden;padding:4px 20px 0;display:flex;flex-direction:column}
.sbody.flush{padding:0}
.p15{font:400 15px/21px var(--sans);color:var(--ink);margin:0 0 12px}
.p15.m{color:var(--meta)}
.p13{font:400 13px/18px var(--sans);color:var(--meta);margin:0 0 8px}
.fl{font:600 13px/18px var(--sans);color:var(--meta);margin:6px 0 6px}
.fld{flex:none;min-height:52px;border-radius:12px;background:var(--surface);box-shadow:0 0 0 1px var(--line);display:flex;align-items:center;padding:0 16px;font:400 17px/24px var(--sans);color:var(--ink);margin-bottom:10px}
.fld.ph{color:var(--faint2)}
.fld.focus{box-shadow:0 0 0 2px var(--accent)}
.fld.bad{box-shadow:0 0 0 2px var(--alarm)}
.fld.area{align-items:flex-start;padding:13px 16px;min-height:104px;font:400 17px/26px var(--serif)}
.btn{flex:none;min-height:52px;border-radius:12px;display:flex;align-items:center;justify-content:center;gap:8px;font:600 17px var(--sans);margin-bottom:8px;padding:0 16px;text-align:center}
.btn.pri{background:var(--accent);color:#fff}
.btn.sec{background:var(--surface);color:var(--accent);box-shadow:0 0 0 1px var(--line)}
.btn.txt{color:var(--accent);font-weight:400;min-height:44px}
.btn.off{opacity:.45}
.refuse{font:400 15px/20px var(--sans);color:var(--alarm);margin:-2px 0 10px}
.radio{display:flex;gap:12px;align-items:flex-start;min-height:52px;padding:8px 0}
.radio i{flex:none;width:22px;height:22px;border-radius:50%;box-shadow:inset 0 0 0 1.6px var(--faint2);margin-top:1px}
.radio.on i{box-shadow:inset 0 0 0 7px var(--accent)}
.radio b{display:block;font:600 17px/22px var(--sans)}
.radio span{display:block;font:400 13px/18px var(--sans);color:var(--meta);margin-top:2px}
.prog{flex:none;height:6px;border-radius:3px;background:var(--wash);overflow:hidden;margin:6px 0 8px}
.prog i{display:block;height:100%;background:var(--accent);border-radius:3px}
.count{font:600 17px/22px var(--sans);font-variant-numeric:tabular-nums;margin:0 0 14px}
.quiet{background:var(--surface);border-radius:12px;box-shadow:0 0 0 1px var(--line);padding:12px 16px;margin:0 0 12px}
.quiet .p15{margin:0}
.wgrid{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin:4px 0 14px}
.wgrid div{height:44px;border-radius:12px;background:var(--surface);box-shadow:0 0 0 1px var(--line);display:flex;align-items:center;gap:10px;padding:0 14px;font:400 17px var(--serif)}
.wgrid div span{font:400 13px var(--sans);color:var(--meta);width:18px;text-align:right}

/* settings-style lists: rows on the paper, section bands on the room */
.scrl{flex:1;min-height:0;overflow:hidden;position:relative}
.sech{padding:24px 20px 8px;font:600 13px/18px var(--sans);color:var(--meta)}
.sech.first{padding-top:8px}
.sgroup{background:var(--surface);border-top:1px solid var(--line);border-bottom:1px solid var(--line)}
.srow{display:flex;align-items:center;gap:12px;min-height:52px;padding:8px 8px 8px 20px;position:relative}
.srow+.srow:before{content:"";position:absolute;left:20px;right:0;top:0;height:1px;background:var(--line)}
.srow .mid{flex:1;min-width:0}
.srow .lab{font:400 17px/22px var(--sans);color:var(--ink)}
.srow .lab.act{color:var(--accent)}
.srow .lab.danger{color:var(--alarm)}
.srow .lab.voice{font:600 17px/22px var(--serif)}
.srow .sub{font:400 13px/18px var(--sans);color:var(--meta);margin-top:2px;padding:0}
.srow .val{font:400 15px/20px var(--sans);color:var(--meta);flex:none}
.srow .chv{width:28px;flex:none;text-align:center;color:var(--faint2);font:400 22px/1 var(--sans)}
.srow .ck{width:36px;flex:none;color:var(--accent);font:600 17px var(--sans);text-align:center}
.srow .gl{flex:none;width:24px;display:flex;justify-content:center;color:var(--accent)}
.srow.pad{padding-right:20px;flex-direction:column;align-items:stretch;gap:0}
.stext{padding:8px 20px 0;font:400 13px/18px var(--sans);color:var(--meta)}
.dial{display:flex;height:44px;border-radius:12px;background:var(--wash);padding:3px;margin:8px 0 2px}
.dial span{flex:1;display:flex;align-items:center;justify-content:center;border-radius:9px;font:500 15px var(--sans);color:var(--meta)}
.dial span.on{background:var(--surface);color:var(--ink);font-weight:600;box-shadow:0 1px 3px rgba(41,36,28,.15)}
.scrollbar2{position:absolute;right:3px;width:3px;border-radius:2px;background:rgba(41,36,28,.28)}
.dk .scrollbar2{background:rgba(232,227,216,.3)}

.alert{position:absolute;z-index:9;left:50%;top:50%;width:286px;margin-left:-143px;transform:translateY(-50%);border-radius:18px;background:var(--surface);box-shadow:0 12px 40px rgba(41,36,28,.3);overflow:hidden;text-align:center}
.alert .at{padding:20px 18px 6px;font:600 17px/22px var(--sans)}
.alert .am{padding:0 18px 18px;font:400 13px/18px var(--sans);color:var(--meta)}
.alert .ab{display:flex;border-top:1px solid var(--line)}
.alert .ab span{flex:1;height:48px;display:flex;align-items:center;justify-content:center;font:400 17px var(--sans);color:var(--accent)}
.alert .ab span+span{border-left:1px solid var(--line)}
.alert .ab span.b{font-weight:600}
.dim.d2{z-index:8}
.fid{position:absolute;z-index:10;left:50%;top:300px;width:156px;height:156px;margin-left:-78px;border-radius:30px;background:rgba(38,42,40,.86);color:#fff;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:10px;font:500 17px var(--sans)}

.lobby{flex:1;display:flex;flex-direction:column;padding:36px 28px 0;min-height:0}
.lobby .lk{align-self:center;width:64px;height:64px;border-radius:32px;background:var(--wash);display:flex;align-items:center;justify-content:center;color:var(--accent);flex:none}
.lobby h4{font:600 24px/30px var(--serif);text-align:center;margin:18px 0 8px}
.lobby .lead{font:400 15px/21px var(--sans);color:var(--meta);text-align:center;margin:0 0 22px}
.orl{display:flex;align-items:center;gap:12px;font:400 13px var(--sans);color:var(--meta);margin:6px 0 14px}
.orl:before,.orl:after{content:"";flex:1;height:1px;background:var(--takeline)}
.lobby.tight{padding-top:14px}
.lobby.tight .lk{width:48px;height:48px}
.lobby.tight h4{margin:10px 0 6px}
.lobby.tight .lead{margin-bottom:14px}

.note{flex:1;min-height:0;overflow:hidden;background:var(--surface);padding:6px 20px 0;border-top:1px solid var(--line);position:relative}
.note h4{font:600 24px/30px var(--serif);margin:10px 0 12px}
.note p{font:400 17px/27px var(--serif);margin:0 0 14px}
.kbar{flex:none;height:52px;display:flex;align-items:center;justify-content:space-between;padding:0 12px;background:var(--surface)}
.kbar span{width:44px;height:44px;border-radius:22px;display:inline-flex;align-items:center;justify-content:center;color:var(--accent);font:500 17px var(--sans);box-shadow:0 0 0 1px var(--line);background:var(--surface)}

/* the app switcher and the home screen (system surfaces, simplified) */
.phone.sys{background:linear-gradient(160deg,#5b6e68,#2b3a35 55%,#161d1b)}
.phone.sys .sb{color:#fff}
.phone.sys .sb .sig,.phone.sys .sb .wifi{background:#fff}
.phone.sys .sb .bat{border-color:#fff}.phone.sys .sb .bat:after{background:#fff}
.swlabel{position:absolute;left:61px;top:102px;display:flex;align-items:center;gap:9px;color:#fff;font:600 15px var(--sans);z-index:3}
.appicon{width:34px;height:34px;border-radius:9px;background:#C2DDD3;display:flex;align-items:center;justify-content:center;flex:none;box-shadow:0 1px 3px rgba(0,0,0,.25)}
.swcard{position:absolute;left:61px;top:146px;width:280px;height:609px;border-radius:36px;overflow:hidden;box-shadow:0 20px 50px rgba(0,0,0,.5);z-index:3;background:#E5F0EC}
.swcard .scr{transform:scale(.6965);transform-origin:0 0}
.swside{position:absolute;top:168px;width:260px;height:566px;border-radius:32px;z-index:2}
.swside.l{left:-218px;background:#f2f2f7}
.swside.r{right:-218px;background:#1f8f4d}
.scr{position:relative;width:402px;height:874px;background:var(--room);display:flex;flex-direction:column;overflow:hidden;font-family:var(--sans);color:var(--ink)}
.cover{flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:16px;font:600 24px var(--serif);color:var(--accent)}
.hgrid{position:absolute;inset:86px 28px auto 28px;display:grid;grid-template-columns:repeat(4,1fr);gap:26px 22px;filter:blur(5px);opacity:.75}
.hgrid i{display:block;height:64px;border-radius:15px;background:rgba(255,255,255,.35)}
.qa{position:absolute;left:28px;top:258px;z-index:4}
.qa .appicon{width:72px;height:72px;border-radius:17px;box-shadow:0 8px 24px rgba(0,0,0,.4)}
.qamenu{margin-top:12px;width:252px;border-radius:14px;background:rgba(250,250,250,.94);overflow:hidden;box-shadow:0 14px 40px rgba(0,0,0,.4);color:#111}
.qamenu div{height:46px;display:flex;align-items:center;justify-content:space-between;padding:0 16px;font:400 17px var(--sans);border-bottom:1px solid rgba(0,0,0,.1)}
.qamenu div.sep{border-bottom:8px solid rgba(0,0,0,.08)}
.qamenu div.red{color:#D7372F;border:0}
.qamenu div.ours{font-weight:600}

/* the popover menu (the shell's ⋯), with the sync row at its head */
.menu.r{left:auto;right:16px;top:112px;width:292px}
.menu .mi.s{font:400 17px var(--sans)}
.menu .srhead{padding:12px 16px 10px;border-bottom:1px solid var(--line);background:var(--taketint)}
.menu .srhead b{display:block;font:600 15px/20px var(--sans)}
.menu .srhead span{display:block;font:400 13px/18px var(--sans);color:var(--meta);margin-top:1px}
.menu .mi.lockrow{color:var(--accent);font:400 17px var(--sans);border-top:6px solid var(--taketint);border-bottom:0}

/* the timeline strip */
.tl{display:grid;grid-template-columns:150px 1fr;max-width:1180px;gap:10px 16px;align-items:center;margin:14px 0 6px;font-size:14px}
.tl .who{font-weight:600}
.tl .bar{display:flex;height:44px;border-radius:10px;overflow:hidden;box-shadow:0 0 0 1px #D8D4CA;font:500 13.5px/1.25 var(--sans)}
.tl .bar span{display:flex;align-items:center;padding:0 12px;border-right:1px solid rgba(0,0,0,.08)}
.tl .open{background:#DDEDE6;color:#22493B}
.tl .cov{background:#EFE9D8;color:#5B4A1C}
.tl .lock{background:#3B6A59;color:#fff}
.tl .ask{background:#fff;color:#29241C}

/* largest standard text size (xxxLarge): text grows, gutters and touch sizes stay */
.xl .wname{font-size:30px;line-height:36px}
.xl .mast{height:64px}
.xl .chip{font-size:20px;height:48px}.xl .chips{height:64px}
.xl .brow .t{font-size:23px;line-height:28px}.xl .brow .m{font-size:18px;line-height:23px}
.xl .brow{min-height:78px}
.xl .bcard .ln{font-size:20px;line-height:26px}
.xl .bcard .door{font-size:20px}
.xl .bcard .doors{gap:0 22px}
.xl .qebox{font-size:23px;min-height:60px}.xl .today{font-size:20px;height:60px}
.xl .tab{font-size:20px}.xl .tabs{height:60px}
.xl .shead .st{font-size:26px;line-height:32px}.xl .shead .done{font-size:23px}.xl .shead{height:64px}
.xl .sech{font-size:18px;line-height:23px}
.xl .srow .lab{font-size:23px;line-height:28px}.xl .srow .sub{font-size:18px;line-height:23px}
.xl .srow .val{font-size:20px;line-height:26px}
.xl .srow .val span{font-size:21px !important}
.xl .stext{font-size:18px;line-height:23px}
.xl .stat{font-size:17px;line-height:18px}
"""

# ---------- icons ----------
I_X = '✕'
I_KEY = '<svg width="20" height="22" viewBox="0 0 20 22" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><circle cx="10" cy="6.5" r="4.5"/><path d="M10 11v9M10 15.5h3.2M10 19h2.4"/></svg>'
I_LOCK = '<svg width="24" height="26" viewBox="0 0 24 26" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="4" y="11" width="16" height="12" rx="3"/><path d="M7.5 11V8a4.5 4.5 0 019 0v3"/></svg>'
I_LOCKS = I_LOCK.replace('width="24" height="26"', 'width="18" height="20"')
I_FACE = '<svg width="{0}" height="{0}" viewBox="0 0 40 40" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M4 12V8a4 4 0 014-4h4M28 4h4a4 4 0 014 4v4M36 28v4a4 4 0 01-4 4h-4M12 36H8a4 4 0 01-4-4v-4"/><path d="M14 15v3M26 15v3M20 15v7h-2M14 26c3.5 3 8.5 3 12 0"/></svg>'
I_OFF = '<svg class="offg" viewBox="0 0 14 14" fill="none" stroke="currentColor" stroke-width="1.4" stroke-linecap="round"><path d="M4 11h6.2a2.6 2.6 0 00.6-5.1A3.6 3.6 0 004 5.2 2.9 2.9 0 004 11zM2 2l10 10"/></svg>'
I_BACKS = I_BACK
def mark(size=34):
    return ('<svg width="%d" height="%d" viewBox="0 0 56 56" fill="#C2DDD3" stroke="#3B6A59" stroke-width="1.8" stroke-linejoin="round">'
            '<rect x="17" y="12" width="22" height="30" rx="4" transform="rotate(-18 28 46)"/>'
            '<rect x="17" y="12" width="22" height="30" rx="4" transform="rotate(18 28 46)"/>'
            '<rect x="17" y="10" width="22" height="30" rx="4"/></svg>') % (size, size)

# ---------- frame helpers ----------
def phone(*parts, cls=''):
    return '<div class="phone %s">' % cls + sb() + ''.join(parts) + '</div>'
def dotsrow(n=9, on=0, stat=''):
    d = ''.join('<i%s></i>' % (' class="on"' if i == on else '') for i in range(n)) if n > 1 else ''
    return '<div class="dotsrow"><div class="d">%s</div>%s</div>' % (d, stat)
def stat(text, kind='spin'):
    g = {'spin': '<i class="spin"></i>', 'off': I_OFF, 'ok': '<span style="color:var(--positive);font-weight:600">✓</span>', '': ''}[kind]
    return '<div class="stat">%s%s</div>' % (g, text)
def empty(text, door=''):
    d = '<div class="door">%s</div>' % door if door else ''
    return '<div class="list"><div class="empty">%s%s</div></div>' % (text, d)
def bcard(lines, doors, x=False, glyph='', title=''):
    """lines: list of (text, cls). doors: list of (label, quiet?)."""
    body = ('<div class="tt">%s</div>' % title if title else '') + ''.join(
        '<div class="ln %s%s">%s</div>' % (c, ' first' if i == 0 else '', t) for i, (t, c) in enumerate(lines))
    hd = '<div class="hd"><div class="gl">%s</div><div>%s</div></div>' % (glyph, body) if glyph else body
    ds = ''.join('<span class="door%s">%s</span>' % (' qt' if q else '', l) for l, q in doors)
    return '<div class="bcard%s">%s<div class="doors">%s</div>%s</div>' % (' x' if x else '', hd, ds, '<span class="xx">✕</span>' if x else '')
def band(*cards): return '<div class="band">%s</div>' % ''.join(cards)
def receipt(text, act=''):
    return '<div class="receipt"><span>%s</span>%s</div>' % (text, '<b>%s</b>' % act if act else '')
def sheet(title, body, done='Done', top=58, back='', quiet_done=False, flush=False, extra=''):
    l = ('<span class="bkb">%s</span>' % I_BACK if back else '') + '<span class="st">%s</span>' % title
    return ('<div class="dim"></div><div class="sheet" style="top:%dpx"><div class="grab"></div>'
            '<div class="shead%s"><div class="l">%s</div>%s</div><div class="sbody%s">%s</div>%s</div>') % (
        top, ' bk' if back else '', l, '<span class="done%s">%s</span>' % (' qt' if quiet_done else '', done) if done else '',
        ' flush' if flush else '', body, extra)
def P(t, c=''): return '<p class="p15 %s">%s</p>' % (c, t)
def P13(t): return '<p class="p13">%s</p>' % t
def fl(t): return '<div class="fl">%s</div>' % t
def fld(t, cls=''): return '<div class="fld %s">%s</div>' % (cls, t)
def btn(t, cls='pri'): return '<div class="btn %s">%s</div>' % (cls, t)
def refuse(t): return '<div class="refuse">%s</div>' % t
def radio(t, s, on=False): return '<div class="radio%s"><i></i><div><b>%s</b><span>%s</span></div></div>' % (' on' if on else '', t, s)
def sech(t, first=False): return '<div class="sech%s">%s</div>' % (' first' if first else '', t)
def sgroup(*rows): return '<div class="sgroup">%s</div>' % ''.join(rows)
def srow(lab, sub='', val='', chev=False, cls='', check=None, glyph=''):
    left = '<span class="gl">%s</span>' % glyph if glyph else ''
    s = '<div class="sub">%s</div>' % sub if sub else ''
    v = '<span class="val">%s</span>' % val if val else ''
    c = '<span class="chv">›</span>' if chev else ''
    k = '' if check is None else '<span class="ck">%s</span>' % ('✓' if check else '')
    pad = '' if (chev or k) else '<span style="width:12px"></span>'
    return '<div class="srow">%s<div class="mid"><div class="lab %s">%s</div>%s</div>%s%s%s%s</div>' % (left, cls, lab, s, v, c, k, pad)
def stext(t): return '<div class="stext">%s</div>' % t
def alert(title, msg, buttons):
    b = ''.join('<span class="%s">%s</span>' % ('b' if bold else '', l) for l, bold in buttons)
    return '<div class="dim d2"></div><div class="alert"><div class="at">%s</div>%s<div class="ab">%s</div></div>' % (
        title, '<div class="am">%s</div>' % msg if msg else '', b)
def faceid(top=300): return '<div class="fid" style="top:%dpx">%s<span>Face ID</span></div>' % (top, I_FACE.format(64))
def caret(): return '<span class="caret"></span>'
def opt(frame, oid, title, text, mine=False, q=False, small=''):
    cls = ' mine' if mine else (' alt' if q else '')
    sm = '<small>%s</small>' % small if small else ''
    return '<div class="opt">%s<div class="cap"><span class="id%s">%s</span><b>%s</b> %s%s</div></div>' % (frame, cls, oid, title, text, sm)
def row(*opts): return '<div class="row">' + ''.join(opts) + '</div>'
NEW = '<span class="new">PROPOSED WORDS</span>'

def page(fname, title, intro, body):
    doc = ('<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">'
           '<title>%s</title><style>%s%s</style></head><body><h1>%s</h1>%s%s</body></html>') % (esc(title), G1CSS, EXTRA, esc(title), intro, body)
    p = os.path.join(OUT, fname)
    with open(p, 'w') as f: f.write(doc)
    print(p, len(doc))

# ---------- the shell (the graders' picks: SW-1 (a) masthead, SW-3 (b) home, BK-1 (a) chips) — a thin layer ----------
def shell(listhtml, wing='Home', n=9, on=0, status='', chipset=None, chip_on=0, bandhtml='', rcpt='', tab=1, qe=True, qetext='New note…'):
    parts = [mast(wing), dotsrow(n, on, status)]
    if chipset: parts.append(chips(chipset, chip_on))
    parts.append(listhtml)
    if rcpt: parts.append(rcpt)
    if bandhtml: parts.append(bandhtml)
    if qe: parts.append(qe_rest(text=qetext))
    parts += [tabs_words(tab), hi()]
    return ''.join(parts)

WELCOME_CHIPS = ["★ Starred", "Unshelved", "Welcome", "All"]
WELCOME_ROWS = [brow("the pocket guide", "start here · lessons you can edit"), brow("the prince", "26 notes · two takes on every paragraph")]
NEWUSER_ROWS = [brow("journal", "3 entries · daily", STAR), brow("the pocket guide", "start here · lessons you can edit"),
                brow("the prince", "26 notes · two takes on every paragraph")]
EMAIL = 'writer@example.com'
