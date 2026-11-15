# VM-44 mockups — inside a note. Shared frame, CSS and components for
# note-write.html, takes-and-history.html, comments-and-callouts.html.
# Inherits design/sketches/sizing-sheet.html (THE BASE) and the two round-1 note sketches' CSS verbatim,
# then adds the few components those lack (listed in each file's build notes).
# Draft working record, not canon.
import os, re, html

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, '..')
SK = os.path.join(HERE, '..', '..', 'sketches')


def _style(name):
    s = open(os.path.join(SK, name)).read()
    return re.search(r'<style>(.*?)</style>', s, re.S).group(1)


_base = _style('sizing-sheet.html')
_seen = set(_base.split('\n'))
_extra = []
for _n in ('NT-5-history-and-commit.html', 'LK-4-LK-3-keyboard-bar.html'):
    for _l in _style(_n).split('\n'):
        if _l not in _seen:
            _seen.add(_l)
            _extra.append(_l)

MINE = r"""
/* ---- added for the note mockups (in the sizing sheet's spirit; listed in the build notes) ---- */
body{padding-bottom:120px}
.frames{flex-wrap:wrap;row-gap:36px;max-width:2130px}
h2{border-top:2px solid #24221E;padding-top:14px;max-width:2122px}
h2 small{font-weight:500;color:#5b574f;font-size:13px;margin-left:8px}
.cap .id.q{background:#8A4B12}
.cap .id.new{background:#3B6A59}
.cap i.w{font-style:normal;background:#EFE7D2;border-radius:4px;padding:0 4px}
.pagep .in{padding:16px 20px 0}
.blk{position:relative;margin:0 0 14px}
.blk p{margin:0}
.blk.seam{border-top:1.5px dotted var(--seam);padding-top:8px;margin-top:-6px}
.blk.empty{height:27px}
.mkf{position:absolute;right:-4px;bottom:1px;display:inline-flex;gap:10px;align-items:center}
.blk.under{padding-bottom:20px}
.blk.under .mkf{bottom:-3px}
.mk{margin-left:0}
.mk.cf{color:var(--alarm)}
.mkg{position:absolute;left:-19px;top:5px;width:18px;display:flex;flex-direction:column;gap:9px;align-items:center}
.mkg svg{width:16px;height:16px}
.mkr{position:absolute;right:-19px;top:4px;width:18px;display:flex;justify-content:center}
.mkr svg{width:17px;height:17px}
.callout{position:relative;margin:0 -18px 14px;padding:10px 18px;border-radius:12px;background:var(--sand)}
.callout .gl{position:absolute;left:1px;top:15px;width:17px;font:400 13px/1 var(--chrome);text-align:center;overflow:hidden}
.callout .gin{font:400 17px/1 var(--chrome);margin-right:8px}
.peek{margin:-6px -12px 8px;padding:6px 12px;border-radius:12px;background:var(--takeTint);box-shadow:inset 0 0 0 1px var(--takeLine)}
.sel{background:rgba(59,106,89,.22);border-radius:2px}
.dk .sel{background:rgba(144,193,175,.28)}
.hit44{outline:1.5px dashed #2F6B4F;outline-offset:0;border-radius:6px}
.fbar{position:absolute;left:0;right:0;z-index:4;display:flex;align-items:center;justify-content:space-between;padding:0 16px;gap:8px}
.rcpt{max-width:100%;white-space:nowrap}
.rcpt.ref{color:var(--ink);white-space:normal;flex:1;justify-content:space-between;height:auto;min-height:44px;padding:8px 6px 8px 16px;border-radius:18px;line-height:20px}
.rcpt .x{display:inline-flex;width:36px;height:44px;align-items:center;justify-content:center;color:var(--muted2);flex:none}
.rcpt .x svg{width:16px;height:16px}
.pill2{height:52px;border-radius:26px;background:var(--glass);box-shadow:0 0 0 1px var(--glassEdge),0 4px 16px rgba(0,0,0,.14);display:flex;align-items:center;padding:0 4px;flex:1;
  -webkit-backdrop-filter:blur(14px) saturate(1.5);backdrop-filter:blur(14px) saturate(1.5)}
.pill2 .lab{flex:1;text-align:center;font:500 15px/20px var(--chrome);color:var(--ink);white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.pill2 .choose{height:44px;padding:0 16px;border-radius:22px;background:var(--accent);color:var(--paper);font:600 15px/44px var(--chrome);flex:none;display:inline-flex;gap:6px;align-items:center}
.pill2 .choose.done{background:transparent;color:var(--positive)}
.pill2 .choose svg{width:18px;height:18px}
.sheet{color:var(--ink)}
.sheet .body{flex:1;overflow:hidden;display:flex;flex-direction:column}
.sheet .body>*{flex-shrink:0}
.band{background:var(--paper)}
.mrow{background:var(--paper)}
.mrow .lab{padding:0}
.mrow .det{font:400 13px/18px var(--chrome);color:var(--muted2)}
.mrow .val{font:400 15px/20px var(--chrome);color:var(--muted2);padding-right:12px;white-space:nowrap}
.mrow .chev{width:28px;display:flex;justify-content:center;color:var(--faint2);flex:none}
.mrow .chev svg{width:16px;height:16px}
.mrow.last:after{display:none}
.mrow.off .lab,.mrow.off .ic{color:var(--faint2)}
.sech{font:600 13px/18px var(--chrome);color:var(--muted2)}
.sech.tight{padding-top:16px}
.expl{font:400 13px/18px var(--chrome);color:var(--muted2);padding:0 20px 10px}
.tog{width:51px;height:31px;border-radius:16px;background:var(--faint2);opacity:.5;position:relative;flex:none;margin-right:12px}
.tog.on{background:var(--accent);opacity:1}
.tog:after{content:"";position:absolute;top:2px;left:2px;width:27px;height:27px;border-radius:14px;background:#fff;box-shadow:0 1px 3px rgba(0,0,0,.3)}
.tog.on:after{left:22px}
.tbtn{height:44px;min-width:44px;padding:0 12px;display:inline-flex;align-items:center;justify-content:center;font:400 17px/22px var(--chrome);color:var(--accent);flex:none;white-space:nowrap}
.tbtn.s{font-weight:600}
.tbtn.sm{font-size:15px;padding:0 10px}
.tbtn.al{color:var(--alarm)}
.brow2{display:flex;align-items:flex-start;min-height:64px;padding:10px 0 10px 20px;gap:10px;position:relative;background:var(--paper)}
.brow2:after{content:"";position:absolute;left:52px;right:0;bottom:0;height:1px;background:var(--line)}
.brow2 .n{width:22px;font:600 13px/20px var(--chrome);color:var(--muted2);font-variant-numeric:tabular-nums;flex:none;padding-top:1px}
.brow2 .mid{flex:1;min-width:0}
.brow2 .hd{font-weight:600;color:var(--ink)}
.brow2 .acc{display:flex;align-items:center;flex:none}
.brow2.lift{box-shadow:0 8px 24px rgba(0,0,0,.22);z-index:3;transform:translate(6px,-8px);border-radius:10px;margin-bottom:-44px}
.brow2.lift:after{display:none}
.dropline{height:3px;background:var(--accent);margin:-2px 12px -1px 52px;border-radius:2px;position:relative;z-index:2}
.pk{width:24px;height:24px;border-radius:12px;box-shadow:inset 0 0 0 1.5px var(--faint2);flex:none;margin:8px 2px 0 0;display:flex;align-items:center;justify-content:center;color:var(--paper)}
.pk.on{background:var(--accent);box-shadow:none}
.pk svg{width:14px;height:14px}
.bulk{display:flex;align-items:center;justify-content:space-around;height:56px;background:var(--room);border-top:1px solid var(--line);flex:none;padding:0 6px}
.srch{margin:0 16px 10px;height:40px;border-radius:12px;background:var(--paper);box-shadow:inset 0 0 0 1px var(--takeLine);display:flex;align-items:center;gap:8px;padding:0 12px;font:400 17px/22px var(--chrome);color:var(--faint2);flex:none}
.srch svg{width:18px;height:18px}
.alert{position:absolute;left:36px;right:36px;z-index:9;border-radius:22px;background:var(--glass);box-shadow:0 0 0 1px var(--glassEdge),0 18px 50px rgba(0,0,0,.3);
  -webkit-backdrop-filter:blur(20px) saturate(1.6);backdrop-filter:blur(20px) saturate(1.6);padding:20px 16px 12px;font-family:var(--chrome);color:var(--ink)}
.alert h4{margin:0 4px 6px;font:600 17px/22px var(--chrome)}
.alert p{margin:0 4px 14px;font:400 15px/20px var(--chrome);color:var(--ink)}
.alert .ab{height:48px;border-radius:14px;display:flex;align-items:center;justify-content:center;font:600 17px/22px var(--chrome);margin-top:8px;background:rgba(127,127,127,.14);color:var(--accent)}
.alert .ab.pri{background:var(--accent);color:var(--paper)}
.alert .ab.al{color:var(--alarm)}
.cal{margin:0 16px;background:var(--paper);border-radius:12px;box-shadow:inset 0 0 0 1px var(--takeLine);padding:12px 12px 8px}
.cal .mo{display:flex;align-items:center;justify-content:space-between;font:600 17px/22px var(--chrome);padding:0 4px 8px}
.cal .mo span{color:var(--accent);display:flex;gap:18px}
.cal .gr{display:grid;grid-template-columns:repeat(7,1fr);text-align:center}
.cal .gr b{font:600 13px/24px var(--chrome);color:var(--muted2)}
.cal .gr i{font:400 19px/44px var(--chrome);font-style:normal;height:44px}
.cal .gr i.on{background:var(--accent);color:var(--paper);border-radius:22px;font-weight:600;width:44px;margin:0 auto}
.cal .gr i.td{color:var(--accent);font-weight:600}
.cal .gr i.o{color:var(--faint2)}
.editm{position:absolute;z-index:8;height:44px;border-radius:22px;background:var(--glass);box-shadow:0 0 0 1px var(--glassEdge),0 8px 26px rgba(0,0,0,.22);display:flex;align-items:center;
  font:400 15px/44px var(--chrome);color:var(--ink);-webkit-backdrop-filter:blur(20px);backdrop-filter:blur(20px);white-space:nowrap}
.editm span{padding:0 12px;border-left:1px solid rgba(127,127,127,.22)}
.editm span:first-child{border:0}
.editm span.a{color:var(--accent);font-weight:500}
.tcard{background:var(--paper);border-radius:12px;box-shadow:inset 0 0 0 1px var(--takeLine);margin:0 16px 12px;overflow:hidden}
.tcard.chosen{box-shadow:inset 0 0 0 2px var(--positive)}
.tcard.peeking{background:var(--takeTint)}
.tcard.live{box-shadow:inset 0 0 0 2px var(--accent)}
.tcard.arch{background:transparent;box-shadow:inset 0 0 0 1px var(--takeLine)}
.tcard .hd{display:flex;align-items:center;height:44px;padding:0 0 0 14px;gap:8px;font:600 15px/20px var(--chrome)}
.tcard .hd .st{display:inline-flex;align-items:center;gap:5px}
.tcard .hd .st svg{width:18px;height:18px;color:var(--positive)}
.tcard .hd .lb{font-weight:400;color:var(--muted2);flex:1;min-width:0;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
.tcard .hd .lk{color:var(--muted2);display:inline-flex}.tcard .hd .lk svg{width:16px;height:16px}
.tcard .bd{padding:0 14px 10px;font:400 17px/25px var(--prose)}
.tcard.arch .bd{color:var(--muted2)}
.tcard .nt{margin:0 14px 10px;padding:8px 10px;border-radius:8px;background:var(--commentTint);font:400 13px/18px var(--chrome);color:var(--commentInk)}
.tcard .ft{display:flex;align-items:center;justify-content:space-between;height:44px;padding:0 2px 0 2px;border-top:1px solid var(--line)}
.sfoot{flex:none;display:flex;align-items:center;gap:8px;padding:10px 16px 30px;background:var(--room);border-top:1px solid var(--line)}
.sfoot .btn{flex:1;padding:0 10px;white-space:nowrap}
.wash-add{background:rgba(90,125,70,.20);border-radius:3px;padding:0 1px}
.wash-rem{text-decoration:line-through;color:var(--alarm);opacity:.8}
.dk .wash-add{background:rgba(147,181,126,.25)}
.gen{font:600 13px/18px var(--chrome);color:var(--muted2);padding:14px 20px 6px;display:flex;align-items:center;gap:8px}
.gen:after{content:"";flex:1;height:1px;background:var(--line)}
.lin{display:flex;align-items:center;min-height:64px;padding:8px 8px 8px 20px;gap:10px;position:relative;background:var(--paper)}
.lin:after{content:"";position:absolute;left:20px;right:0;bottom:0;height:1px;background:var(--line)}
.lin.me{box-shadow:inset 3px 0 0 var(--accent)}
.lin .mid{flex:1;min-width:0}
.lin .vb{font:600 13px/18px var(--chrome);color:var(--accent)}
.idband{background:var(--wash);padding:10px 20px;font:400 13px/18px var(--chrome);color:var(--ink)}
.ccard{margin:0 16px 10px;border-radius:12px;background:var(--commentTint);padding:10px 4px 6px 14px;position:relative}
.ccard .tx{font:400 17px/24px var(--prose);color:var(--ink);padding-right:44px}
.ccard .dt{font:400 13px/18px var(--chrome);color:var(--commentInk);margin-top:2px;height:26px}
.ccard .more{position:absolute;right:0;top:0}
.ccard.del{background:transparent;box-shadow:inset 0 0 0 1px var(--line);padding-bottom:0}
.ccard.del .tx{color:var(--muted2)}
.ccard.ed{box-shadow:inset 0 0 0 2px var(--accent)}
.draft{flex:none;display:flex;align-items:flex-end;gap:8px;padding:10px 12px 10px 16px;background:var(--room);border-top:1px solid var(--line)}
.draft .fld{flex:1;min-height:48px;border-radius:12px;background:var(--paper);box-shadow:inset 0 0 0 1px var(--takeLine);padding:12px 14px;font:400 17px/24px var(--prose);color:var(--ink)}
.draft .fld.ph{color:var(--faint2)}
.draft .add{height:48px;padding:0 16px;border-radius:12px;font:600 17px/48px var(--chrome);color:var(--faint2);flex:none}
.draft .add.go{background:var(--accent);color:var(--paper)}
.kept{font:400 13px/18px var(--chrome);color:var(--commentInk);padding:6px 20px 0;background:var(--room);display:flex;justify-content:space-between;align-items:center;flex:none}
.sw5{display:flex;justify-content:space-between;padding:4px 20px 6px}
.sw5 div{width:60px;text-align:center;font:400 13px/18px var(--chrome);color:var(--muted2)}
.sw5 i{display:flex;align-items:center;justify-content:center;width:56px;height:44px;border-radius:12px;margin:0 auto 6px;box-shadow:inset 0 0 0 1px var(--glassEdge);font:400 17px/1 var(--prose);font-style:normal;color:var(--ink)}
.sw5 div.on{color:var(--ink);font-weight:600}
.sw5 div.on i{box-shadow:inset 0 0 0 2.5px var(--accent)}
.glf{width:56px;height:48px;border-radius:12px;background:var(--paper);box-shadow:inset 0 0 0 1px var(--takeLine);display:flex;align-items:center;justify-content:center;font:400 24px/1 var(--chrome);flex:none}
.glf.foc{box-shadow:inset 0 0 0 2px var(--accent)}
.share{position:absolute;left:8px;right:8px;bottom:8px;z-index:8;border-radius:34px;background:var(--glass);box-shadow:0 0 0 1px var(--glassEdge),0 -6px 30px rgba(0,0,0,.2);padding:16px;
  -webkit-backdrop-filter:blur(20px);backdrop-filter:blur(20px);font-family:var(--chrome);color:var(--ink)}
.share .apps{display:flex;gap:18px;padding:16px 4px;border-top:1px solid rgba(127,127,127,.2);border-bottom:1px solid rgba(127,127,127,.2);margin:14px 0 6px}
.share .apps div{width:62px;text-align:center;font:400 12px/16px var(--chrome)}
.share .apps i{display:block;width:60px;height:60px;border-radius:14px;background:rgba(127,127,127,.22);margin-bottom:6px}
.share .sr{height:48px;display:flex;align-items:center;justify-content:space-between;font:400 17px/22px var(--chrome);padding:0 6px}
.ttl-field{box-shadow:inset 0 0 0 2px var(--accent);border-radius:10px;margin:-6px -10px;padding:6px 10px;background:var(--paper)}
.barsub{font:400 13px/16px var(--chrome);color:var(--muted2);font-weight:400}
.topbar .tt.two{font:600 15px/18px var(--prose);padding-top:1px}
.find{position:absolute;left:8px;right:8px;z-index:6;height:52px;border-radius:26px;background:var(--glass);box-shadow:0 0 0 1px var(--glassEdge),0 4px 16px rgba(0,0,0,.14);display:flex;align-items:center;padding:0 4px 0 6px;gap:2px;
  -webkit-backdrop-filter:blur(14px);backdrop-filter:blur(14px)}
.find .f{flex:1;height:38px;border-radius:19px;background:rgba(127,127,127,.14);display:flex;align-items:center;gap:6px;padding:0 12px;font:400 17px/22px var(--chrome)}
.find .f svg{width:16px;height:16px;color:var(--muted2)}
.find .f em{margin-left:auto;font-style:normal;color:var(--muted2);font-size:15px}
.hl{background:#F6E27A;border-radius:2px}.hl.cur{background:#F2B33D}
.dk .hl{background:#6E6220}.dk .hl.cur{background:#A8771B}
table.plain{max-width:2100px}
table.plain td{font-size:13px;line-height:1.45;max-width:420px}
table.plain td:first-child{font-weight:650;white-space:nowrap}
.spin{width:18px;height:18px;border-radius:9px;border:2px solid var(--line);border-top-color:var(--accent);display:inline-block;vertical-align:-3px;margin-right:8px}
/* largest standard text size (xxxLarge): her words scale on; chrome stops here */
.xxl .t-body{font-size:23px;line-height:35px}
.xxl .t-title{font-size:30px;line-height:36px}
.xxl .t-stitle{font-size:26px;line-height:31px}
.xxl .t-row{font-size:23px;line-height:28px}
.xxl .t-prev{font-size:21px;line-height:26px}
.xxl .t-meta,.xxl .sech,.xxl .expl,.xxl .mrow .det,.xxl .ccard .dt,.xxl .kept{font-size:19px;line-height:24px}
.xxl .t-ctl,.xxl .mrow .lab,.xxl .tbtn,.xxl .draft .add{font-size:23px;line-height:28px}
.xxl .chip,.xxl .tbtn.sm,.xxl .mrow .val,.xxl .tcard .hd,.xxl .btn{font-size:21px;line-height:26px}
.xxl .chip{height:40px;border-radius:20px}
.xxl .mrow{min-height:64px}
.xxl .tcard .bd,.xxl .ccard .tx,.xxl .draft .fld{font-size:23px;line-height:32px}
.xxl .tcard .hd,.xxl .tcard .ft{height:52px}
.xxl .mk{font-size:19px}
.xxl .draft .add{line-height:48px}
"""

CSS = _base + '\n' + '\n'.join(_extra) + MINE


def esc(s):
    return html.escape(s, quote=False)


def ic(d, sw=1.7, extra=''):
    paths = ''.join('<path d="%s"/>' % p for p in d.split('|') if p)
    return ('<svg viewBox="0 0 20 20" fill="none" stroke="currentColor" stroke-width="%s" stroke-linecap="round" '
            'stroke-linejoin="round" aria-hidden="true">%s%s</svg>' % (sw, paths, extra))


I_BACK = ic('M12.5 3.5 6 10l6.5 6.5', 2)
I_FIND = ic('m12.7 12.7 4.3 4.3', extra='<circle cx="8.6" cy="8.6" r="5.4"/>')
I_MORE = ic('', extra='<circle cx="4" cy="10" r="1.3" fill="currentColor" stroke="none"/><circle cx="10" cy="10" r="1.3" fill="currentColor" stroke="none"/><circle cx="16" cy="10" r="1.3" fill="currentColor" stroke="none"/>')
I_CHEV = ic('M7.5 4 13.5 10l-6 6')
I_FORK = ic('M6 3.5v3c0 3.2 4 2.8 4 6v4M14 3.5v3c0 3.2-4 2.8-4 6')
I_CMT = ic('M4 4.5h12a1.5 1.5 0 0 1 1.5 1.5v6.5A1.5 1.5 0 0 1 16 14h-5.5L7 17v-3H4a1.5 1.5 0 0 1-1.5-1.5V6A1.5 1.5 0 0 1 4 4.5Z')
I_BOOK = ic('M4 3.5h9.5a2.5 2.5 0 0 1 2.5 2.5v10.5H6.5A2.5 2.5 0 0 1 4 14V3.5Z|M4 14a2.5 2.5 0 0 1 2.5-2.5H16')
I_TAG = ic('M3 10V3.5h6.5l7.5 7.5-6.5 6.5L3 10Z', extra='<circle cx="6.8" cy="7.2" r="1" fill="currentColor" stroke="none"/>')
I_CAL = ic('M3.5 8h13|M7 2.5v3M13 2.5v3', extra='<rect x="3.5" y="4" width="13" height="12.5" rx="2"/>')
I_LIST = ic('M7 5h10M7 10h10M7 15h10', extra='<circle cx="3.5" cy="5" r="1" fill="currentColor" stroke="none"/><circle cx="3.5" cy="10" r="1" fill="currentColor" stroke="none"/><circle cx="3.5" cy="15" r="1" fill="currentColor" stroke="none"/>')
I_SEAL = ic('M6.5 9V6.5a3.5 3.5 0 0 1 7 0V9', extra='<rect x="4" y="9" width="12" height="8" rx="2"/>')
I_STAR = ic('M10 2.8l2.2 4.6 5 .7-3.6 3.5.9 5-4.5-2.4-4.5 2.4.9-5L2.8 8.1l5-.7L10 2.8Z')
I_UNDO = ic('M4 10a6 6 0 1 0 2-4.5M4 4v3.5h3.5')
I_REDO = ic('M16 10a6 6 0 1 1-2-4.5M16 4v3.5h-3.5')
I_COPY = ic('M13 7V5a1.5 1.5 0 0 0-1.5-1.5H5A1.5 1.5 0 0 0 3.5 5v6.5A1.5 1.5 0 0 0 5 13h2', extra='<rect x="7" y="7" width="9.5" height="9.5" rx="1.5"/>')
I_SHARE = ic('M10 12.5V3M6.5 6 10 2.5 13.5 6M4.5 10v6h11v-6')
I_ARCH = ic('M4.5 7.5V16h11V7.5M8 11h4', extra='<rect x="3" y="3.5" width="14" height="4" rx="1"/>')
I_TRASH = ic('M3.5 5.5h13M8 5.5V3.5h4v2M5.5 5.5l.8 11h7.4l.8-11')
I_WING = ic('M3.5 16.5V8l6.5-4 6.5 4v8.5M3.5 16.5h13M8 16.5V12h4v4.5')
I_PLUS = ic('M10 4v12M4 10h12')
I_CHECK = ic('m4 10.5 4 4 8-9', 2)
I_X = ic('m5 5 10 10M15 5 5 15')
I_GRIP = ic('M4 7h12M4 10h12M4 13h12')
I_UP = ic('M10 16V4M5 9l5-5 5 5')
I_DOWN = ic('M10 4v12M5 11l5 5 5-5')
I_HIST = ic('M4 10a6 6 0 1 0 2-4.5M4 4v3.5h3.5M10 7v3.5l2.2 1.3')
I_TREE = ic('M10 7v3M5 13v-1.5a1.5 1.5 0 0 1 1.5-1.5h7a1.5 1.5 0 0 1 1.5 1.5V13', extra='<circle cx="10" cy="5" r="2"/><circle cx="5" cy="15" r="2"/><circle cx="15" cy="15" r="2"/>')
I_NL = ic('M16 4v5.5a2.5 2.5 0 0 1-2.5 2.5H5M8 8.5 4.5 12 8 15.5')
I_NEWB = ic('M3 5h14M3 9h8M10 15h7M13.5 11.5v7')
I_LINK = ic('M8.5 11.5a3.2 3.2 0 0 0 4.5 0l2.6-2.6a3.2 3.2 0 0 0-4.5-4.5l-.9.9M11.5 8.5a3.2 3.2 0 0 0-4.5 0L4.4 11.1a3.2 3.2 0 0 0 4.5 4.5l.9-.9')
I_DUP = ic('M10 9.5v5M7.5 12h5', extra='<rect x="5.5" y="6.5" width="11" height="11" rx="2"/><path d="M3.5 13V4.5a1.5 1.5 0 0 1 1.5-1.5h8"/>')
I_VERS = ic('M3 10l7 3.5 7-3.5M3 13.5 10 17l7-3.5M10 3 3 6.5 10 10l7-3.5L10 3Z')
I_TRAY = ic('M3 11.5 5 4h10l2 7.5V16H3v-4.5ZM3 11.5h4.5l1 2h3l1-2H17')
I_PEN = ic('M4 16l.8-3.6L13.5 3.7l2.8 2.8L7.6 15.2 4 16Z')
I_COUNT = ic('M3 6h14M3 10h14M3 14h8')
I_DIV = ic('M3 6h14M3 14h14M7 10h1M10 10h1M13 10h1M4 10h1M16 10h0')
I_MERGE = ic('M4 4.5h12M4 15.5h12M10 7v6M7.5 9 10 6.5 12.5 9M7.5 11l2.5 2.5 2.5-2.5')
I_EXTRACT = ic('M3 5h14M3 9h7M13 9h4v8h-4zM3 13h7')
I_CALLOUT = ic('M6.5 8h7M6.5 11.5h4', extra='<rect x="3" y="4" width="14" height="12" rx="3"/>')
I_NAME = ic('M4 5.5h12M10 5.5v10M7.5 15.5h5')
I_COMMIT = ic('M3 10h3.5M13.5 10H17', extra='<circle cx="10" cy="10" r="3.5"/>')
I_EYE = ic('M2.5 10S5.5 4.5 10 4.5 17.5 10 17.5 10 14.5 15.5 10 15.5 2.5 10 2.5 10Z', extra='<circle cx="10" cy="10" r="2.2"/>')
I_BRANCH = ic('M6 3.5v13M6 9c0-3 8-2 8-5.5', extra='<circle cx="14" cy="3.5" r="0"/>')
I_BLANK = ic('', extra='<circle cx="10" cy="10" r="6"/>')
I_KBD = ic('M5.5 8h.01M8.5 8h.01M11.5 8h.01M14.5 8h.01M6.5 12h7', extra='<rect x="2.5" y="4.5" width="15" height="11" rx="2.5"/>')
I_OUT = ic('M3 5h14M9 10h8M3 15h14M6 8l-2.5 2L6 12')
I_IN = ic('M3 5h14M9 10h8M3 15h14M3.5 8l2.5 2-2.5 2')
I_BUL = ic('M8 6h9M8 14h9', extra='<circle cx="4" cy="6" r="1.2" fill="currentColor" stroke="none"/><circle cx="4" cy="14" r="1.2" fill="currentColor" stroke="none"/>')
I_CHK = ic('m6.8 10.2 2.2 2.3 4.2-4.8', extra='<rect x="3.5" y="3.5" width="13" height="13" rx="3"/>')
I_TOP = ic('M4 4h12M10 17V8M5.5 12 10 7.5l4.5 4.5')
I_END = ic('M4 16h12M10 3v9M5.5 8 10 12.5 14.5 8')


def mk(n, kind='takes', word=''):
    if kind == 'takes':
        return '<span class="mk" style="color:var(--accent)">%s%s%s</span>' % (I_FORK, n, (' · ' + word) if word else '')
    if kind == 'conflict':
        return '<span class="mk cf">%s%s · conflict</span>' % (I_FORK, n)
    return '<span class="mk" style="color:var(--commentInk)">%s%s</span>' % (I_CMT, n)


def blk(text, marks='', under=False, cls='', style=''):
    """A block on the page. marks = the foot cluster (pick NT-10 (c))."""
    m = '<span class="mkf">%s</span>' % marks if marks else ''
    return '<div class="blk %s%s" style="%s"><p>%s</p>%s</div>' % (cls, ' under' if (marks and under) else '', style, text, m)


CARET = '<span class="caret"></span>'

# the seeded note the round-1 sketches use: Essays ▸ "On keeping a commonplace book"
B1 = 'I started copying sentences into a notebook the winter I stopped trusting my memory for them.'
B1W = 'That winter I began copying other people’s sentences into a little notebook, and it felt like keeping company.'
B1S = 'I copy sentences into a notebook because my memory stopped keeping them.'
B2 = 'To Sherlock Holmes she is always <i>the</i> woman. I have seldom heard him mention her under any other name. In his eyes she eclipses and predominates the whole of her sex.'
B3 = ('It was not that he felt any emotion akin to love for Irene Adler. All emotions, and that one particularly, were abhorrent to his cold, '
      'precise but admirably balanced mind. He was, I take it, the most perfect reasoning and observing machine that the world has seen, '
      'but as a lover he would have placed himself in a false position.')
B4 = 'He never spoke of the softer passions, save with a gibe and a sneer. They were admirable things for the observer, excellent for drawing the veil from men’s motives and actions.'
TITLE = 'On keeping a commonplace book'


def sb():
    return '<div class="sb"><span>9:41</span><i></i></div>'


def ib(icon, cls=''):
    return '<span class="ib %s">%s</span>' % (cls, icon)


def topbar(title='', sub='', right=None, left=None):
    r = right if right is not None else ib(I_FIND) + ib(I_MORE)
    tt = '<span class="tt">%s</span>' % title
    if sub:
        tt = '<span class="tt two">%s<br><span class="barsub">%s</span></span>' % (title, sub)
    return '<div class="topbar">%s%s<span class="r">%s</span></div>' % (left if left is not None else ib(I_BACK), tt, r)


def chip(icon, text, empty=False, style=''):
    return '<span class="chip%s" style="%s">%s%s</span>' % (' empty' if empty else '', style, icon, text)


def chips(*c):
    return '<div class="chips">%s</div>' % ''.join(c)


STD_CHIPS = (chip(I_BOOK, 'Essays'), chip(I_TAG, 'essay, goals'), chip(I_CAL, 'Jul 25'), chip(I_LIST, '4 blocks'))


def mast(title=TITLE, cs=STD_CHIPS, extra=''):
    return '<div class="mast"><div class="t-title">%s</div>%s%s</div>' % (title, chips(*cs), extra)


def page(*parts, mast_html='', pad='16px'):
    inner = '<div class="in" style="padding-top:%s"><div class="t-body">%s</div></div>' % (pad, ''.join(parts))
    return '<div class="pagep">%s%s</div>' % (mast_html, inner)


def kbd(ret='return', emoji=False):
    rows = ['QWERTYUIOP', 'ASDFGHJKL']
    out = '<div class="sug"><span>Suppose</span><span>Think</span><span>Believe</span></div>'
    for r in rows:
        out += '<div class="kr">%s</div>' % ''.join('<div class="k">%s</div>' % c for c in r)
    out += '<div class="kr"><div class="k fn">⇧</div>%s<div class="k fn">⌫</div></div>' % ''.join('<div class="k">%s</div>' % c for c in 'ZXCVBNM')
    out += '<div class="kr"><div class="k fn w2">123</div><div class="k sp"></div><div class="k fn w2">%s</div></div>' % ret
    return '<div class="kb-abs"><div class="kbd">%s</div></div>' % out


def fade(bottom=327, h=96):
    return '<div class="fade" style="bottom:%dpx;height:%dpx"></div>' % (bottom, h)


def gc(inner, on=False):
    return '<span class="gc%s">%s</span>' % (' on' if on else '', inner)


AA = 'Aa'


def bar(cells=None, receipt='', bottom=333, on=None):
    """The keyboard bar, LK-4 pick: one glass capsule at the trailing edge; the freed space carries the receipt."""
    cells = cells if cells is not None else [AA, I_NL, I_FORK, I_MORE]
    cap = '<span class="gcap">%s</span>' % ''.join(gc(c, on == i) for i, c in enumerate(cells))
    return '<div class="fbar" style="bottom:%dpx">%s%s</div>' % (bottom, receipt or '<span></span>', cap)


def rcpt(text, act='Undo', ref=False, x=False):
    a = '<b>%s</b>' % act if act else ''
    xx = '<span class="x">%s</span>' % I_X if x else ''
    return '<span class="rcpt%s">%s%s%s</span>' % (' ref' if ref else '', text, a, xx)


def foot_rcpt(text, act='Undo', ref=False, x=False, bottom=26):
    return '<div class="fbar" style="bottom:%dpx;justify-content:flex-start">%s</div>' % (bottom, rcpt(text, act, ref, x))


def dimmer():
    return '<div class="dimmer"></div>'


def sheet(top, title, body, meta='', right='Done', left='', foot=''):
    r = '<span class="tbtn s">%s</span>' % right if right else ''
    l = left
    head = ('<div class="grab"></div><div class="shead"><div class="t-stitle">%s</div><span style="display:flex;align-items:center">%s%s</span></div>'
            % (title, l, r))
    m = '<div class="t-meta ell" style="padding:0 20px 12px;margin-top:-8px">%s</div>' % meta if meta else ''
    return '<div class="sheet" style="top:%dpx">%s%s<div class="body">%s</div>%s</div>' % (top, head, m, body, foot)


def sech(t, tight=False):
    return '<div class="sech%s">%s</div>' % (' tight' if tight else '', t)


def mrow(icon, label, det='', val='', chev=False, cls='', trail=''):
    d = '<div class="det">%s</div>' % det if det else ''
    v = '<span class="val">%s</span>' % val if val else ''
    c = '<span class="chev">%s</span>' % I_CHEV if chev else ''
    i = '<span class="ic">%s</span>' % icon if icon else ''
    return '<div class="mrow %s">%s<div class="mid"><div class="lab">%s</div>%s</div>%s%s%s</div>' % (cls, i, label, d, v, trail, c)


def tog(on=True):
    return '<span class="tog%s"></span>' % (' on' if on else '')


def menu(items, style):
    out = ''
    for it in items:
        if it is None:
            out += '<div class="sepr"></div>'
        else:
            label, icon = it[0], it[1]
            cls = it[2] if len(it) > 2 else ''
            out += '<div class="mi %s">%s%s</div>' % (cls, label, icon)
    return '<div class="sysmenu" style="%s">%s</div>' % (style, out)


def alert(top, title, msg, buttons):
    b = ''.join('<div class="ab %s">%s</div>' % (c, t) for t, c in buttons)
    return '<div class="alert" style="top:%dpx"><h4>%s</h4><p>%s</p>%s</div>' % (top, title, msg, b)


def phone(*parts, dark=False, over='', cls=''):
    return ('<div class="phone %s %s">%s<div class="screen">%s</div>%s<div class="home"></div></div>'
            % ('dk' if dark else 'lt', cls, sb(), ''.join(parts), over))


def frame(ph, fid, title, text, kind=''):
    """kind: '' plain step · 'pick' my pick · 'q' an open question's alternative · 'new' a state frame"""
    return '<div class="fcol">%s<div class="cap"><span class="id %s">%s</span><b>%s</b> %s</div></div>' % (ph, kind, fid, title, text)


def row(*frames):
    return '<div class="scroll"><div class="frames">%s</div></div>' % ''.join(frames)


def section(title, lede, *rows, small=''):
    s = '<h2>%s%s</h2>' % (title, '<small>%s</small>' % small if small else '')
    if lede:
        s += '<p class="lede">%s</p>' % lede
    return s + ''.join(rows)


def notes_table(rows):
    head = '<tr><th>Screen</th><th>Delivers (work-list rows)</th><th>Stands on</th><th>New</th><th>Do not get wrong</th><th>Size</th></tr>'
    body = ''.join('<tr>%s</tr>' % ''.join('<td>%s</td>' % c for c in r) for r in rows)
    return '<table class="plain">%s%s</table>' % (head, body)


TOKENS = ('<h2>Token values used</h2><p class="note">Study voice under the sea-glass palette, light, with one dark frame of each key screen; every size, ink, radius '
          'and component is <code>sketches/sizing-sheet.html</code>’s (type 13 · 15 · 17 · 20 · 24, 44 pt touch minimum, gutter 20, the corrected muted and faint inks). '
          'The bar and the masthead are the round-1 picks (<code>LK-4-LK-3-keyboard-bar.html</code>: one capsule, seven cells and a menu; '
          '<code>NT-5-history-and-commit.html</code>: the masthead that scrolls away, both history doors). She has not ruled on those picks; each is a thin layer here '
          '(the bar is one helper, the masthead one helper, the markers one helper) so a different pick is a re-skin. Glass is drawn as translucent white; menus and '
          'alerts are the system’s shapes with the app’s tokens; the keyboard is a simplified drawing at its measured 327 pt. Draft working record, not canon.</p>')


def write(fname, title, intro, body):
    doc = ('<!doctype html><html lang="en"><head><meta charset="utf-8"><title>%s</title><meta name="viewport" content="width=device-width,initial-scale=1">'
           '<style>%s</style></head><body><h1>%s</h1>%s%s%s</body></html>' % (esc(title), CSS, title, intro, body, TOKENS))
    p = os.path.abspath(os.path.join(OUT, fname))
    open(p, 'w').write(doc)
    print(p, len(doc))
