# StageAmbient — the stage ambient (VX-458)

A full-screen, pure black-and-white pixel scene for the Pro's built-in screen, shown while the stage
coordinator holds the stage and nobody is walking or testing. The coordinator turns it on and off. It is a
coordinator tool, **not part of the Variorum app**: its own Swift package, Apple frameworks only (AppKit,
Core Animation, Core Graphics, ImageIO), never in the app target or `VariorumCore`.

The first scene is a koi pond seen from overhead. More scenes plug into the same system (below).

## Driving it

```
Tools/ambient on [--scene NAME] [--stay]   # idempotent; returns once the window is verified up
Tools/ambient off                          # synchronous; exit 0 once gone (or if it wasn't running)
Tools/ambient status                       # RUNNING scene=… pid=… since=…  |  OFF   (always exit 0)
Tools/ambient next                         # dissolve to the next weighted pick now
Tools/ambient list                         # scenes and weights
Tools/ambient log                          # why it came and went (~/.variorum/ambient.log)
Tools/ambient build                        # (re)build the bundle
```

`on` builds the package if needed (`swift build -c release`), assembles a tiny agent bundle at
`Tools/StageAmbient/.build/StageAmbient.app` (`LSUIElement`, ad-hoc signed, bundle id
`io.lduarte.StageAmbient`), and launches it through LaunchServices so it outlives the calling shell.
`--stay` keeps the starting scene (no rotation); `--scene NAME` picks the first scene.

Files it writes, and only these: `~/.variorum/ambient.log` (one line per start, scene change, pause and exit,
with the reason — a claim's `who` and reason, the input, the signal) and `~/.variorum/ambient.state` (pid,
scene, since, window number; removed on exit). Never `stage.log`, which is `Tools/stage`'s own.

## The rails, and how each is held

1. **Never "Variorum".** The process and app are `StageAmbient`, so `pgrep -lx Variorum` and
   `pgrep -lf "MacOS/Variorum$"` never see it. The pre-GO check is `pgrep -x StageAmbient` (empty).
2. **Off whenever anyone else holds the stage.** The coordinator runs `Tools/ambient off` before every GO,
   and the app also polls `~/.variorum/stage.d/claim` four times a second and quits itself on any claim
   whose reason does not start with exactly `HOLD:` (so the coordinator's `GO pending:` bridge ends it, and
   so does a `HOLD FOR <walk>` hold). A lock directory without its claim file counts as a claim after
   0.5 s. `on` refuses with one line while such a claim exists. The values are read exactly as
   `Tools/stage` writes them (bash `printf %q`), pinned against the real tool in `StageClaimTests`.
3. **No screensaver machinery.** It is an ordinary app window (borderless, screen-saver level), so no
   password-on-wake can lock the screen.
4. **No faked activity.** It posts no events and takes no power or user-activity assertion. It detects
   input by *reading* the HID system's idle time, the same number the coordinator reads.
5. **Real input ends it.** The idle time is polled ten times a second; any mouse, trackpad or key input
   after a 0.75 s launch grace quits it. The window also swallows the waking click or keystroke, so it
   never lands in a hidden app.
6. **Light.** The scene is 576 × 373 pixels at the Pro's 3-point pixel scale, scaled up
   nearest-neighbour by one Core Animation layer. The frame cap is 12 fps, and the expensive part of the
   water is cached between frames. Drawing pauses while the display sleeps or the screen is locked.
   Measured CPU: see "Measured" below.
7. **The cursor.** It hides while the ambient is up and comes back on every exit it controls (input,
   claim, TERM/INT/HUP, losing focus). If the process dies outright, the window server restores it.
   Activation is handed back to the app that was frontmost when it started.
8. **Burn-in safe.** Everything in the scene moves: koi, water, ripples, and lilypads on a slow
   circulating current. The whole picture also orbits by up to 2.5 points. `nothingBrightStaysStill`
   samples the scene every 5 s for 20 minutes. Its worst pixel was lit in 35% of samples, before the
   orbit.

## The scene system

- `AmbientScene` (`Sources/AmbientKit/Scene.swift`) has setup (`init(size:seed:)`), `update(dt:)` and
  `draw(into: Canvas)`. A `Canvas` is an intensity field, 0 black to 1 white. The Director
  ordered-dithers it (Bayer 4×4) into the 1-bit frame, and exact 0 and 1 stay exact, so glyph scenes can
  draw hard pixels.
- `SceneRegistry.all` names the scenes. `ambient.json` weights them:
  `{ "fps", "pixelScale", "rotateMinutes", "dissolveSeconds", "scenes": [{ "name", "weight" }] }`.
  Missing keys keep their defaults, and unknown names are skipped.
- **Rotation:** every `rotateMinutes` (default 10) the Director dissolves, pixel by pixel over
  `dissolveSeconds`, to a weighted-random pick other than the current one. With one scene, it dissolves
  into a freshly seeded copy of it. `Tools/ambient next` (SIGUSR1) does the same at once.
- **To add a scene:** add one type conforming to `AmbientScene` under `Sources/AmbientKit/Scenes/<Name>/`,
  add one line to `SceneRegistry.all`, and add one entry with a weight to `ambient.json`.

## Scene 1: the koi pond

5 to 9 koi, each a 14-joint spine. The head drags the body, every link keeps its length, and no joint
bends past about 17°, so they bend instead of folding. A travelling wave adds the swim, and its tail beat
quickens with speed. The varieties are kohaku, sanke, showa, tancho, ogon, chagoi, asagi, shiro utsuri and
kigoi, with markings drawn as dither densities inside a crisp outline. Big rounded pectoral fins paddle
harder when a koi hovers, and the tail fins are translucent. Deeper koi are dimmer and narrower.
Behaviour comes from smooth-noise wander steering, separation from koi at a similar depth, and soft
avoidance of the edges and, when shallow, of lilypads. Each koi also runs a small mode machine: cruise,
drift, pause, rise to gulp at the surface (ripple rings), and a rare dart.

The water is a sparse, slowly wobbling caustic web plus a few surface glints. Lilypads have a notch,
veins and an irregular rim, and some carry a flower. They ride a slow current, turn, and get nudged by
koi brushing underneath. Every minute or two a leaf falls with a flutter and lands with a ripple. A
curious koi comes to nibble it, then it floats and finally sinks. Nothing loops.

## Dev aids (no window, no stage needed)

```
B=$(swift build -c release --package-path Tools/StageAmbient --show-bin-path)/StageAmbient
$B --render-gif out.gif --seconds 20 [--skip 30] [--seed N] [--size 576x373] [--gif-scale 2]
$B --frames dir/ --seconds 10 --every 12      # PNG snapshots
$B --bench --seconds 60                       # ms per frame and the implied CPU at the frame cap
$B --gallery koi.png                          # every koi variety, still
```

For an evidence window only: `--allow-claimant WHO` lets the named claimant's claim stand (nobody else's).
`--stage-dir DIR` watches a different lock. `Tools/ambient on --allow-claimant WHO` passes the first through.

Tests: `cd Tools/StageAmbient && swift test`. They are headless and include the real-`Tools/stage`
claim probes.

## Measured

(Filled in from the evidence window: CPU, quit latencies, cursor and focus.)
