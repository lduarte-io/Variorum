//
//  LifecycleProse.swift
//  VariorumCoreTests — VX-378 U3: THE PAGE'S PROSE, riding as data beside the
//  fixture (`LifecycleFixture.swift` carries each stage's words). The frame of
//  `notes/plans/vx-266/castle-lifecycle.html` — its head and styles, the lead,
//  the legend, the three facts on every row, the three-roads table, "What we
//  don't promise" and the footer — byte for byte as the target page had them,
//  except where a line below says it was changed and why. The renderer
//  (`LifecyclePage.swift`) owns only the facts.
//
//  Changed from the target page (prose only — rendering the fixture with the
//  target's own lead and footer and no review notes reproduces the target page
//  byte for byte, `cmp`-checked at U3 piece D): the lead's last sentence and
//  the footer now say the page is rendered from the fixture; one style line
//  for the "under review" note a FACTS DIFF puts on its stage. VX-307 U2b
//  (VX-412, rules 2–3 as amended): the three-roads table's twelve-words row
//  reads "shown once when you ask" (the words are never shown before the
//  first screen).
//

enum LifecycleProse {
    static let topBeforeLead = #"""
<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Castle lifecycle</title>
<style>
  :root { --bg:#faf8f3; --ink:#1d1b17; --muted:#6b665c; --rule:#d9d3c6; --card:#ffffff; --std:#e8f0fb; --cas:#f3e8fb; --warn:#fbeede; --ok:#e7f3e8; --acc:#4a5a8a; }
  @media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) { --bg:#000; --ink:#ece8df; --muted:#9a948a; --rule:#2a2823; --card:#121110; --std:#141c2a; --cas:#1e1428; --warn:#2a1e12; --ok:#12241a; --acc:#9fb0e6; } }
  :root[data-theme="dark"] { --bg:#000; --ink:#ece8df; --muted:#9a948a; --rule:#2a2823; --card:#121110; --std:#141c2a; --cas:#1e1428; --warn:#2a1e12; --ok:#12241a; --acc:#9fb0e6; }
  body { margin:0; padding:24px 16px 64px; background:var(--bg); color:var(--ink); font:16px/1.5 -apple-system, "SF Pro Text", Helvetica, Arial, sans-serif; max-width:980px; margin-inline:auto; }
  h1 { font-size:28px; margin:0 0 4px; } h2 { font-size:20px; margin:40px 0 8px; border-bottom:1px solid var(--rule); padding-bottom:4px; }
  p.lead { color:var(--muted); margin:0 0 20px; }
  .stage { background:var(--card); border:1px solid var(--rule); border-radius:10px; padding:14px 16px; margin:14px 0; }
  .stage.std { border-left:6px solid #7a94c9; } .stage.cas { border-left:6px solid #a77ac9; } .stage.any { border-left:6px solid #a09888; }
  .stage h3 { margin:0 0 6px; font-size:17px; } .stage h3 small { color:var(--muted); font-weight:normal; margin-left:8px; }
  dl { display:grid; grid-template-columns: 11em 1fr; gap:4px 12px; margin:8px 0 0; } dt { color:var(--muted); } dd { margin:0; }
  @media (max-width:600px) { dl { grid-template-columns:1fr; } dt { margin-top:6px; } }
  .roads span { display:inline-block; padding:1px 8px; border-radius:999px; font-size:14px; margin:2px 4px 2px 0; border:1px solid var(--rule); }
  .roads .s { background:var(--ok); } .roads .q { background:var(--std); } .roads .x { background:var(--warn); text-decoration:line-through; color:var(--muted); }
  .note { font-size:14px; color:var(--muted); margin-top:6px; }
  .note.diff { background:var(--warn); color:var(--ink); padding:6px 8px; border-radius:6px; }
  table { border-collapse:collapse; width:100%; margin:8px 0; font-size:15px; } th, td { text-align:left; padding:6px 8px; border-bottom:1px solid var(--rule); vertical-align:top; } th { color:var(--muted); font-weight:600; }
  .legend span { display:inline-block; margin-right:14px; font-size:14px; }
  .key { font-weight:600; color:var(--acc); }
  footer { margin-top:48px; color:var(--muted); font-size:14px; }
</style>
</head>
<body>
<h1>Castle lifecycle</h1>

"""#

    static let lead = #"One person, one library, the ordinary road — what is written at each stage, and every way the library and its backups can be opened, depending on the choices you make. The contract behind every line is <code>notes/CastleRules.md</code>; the rule numbers in brackets point at it. This page is rendered from the fixture the corrector phase's lifecycle test asserts against, stage by stage, so it can never drift; where the build does something other than a line says, that stage carries an <em>under review</em> note until the line is ruled."#

    static let topAfterLead = #"""


<div class="legend">
  <span class="roads"><span class="s">secret you know</span> passphrase or twelve words</span>
  <span class="roads"><span class="q">quiet road</span> opens without typing</span>
  <span class="roads"><span class="x">gone</span> a road that no longer opens anything</span>
</div>
<p class="note">Three facts hold on every row below. <b>One posture at a time:</b> Castle protects your library while it is in Castle — entering takes everything in, leaving hands everything out [11–13]. A <b>quiet road opens only a key it directly holds</b> — it never reaches through the key file's list of earlier keys; only typed secrets do that [4]. And the Apple road, being your iCloud Keychain, <b>also works on your other Macs</b> signed into the same Apple account [8].</p>

<h2>The three kinds of road</h2>
<table>
  <tr><th>Road</th><th>What it is</th><th>Standard</th><th>Castle</th></tr>
  <tr><td class="key">Twelve words</td><td>Made with the library, shown once when you ask, written down by you [2]</td><td>always</td><td>always</td></tr>
  <tr><td class="key">Passphrase</td><td>Asked at the tutorial's end; reminded until set [3]</td><td>when you set one</td><td>required to enter</td></tr>
  <tr><td class="key">Apple road</td><td>Your iCloud Keychain, through your Apple account — a convenience the app doesn't answer for [8, 25]</td><td>yes</td><td><b>never</b> [9]</td></tr>
  <tr><td class="key">On-device road</td><td>This Mac's login keychain: your login password or Touch ID [8]</td><td>yes</td><td>Touch ID only, if you choose it; "Always ask" = none</td></tr>
  <tr><td class="key">Sync</td><td>For a synced library, the account's shared keys — wrapped by passphrase and words only [14]; one pair of secrets per account [7]</td><td>yes</td><td>yes</td></tr>
</table>

<h2>The stages</h2>


"""#

    static let bottom = #"""
<h2>What we don't promise</h2>
<ul>
  <li>That Apple's roads keep working across Apple ID changes, sign-outs, keychain resets or a move to a new Mac. We promise you never need them [25].</li>
  <li>Anything about stores from before this design. Export or sign in to sync before the switch, then start fresh [26].</li>
  <li>That a device which hasn't followed into Castle can't read its own local copy. It can, through its own quiet road, until it follows [10].</li>
  <li>Recovery of a library whose every key-file copy and every backup are gone [27].</li>
</ul>


"""#

    static let footer = #"Written 2026-10-16 from the VX-305 simplification sitting as the target; rendered since VX-378 U3 from the lifecycle fixture (<code>Tests/VariorumCoreTests/Protection/Scenario/Lifecycle/</code>). Local file — not published anywhere."#

    static let end = #"""

</body>
</html>

"""#
}
